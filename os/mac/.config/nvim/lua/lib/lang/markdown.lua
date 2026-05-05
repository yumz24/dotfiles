local M = {}

function M.setup()
  local bufnr = vim.api.nvim_get_current_buf()

  -- 別タブでターミナルを開き、glowで表示する
  vim.api.nvim_buf_create_user_command(bufnr, "GlowTab", function()
    local file = vim.fn.expand("%:p")
    -- 新しいタブを作成 -> ターミナル起動 -> glowでファイル表示
    vim.cmd("tabnew | term glow -p " .. vim.fn.shellescape(file))
    -- ターミナルが開いたら自動的に挿入モードにならないようにする（閲覧用）
    vim.cmd("stopinsert")
  end, { desc = "Open preview in a new tab" })

  -- キーマップ設定
  vim.keymap.set("n", "<Leader>p", ":GlowTab<CR>", { buffer = bufnr, silent = true })
end

return M
