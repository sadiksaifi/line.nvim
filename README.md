# line.nvim

An opinionated, minimal, and performant Neovim statusline plugin written in pure Lua. This plugin provides a basic set of essential features without overwhelming configuration options.

![line.nvim](https://github.com/user-attachments/assets/b15ffd0d-3754-4842-b8d4-8aadda668c33)

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
    extension = true,    -- Show file extension badge
  },

  -- Icons
  icons = {
    error = "󰅚",   -- Error diagnostic icon
    warn  = "󰋽",   -- Warning diagnostic icon
    git   = " ",  -- Git branch icon
  },

  -- Theme selection
  theme = "default", -- Available: "default", "rosepine", "catpuccin", "tokyonight", "gruvbox", "vscode", "dracula", "solarized", "boring"

  -- Color overrides (optional - override specific colors from the selected theme)
  colors = {
    -- statusline = { fg = "#cdd6f4", bg = "#1e1e2e" },
    -- normal     = { fg = "#1e1e2e", bg = "#89b4fa" },
    -- insert     = { fg = "#1e1e2e", bg = "#a6e3a1" },
    -- visual     = { fg = "#1e1e2e", bg = "#f9e2af" },
    -- replace    = { fg = "#1e1e2e", bg = "#f38ba8" },
    -- command    = { fg = "#1e1e2e", bg = "#cba6f7" },
    -- select     = { fg = "#1e1e2e", bg = "#74c7ec" },
    -- shell      = { fg = "#1e1e2e", bg = "#fab387" },
    -- terminal   = { fg = "#1e1e2e", bg = "#fab387" },
    -- file       = { fg = "#cdd6f4", bg = "#1e1e2e" },
    -- diagnostic_error = { fg = "#f38ba8", bg = "#1e1e2e" },
    -- diagnostic      = { fg = "#f9e2af", bg = "#1e1e2e" },
    -- lsp        = { fg = "#89b4fa", bg = "#1e1e2e" },
    -- git        = { fg = "#a6e3a1", bg = "#1e1e2e" },
    -- extension  = { fg = "#1e1e2e", bg = "#cba6f7" },
    -- separator  = { fg = "#6c7086", bg = "#1e1e2e" },
  },
})
```

> **Tip:** Theme System: Choose from 9 built-in themes (`"default"`, `"rosepine"`, `"catpuccin"`, `"tokyonight"`, `"gruvbox"`, `"vscode"`, `"dracula"`, `"solarized"`, `"boring"`) or override specific colors from any theme. The plugin provides carefully crafted color palettes that work well with popular Neovim colorschemes.
>
> ```lua
> ---@type require('line.types').LineConfig
> local config = {
>   theme = "rosepine", -- Use Rose Pine theme
>   colors = {
>     statusline = { fg = "#ffffff", bg = "#22223b" }, -- Override just the statusline colors
>   },
> }
> require("line").setup(config)
> ```
>
> **Theme System:**
>
> - `theme = "default"` - Modern, elegant color palette (default)
> - `theme = "rosepine"` - Rose Pine inspired colors
> - `theme = "catpuccin"` - Catppuccin inspired colors
> - `theme = "tokyonight"` - Tokyo Night inspired colors
> - `theme = "gruvbox"` - Gruvbox inspired colors
> - `theme = "vscode"` - VS Code inspired colors
> - `theme = "dracula"` - Dracula inspired colors
> - `theme = "solarized"` - Solarized inspired colors
> - `theme = "boring"` - Minimal, basic dark colors for clean simplicity
>
> **Color Overrides:**
>
> You can override any color from the selected theme by providing a `colors` table. Only the colors you specify will be overridden, while the rest will use the theme's default colors.

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
