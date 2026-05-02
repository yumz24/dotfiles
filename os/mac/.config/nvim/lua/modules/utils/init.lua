local M = {}

local editor = require('modules.utils.editor')
local explorer = require('modules.utils.explorer')
local git = require('modules.utils.git')
local lang = require('modules.utils.lang')
local linter = require('modules.utils.linter')
local window = require('modules.utils.window')

M = vim.tbl_extend('force', M, editor, explorer, git, lang, linter, window)

return M
