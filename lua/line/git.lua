-- Git branch detection. Reads .git/HEAD directly instead of spawning git. Lookups run in event
-- handlers or scheduled callbacks; rendering only reads the caches.
local M = {}

local api = vim.api

---@type table<integer, string|false> buffer -> repository root, false when not in a repository
local root_cache = {}
---@type table<string, string> repository root -> branch name or short commit hash
local head_cache = {}
---@type table<string, boolean> repository roots with a running `git` fallback process
local pending = {}
---@type table<string, boolean> roots that needed a new `git` query while one was running
local requery = {}
---@type table<string, integer> root -> number of HEAD reads, to discard outdated `git` results
local generation = {}
---@type table<integer, boolean> buffers with a scheduled refresh
local queued = {}

---@param path string
---@return string?
local function read_first_line(path)
  local file = io.open(path, "r")
  if not file then
    return nil
  end
  local line = file:read("*l")
  file:close()
  return line
end

---Resolve the git directory of a repository root. Supports worktrees and submodules, where .git
---is a file containing "gitdir: <path>".
---@param root string
---@return string?
local function git_dir(root)
  local dotgit = vim.fs.joinpath(root, ".git")
  local stat = vim.uv.fs_stat(dotgit)
  if not stat then
    return nil
  end
  if stat.type == "directory" then
    return dotgit
  end
  local dir = (read_first_line(dotgit) or ""):match("^gitdir:%s*(.-)%s*$")
  if not dir or dir == "" then
    return nil
  end
  if not vim.startswith(dir, "/") and not dir:match("^%a:[/\\]") then
    dir = vim.fs.joinpath(root, dir)
  end
  return vim.fs.normalize(dir)
end

---@param root string
---@param head string
local function store(root, head)
  if head_cache[root] ~= head then
    head_cache[root] = head
    api.nvim__redraw({ statusline = true })
  end
end

---Ask git for the branch when HEAD cannot be parsed, for example with the reftable backend.
---@param root string
local function query_git(root)
  if pending[root] then
    requery[root] = true
    return
  end
  if vim.fn.executable("git") == 0 then
    return
  end
  pending[root] = true
  local started = generation[root]

  ---@param result vim.SystemCompleted
  ---@param head string
  local function finish(result, head)
    pending[root] = nil
    if started ~= generation[root] then
      -- HEAD was read again while git ran, so this result may be outdated. Query again only if the
      -- newer read also needed git.
      if requery[root] then
        requery[root] = nil
        query_git(root)
      end
      return
    end
    requery[root] = nil
    store(root, result.code == 0 and head or "")
  end

  vim.system(
    { "git", "-C", root, "rev-parse", "--abbrev-ref", "HEAD" },
    { text = true },
    vim.schedule_wrap(function(result)
      local branch = vim.trim(result.stdout or "")
      if result.code ~= 0 or branch ~= "HEAD" then
        finish(result, branch)
        return
      end
      -- Detached HEAD: show the short commit hash.
      vim.system(
        { "git", "-C", root, "rev-parse", "--short", "HEAD" },
        { text = true },
        vim.schedule_wrap(function(sha)
          finish(sha, vim.trim(sha.stdout or ""))
        end)
      )
    end)
  )
end

---@param root string
local function read_head(root)
  generation[root] = (generation[root] or 0) + 1
  requery[root] = nil
  local dir = git_dir(root)
  local head = dir and read_first_line(vim.fs.joinpath(dir, "HEAD"))
  if not head then
    store(root, "")
    return
  end
  local ref = head:match("^ref:%s*refs/heads/(.-)%s*$")
  if ref and ref ~= ".invalid" then
    store(root, ref)
    return
  end
  local sha = head:match("^(%x+)%s*$")
  if sha then
    store(root, sha:sub(1, 7))
    return
  end
  query_git(root)
end

---Look up the buffer's repository and re-read its HEAD. Does filesystem work; never call it while
---rendering.
---@param buf integer
function M.refresh(buf)
  if not api.nvim_buf_is_valid(buf) then
    return
  end
  -- Recheck buffers outside a repository, in case one was created since.
  if not root_cache[buf] then
    root_cache[buf] = vim.fs.root(buf, ".git") or false
  end
  local root = root_cache[buf]
  if root then
    read_head(root)
  end
end

---Refresh the buffers shown in any window.
function M.refresh_visible()
  local seen = {}
  for _, win in ipairs(api.nvim_list_wins()) do
    local buf = api.nvim_win_get_buf(win)
    if not seen[buf] then
      seen[buf] = true
      M.refresh(buf)
    end
  end
end

---Branch name or short commit hash for the buffer's repository, or "" outside a repository.
---Reads only the cache; a miss schedules a refresh and returns "".
---@param buf integer
---@return string
function M.branch(buf)
  local root = root_cache[buf]
  local head = root and head_cache[root]
  if root == false then
    return ""
  end
  if head then
    return head
  end
  if not queued[buf] then
    queued[buf] = true
    vim.schedule(function()
      queued[buf] = nil
      M.refresh(buf)
    end)
  end
  return ""
end

---HEAD may have changed (focus regained, shell command, terminal closed). Re-read every known
---repository and recheck visible buffers that were outside a repository.
function M.reload()
  for buf, root in pairs(root_cache) do
    if root == false then
      root_cache[buf] = nil
    end
  end
  for root in pairs(head_cache) do
    read_head(root)
  end
  M.refresh_visible()
end

---Forget cached data. Without a buffer, forgets every repository root, for example after the
---current directory changed.
---@param buf integer?
function M.invalidate(buf)
  if buf then
    root_cache[buf] = nil
  else
    root_cache = {}
  end
end

---@param buf integer
function M.forget(buf)
  root_cache[buf] = nil
  queued[buf] = nil
end

---Reset all state. Used by setup().
function M.reset()
  root_cache, head_cache, queued, requery = {}, {}, {}, {}
  -- Keep `generation` so results of git processes still running are discarded.
  for root in pairs(generation) do
    generation[root] = generation[root] + 1
  end
end

return M
