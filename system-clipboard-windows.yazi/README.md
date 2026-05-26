# system-clipboard-windows.yazi


## Config

> [!NOTE]
> You need yazi 3.x and windows for this plugin to work.

> [!Important]
> This plugin wraps around the magnificent ["ClipBoard" project](https://github.com/Slackadays/ClipBoard).
> You need to have it installed on your system. (Make sure that It's on your $PATH)

## Configuration

Copy or install this plugin and add the following keymap to your `manager.prepend_keymap`:

```toml
[[mgr.prepend_keymap]]
on = [ "<C-y>" ]
run = "plugin system-clipboard 'copy'"
desc = "Copy hovered path to system clipboard"

[[mgr.prepend_keymap]]
on = [ "<C-p>" ]
run = "plugin system-clipboard 'paste'"
desc = "Paste path from system clipboard"
```

> [!Tip]
> If you want to use this plugin with yazi's default yanking behaviour you should use `cx.yanked` instead of `tab.selected` in `init.lua` (See [#1487](https://github.com/sxyazi/yazi/issues/1487))
