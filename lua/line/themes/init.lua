local M = {}

-- Theme modules load on first use, so only the selected theme is required.
local names = {
  "auto",
  "default",
  "rosepine",
  "catppuccin",
  "tokyonight",
  "gruvbox",
  "vscode",
  "dracula",
  "solarized",
  "boring",
}

local aliases = {
  catpuccin = "catppuccin",
}

---Resolve a theme name, following aliases.
---@param theme_name string
---@return string?
local function resolve(theme_name)
  theme_name = aliases[theme_name] or theme_name
  if vim.list_contains(names, theme_name) then
    return theme_name
  end
end

---Get a theme by name. The "auto" theme is generated from the active colorscheme on every call.
---@param theme_name string
---@return LineTheme?
function M.get_theme(theme_name)
  local name = resolve(theme_name)
  if not name then
    return nil
  end
  if name == "auto" then
    return { colors = require("line.themes.auto").generate() }
  end
  return require("line.themes." .. name)
end

---Get all available theme names.
---@return string[]
function M.get_available_themes()
  return vim.list_slice(names)
end

return M
