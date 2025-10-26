local M = {}

local themes = require("line.themes")

---Set up standard User highlight groups for statusline components
---This follows the pattern used by lualine.nvim and other statusline plugins
---@param colors table Theme colors to use for highlight groups
function M.setup_user_highlights(colors)
  -- User1-User9 are standard Neovim highlight groups for statusline
  -- We use the theme colors instead of hardcoded values
  
  -- User1: Normal mode
  vim.api.nvim_set_hl(0, "User1", {
    fg = colors.normal.fg,
    bg = colors.normal.bg,
    bold = true,
  })
  
  -- User2: Insert mode
  vim.api.nvim_set_hl(0, "User2", {
    fg = colors.insert.fg,
    bg = colors.insert.bg,
    bold = true,
  })
  
  -- User3: Visual mode
  vim.api.nvim_set_hl(0, "User3", {
    fg = colors.visual.fg,
    bg = colors.visual.bg,
    bold = true,
  })
  
  -- User4: Replace mode
  vim.api.nvim_set_hl(0, "User4", {
    fg = colors.replace.fg,
    bg = colors.replace.bg,
    bold = true,
  })
  
  -- User5: Command mode
  vim.api.nvim_set_hl(0, "User5", {
    fg = colors.command.fg,
    bg = colors.command.bg,
    bold = true,
  })
  
  -- User6: Select mode
  vim.api.nvim_set_hl(0, "User6", {
    fg = colors.select.fg,
    bg = colors.select.bg,
    bold = true,
  })
  
  -- User7: Shell mode
  vim.api.nvim_set_hl(0, "User7", {
    fg = colors.shell.fg,
    bg = colors.shell.bg,
    bold = true,
  })
  
  -- User8: Terminal mode (same as shell)
  vim.api.nvim_set_hl(0, "User8", {
    fg = colors.terminal.fg,
    bg = colors.terminal.bg,
    bold = true,
  })
  
  -- User9: Reserved for future use
  vim.api.nvim_set_hl(0, "User9", {
    fg = colors.separator.fg,
    bg = colors.statusline.bg,
  })
end

---Merge theme colors with user overrides
---@param theme_name string|nil Theme name to use
---@param user_colors table|nil User color overrides
---@return table Merged color configuration
function M.merge(theme_name, user_colors)
  local result
  
  -- Get base colors from theme
  if theme_name and themes.get_theme(theme_name) then
    result = vim.deepcopy(themes.get_theme(theme_name).colors)
  else
    -- Default to default theme
    result = vim.deepcopy(themes.get_theme("default").colors)
  end
  
  -- Apply user color overrides if provided
  if user_colors and type(user_colors) == "table" then
    for k, v in pairs(user_colors) do
      if result[k] and type(v) == "table" then
        result[k] = vim.tbl_extend("force", result[k], v)
      end
    end
  end
  
  return result
end

return M
