local M = {}

---@type LineOptions
M.defaults = {
  root_markers = {
    ".git",
    ".vscode",
    ".editorconfig",
    "package.json",
    "deno.json",
    "pyproject.toml",
    "Cargo.toml",
    "go.mod",
    "composer.json",
    "Gemfile",
  },
  lsp = {
    ignored_clients = {
      "null-ls",
      "eslint",
    },
  },
  components = {
    mode = true,
    file_path = true,
    lsp = true,
    diagnostics = true,
    git = true,
    extension = true,
    progress = true,
    location = false,
    recording = false,
  },
  icons = {
    error = "󰅚",
    warn = "󰋽",
    info = "󰋼",
    hint = "󰌶",
    git = " ",
    modified = "●",
    readonly = "",
    busy = "◐",
  },
  theme = "default",
  colors = {},
}

---@type LineOptions
M.options = vim.deepcopy(M.defaults)

---Validate the user config and merge it with the defaults.
---@param user LineConfig?
---@return LineOptions
function M.setup(user)
  user = user or {}
  vim.validate("config", user, "table")
  vim.validate("config.root_markers", user.root_markers, "table", true)
  vim.validate("config.lsp", user.lsp, "table", true)
  vim.validate("config.components", user.components, "table", true)
  vim.validate("config.icons", user.icons, "table", true)
  vim.validate("config.theme", user.theme, "string", true)
  vim.validate("config.colors", user.colors, "table", true)

  -- List options replace the default list instead of merging by index.
  M.options = vim.tbl_deep_extend("force", M.defaults, user, {
    root_markers = user.root_markers or M.defaults.root_markers,
    lsp = {
      ignored_clients = (user.lsp or {}).ignored_clients or M.defaults.lsp.ignored_clients,
    },
  })
  return M.options
end

return M
