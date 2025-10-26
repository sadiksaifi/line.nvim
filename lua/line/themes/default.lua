local M = {}

-- Default theme - modern, elegant color palette
M.colors = {
  statusline = { fg = "#cdd6f4", bg = "#1e1e2e" },
  normal = { fg = "#1e1e2e", bg = "#89b4fa" },
  insert = { fg = "#1e1e2e", bg = "#a6e3a1" },
  visual = { fg = "#1e1e2e", bg = "#f9e2af" },
  replace = { fg = "#1e1e2e", bg = "#f38ba8" },
  command = { fg = "#1e1e2e", bg = "#cba6f7" },
  select = { fg = "#1e1e2e", bg = "#74c7ec" },
  shell = { fg = "#1e1e2e", bg = "#fab387" },
  terminal = { fg = "#1e1e2e", bg = "#fab387" },
  file = { fg = "#cdd6f4", bg = "#1e1e2e" },
  diagnostic_error = { fg = "#f38ba8", bg = "#1e1e2e" },
  diagnostic = { fg = "#f9e2af", bg = "#1e1e2e" },
  lsp = { fg = "#89b4fa", bg = "#1e1e2e" },
  git = { fg = "#a6e3a1", bg = "#1e1e2e" },
  extension = { fg = "#1e1e2e", bg = "#cba6f7" },
  separator = { fg = "#6c7086", bg = "#1e1e2e" },
}

return M
