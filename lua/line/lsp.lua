-- LSP client names per buffer and progress tracking through the LspProgress event.
local M = {}

local spinner_frames = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" }
local spinner_interval = 100

---@type table<integer, string> buffer -> comma-separated client names
local names_cache = {}
---@type table<integer, table<string|integer, number|true>> client id -> token -> percentage
local progress = {}
local frame = 1
---@type uv.uv_timer_t?
local timer

---@type string[]
local ignored = {}

local work_done_kinds = { begin = true, report = true, ["end"] = true }

---@param buf integer
---@return string
function M.names(buf)
  local names = names_cache[buf]
  if names then
    return names
  end
  local list = {}
  for _, client in ipairs(vim.lsp.get_clients({ bufnr = buf })) do
    if not vim.list_contains(ignored, client.name) then
      list[#list + 1] = client.name
    end
  end
  names = table.concat(vim.list.unique(list), ",")
  names_cache[buf] = names
  return names
end

---Clients attached to the buffer that report work in progress, and their average percentage.
---@param buf integer
---@return string? names Comma-separated client names, or nil when nothing is loading
---@return integer? percent Average reported percentage, or nil when no client reports one
function M.loading(buf)
  if not next(progress) then
    return nil
  end
  local list, sum, count = {}, 0, 0
  for _, client in ipairs(vim.lsp.get_clients({ bufnr = buf })) do
    local tokens = progress[client.id]
    if tokens and not vim.list_contains(ignored, client.name) then
      list[#list + 1] = client.name
      for _, percent in pairs(tokens) do
        if type(percent) == "number" then
          sum, count = sum + percent, count + 1
        end
      end
    end
  end
  if #list == 0 then
    return nil
  end
  return table.concat(vim.list.unique(list), ","), count > 0 and math.floor(sum / count) or nil
end

---@return string
function M.spinner()
  return spinner_frames[frame]
end

local function stop_timer()
  if timer then
    timer:stop()
    timer:close()
    timer = nil
  end
end

local function tick()
  -- Drop progress of clients that exited without sending "end".
  for id in pairs(progress) do
    if not vim.lsp.get_client_by_id(id) then
      progress[id] = nil
    end
  end
  if not next(progress) then
    stop_timer()
  end
  frame = frame % #spinner_frames + 1
  vim.api.nvim__redraw({ statusline = true })
end

local function start_timer()
  if timer then
    return
  end
  timer = assert(vim.uv.new_timer())
  timer:start(0, spinner_interval, vim.schedule_wrap(tick))
end

---Handle an LspProgress event.
---@param data { client_id: integer, params: lsp.ProgressParams }
function M.on_progress(data)
  local value = data.params and data.params.value
  -- Partial results also arrive through $/progress but are not work-done progress: they have no
  -- kind and never send "end".
  if type(value) ~= "table" or not work_done_kinds[value.kind] then
    return
  end
  local id, token = data.client_id, data.params.token
  local client = vim.lsp.get_client_by_id(id)
  if not client or vim.list_contains(ignored, client.name) then
    return
  end
  if value.kind == "end" then
    local tokens = progress[id]
    if tokens then
      tokens[token] = nil
      if not next(tokens) then
        progress[id] = nil
      end
    end
  else
    local tokens = progress[id] or {}
    progress[id] = tokens
    -- Keep the last percentage when a report omits it.
    tokens[token] = type(value.percentage) == "number" and value.percentage or tokens[token] or true
    start_timer()
  end
end

---Forget cached client names. Without a buffer, clears all buffers.
---@param buf integer?
function M.invalidate(buf)
  if buf then
    names_cache[buf] = nil
  else
    names_cache = {}
  end
end

---@param ignored_clients string[]
function M.setup(ignored_clients)
  ignored = ignored_clients
  names_cache = {}
  progress = {}
  stop_timer()
end

return M
