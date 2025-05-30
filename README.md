# line.nvim

A minimal, performant, and beautiful Neovim statusline plugin written in pure Lua.

## Features

- Minimal and fast statusline implementation
- Built-in LSP status with loading animation
- Diagnostic counts with icons
- Git branch information
- Smart project root detection
- Modern, cohesive color scheme
- Highly configurable, but simple by default

## Requirements

- Neovim >= 0.11.0

## Installation (with lazy.nvim)

Add this to your `lua/plugins/line.lua` (or wherever you keep your lazy.nvim specs):

```lua
return {
  "sadiksaifi/line.nvim",
  opts = {}, -- or your custom options below
}
```

> **Note:** With lazy.nvim, the `opts` table is automatically passed to the plugin's `setup()` function. You do not need to call `setup()` manually.

## Configuration

You can override any option by passing it in the `opts` table. Here are all available options with their **default values** and explanations:

```lua
return {
  "sadiksaifi/line.nvim",
  opts = {
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

    -- Icons (can be overridden)
    icons = {
      error = "󰅚",   -- Error diagnostic icon
      warn  = "󰋽",   -- Warning diagnostic icon
      git   = " ",  -- Git branch icon
    },

    -- Colors (all can be overridden; these are the defaults)
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
  },
}
```

### Option Explanations

- **root_markers**: List of files/directories to detect the project root. (Default: see above)
- **lsp.ignored_clients**: LSP client names to ignore in the statusline. (Default: `null-ls`, `eslint`)
- **components**: Enable/disable each statusline section. (All enabled by default)
- **icons**: Unicode icons for error, warning, and git branch. (See above for defaults)
- **colors**: All highlight groups can be overridden. (See above for defaults)

## Example: Customizing Colors and Icons

```lua
return {
  "sadiksaifi/line.nvim",
  opts = {
    colors = {
      statusline = { fg = "#ffffff", bg = "#22223b" },
      extension  = { fg = "#22223b", bg = "#f7768e" },
      separator  = { fg = "#f7768e", bg = "#22223b" },
    },
    icons = {
      git = "",
    },
  },
}
```

## Components

### Left Side

- Current mode (using built-in Neovim mode names)
- File path relative to project root

### Right Side

- LSP status (spinner while loading, client names when ready)
- Diagnostic counts with icons (errors/warnings)
- Git branch information

## Performance

The plugin is designed to be performant with minimal flickering:

- Only updates on actual changes
- Uses efficient event handling
- Avoids unnecessary redraws
- Caches project root detection
- Efficient LSP state tracking

## Types

All options are fully typed for LSP/autocomplete support.
You can import the types from `require('line.types')` in your config for better editor hints.

### Example

```lua
---@type require('line.types').LineConfig
local config = {
  -- your config here
}
```

## Contributing

Before making any contributions to this project, please read our [Contributing Guidelines](CONTRIBUTING.md). The guidelines cover:

- Code style and formatting
- Commit message conventions
- Pull request process
- Development setup
- Testing requirements
- Documentation standards

We welcome all contributions, whether they're bug fixes, new features, or documentation improvements. Please make sure to:

1. Fork the repository
2. Create a new branch for your changes
3. Follow the coding standards in `.editorconfig`
4. Update documentation if needed
5. Submit a pull request

## License

[MIT License](./LICENSE)
