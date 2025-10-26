local M = {}

-- VS Code theme - inspired by VS Code dark theme
M.colors = {
  statusline = { fg = "#cccccc", bg = "#1e1e1e" },
  normal = { fg = "#1e1e1e", bg = "#007acc" },
  insert = { fg = "#1e1e1e", bg = "#4ec9b0" },
  visual = { fg = "#1e1e1e", bg = "#dcdcaa" },
  replace = { fg = "#1e1e1e", bg = "#f44747" },
  command = { fg = "#1e1e1e", bg = "#c586c0" },
  select = { fg = "#1e1e1e", bg = "#4fc1ff" },
  shell = { fg = "#1e1e1e", bg = "#ce9178" },
  terminal = { fg = "#1e1e1e", bg = "#ce9178" },
  file = { fg = "#cccccc", bg = "#1e1e1e" },
  diagnostic_error = { fg = "#f44747", bg = "#1e1e1e" },
  diagnostic = { fg = "#dcdcaa", bg = "#1e1e1e" },
  lsp = { fg = "#007acc", bg = "#1e1e1e" },
  git = { fg = "#4ec9b0", bg = "#1e1e1e" },
  extension = { fg = "#1e1e1e", bg = "#c586c0" },
  separator = { fg = "#808080", bg = "#1e1e1e" },
}

return M
