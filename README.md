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

  -- Colors (three modes: "inherit", "default", or custom table)
  colors = "inherit", -- or "default" or table with any of these options:
  -- colors = {
  --   statusline = { fg = "#cdd6f4", bg = "#1e1e2e" },
  --   normal     = { fg = "#1e1e2e", bg = "#89b4fa" },
  --   insert     = { fg = "#1e1e2e", bg = "#a6e3a1" },
  --   visual     = { fg = "#1e1e2e", bg = "#f9e2af" },
  --   replace    = { fg = "#1e1e2e", bg = "#f38ba8" },
  --   command    = { fg = "#1e1e2e", bg = "#cba6f7" },
  --   select     = { fg = "#1e1e2e", bg = "#74c7ec" },
  --   shell      = { fg = "#1e1e2e", bg = "#fab387" },
  --   terminal   = { fg = "#1e1e2e", bg = "#fab387" },
  --   file       = { fg = "#cdd6f4", bg = "#1e1e2e" },
  --   diagnostic_error = { fg = "#f38ba8", bg = "#1e1e2e" },
  --   diagnostic      = { fg = "#f9e2af", bg = "#1e1e2e" },
  --   lsp        = { fg = "#89b4fa", bg = "#1e1e2e" },
  --   git        = { fg = "#a6e3a1", bg = "#1e1e2e" },
  --   extension  = { fg = "#1e1e2e", bg = "#cba6f7" },
  --   separator  = { fg = "#6c7086", bg = "#1e1e2e" },
  -- },
})
```

> **Tip:** Color modes: `"inherit"` (default) uses your colorscheme with proper highlight group inheritance, `"default"` uses fallback colors, or provide a table to override specific colors. The plugin follows standard Neovim highlight group patterns used by lualine.nvim and mini.statusline.
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
>
> **Color Modes:**
>
> - `colors = "inherit"` - Uses colors from your current colorscheme with proper fallback chain (default)
> - `colors = "default"` - Uses built-in fallback colors that work with most themes
> - `colors = { statusline = {...} }` - Override specific colors while inheriting others
>
> **Color Inheritance:**
>
> The plugin uses standard Neovim highlight groups (`User1-User9`, `StatusLine`, `DiagnosticError`, etc.) and follows a proper fallback hierarchy to ensure compatibility with all colorschemes.

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
