local M = {}

-- Catppuccin theme - inspired by catppuccin colorscheme
M.colors = {
  statusline = { fg = "#cdd6f4", bg = "#11111b" },
  normal = { fg = "#11111b", bg = "#89b4fa" },
  insert = { fg = "#11111b", bg = "#a6e3a1" },
  visual = { fg = "#11111b", bg = "#f9e2af" },
  replace = { fg = "#11111b", bg = "#f38ba8" },
  command = { fg = "#11111b", bg = "#cba6f7" },
  select = { fg = "#11111b", bg = "#74c7ec" },
  shell = { fg = "#11111b", bg = "#fab387" },
  terminal = { fg = "#11111b", bg = "#fab387" },
  file = { fg = "#cdd6f4", bg = "#11111b" },
  diagnostic_error = { fg = "#f38ba8", bg = "#11111b" },
  diagnostic = { fg = "#f9e2af", bg = "#11111b" },
  lsp = { fg = "#89b4fa", bg = "#11111b" },
  git = { fg = "#a6e3a1", bg = "#11111b" },
  extension = { fg = "#11111b", bg = "#cba6f7" },
  separator = { fg = "#6c7086", bg = "#11111b" },
}

return M
