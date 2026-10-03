# line.nvim

An opinionated, minimal, and performant Neovim statusline plugin written in pure Lua. This plugin provides a basic set of essential features without overwhelming configuration options.

![line.nvim](https://github.com/user-attachments/assets/b15ffd0d-3754-4842-b8d4-8aadda668c33)

## Features

- Mode, file path, diagnostics, LSP, and git branch in one line
- Fits any window width: hides low-priority components and shortens directories instead of cutting off the file name
- File name emphasized over its directory
- Readable labels for terminals, quickfix lists, help, and plugin windows such as file trees and pickers
- LSP client names per buffer, with a spinner, the loading server, and its percentage while it reports progress
- Error, warning, info, and hint counts per buffer
- Git branch read from `.git/HEAD`, with no blocking `git` process; supports worktrees and detached HEAD
- Modified and readonly flags, and the exit code of finished terminals
- Neovim 0.12 progress messages and the `'busy'` buffer status
- Dimmed statusline for inactive windows; works with `laststatus=3`
- 10 themes, including `auto`, which derives colors from your colorscheme
- `:checkhealth line`

## Requirements

- Neovim >= 0.12.0
- A [Nerd Font](https://www.nerdfonts.com) for the default icons

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

### Using vim.pack

Add this to your `init.lua`:

```lua
vim.pack.add({
  "https://github.com/sadiksaifi/line.nvim",
})

require("line").setup() -- or your custom options
```

## Configuration

The plugin works out of the box with sensible defaults. You can customize it by passing options to the `setup()` function. All options are typed for LSP completion. Calling `setup()` again replaces the previous configuration.

```lua
require("line").setup({
  -- Markers that identify the project root. File paths are shown relative to it.
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
    mode = true,         -- Current mode
    file_path = true,    -- File path with modified/readonly flags
    lsp = true,          -- LSP clients, spinner while loading
    diagnostics = true,  -- Diagnostic counts
    git = true,          -- Git branch
    extension = true,    -- File extension badge
    progress = true,     -- Progress messages and 'busy' status
    location = false,    -- Line, column, and scroll percentage
    recording = false,   -- Register of the macro being recorded
  },

  -- Icons
  icons = {
    error = "󰅚",
    warn = "󰋽",
    info = "󰋼",
    hint = "󰌶",
    git = " ",
    modified = "●",
    readonly = "",
    busy = "◐",
  },

  -- Available: "auto", "default", "rosepine", "catppuccin", "tokyonight",
  -- "gruvbox", "vscode", "dracula", "solarized", "boring"
  theme = "default",

  -- Override specific colors of the selected theme
  colors = {
    -- statusline       = { fg = "#cdd6f4", bg = "#1e1e2e" },
    -- normal           = { fg = "#1e1e2e", bg = "#89b4fa" },
    -- insert           = { fg = "#1e1e2e", bg = "#a6e3a1" },
    -- visual           = { fg = "#1e1e2e", bg = "#f9e2af" },
    -- replace          = { fg = "#1e1e2e", bg = "#f38ba8" },
    -- command          = { fg = "#1e1e2e", bg = "#cba6f7" },
    -- select           = { fg = "#1e1e2e", bg = "#74c7ec" },
    -- shell            = { fg = "#1e1e2e", bg = "#fab387" },
    -- terminal         = { fg = "#1e1e2e", bg = "#fab387" },
    -- file             = { fg = "#cdd6f4", bg = "#1e1e2e" },
    -- file_dir         = { fg = "#6c7086", bg = "#1e1e2e" },
    -- diagnostic_error = { fg = "#f38ba8", bg = "#1e1e2e" },
    -- diagnostic       = { fg = "#f9e2af", bg = "#1e1e2e" }, -- warnings
    -- diagnostic_info  = { fg = "#89dceb", bg = "#1e1e2e" },
    -- diagnostic_hint  = { fg = "#94e2d5", bg = "#1e1e2e" },
    -- lsp              = { fg = "#89b4fa", bg = "#1e1e2e" },
    -- git              = { fg = "#a6e3a1", bg = "#1e1e2e" },
    -- extension        = { fg = "#1e1e2e", bg = "#cba6f7" },
    -- separator        = { fg = "#6c7086", bg = "#1e1e2e" },
    -- inactive         = { fg = "#6c7086", bg = "#1e1e2e" },
  },
})
```

> **Tip:** Annotate your config to get completion in your own config files:
>
> ```lua
> ---@type LineConfig
> local config = {
>   theme = "rosepine",
>   colors = {
>     statusline = { fg = "#ffffff", bg = "#22223b" },
>   },
> }
> require("line").setup(config)
> ```

### Themes

- `auto`: colors taken from the active colorscheme, updated on every `:colorscheme`
- `default`: modern, elegant color palette
- `rosepine`: Rose Pine inspired colors
- `catppuccin`: Catppuccin inspired colors (`catpuccin` still works)
- `tokyonight`: Tokyo Night inspired colors
- `gruvbox`: Gruvbox inspired colors
- `vscode`: VS Code inspired colors
- `dracula`: Dracula inspired colors
- `solarized`: Solarized inspired colors
- `boring`: minimal, basic dark colors

Only the colors you set in `colors` override the theme. The rest keep the theme's values.

### Highlight groups

Each color key sets one highlight group: `LineStatusline`, `LineSeparator`, `LineModeNormal`, `LineModeInsert`, `LineModeVisual`, `LineModeReplace`, `LineModeCommand`, `LineModeSelect`, `LineModeShell`, `LineModeTerminal`, `LineFile`, `LineFileDir`, `LineLsp`, `LineDiagnosticError`, `LineDiagnostic`, `LineDiagnosticInfo`, `LineDiagnosticHint`, `LineGit`, `LineExtension`, and `LineInactive`.

## Components

### Left side

- Current mode
- File path relative to the project root, with modified and readonly flags

### Right side

- Macro recording (opt-in)
- Progress messages and `'busy'` status
- Diagnostic counts (errors, warnings, info, hints)
- LSP status: client names, or a spinner with the loading clients and their percentage
- Git branch
- Cursor location (opt-in)
- File extension badge

Inactive windows show only the file path.

### Narrow windows

When the line does not fit, line.nvim drops content in this order until it fits:

1. Cursor location
2. LSP clients
3. Directory names in the path shorten to one letter (`lua/line/init.lua` becomes `l/l/init.lua`)
4. Git branch
5. Progress
6. Extension badge
7. Diagnostics

The mode shows a short label (`N`, `I`, `V`) below 60 columns. Branch names and LSP client lists longer than 30 characters end with `…`.

### Special buffers

- Terminals show the running command and, after it exits, its exit code
- Quickfix and location lists show their title. line.nvim sets `g:qf_disable_statusline` so the quickfix ftplugin does not replace the statusline. Set it to `0` before `setup()` to keep the default.
- Plugin windows (`'buftype'` set, such as file trees and pickers) show their filetype in the badge
- URI buffers such as `oil:///path` show the scheme and a short path

## Development

- Format with [StyLua](https://github.com/JohnnyMorganz/StyLua): `stylua .`
- `.luarc.json` configures [lua-language-server](https://github.com/LuaLS/lua-language-server) with the Neovim runtime from `$VIMRUNTIME`. Start the language server from Neovim so `$VIMRUNTIME` is set.

## Contributing

Contributions are welcome! Please read our [Contributing Guidelines](CONTRIBUTING.md) before submitting any changes.

## License

[MIT License](./LICENSE)
