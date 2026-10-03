local M = {}

local themes = require("line.themes")

-- Highlight group for each color key.
local groups = {
  statusline = "LineStatusline",
  separator = "LineSeparator",
  normal = "LineModeNormal",
  insert = "LineModeInsert",
  visual = "LineModeVisual",
  replace = "LineModeReplace",
  command = "LineModeCommand",
  select = "LineModeSelect",
  shell = "LineModeShell",
  terminal = "LineModeTerminal",
  file = "LineFile",
  file_dir = "LineFileDir",
  lsp = "LineLsp",
  diagnostic_error = "LineDiagnosticError",
  diagnostic = "LineDiagnostic",
  diagnostic_info = "LineDiagnosticInfo",
  diagnostic_hint = "LineDiagnosticHint",
  git = "LineGit",
  extension = "LineExtension",
  inactive = "LineInactive",
}

---Merge theme colors with user overrides. Unknown theme names fall back to "default".
---@param theme_name string?
---@param user_colors LineColors?
---@return LineColors
function M.merge(theme_name, user_colors)
  local theme = theme_name and themes.get_theme(theme_name) or themes.get_theme("default")
  ---@cast theme -nil
  local result = vim.deepcopy(theme.colors)

  for key, value in pairs(user_colors or {}) do
    if groups[key] and type(value) == "table" then
      result[key] = vim.tbl_extend("force", result[key] or {}, value)
    end
  end

  -- Keys that custom or older themes may omit.
  result.diagnostic_info = result.diagnostic_info or result.lsp
  result.diagnostic_hint = result.diagnostic_hint or result.git
  result.inactive = result.inactive or { fg = result.separator.fg, bg = result.statusline.bg }
  result.file_dir = result.file_dir or { fg = result.separator.fg, bg = result.file.bg }

  return result
end

---Define the Line* highlight groups from merged colors.
---@param colors LineColors
function M.apply(colors)
  for key, group in pairs(groups) do
    local c = colors[key]
    if c then
      vim.api.nvim_set_hl(
        0,
        group,
        { fg = c.fg, bg = c.bg, bold = key ~= "inactive" and key ~= "file_dir" }
      )
    end
  end
end

return M
