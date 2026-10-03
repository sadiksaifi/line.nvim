-- Statusline components. Each component takes the buffer, window, and statusline width being drawn
-- and returns a statusline string, or "" when it has nothing to show.
local M = {}

local api = vim.api
local git = require("line.git")
local lsp = require("line.lsp")

local RESET = "%#LineStatusline#"

-- Below this statusline width, the mode shows its short label.
local SHORT_MODE_WIDTH = 60
-- Longest branch or LSP client list shown before truncating with an ellipsis.
local MAX_LABEL = 30

---@type LineOptions
local config

---@param s string
---@return string
local function escape(s)
  return (s:gsub("%%", "%%%%"))
end

---Shorten a label to `max` display cells, ending with an ellipsis.
---@param s string
---@param max integer
---@return string
local function truncate(s, max)
  if vim.fn.strdisplaywidth(s) <= max then
    return s
  end
  return vim.fn.strcharpart(s, 0, max - 1) .. "…"
end

-- Mode ----------------------------------------------------------------------

-- Keyed by the full mode from nvim_get_mode(), then by its first two characters, then by its first.
-- Each entry is { label, short label }.
local mode_names = {
  n = { "Normal", "N" },
  no = { "O-Pending", "O" },
  v = { "Visual", "V" },
  V = { "V-Line", "VL" },
  ["\22"] = { "V-Block", "VB" },
  s = { "Select", "S" },
  S = { "S-Line", "SL" },
  ["\19"] = { "S-Block", "SB" },
  i = { "Insert", "I" },
  R = { "Replace", "R" },
  Rv = { "V-Replace", "VR" },
  c = { "Command", "C" },
  cv = { "Ex", "EX" },
  r = { "Prompt", "P" },
  rm = { "More", "M" },
  ["r?"] = { "Confirm", "?" },
  ["!"] = { "Shell", "!" },
  t = { "Terminal", "T" },
}

local mode_groups = {
  n = "LineModeNormal",
  v = "LineModeVisual",
  V = "LineModeVisual",
  ["\22"] = "LineModeVisual",
  s = "LineModeSelect",
  S = "LineModeSelect",
  ["\19"] = "LineModeSelect",
  i = "LineModeInsert",
  R = "LineModeReplace",
  c = "LineModeCommand",
  r = "LineModeCommand",
  ["!"] = "LineModeShell",
  t = "LineModeTerminal",
}

---@type table<string, string> mode and width class -> rendered component
local mode_cache = {}

---@param _buf integer
---@param _win integer
---@param width integer
---@return string
function M.mode(_buf, _win, width)
  local mode = api.nvim_get_mode().mode
  local short = width < SHORT_MODE_WIDTH
  local key = short and mode .. "\0" or mode
  local cached = mode_cache[key]
  if cached then
    return cached
  end
  local first = mode:sub(1, 1)
  local names = mode_names[mode] or mode_names[mode:sub(1, 2)] or mode_names[first]
  local name = names and names[short and 2 or 1] or mode
  local group = mode_groups[first] or "LineModeNormal"
  cached = string.format("%%#%s# %s %s", group, escape(name), RESET)
  mode_cache[key] = cached
  return cached
end

-- File path -----------------------------------------------------------------

---@type table<integer, string> buffer -> escaped display path
local path_cache = {}

---Display name of a terminal buffer: the command it runs, without directories.
---@param name string
---@return string
local function terminal_name(name)
  local cmd = name:match("^term://.-//%d+:(.*)$")
  if not cmd or cmd == "" then
    return "terminal"
  end
  local program, args = cmd:match("^(%S+)(.*)$")
  return vim.fs.basename(program) .. args
end

---@param buf integer
---@return string
local function display_path(buf)
  local cached = path_cache[buf]
  if cached then
    return cached
  end
  local name = api.nvim_buf_get_name(buf)
  local buftype = vim.bo[buf].buftype
  local path
  if name == "" then
    path = ""
  elseif buftype == "terminal" then
    path = terminal_name(name)
  elseif buftype == "help" then
    path = vim.fs.basename(name)
  elseif name:match("^%a[%w+.-]*://") then
    -- Plugin URIs such as oil:///path: show the scheme and a short path.
    local scheme, rest = name:match("^(%a[%w+.-]*)://(.*)$")
    path = scheme .. ": " .. vim.fn.fnamemodify(rest, ":~:.")
  elseif buftype ~= "" then
    path = vim.fs.basename(name)
  else
    local root = vim.fs.root(buf, config.root_markers)
    if root and root ~= vim.uv.os_homedir() then
      path = vim.fs.relpath(root, name)
    end
    path = path or vim.fn.fnamemodify(name, ":~:.")
  end
  cached = escape(path)
  path_cache[buf] = cached
  return cached
end

---@param buf integer
---@return string
local function flags(buf)
  local bo = vim.bo[buf]
  local out = ""
  if bo.buftype == "terminal" then
    local info = api.nvim_get_chan_info(bo.channel)
    if info.exitcode and info.exitcode >= 0 then
      out = string.format(" [Exit: %d]", info.exitcode)
    end
  elseif bo.modified then
    out = " " .. config.icons.modified
  end
  if bo.buftype == "" and (bo.readonly or not bo.modifiable) then
    out = out .. " " .. config.icons.readonly
  end
  return out
end

---@param buf integer
---@param win integer
---@param _ integer
---@param short boolean? Shorten directory names to one character
---@param inactive boolean?
---@return string
function M.file_path(buf, win, _, short, inactive)
  local path
  if vim.bo[buf].buftype == "quickfix" then
    path = escape(vim.w[win].quickfix_title or "")
  else
    path = display_path(buf)
  end
  if path == "" then
    return ""
  end
  if short then
    path = vim.fn.pathshorten(path)
  end
  local f = flags(buf)
  if inactive then
    return "%#LineInactive# " .. path .. f .. " "
  end
  local dir, file = path:match("^(.*/)([^/]+)$")
  if dir then
    return "%#LineFileDir# " .. dir .. "%#LineFile#" .. file .. f .. " " .. RESET
  end
  return "%#LineFile# " .. path .. f .. " " .. RESET
end

-- Diagnostics ---------------------------------------------------------------

local severity = vim.diagnostic.severity
local diagnostic_parts = {
  { severity.ERROR, "LineDiagnosticError", "error" },
  { severity.WARN, "LineDiagnostic", "warn" },
  { severity.INFO, "LineDiagnosticInfo", "info" },
  { severity.HINT, "LineDiagnosticHint", "hint" },
}

---@type table<integer, string> buffer -> rendered component
local diagnostic_cache = {}

---@param buf integer
---@return string
function M.diagnostics(buf)
  local cached = diagnostic_cache[buf]
  if cached then
    return cached
  end
  local counts = vim.diagnostic.count(buf, { enabled = true })
  local parts = {}
  for _, part in ipairs(diagnostic_parts) do
    local count = counts[part[1]]
    if count and count > 0 then
      parts[#parts + 1] =
        string.format("%%#%s#%s %d", part[2], escape(config.icons[part[3]]), count)
    end
  end
  cached = #parts > 0 and table.concat(parts, " ") .. RESET or ""
  diagnostic_cache[buf] = cached
  return cached
end

-- LSP -----------------------------------------------------------------------

---@param buf integer
---@return string
function M.lsp(buf)
  local loading, percent = lsp.loading(buf)
  if loading then
    local text = lsp.spinner() .. " " .. escape(truncate(loading, MAX_LABEL))
    if percent then
      text = text .. " " .. percent .. "%%"
    end
    return "%#LineLsp#" .. text .. RESET
  end
  local names = lsp.names(buf)
  if names == "" then
    return ""
  end
  return "%#LineLsp#" .. escape(truncate(names, MAX_LABEL)) .. RESET
end

-- Neovim progress messages and 'busy' ------------------------------------------

---@param buf integer
---@return string
function M.progress(buf)
  local out = vim.trim(vim.ui.progress_status())
  if vim.bo[buf].busy > 0 then
    out = out == "" and config.icons.busy or config.icons.busy .. " " .. out
  end
  if out == "" then
    return ""
  end
  return "%#LineLsp#" .. out .. RESET
end

-- Git -----------------------------------------------------------------------

---@param buf integer
---@return string
function M.git(buf)
  local branch = git.branch(buf)
  if branch == "" then
    return ""
  end
  return "%#LineGit#" .. escape(config.icons.git .. truncate(branch, MAX_LABEL)) .. RESET
end

-- Location and recording ------------------------------------------------------

---@return string
function M.location()
  return "%#LineFile#%l:%c %P" .. RESET
end

---@return string
function M.recording()
  local reg = vim.fn.reg_recording()
  if reg == "" then
    return ""
  end
  return "%#LineDiagnostic#Recording @" .. reg .. RESET
end

-- Extension badge -------------------------------------------------------------

---@param buf integer
---@param win integer
---@return string
function M.extension(buf, win)
  local bo = vim.bo[buf]
  local label
  if bo.buftype == "terminal" or bo.buftype == "help" then
    label = bo.buftype
  elseif bo.buftype == "quickfix" then
    label = vim.fn.getwininfo(win)[1].loclist == 1 and "loclist" or "quickfix"
  elseif bo.buftype ~= "" then
    -- Plugin windows (file trees, pickers, plugin managers) are named by their filetype.
    label = bo.filetype ~= "" and bo.filetype or bo.buftype
  else
    local name = api.nvim_buf_get_name(buf)
    if name == "" then
      label = "[No Name]"
    else
      label = vim.fs.ext(name)
      if label == "" then
        label = bo.filetype
      end
    end
  end
  if label == "" then
    return ""
  end
  return "%#LineExtension# " .. escape(label) .. " " .. RESET
end

-- Cache management ------------------------------------------------------------

---Forget cached diagnostics for a buffer.
---@param buf integer
function M.invalidate_diagnostics(buf)
  diagnostic_cache[buf] = nil
end

---Forget cached paths. Without a buffer, clears all buffers.
---@param buf integer?
function M.invalidate_path(buf)
  if buf then
    path_cache[buf] = nil
  else
    path_cache = {}
  end
end

---@param buf integer
function M.forget(buf)
  path_cache[buf] = nil
  diagnostic_cache[buf] = nil
end

---@param opts LineOptions
function M.setup(opts)
  config = opts
  mode_cache = {}
  path_cache = {}
  diagnostic_cache = {}
end

return M
