local M = {}

---Read one color attribute of a highlight group as "#rrggbb", resolving links and 'reverse'.
---@param group string
---@param attr "fg"|"bg"
---@return string?
local function color(group, attr)
  local hl = vim.api.nvim_get_hl(0, { name = group, link = false, create = false })
  if hl.reverse then
    attr = attr == "fg" and "bg" or "fg"
  end
  local value = hl[attr]
  return value and string.format("#%06x", value) or nil
end

---Return the foreground of the first highlight group that defines one.
---@param groups string[]
---@param fallback string
---@return string
local function first_fg(groups, fallback)
  for _, group in ipairs(groups) do
    local fg = color(group, "fg")
    if fg then
      return fg
    end
  end
  return fallback
end

---Generate theme colors from the active colorscheme. Groups the colorscheme does not define fall
---back to the default theme.
---@return LineColors
function M.generate()
  local base = require("line.themes.default").colors

  local bg = color("StatusLine", "bg") or color("Normal", "bg") or base.statusline.bg --[[@as string]]
  local fg = color("StatusLine", "fg") or color("Normal", "fg") or base.statusline.fg --[[@as string]]

  ---@param accent string
  ---@return LineHighlight
  local function badge(accent)
    return { fg = bg, bg = accent }
  end

  ---@param accent string
  ---@return LineHighlight
  local function text(accent)
    return { fg = accent, bg = bg }
  end

  local normal = first_fg({ "Function", "Directory" }, base.normal.bg)
  local insert = first_fg({ "String", "Added" }, base.insert.bg)
  local visual = first_fg({ "Constant", "Number" }, base.visual.bg)
  local replace = first_fg({ "DiagnosticError", "ErrorMsg" }, base.replace.bg)
  local command = first_fg({ "Statement", "Keyword" }, base.command.bg)
  local select = first_fg({ "Type", "Identifier" }, base.select.bg)
  local shell = first_fg({ "Special", "PreProc" }, base.shell.bg)

  return {
    statusline = { fg = fg, bg = bg },
    normal = badge(normal),
    insert = badge(insert),
    visual = badge(visual),
    replace = badge(replace),
    command = badge(command),
    select = badge(select),
    shell = badge(shell),
    terminal = badge(shell),
    file = text(fg),
    diagnostic_error = text(first_fg({ "DiagnosticError" }, base.diagnostic_error.fg)),
    diagnostic = text(first_fg({ "DiagnosticWarn" }, base.diagnostic.fg)),
    diagnostic_info = text(first_fg({ "DiagnosticInfo" }, base.diagnostic_info.fg)),
    diagnostic_hint = text(first_fg({ "DiagnosticHint" }, base.diagnostic_hint.fg)),
    lsp = text(normal),
    git = text(insert),
    extension = badge(command),
    separator = text(first_fg({ "Comment", "NonText" }, base.separator.fg)),
  }
end

return M
