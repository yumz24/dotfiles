local M = {}

function M.setup()
    require('modules.ui').setup()
    require('modules.commands').setup()
    require('modules.autocmds').setup()
    require("modules.utils.lang.rust").setup()
    require("modules.utils.lang.python").setup()
    
    -- vim.opt.shortmess:append "I"
end

return M
