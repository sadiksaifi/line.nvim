# line.nvim

An opinionated, minimal, and performant Neovim statusline plugin written in pure Lua. This plugin provides a basic set of essential features without overwhelming configuration options.

![line.nvim](https://github.com/user-attachments/assets/8062e940-88a1-4566-b8f6-315855c625e9)

## Features

- Minimal and fast statusline implementation
- Built-in LSP status with loading animation
- Diagnostic counts with icons
- Git branch information

## Requirements

- Neovim >= 0.11.0

## Installation

### Using lazy.nvim

Add this to your `lua/plugins/line.lua`:

```lua
return {
  "sadiksaifi/line.nvim",
  opts = {}, -- or your custom options below
}
```

> **Note:** With lazy.nvim, the `opts` table is automatically passed to the plugin's `setup()` function.

### Using vim.pack (Neovim 0.12+)

Add this to your `init.lua`:

```lua
vim.pack.add({
  "sadiksaifi/line.nvim"
})

require("line").setup() -- or your custom options
```

## Configuration

The plugin works out of the box with sensible defaults. You can customize it by passing options to the `setup()` function. All options are fully typed for LSP/autocomplete support.

```lua
require("line").setup({
  -- Project root detection
  root_markers = {
    ".git", ".vscode", ".editorconfig", "package.json", "deno.json",
    "pyproject.toml", "Cargo.toml", "go.mod", "composer.json", "Gemfile",
  },

  -- LSP configuration
  lsp = {
    ignored_clients = { "null-ls", "eslint" },
  },

  -- Statusline components (enable/disable)
  components = {
    mode = true,         -- Show current mode
    file_path = true,    -- Show file path
    lsp = true,          -- Show LSP status
    diagnostics = true,  -- Show diagnostics
    git = true,          -- Show git branch
  },

  -- Icons
  icons = {
    error = "󰅚",   -- Error diagnostic icon
    warn  = "󰋽",   -- Warning diagnostic icon
    git   = " ",  -- Git branch icon
  },

  -- Colors (all can be overridden)
  colors = {
    statusline = { fg = "#c0caf5", bg = "#303038" },
    normal     = { fg = "#24283b", bg = "#a2d2fb" },
    insert     = { fg = "#24283b", bg = "#9ece6a" },
    visual     = { fg = "#24283b", bg = "#bb9af7" },
    replace    = { fg = "#24283b", bg = "#f7768e" },
    command    = { fg = "#24283b", bg = "#e0af68" },
    select     = { fg = "#24283b", bg = "#7dcfff" },
    shell      = { fg = "#24283b", bg = "#7aa2f7" },
    terminal   = { fg = "#24283b", bg = "#7aa2f7" },
    file       = { fg = "#c0caf5", bg = "#303038" },
    diagnostic_error = { fg = "#f7768e", bg = "#303038" },
    diagnostic      = { fg = "#e0af68", bg = "#303038" },
    lsp        = { fg = "#a2d2fb", bg = "#303038" },
    git        = { fg = "#a2d2fb", bg = "#303038" },
    extension  = { fg = "#24283b", bg = "#a2d2fb" },
    separator  = { fg = "#c0caf5", bg = "#303038" },
  },
})
```

> **Tip:** For better editor hints, you can use the types:
>
> ```lua
> ---@type require('line.types').LineConfig
> local config = {
>   colors = {
>     statusline = { fg = "#ffffff", bg = "#22223b" },
>   },
> }
> require("line").setup(config)
> ```

## Components

### Left Side

- Current mode (using built-in Neovim mode names)
- File path relative to project root

### Right Side

- LSP status (spinner while loading, client names when ready)
- Diagnostic counts with icons (errors/warnings)
- Git branch information

## Contributing

Contributions are welcome! Please read our [Contributing Guidelines](CONTRIBUTING.md) before submitting any changes.

## License

[MIT License](./LICENSE)
