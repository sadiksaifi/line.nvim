---@class LineColors
---@field statusline table
---@field normal table
---@field insert table
---@field visual table
---@field replace table
---@field command table
---@field select table
---@field shell table
---@field terminal table
---@field file table
---@field diagnostic_error table
---@field diagnostic table
---@field lsp table
---@field git table
---@field extension table
---@field separator table

---@class LineIcons
---@field error string
---@field warn string
---@field git string

---@class LineLspConfig
---@field ignored_clients string[]

---@class LineComponents
---@field mode boolean
---@field file_path boolean
---@field lsp boolean
---@field diagnostics boolean
---@field git boolean

---@class LineConfig
---@field root_markers? string[]
---@field lsp? LineLspConfig
---@field components? LineComponents
---@field icons? LineIcons
---@field colors? LineColors
