---@meta
-- Type definitions for line.nvim. This file is never required at runtime.

---@alias LineThemeName
---| "auto" Derive colors from the active colorscheme
---| "default"
---| "rosepine"
---| "catppuccin"
---| "catpuccin" Deprecated spelling of "catppuccin"
---| "tokyonight"
---| "gruvbox"
---| "vscode"
---| "dracula"
---| "solarized"
---| "boring"

---@class LineHighlight
---@field fg? string Foreground color as "#rrggbb"
---@field bg? string Background color as "#rrggbb"

---@class LineColors
---@field statusline? LineHighlight
---@field normal? LineHighlight
---@field insert? LineHighlight
---@field visual? LineHighlight
---@field replace? LineHighlight
---@field command? LineHighlight
---@field select? LineHighlight
---@field shell? LineHighlight
---@field terminal? LineHighlight
---@field file? LineHighlight File name and cursor location
---@field file_dir? LineHighlight Directory part of the file path
---@field diagnostic_error? LineHighlight
---@field diagnostic? LineHighlight Warning diagnostics
---@field diagnostic_info? LineHighlight
---@field diagnostic_hint? LineHighlight
---@field lsp? LineHighlight
---@field git? LineHighlight
---@field extension? LineHighlight
---@field separator? LineHighlight
---@field inactive? LineHighlight Statusline of non-current windows

---@class LineTheme
---@field colors LineColors

---@class LineIcons
---@field error? string
---@field warn? string
---@field info? string
---@field hint? string
---@field git? string
---@field modified? string
---@field readonly? string
---@field busy? string Shown when the buffer's 'busy' option is set

---@class LineLspConfig
---@field ignored_clients? string[] LSP client names hidden from the statusline

---@class LineComponents
---@field mode? boolean Current mode
---@field file_path? boolean File path relative to the project root, with modified/readonly flags
---@field lsp? boolean Attached LSP clients, with a spinner while a client reports progress
---@field diagnostics? boolean Diagnostic counts per severity
---@field git? boolean Git branch of the buffer's repository
---@field extension? boolean File extension badge
---@field progress? boolean Neovim progress messages and the 'busy' buffer status
---@field location? boolean Cursor line, column, and scroll percentage
---@field recording? boolean Register of the macro being recorded

---@class LineConfig
---@field root_markers? string[] Markers that identify the project root for file paths
---@field lsp? LineLspConfig
---@field components? LineComponents
---@field icons? LineIcons
---@field theme? LineThemeName
---@field colors? LineColors Overrides applied on top of the theme

---Options after setup() merged the user config with the defaults.
---@class LineOptions : LineConfig
---@field root_markers string[]
---@field lsp LineLspConfig
---@field components LineComponents
---@field icons LineIcons
---@field theme LineThemeName
---@field colors LineColors
