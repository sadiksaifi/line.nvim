local M = {}

-- Gruvbox theme - inspired by gruvbox colorscheme
M.colors = {
  statusline = { fg = "#ebdbb2", bg = "#3c3836" },
  normal = { fg = "#3c3836", bg = "#83a598" },
  insert = { fg = "#3c3836", bg = "#b8bb26" },
  visual = { fg = "#3c3836", bg = "#fe8019" },
  replace = { fg = "#3c3836", bg = "#fb4934" },
  command = { fg = "#3c3836", bg = "#d3869b" },
  select = { fg = "#3c3836", bg = "#8ec07c" },
  shell = { fg = "#3c3836", bg = "#fabd2f" },
  terminal = { fg = "#3c3836", bg = "#fabd2f" },
  file = { fg = "#ebdbb2", bg = "#3c3836" },
  diagnostic_error = { fg = "#fb4934", bg = "#3c3836" },
  diagnostic = { fg = "#fe8019", bg = "#3c3836" },
  lsp = { fg = "#83a598", bg = "#3c3836" },
  git = { fg = "#b8bb26", bg = "#3c3836" },
  extension = { fg = "#3c3836", bg = "#d3869b" },
  separator = { fg = "#928374", bg = "#3c3836" },
}

return M
