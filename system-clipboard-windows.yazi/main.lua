-- system-clipboard plugin for yazi using PowerShell on Windows

--
-- === Sync Block Definitions ===
-- These MUST be at the top level of the file as per Yazi plugin documentation.
--

-- Creates a function that, when called, will synchronously get the
-- paths of the selected or hovered files.
local get_urls = ya.sync(function()
	local tab = cx.active
	if not tab then return {} end

	local paths = {}
	-- Handle selected files
	if tab.selected and #tab.selected > 0 then
		for _, u in pairs(tab.selected) do
			if u then paths[#paths + 1] = tostring(u) end
		end
	end

	-- Handle hovered file if no files are selected
	if #paths == 0 and tab.current and tab.current.hovered and tab.current.hovered.url then
		paths[1] = tostring(tab.current.hovered.url)
	end

	return paths
end)

-- Creates a function that, when called, will synchronously get the
-- path of the current working directory.
local get_dest_dir = ya.sync(function()
	if cx and cx.active and cx.active.current and cx.active.current.cwd then
		return tostring(cx.active.current.cwd)
	end
	return nil
end)


--
-- === Plugin Logic ===
--

-- Notifier for command results
local function notify_status(status, err, success_msg, failure_title)
	if status and status.success then
		ya.notify({ title = "System Clipboard", content = success_msg, level = "info", timeout = 5 })
		return true
	else
		local error_reason = "unknown error"
		if status then
			error_reason = "exit code " .. tostring(status.code)
		elseif err then
			error_reason = tostring(err)
		end
		ya.notify({
			title = failure_title,
			content = "Operation failed: " .. error_reason,
			level = "error",
			timeout = 5,
		})
		return false
	end
end

-- Copy files to clipboard (equivalent to Ctrl+C)
local function copy_files()
	-- Call the sync function defined at the top level
	local urls = get_urls()

	if #urls == 0 then
		ya.notify({ title = "System Clipboard", content = "No file selected to copy.", level = "warn", timeout = 5 })
		return
	end

	-- Build a PowerShell-compatible list of paths
	local quoted_urls = {}
	for _, url in ipairs(urls) do
		quoted_urls[#quoted_urls + 1] = string.format("'%s'", url)
	end
	local paths_str = table.concat(quoted_urls, ",")

	local ps_command = string.format("Set-Clipboard -Path %s", paths_str)
	local cmd = Command("powershell"):arg({ "-NoProfile", "-Command", ps_command })

	local status, err = cmd:spawn():wait()
	notify_status(
		status,
		err,
		"Copied " .. #urls .. " item(s) to clipboard.",
		"Clipboard Copy Failed"
	)
end

-- Paste files from clipboard (equivalent to Ctrl+V)
local function paste_files()
	-- Call the sync function defined at the top level
	local dest_dir = get_dest_dir()

	if not dest_dir then
		ya.notify({ title = "System Clipboard", content = "Could not determine current directory.", level = "error", timeout = 5 })
		return
	end

	-- PowerShell command to paste files.
	local ps_command = "try { $files = Get-Clipboard -Format FileDropList; if ($null -ne $files) { Copy-Item -Path $files.FullName -Destination . -Recurse -Force } else { Write-Host 'No files on clipboard'; exit 1 } } catch { Write-Error $_; exit 1 }"

	local cmd = Command("powershell"):arg({ "-NoProfile", "-Command", ps_command }):cwd(dest_dir)

	local status, err = cmd:spawn():wait()
	notify_status(status, err, "Pasted files from clipboard.", "Clipboard Paste Failed")
end

-- Export plugin functions
return {
	entry = function(_, job)
		local action = job.args[1]
		if not action then
			return
		end

		ya.emit("escape", { visual = true })

		if action == "paste" then
			paste_files()
		else
			copy_files()
		end
	end
}
