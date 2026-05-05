local M = {}

function M.setup()
    -- キーマップ確認 ( bang 属性を活かして詳細表示などの切り替えに対応)
    vim.api.nvim_create_user_command('Map', function()
        local ok, editor = pcall(require, 'lib.utils.editor')
        if ok and editor.show_keymaps then
            editor.show_keymaps()
        end
    end, { desc = 'Show all keymaps', bang = true })

    -- Quickfixを空にする
    vim.api.nvim_create_user_command('QfClear', function()
        vim.fn.setqflist({})
        vim.cmd('cclose')
        print("Quickfix list cleared")
    end, { desc = 'Clear Quickfix list' })

  end

return M
