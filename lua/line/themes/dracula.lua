local M = {}

-- Dracula theme - inspired by dracula colorscheme
M.colors = {
  statusline = { fg = "#f8f8f2", bg = "#282a36" },
  normal = { fg = "#282a36", bg = "#8be9fd" },
  insert = { fg = "#282a36", bg = "#50fa7b" },
  visual = { fg = "#282a36", bg = "#ffb86c" },
  replace = { fg = "#282a36", bg = "#ff5555" },
  command = { fg = "#282a36", bg = "#bd93f9" },
  select = { fg = "#282a36", bg = "#8be9fd" },
  shell = { fg = "#282a36", bg = "#ffb86c" },
  terminal = { fg = "#282a36", bg = "#ffb86c" },
  file = { fg = "#f8f8f2", bg = "#282a36" },
  diagnostic_error = { fg = "#ff5555", bg = "#282a36" },
  diagnostic = { fg = "#ffb86c", bg = "#282a36" },
  lsp = { fg = "#8be9fd", bg = "#282a36" },
  git = { fg = "#50fa7b", bg = "#282a36" },
  extension = { fg = "#282a36", bg = "#bd93f9" },
  separator = { fg = "#6272a4", bg = "#282a36" },
}

return M
