local M = {}

-- Cache for project roots
local root_cache = {}

-- Find project root based on markers
function M.find_project_root(markers)
  local current_dir = vim.fn.expand("%:p:h")

  -- Check cache first
  if root_cache[current_dir] then
    return root_cache[current_dir]
  end

  -- Start from current directory and go up
  local dir = current_dir
  while dir ~= "/" do
    -- Check each marker
    for _, marker in ipairs(markers) do
      local path = dir .. "/" .. marker
      if vim.fn.filereadable(path) == 1 or vim.fn.isdirectory(path) == 1 then
        root_cache[current_dir] = dir
        return dir
      end
    end
    dir = vim.fn.fnamemodify(dir, ":h")
  end

  -- If no root found, use current directory
  root_cache[current_dir] = current_dir
  return current_dir
end

-- Get git branch name
function M.get_git_branch()
  local branch = vim.fn.system("git branch --show-current 2>/dev/null")
  if vim.v.shell_error ~= 0 then
    return ""
  end
  return vim.fn.trim(branch)
end

-- Clear root cache for a directory
function M.clear_root_cache(dir)
  root_cache[dir] = nil
end

-- Clear all root cache
function M.clear_all_root_cache()
  root_cache = {}
end

return M
