-- https://github.com/sxyazi/yazi/pull/3684 自定义终端的标题

return {
	entry = function(_, job)
    ps.sub("ind-app-title", function(args)
      -- starting Yazi with --chooser-file means it's running as a file picker
      if rt.args.chooser_file then
        args.value = "File picker: " .. tostring(cx.active.current.cwd)
      else
        -- args.value = 'Yazi: ' .. tostring(cx.active.current.cwd)
        args.value = 'Yazi: ' .. tostring(cx.active.name)
      end
      return args
    end)
	end,
}



