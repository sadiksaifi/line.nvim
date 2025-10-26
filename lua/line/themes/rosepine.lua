local M = {}

-- Rose Pine theme - inspired by rose-pine colorscheme
M.colors = {
  statusline = { fg = "#e0def4", bg = "#26233a" },
  normal = { fg = "#26233a", bg = "#9ccfd8" },
  insert = { fg = "#26233a", bg = "#c4a7e7" },
  visual = { fg = "#26233a", bg = "#f6c177" },
  replace = { fg = "#26233a", bg = "#eb6f92" },
  command = { fg = "#26233a", bg = "#9ccfd8" },
  select = { fg = "#26233a", bg = "#c4a7e7" },
  shell = { fg = "#26233a", bg = "#f6c177" },
  terminal = { fg = "#26233a", bg = "#f6c177" },
  file = { fg = "#e0def4", bg = "#26233a" },
  diagnostic_error = { fg = "#eb6f92", bg = "#26233a" },
  diagnostic = { fg = "#f6c177", bg = "#26233a" },
  lsp = { fg = "#9ccfd8", bg = "#26233a" },
  git = { fg = "#c4a7e7", bg = "#26233a" },
  extension = { fg = "#26233a", bg = "#9ccfd8" },
  separator = { fg = "#6e6a86", bg = "#26233a" },
}

return M
