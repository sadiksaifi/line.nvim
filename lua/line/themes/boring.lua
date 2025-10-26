local M = {}

local bg = "#262626"
local fg = "#D3D3D3"
-- Boring theme - minimal, transparent with soft white text
M.colors = {
  statusline = { fg = fg, bg = bg },
  normal = { fg = fg, bg = bg },
  insert = { fg = fg, bg = bg },
  visual = { fg = fg, bg = bg },
  replace = { fg = fg, bg = bg },
  command = { fg = fg, bg = bg },
  select = { fg = fg, bg = bg },
  shell = { fg = fg, bg = bg },
  terminal = { fg = fg, bg = bg },
  file = { fg = fg, bg = bg },
  diagnostic_error = { fg = fg, bg = bg },
  diagnostic = { fg = fg, bg = bg },
  lsp = { fg = fg, bg = bg },
  git = { fg = fg, bg = bg },
  extension = { fg = fg, bg = bg },
  separator = { fg = fg, bg = bg },
}

return M
