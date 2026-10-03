local M = {}

function M.check()
  local health = vim.health
  health.start("line.nvim")

  if vim.fn.has("nvim-0.12") == 1 then
    health.ok("Neovim " .. tostring(vim.version()))
  else
    health.error("Neovim 0.12 or later is required", "Upgrade Neovim")
    return
  end

  local line = require("line")
  if not line.is_configured() then
    health.warn("setup() has not been called", 'Call require("line").setup()')
    return
  end
  health.ok("setup() has been called")

  local options = require("line.config").options
  health.ok(string.format('Theme: "%s"', options.theme))

  if vim.go.statusline == line.STATUSLINE then
    health.ok("'statusline' is set by line.nvim")
  else
    health.warn(
      "'statusline' was changed after setup(): " .. vim.go.statusline,
      "Remove other code or plugins that set 'statusline'"
    )
  end

  if vim.o.laststatus == 0 then
    health.warn("'laststatus' is 0, so no statusline is shown", "Set 'laststatus' to 2 or 3")
  end

  if options.components.git then
    if vim.fn.executable("git") == 1 then
      health.ok("git executable found")
    else
      health.info("git executable not found. Branches are still read from .git/HEAD.")
    end
  end
end

return M
