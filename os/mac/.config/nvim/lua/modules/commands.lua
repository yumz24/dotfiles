-- ============================================================================
-- User Command (:Mapなど) の定義
-- ============================================================================

local M = {}

function M.setup()
    local utils = require('modules.utils')
    if type(utils) ~= 'table' then return end

    -- 汎用コマンド
    vim.api.nvim_create_user_command('QfClear', utils.clear_quickfix, { desc = 'Clear Quickfix list' })
    vim.api.nvim_create_user_command('MoveToTab', utils.move_window_to_tab, { desc = 'Move window to new tab' })
    vim.api.nvim_create_user_command('Map', utils.show_keymaps, { desc = 'Show all keymaps', bang = true })

    -- Python用
    vim.api.nvim_create_user_command("RunPython", function()
      if vim.bo.filetype ~= "python" then
        vim.notify("Not a Python file", vim.log.levels.WARN)
        return
      end
      utils.run_python()
    end, { desc = 'Run Python' })
end

return M
