local M = {}

M.default = {
  statusline = { fg = "#c0caf5", bg = "#303038" },
  normal = { fg = "#24283b", bg = "#a2d2fb" },
  insert = { fg = "#24283b", bg = "#9ece6a" },
  visual = { fg = "#24283b", bg = "#bb9af7" },
  replace = { fg = "#24283b", bg = "#f7768e" },
  command = { fg = "#24283b", bg = "#e0af68" },
  select = { fg = "#24283b", bg = "#7dcfff" },
  shell = { fg = "#24283b", bg = "#7aa2f7" },
  terminal = { fg = "#24283b", bg = "#7aa2f7" },
  file = { fg = "#c0caf5", bg = "#303038" },
  diagnostic_error = { fg = "#f7768e", bg = "#303038" },
  diagnostic = { fg = "#e0af68", bg = "#303038" },
  lsp = { fg = "#a2d2fb", bg = "#303038" },
  git = { fg = "#a2d2fb", bg = "#303038" },
  extension = { fg = "#24283b", bg = "#a2d2fb" },
  separator = { fg = "#c0caf5", bg = "#303038" },
}

function M.merge(user)
  local result = vim.deepcopy(M.default)
  if user then
    for k, v in pairs(user) do
      result[k] = vim.tbl_extend("force", result[k] or {}, v)
    end
  end
  return result
end

return M
