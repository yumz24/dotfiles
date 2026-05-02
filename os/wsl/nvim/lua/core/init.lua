local M = {}

function M.setup()
	vim.g.mapleader = " "
	vim.g.maplocalleader = " "

	require('core.options')
	require('core.keymaps').setup()
end

return M
