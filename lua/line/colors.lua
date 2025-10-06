local M = {}

-- Fallback colors when colorscheme colors are not available
-- Modern, elegant color palette inspired by popular themes like Catppuccin, Gruvbox, and Tokyo Night
M.fallback = {
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

-- Get color from highlight group, with fallback
local function get_hl_color(hl_group, attr)
  local ok, hl = pcall(vim.api.nvim_get_hl, 0, { name = hl_group })
  if ok and hl[attr] then
    return string.format("#%06x", hl[attr])
  end
  return nil
end

-- Check if two colors have good contrast
local function has_good_contrast(fg, bg)
  if not fg or not bg then return false end
  
  -- Convert hex to RGB
  local function hex_to_rgb(hex)
    local r = tonumber(hex:sub(2, 3), 16)
    local g = tonumber(hex:sub(4, 5), 16)
    local b = tonumber(hex:sub(6, 7), 16)
    return r, g, b
  end
  
  local fg_r, fg_g, fg_b = hex_to_rgb(fg)
  local bg_r, bg_g, bg_b = hex_to_rgb(bg)
  
  -- Calculate relative luminance
  local function luminance(r, g, b)
    r, g, b = r / 255, g / 255, b / 255
    r = r <= 0.03928 and r / 12.92 or ((r + 0.055) / 1.055) ^ 2.4
    g = g <= 0.03928 and g / 12.92 or ((g + 0.055) / 1.055) ^ 2.4
    b = b <= 0.03928 and b / 12.92 or ((b + 0.055) / 1.055) ^ 2.4
    return 0.2126 * r + 0.7152 * g + 0.0722 * b
  end
  
  local fg_lum = luminance(fg_r, fg_g, fg_b)
  local bg_lum = luminance(bg_r, bg_g, bg_b)
  
  -- Calculate contrast ratio
  local lighter = math.max(fg_lum, bg_lum)
  local darker = math.min(fg_lum, bg_lum)
  local contrast = (lighter + 0.05) / (darker + 0.05)
  
  -- Return true if contrast ratio is at least 4.5 (WCAG AA standard)
  return contrast >= 4.5
end

-- Generate colors based on current colorscheme
-- This follows the standard pattern used by lualine.nvim and mini.statusline
function M.generate_from_colorscheme()
  local colors = {}
  
  -- Get base colors first
  local statusline_fg = get_hl_color("StatusLine", "fg") or get_hl_color("Normal", "fg")
  local statusline_bg = get_hl_color("StatusLine", "bg") or get_hl_color("Normal", "bg")
  local normal_fg = get_hl_color("Normal", "fg")
  local normal_bg = get_hl_color("Normal", "bg")
  
  -- Statusline colors - ensure good contrast
  colors.statusline = {
    fg = statusline_fg or M.fallback.statusline.fg,
    bg = statusline_bg or M.fallback.statusline.bg,
  }
  
  -- Determine if statusline background is light or dark
  local function is_light_bg(bg_color)
    if not bg_color then return false end
    local hex = bg_color:match("#(%x%x%x%x%x%x)")
    if not hex then return false end
    local r = tonumber(hex:sub(1, 2), 16)
    local g = tonumber(hex:sub(3, 4), 16)
    local b = tonumber(hex:sub(5, 6), 16)
    -- Calculate luminance
    local luminance = (0.299 * r + 0.587 * g + 0.114 * b) / 255
    return luminance > 0.5
  end
  
  local is_light_statusline = is_light_bg(colors.statusline.bg)
  
  -- Mode colors - use User groups if available, otherwise create high-contrast colors
  colors.normal = {
    fg = get_hl_color("User1", "fg") or (statusline_bg and "#ffffff") or M.fallback.normal.fg,
    bg = get_hl_color("User1", "bg") or (statusline_bg and "#0087ff") or M.fallback.normal.bg,
  }
  
  colors.insert = {
    fg = get_hl_color("User2", "fg") or (statusline_bg and "#ffffff") or M.fallback.insert.fg,
    bg = get_hl_color("User2", "bg") or (statusline_bg and "#00af00") or M.fallback.insert.bg,
  }
  
  colors.visual = {
    fg = get_hl_color("User3", "fg") or (statusline_bg and "#000000") or M.fallback.visual.fg,
    bg = get_hl_color("User3", "bg") or (statusline_bg and "#ffaf00") or M.fallback.visual.bg,
  }
  
  colors.replace = {
    fg = get_hl_color("User4", "fg") or (statusline_bg and "#ffffff") or M.fallback.replace.fg,
    bg = get_hl_color("User4", "bg") or (statusline_bg and "#d70000") or M.fallback.replace.bg,
  }
  
  colors.command = {
    fg = get_hl_color("User5", "fg") or (statusline_bg and "#ffffff") or M.fallback.command.fg,
    bg = get_hl_color("User5", "bg") or (statusline_bg and "#8700af") or M.fallback.command.bg,
  }
  
  colors.select = {
    fg = get_hl_color("User6", "fg") or (statusline_bg and "#000000") or M.fallback.select.fg,
    bg = get_hl_color("User6", "bg") or (statusline_bg and "#00afaf") or M.fallback.select.bg,
  }
  
  colors.shell = {
    fg = get_hl_color("User7", "fg") or (statusline_bg and "#000000") or M.fallback.shell.fg,
    bg = get_hl_color("User7", "bg") or (statusline_bg and "#ff8700") or M.fallback.shell.bg,
  }
  
  colors.terminal = {
    fg = get_hl_color("User8", "fg") or (statusline_bg and "#000000") or M.fallback.terminal.fg,
    bg = get_hl_color("User8", "bg") or (statusline_bg and "#ff8700") or M.fallback.terminal.bg,
  }
  
  -- File path colors - ensure good contrast against statusline background
  local file_fg = get_hl_color("Directory", "fg") or get_hl_color("Normal", "fg")
  -- Force high contrast based on statusline background
  if is_light_statusline then
    file_fg = "#000000" -- Dark text on light background
  else
    file_fg = "#ffffff" -- Light text on dark background
  end
  colors.file = {
    fg = file_fg,
    bg = colors.statusline.bg,
  }
  
  -- Diagnostic colors - use high-contrast colors
  local error_fg, warn_fg
  if is_light_statusline then
    error_fg = "#cc0000" -- Dark red on light background
    warn_fg = "#cc6600"  -- Dark orange on light background
  else
    error_fg = "#ff5f5f" -- Light red on dark background
    warn_fg = "#ffaf00"  -- Light orange on dark background
  end
  colors.diagnostic_error = {
    fg = error_fg,
    bg = colors.statusline.bg,
  }
  
  colors.diagnostic = {
    fg = warn_fg,
    bg = colors.statusline.bg,
  }
  
  -- LSP colors - ensure visibility
  local lsp_fg
  if is_light_statusline then
    lsp_fg = "#0000ff" -- Dark blue on light background
  else
    lsp_fg = "#5fafff" -- Light blue on dark background
  end
  colors.lsp = {
    fg = lsp_fg,
    bg = colors.statusline.bg,
  }
  
  -- Git colors - ensure visibility
  local git_fg
  if is_light_statusline then
    git_fg = "#008000" -- Dark green on light background
  else
    git_fg = "#5faf5f" -- Light green on dark background
  end
  colors.git = {
    fg = git_fg,
    bg = colors.statusline.bg,
  }
  
  -- Extension badge colors - ensure good contrast
  local extension_fg, extension_bg
  if is_light_statusline then
    extension_fg = "#000000" -- Dark text
    extension_bg = "#5f5faf" -- Light purple background
  else
    extension_fg = "#ffffff" -- Light text
    extension_bg = "#5f5faf" -- Purple background
  end
  colors.extension = {
    fg = extension_fg,
    bg = extension_bg,
  }
  
  -- Separator colors - use subtle but visible colors
  local separator_fg
  if is_light_statusline then
    separator_fg = "#666666" -- Dark gray on light background
  else
    separator_fg = "#888888" -- Light gray on dark background
  end
  colors.separator = {
    fg = separator_fg,
    bg = colors.statusline.bg,
  }
  
  return colors
end

-- Set up standard User highlight groups for statusline components
-- This follows the pattern used by lualine.nvim and other statusline plugins
function M.setup_user_highlights()
  -- User1-User9 are standard Neovim highlight groups for statusline
  -- We set them up with high-contrast colors that work with most colorschemes
  
  -- Get statusline background to determine text color
  local statusline_bg = get_hl_color("StatusLine", "bg") or get_hl_color("Normal", "bg")
  local is_dark_bg = statusline_bg and (statusline_bg:match("#%x%x%x%x%x%x") and tonumber(statusline_bg:sub(2, 3), 16) < 128)
  
  -- User1: Normal mode (blue)
  vim.api.nvim_set_hl(0, "User1", {
    fg = is_dark_bg and "#ffffff" or "#000000",
    bg = "#0087ff",
    bold = true,
  })
  
  -- User2: Insert mode (green)
  vim.api.nvim_set_hl(0, "User2", {
    fg = is_dark_bg and "#ffffff" or "#000000",
    bg = "#00af00",
    bold = true,
  })
  
  -- User3: Visual mode (orange)
  vim.api.nvim_set_hl(0, "User3", {
    fg = "#000000",
    bg = "#ffaf00",
    bold = true,
  })
  
  -- User4: Replace mode (red)
  vim.api.nvim_set_hl(0, "User4", {
    fg = is_dark_bg and "#ffffff" or "#000000",
    bg = "#d70000",
    bold = true,
  })
  
  -- User5: Command mode (purple)
  vim.api.nvim_set_hl(0, "User5", {
    fg = is_dark_bg and "#ffffff" or "#000000",
    bg = "#8700af",
    bold = true,
  })
  
  -- User6: Select mode (cyan)
  vim.api.nvim_set_hl(0, "User6", {
    fg = "#000000",
    bg = "#00afaf",
    bold = true,
  })
  
  -- User7: Shell mode (orange)
  vim.api.nvim_set_hl(0, "User7", {
    fg = "#000000",
    bg = "#ff8700",
    bold = true,
  })
  
  -- User8: Terminal mode (same as shell)
  vim.api.nvim_set_hl(0, "User8", {
    fg = "#000000",
    bg = "#ff8700",
    bold = true,
  })
  
  -- User9: Reserved for future use
  vim.api.nvim_set_hl(0, "User9", {
    fg = "#888888",
    bg = statusline_bg or "#333333",
  })
end

function M.merge(user)
  local result
  
  -- Handle different color modes
  if type(user) == "string" then
    if user == "inherit" then
      -- Use colors from current colorscheme
      result = M.generate_from_colorscheme()
    elseif user == "default" then
      -- Use fallback colors
      result = vim.deepcopy(M.fallback)
    else
      -- Invalid string, fall back to default
      result = vim.deepcopy(M.fallback)
    end
  elseif type(user) == "table" then
    -- User provided custom colors, start with colorscheme colors and override
    result = M.generate_from_colorscheme()
    for k, v in pairs(user) do
      result[k] = vim.tbl_extend("force", result[k] or {}, v)
    end
  else
    -- No colors provided, default to inherit mode
    result = M.generate_from_colorscheme()
  end
  
  return result
end

return M
