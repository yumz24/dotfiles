local M = {}

local html = require('modules.utils.lang.html')
local markdown = require('modules.utils.lang.markdown')
local python = require('modules.utils.lang.python')
local rust = require('modules.utils.lang.rust')

M = vim.tbl_extend('force', M, html, markdown, python, rust)

return M
