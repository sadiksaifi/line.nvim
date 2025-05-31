local M = {}

local colors_mod = require("line.colors")
---@type LineConfig
local default_config = {
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
  },
  icons = {
    error = "󰅚",
    warn = "󰋽",
    git = " ",
  },
  colors = {}, -- user can override colors
}

-- Mode names for statusline
local mode_names = {
  n = "Normal",
  i = "Insert",
  v = "Visual",
  V = "V-Line",
  ["\22"] = "V-Block",
  c = "Command",
  s = "Select",
  S = "S-Line",
  ["\19"] = "S-Block",
  R = "Replace",
  r = "Replace",
  ["!"] = "Shell",
  t = "Terminal",
}

-- LSP spinner frames
local spinner_frames = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" }

-- State management
local state = {
  config = default_config,
  lsp_clients = {},
  lsp_progress = {},
  current_mode = "n",
  diagnostics = { error = 0, warn = 0 },
  git_branch = "",
  project_root = "",
  spinner_frame = 1,
  spinner_timer = nil,
  is_loading = false,
  colors = {},
}

-- Utility functions
local function get_mode_hl()
  local mode = vim.api.nvim_get_mode().mode
  local mode_map = {
    n = "LineModeNormal",
    i = "LineModeInsert",
    v = "LineModeVisual",
    V = "LineModeVisual",
    ["\22"] = "LineModeVisual",
    c = "LineModeCommand",
    s = "LineModeSelect",
    S = "LineModeSelect",
    ["\19"] = "LineModeSelect",
    R = "LineModeReplace",
    r = "LineModeReplace",
    ["!"] = "LineModeShell",
    t = "LineModeTerminal",
  }
  local hl = mode_map[mode] or "LineModeNormal"
  return string.format("%%#%s# %s %%#LineStatusline#", hl, mode_names[mode] or "Unknown")
end

local function get_file_path()
  local bufname = vim.api.nvim_buf_get_name(0)
  if bufname == "" then
    return ""
  end
  local hl = "%#LineFile#"
  local relative_path = vim.fn.fnamemodify(bufname, ":~:.")
  return hl .. " " .. relative_path .. " " .. "%#LineStatusline#"
end

local function update_spinner()
  if state.is_loading then
    state.spinner_frame = (state.spinner_frame % #spinner_frames) + 1
    vim.cmd("redrawstatus")
  end
end

local function start_spinner()
  if not state.spinner_timer then
    state.is_loading = true
    state.spinner_timer = vim.loop.new_timer()
    state.spinner_timer:start(0, 100, vim.schedule_wrap(update_spinner))
  end
end

local function stop_spinner()
  if state.spinner_timer then
    state.spinner_timer:stop()
    state.spinner_timer:close()
    state.spinner_timer = nil
  end
  state.is_loading = false
  state.lsp_progress = {}
  vim.cmd("redrawstatus")
end

-- Right component helpers (no trailing space, statusline bg)
local function get_lsp_status()
  if #state.lsp_clients == 0 then
    return ""
  end
  local hl = "%#LineLsp#"
  if state.is_loading then
    local frame = spinner_frames[state.spinner_frame]
    return hl .. " Loading LSP" .. " " .. frame .. "%#LineStatusline#"
  end
  return hl .. table.concat(state.lsp_clients, ",") .. "%#LineStatusline#"
end

local function get_diagnostics()
  local error_count = state.diagnostics.error
  local warn_count = state.diagnostics.warn
  local parts = {}
  if error_count > 0 then
    table.insert(
      parts,
      "%#LineDiagnosticError# "
        .. state.config.icons.error
        .. " "
        .. error_count
        .. "%#LineStatusline#"
    )
  end
  if warn_count > 0 then
    table.insert(
      parts,
      "%#LineDiagnostic# " .. state.config.icons.warn .. " " .. warn_count .. "%#LineStatusline#"
    )
  end
  if #parts == 0 then
    return ""
  end
  return table.concat(parts, "")
end

local function get_git_branch()
  if state.git_branch == "" then
    return ""
  end
  local hl = "%#LineGit#"
  return hl .. state.config.icons.git .. "" .. state.git_branch .. " " .. "%#LineStatusline#"
end

-- Extension badge keeps its own bg and a space before for separation
local function get_extension_badge()
  local bufname = vim.api.nvim_buf_get_name(0)
  if bufname == "" then
    return ""
  end
  local ext = vim.fn.fnamemodify(bufname, ":e")
  if ext == "" then
    return ""
  end
  return string.format("%%#LineExtension# %s %%#LineStatusline#", ext)
end

-- Event handlers
local function on_mode_change()
  vim.cmd("redrawstatus")
end

local function on_lsp_attach(client)
  if not vim.tbl_contains(state.config.lsp.ignored_clients, client.name) then
    -- Check if client is already in the list
    local exists = false
    for _, name in ipairs(state.lsp_clients) do
      if name == client.name then
        exists = true
        break
      end
    end
    if not exists then
      table.insert(state.lsp_clients, client.name)
      vim.cmd("redrawstatus")
    end
  end
end

local function on_lsp_detach(client)
  for i, name in ipairs(state.lsp_clients) do
    if name == client.name then
      table.remove(state.lsp_clients, i)
      break
    end
  end
  vim.cmd("redrawstatus")
end

local function on_lsp_progress(_, result)
  if result.token then
    if result.value then
      -- Progress update
      state.lsp_progress[result.token] = result.value
      start_spinner()
    else
      -- Progress end
      state.lsp_progress[result.token] = nil
      if not next(state.lsp_progress) then
        stop_spinner()
      end
    end
  end
end

local function on_diagnostics_update()
  local diagnostics = vim.diagnostic.get(0)
  state.diagnostics = {
    error = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.ERROR }),
    warn = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.WARN }),
  }
  vim.cmd("redrawstatus")
end

local function update_git_branch()
  local utils = require("line.utils")
  state.git_branch = utils.get_git_branch()
  vim.cmd("redrawstatus")
end

-- Statusline function
function M.get_statusline()
  local left = {}
  local right = {}

  -- Left side components
  if state.config.components.mode then
    table.insert(left, get_mode_hl())
  end

  if state.config.components.file_path then
    table.insert(left, get_file_path())
  end

  -- Right side components (order: diagnostics, lsp, git)
  if state.config.components.diagnostics then
    table.insert(right, get_diagnostics())
  end
  if state.config.components.lsp then
    table.insert(right, get_lsp_status())
  end
  if state.config.components.git then
    table.insert(right, get_git_branch())
  end

  -- Extension badge is always last
  local extension_badge = get_extension_badge()

  -- Filter out empty right components (before extension)
  local filtered_right = {}
  for _, v in ipairs(right) do
    if v and v ~= "" then
      table.insert(filtered_right, v)
    end
  end

  -- Insert pipe separator between right components (not before first, not after last)
  local right_str = ""
  for i, v in ipairs(filtered_right) do
    right_str = right_str .. v
    if i < #filtered_right then
      right_str = right_str .. "%#LineSeparator# | %#LineStatusline#"
    end
  end

  -- Add extension badge at the end (no separator after)
  if extension_badge ~= "" then
    right_str = right_str .. extension_badge
  end

  local left_str = table.concat(left, "")

  -- Use '%=' to right-align the right section, and add a single space after if not empty
  return "%#LineStatusline#" .. left_str .. "%=" .. right_str .. "%*"
end

-- Setup function
---Setup line.nvim
---@param config LineConfig
function M.setup(config)
  -- Merge user config with defaults
  state.config = vim.tbl_deep_extend("force", default_config, config or {})

  -- Merge and store colors
  state.colors = colors_mod.merge(state.config.colors)

  -- Set highlights for each component
  local color_map = {
    LineStatusline = state.colors.statusline,
    LineSeparator = state.colors.separator,
    LineModeNormal = state.colors.normal,
    LineModeInsert = state.colors.insert,
    LineModeVisual = state.colors.visual,
    LineModeReplace = state.colors.replace,
    LineModeCommand = state.colors.command,
    LineModeSelect = state.colors.select,
    LineModeShell = state.colors.shell,
    LineModeTerminal = state.colors.terminal,
    LineFile = state.colors.file,
    LineLsp = state.colors.lsp,
    LineDiagnosticError = state.colors.diagnostic_error,
    LineDiagnostic = state.colors.diagnostic,
    LineGit = state.colors.git,
    LineExtension = state.colors.extension,
  }
  for group, c in pairs(color_map) do
    vim.api.nvim_set_hl(0, group, { fg = c.fg, bg = c.bg, bold = true })
  end

  -- Set up statusline
  vim.opt.statusline = '%{%v:lua.require("line").get_statusline()%}'

  -- Set up event handlers
  vim.api.nvim_create_autocmd("ModeChanged", {
    callback = on_mode_change,
  })

  vim.api.nvim_create_autocmd("LspAttach", {
    callback = function(args)
      on_lsp_attach(vim.lsp.get_client_by_id(args.data.client_id))
    end,
  })

  vim.api.nvim_create_autocmd("LspDetach", {
    callback = function(args)
      on_lsp_detach(vim.lsp.get_client_by_id(args.data.client_id))
    end,
  })

  vim.api.nvim_create_autocmd("DiagnosticChanged", {
    callback = on_diagnostics_update,
  })

  -- Set up LSP progress handler
  vim.lsp.handlers["$/progress"] = function(_, result, ctx)
    if not result.token then
      return
    end

    -- Handle progress end
    if not result.value then
      state.lsp_progress[result.token] = nil
      -- Only stop spinner if no more progress items
      if not next(state.lsp_progress) then
        stop_spinner()
      end
      return
    end

    -- Handle progress update
    if result.value.kind == "begin" then
      state.lsp_progress[result.token] = result.value
      start_spinner()
    elseif result.value.kind == "end" then
      state.lsp_progress[result.token] = nil
      -- Only stop spinner if no more progress items
      if not next(state.lsp_progress) then
        stop_spinner()
      end
    end
  end

  -- Set up git branch updates
  vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost" }, {
    callback = update_git_branch,
  })

  -- Initial git branch update
  update_git_branch()
end

return M
