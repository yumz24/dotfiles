vim.g.mapleader = " "
vim.g.maplocalleader = " "

require("core.options")

require("config.ui.highlights").setup()
require("config.ui.statusline").setup()
require("config.lsp").setup()

require("config.autocmds").setup()
require("config.commands").setup()

require("core.keymaps").setup()

vim.cmd("filetype plugin on")
