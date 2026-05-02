local M = {}

function M.setup()
  require('config.lsp').setup()
  require('config.autocmd')
end

return M
