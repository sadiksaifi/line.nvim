-- Git branch detection. Reads .git/HEAD directly instead of spawning git, so lookups never block.
local M = {}

---@type table<integer, string|false> buffer -> repository root, false when not in a repository
local root_cache = {}
---@type table<string, string> repository root -> branch name or short commit hash
local head_cache = {}
---@type table<string, boolean> repository roots with a running `git` fallback process
local pending = {}

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

---Ask git for the branch when HEAD cannot be parsed, for example with the reftable backend.
---@param root string
local function query_git(root)
  if pending[root] or vim.fn.executable("git") == 0 then
    return
  end
  pending[root] = true
  vim.system(
    { "git", "-C", root, "rev-parse", "--abbrev-ref", "HEAD" },
    { text = true },
    vim.schedule_wrap(function(result)
      pending[root] = nil
      local branch = vim.trim(result.stdout or "")
      head_cache[root] = result.code == 0 and branch or ""
      vim.api.nvim__redraw({ statusline = true })
    end)
  )
end

---@param root string
---@return string
local function read_head(root)
  local dir = git_dir(root)
  local head = dir and read_first_line(vim.fs.joinpath(dir, "HEAD"))
  if not head then
    return ""
  end
  local ref = head:match("^ref:%s*refs/heads/(.-)%s*$")
  if ref and ref ~= ".invalid" then
    return ref
  end
  local sha = head:match("^(%x+)%s*$")
  if sha then
    return sha:sub(1, 7)
  end
  query_git(root)
  return head_cache[root] or ""
end

---@param buf integer
---@return string?
local function root_of(buf)
  local root = root_cache[buf]
  if root == nil then
    root = vim.fs.root(buf, ".git") or false
    root_cache[buf] = root
  end
  return root or nil
end

---Branch name or short commit hash for the buffer's repository, or "" outside a repository.
---@param buf integer
---@return string
function M.branch(buf)
  local root = root_of(buf)
  if not root then
    return ""
  end
  local head = head_cache[root]
  if not head then
    head = read_head(root)
    head_cache[root] = head
  end
  return head
end

---Re-read HEAD for the buffer's repository.
---@param buf integer
function M.refresh(buf)
  local root = root_of(buf)
  if root then
    head_cache[root] = read_head(root)
  end
end

---Forget cached branch names, keeping repository roots.
function M.invalidate_heads()
  head_cache = {}
end

---Forget cached data. Without a buffer, clears everything.
---@param buf integer?
function M.invalidate(buf)
  if buf then
    root_cache[buf] = nil
  else
    root_cache = {}
    head_cache = {}
  end
end

return M
