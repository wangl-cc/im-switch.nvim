# IM-Switch.nvim

A simple neovim plugin to automatically switch input method (only support macOS now).

## Features

- Automatically switch input method when entering/leaving insert mode.
- File patterns to enable IM switching only in specific files.
- Support different IM in different buffers.
- Async, no blocking.

## Installation

Use your favorite plugin manager, for example, with `lazy.nvim`:

```lua
{
  'wangl-cc/im-switch',
  dependencies = { "nvim-lua/plenary.nvim" },
  event = 'VeryLazy',
  opts = {},
}
```

## Options

```lua
{
   normal_im = 'com.apple.keylayout.ABC', -- IM to switch in normal mode
   pattern = { "*.md", "*.txt" }, -- File patterns to enable IM switching
}
```

## Thanks

This plugin is inspired by:

- [daipeihust/im-select](https://github.com/daipeihust/im-select):
    [MIT license](https://github.com/daipeihust/im-select/blob/9cd5278b185a9d6daa12ba35471ec2cc1a2e3012/README.md),
    the objective-c code is copied from it with some modifications.
