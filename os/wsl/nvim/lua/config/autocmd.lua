local map = vim.keymap.set

vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(ev)
    local opts = { buffer = ev.buf, silent = true }

    -- 定義ジャンプ
    map("n", "gd", vim.lsp.buf.definition, opts)
    map("n", "gr", vim.lsp.buf.references, opts)
    map("n", "gi", vim.lsp.buf.implementation, opts)

    -- 情報
    map("n", "K", vim.lsp.buf.hover, opts)
    map("n", "<leader>rn", vim.lsp.buf.rename, opts)
    map("n", "<leader>ca", vim.lsp.buf.code_action, opts)

    -- 診断
    map("n", "[d", vim.diagnostic.goto_prev, opts)
    map("n", "]d", vim.diagnostic.goto_next, opts)
  end,
})
