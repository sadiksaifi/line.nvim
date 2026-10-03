local M = {}

local api = vim.api

local SEPARATOR = "%#LineSeparator# | %#LineStatusline#"
local STATUSLINE = "%!v:lua.require'line'.render()"
-- Components ranked at or below this drop rank are hidden only after the path is shortened.
local SHORTEN_PATH_AT = 5

---@alias LineComponentFn fun(buf: integer, win: integer, width: integer): string

---A right side component. When the statusline is too narrow, components with the highest `drop`
---are hidden first. A `drop` of 0 is never hidden.
---@class LineSlot
---@field render LineComponentFn
---@field drop integer
---@field width? integer Fixed display width, for components made of statusline items like %l

---@type LineComponentFn?
local mode
local show_file = false
---@type LineSlot[]
local right = {}
---@type LineSlot?
local badge

local configured = false

---Display width of a statusline string, ignoring highlight and alignment items.
---@param s string
---@return integer
local function cells(s)
  s = s:gsub("%%#[^#]*#", ""):gsub("%%[<=*]", ""):gsub("%%%%", "%%")
  return api.nvim_strwidth(s)
end

---@class LineItem
---@field text string
---@field width integer
---@field drop integer
---@field hidden? boolean

---Width of the visible right side items, including separators and the space before the badge.
---@param items LineItem[]
---@param badge_item LineItem?
---@return integer
local function right_width(items, badge_item)
  local total, count = 0, 0
  for _, item in ipairs(items) do
    if not item.hidden then
      total, count = total + item.width, count + 1
    end
  end
  total = total + math.max(count - 1, 0) * 3
  if badge_item and not badge_item.hidden then
    total = total + badge_item.width
  end
  if count > 0 or (badge_item and not badge_item.hidden) then
    total = total + 1
  end
  return total
end

---Render the statusline of the window in g:statusline_winid.
---@return string
function M.render()
  local components = require("line.components")
  local current = api.nvim_get_current_win()
  local win = vim.g.statusline_winid or current
  local buf = api.nvim_win_get_buf(win)
  local global = vim.o.laststatus == 3
  local width = global and vim.o.columns or api.nvim_win_get_width(win)

  if win ~= current and not global then
    local file = components.file_path(buf, win, width, false, true)
    if cells(file) > width then
      file = components.file_path(buf, win, width, true, true)
    end
    return "%#LineInactive#%<" .. file
  end

  local mode_text = mode and mode(buf, win, width) or ""
  local file = show_file and components.file_path(buf, win, width, false) or ""

  ---@type LineItem[]
  local items = {}
  for _, slot in ipairs(right) do
    local text = slot.render(buf, win, width)
    if text ~= "" then
      items[#items + 1] = { text = text, width = slot.width or cells(text), drop = slot.drop }
    end
  end
  ---@type LineItem?
  local badge_item
  if badge then
    local text = badge.render(buf, win, width)
    if text ~= "" then
      badge_item = { text = text, width = cells(text), drop = badge.drop }
    end
  end

  -- Fit the line to the window. Hide components from the lowest priority up, and shorten
  -- directory names before hiding anything ranked SHORTEN_PATH_AT or higher.
  local left_width = cells(mode_text) + cells(file)
  local shortened = false
  local candidates = vim.list_extend({ badge_item }, items)
  table.sort(candidates, function(a, b)
    return a.drop > b.drop
  end)
  for _, item in ipairs(candidates) do
    if left_width + right_width(items, badge_item) <= width then
      break
    end
    if not shortened and file ~= "" and item.drop <= SHORTEN_PATH_AT then
      shortened = true
      file = components.file_path(buf, win, width, true)
      left_width = cells(mode_text) + cells(file)
      if left_width + right_width(items, badge_item) <= width then
        break
      end
    end
    if item.drop == 0 then
      break
    end
    item.hidden = true
  end
  if not shortened and file ~= "" and left_width + right_width(items, badge_item) > width then
    file = components.file_path(buf, win, width, true)
  end

  local parts = { "%#LineStatusline#", mode_text, "%<", file, "%=" }
  local count = 0
  for _, item in ipairs(items) do
    if not item.hidden then
      if count > 0 then
        parts[#parts + 1] = SEPARATOR
      end
      parts[#parts + 1] = item.text
      count = count + 1
    end
  end
  local badge_text = badge_item and not badge_item.hidden and badge_item.text or ""
  if count > 0 or badge_text ~= "" then
    parts[#parts + 1] = " "
  end
  parts[#parts + 1] = badge_text
  parts[#parts + 1] = "%*"
  return table.concat(parts)
end

---Kept for configs that reference the old entry point.
M.get_statusline = M.render

---Reapply theme colors to the Line* highlight groups.
function M.refresh()
  local colors = require("line.colors")
  local options = require("line.config").options
  colors.apply(colors.merge(options.theme, options.colors))
end

---Redraw statuslines that show a buffer, or all statuslines.
---@param buf integer?
local function redraw(buf)
  if buf and api.nvim_buf_is_valid(buf) then
    api.nvim__redraw({ buf = buf, statusline = true })
  else
    api.nvim__redraw({ statusline = true })
  end
end

---@param opts LineOptions
local function build_layout(opts)
  local c = require("line.components")
  local enabled = opts.components
  mode = enabled.mode and c.mode or nil
  show_file = enabled.file_path == true
  right, badge = {}, nil

  ---@param on boolean?
  ---@param render LineComponentFn
  ---@param drop integer
  ---@param width integer?
  local function add(on, render, drop, width)
    if on then
      right[#right + 1] = { render = render, drop = drop, width = width }
    end
  end
  -- Display order. The drop rank decides what disappears first in narrow windows.
  add(enabled.recording, c.recording, 0)
  add(enabled.progress, c.progress, 3)
  add(enabled.diagnostics, c.diagnostics, 1)
  add(enabled.lsp, c.lsp, 5)
  add(enabled.git, c.git, 4)
  add(enabled.location, c.location, 6, 12)
  if enabled.extension then
    badge = { render = c.extension, drop = 2 }
  end
end

---@param opts LineOptions
local function create_autocmds(opts)
  local components = require("line.components")
  local enabled = opts.components
  local group = api.nvim_create_augroup("line.nvim", { clear = true })

  ---@param event string|string[]
  ---@param callback fun(args: vim.api.keyset.create_autocmd.callback_args)
  ---@param pattern string?
  local function on(event, callback, pattern)
    api.nvim_create_autocmd(event, { group = group, pattern = pattern, callback = callback })
  end

  on("ColorScheme", M.refresh)

  on("BufWipeout", function(args)
    components.forget(args.buf)
    require("line.lsp").invalidate(args.buf)
    require("line.git").invalidate(args.buf)
  end)

  on("BufFilePost", function(args)
    components.invalidate_path(args.buf)
    require("line.git").invalidate(args.buf)
  end)

  on("DirChanged", function()
    components.invalidate_path()
    require("line.git").invalidate()
    redraw()
  end)

  on("BufModifiedSet", function(args)
    redraw(args.buf)
  end)

  if enabled.mode then
    on("ModeChanged", function()
      api.nvim__redraw({ win = api.nvim_get_current_win(), statusline = true })
    end)
  end

  if enabled.diagnostics then
    on("DiagnosticChanged", function(args)
      components.invalidate_diagnostics(args.buf)
      redraw(args.buf)
    end)
  end

  if enabled.lsp then
    local lsp = require("line.lsp")
    on("LspAttach", function(args)
      lsp.invalidate(args.buf)
      redraw(args.buf)
    end)
    -- The client is still attached while LspDetach runs, so update after it finishes.
    on("LspDetach", function(args)
      vim.schedule(function()
        lsp.invalidate(args.buf)
        redraw(args.buf)
      end)
    end)
    on("LspProgress", function(args)
      lsp.on_progress(args.data)
    end)
  end

  if enabled.progress then
    -- Initialize vim.ui progress tracking before our handler so it sees every event.
    vim.ui.progress_status()
    on("Progress", function()
      redraw()
    end)
    on("OptionSet", function()
      redraw()
    end, "busy")
  end

  if enabled.git then
    local git = require("line.git")
    on("BufEnter", function(args)
      git.refresh(args.buf)
    end)
    on({ "FocusGained", "ShellCmdPost", "TermLeave" }, function()
      git.invalidate_heads()
      redraw()
    end)
  end

  if enabled.recording then
    on("RecordingEnter", function()
      redraw()
    end)
    -- reg_recording() still returns the register while RecordingLeave runs.
    on("RecordingLeave", function()
      vim.schedule(redraw)
    end)
  end
end

---Set up line.nvim. Calling it again replaces the previous configuration.
---@param opts? LineConfig
function M.setup(opts)
  if vim.fn.has("nvim-0.12") == 0 then
    vim.notify("line.nvim requires Neovim 0.12 or later", vim.log.levels.ERROR)
    return
  end

  local options = require("line.config").setup(opts)
  if not require("line.themes").get_theme(options.theme) then
    vim.notify(
      string.format('line.nvim: unknown theme "%s", using "default"', options.theme),
      vim.log.levels.WARN
    )
    options.theme = "default"
  end

  require("line.components").setup(options)
  require("line.lsp").setup(options.lsp.ignored_clients)
  require("line.git").invalidate()

  M.refresh()
  build_layout(options)
  create_autocmds(options)

  -- Keep the quickfix ftplugin from replacing this statusline with its own.
  if vim.g.qf_disable_statusline == nil then
    vim.g.qf_disable_statusline = 1
  end
  vim.o.statusline = STATUSLINE
  configured = true
  redraw()
end

---Whether setup() completed. Used by :checkhealth.
---@return boolean
function M.is_configured()
  return configured
end

M.STATUSLINE = STATUSLINE

return M
