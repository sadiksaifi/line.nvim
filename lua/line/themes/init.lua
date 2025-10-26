local M = {}

-- Theme registry
local themes = {
  default = require("line.themes.default"),
  rosepine = require("line.themes.rosepine"),
  catpuccin = require("line.themes.catpuccin"),
  tokyonight = require("line.themes.tokyonight"),
  gruvbox = require("line.themes.gruvbox"),
  vscode = require("line.themes.vscode"),
  dracula = require("line.themes.dracula"),
  solarized = require("line.themes.solarized"),
  boring = require("line.themes.boring"),
}

---Get theme colors by name
---@param theme_name string
---@return table|nil
function M.get_theme(theme_name)
  return themes[theme_name]
end

---Get all available theme names
---@return string[]
function M.get_available_themes()
  local theme_names = {}
  for name, _ in pairs(themes) do
    table.insert(theme_names, name)
  end
  return theme_names
end

return M
