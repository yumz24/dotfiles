local M = {}
local map = vim.keymap.set

local function opts(desc, extra_opts)
  local base = { noremap = true, silent = true, desc = desc }
  if extra_opts then
    -- extra_opts (exprなど) があれば統合する
    base = vim.tbl_extend("force", base, extra_opts)
  end
  return base
end

function M.setup()
end

return M
