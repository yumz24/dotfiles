local M = {}

function M.setup()
  vim.cmd.colorscheme("habamax")
  require('modules.ui.highlights').setup()
  require('modules.ui.statusline').setup()
end

return M
