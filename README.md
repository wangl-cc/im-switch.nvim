# IM-Switch.nvim

A simple neovim plugin to automatically switch input method (only support macOS now).

## Features

- Automatically switch input method when entering/leaving insert mode.
- File patterns to enable IM switching only in specific files.
- Support different IM in different buffers.
- Async, no blocking.
- Manually toggle IM switching by `:IMSwitch` command.

## Installation

Use your favorite plugin manager, for example, with `lazy.nvim`:

```lua
{
  'wangl-cc/im-switch',
  dependencies = { "nvim-lua/plenary.nvim" },
  event = "BufWinEnter",
  opts = {},
}
```

If you only enable IM switching manually, you can lazy load it by cmd:

```lua
{
  'wangl-cc/im-switch',
  dependencies = { "nvim-lua/plenary.nvim" },
  cmd = "IMSwitch",
  opts = {
    filter = false,
  },
}
```

## Options

```lua
{
  normal_im = "com.apple.keylayout.ABC", -- IM to switch in normal mode
  -- Filter to decide which buffer to enable IM switching
  -- Set filter to false to don't enable IM switching automatically
  -- Set filter to true to enable IM switching in all buffers
  filter = {
    -- File patterns to enable IM switching
    pattern = { "*.md", "*.txt" },
    -- Buffer options to enable IM switching
    -- each option can be a value or a list of values
    bo = {
      readonly = false,
      buftype = "",
    },
  },
  -- Whether to create `IMSwitch` command
  command = true,
}
```

## Thanks

- [daipeihust/im-select](https://github.com/daipeihust/im-select):
    [MIT license](https://github.com/daipeihust/im-select/blob/9cd5278b185a9d6daa12ba35471ec2cc1a2e3012/LICENSE)
    the objective-c code is copied from it with some modifications.
