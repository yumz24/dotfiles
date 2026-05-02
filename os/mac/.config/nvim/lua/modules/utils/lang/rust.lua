local M = {}

local fn = vim.fn
local keymap_opts = { noremap = true, silent = true }

function M.setup()
  vim.api.nvim_create_autocmd("FileType", {
    pattern = "rust",
    callback = function(args)
      -- rustupで入れた場合の一般的なパスを直接指定
      local cmd = { vim.fn.expand("~/.cargo/bin/rust-analyzer") }
      
      -- もし上のパスに不安があれば、単に "rust-analyzer" に戻してください
      -- local cmd = { "rust-analyzer" }

      vim.lsp.start({
        name = "rust-analyzer",
        cmd = cmd,
        -- root_dirをより柔軟に（Cargo.tomlがなくてもカレントディレクトリで起動）
        root_dir = vim.fs.root(args.buf, { "Cargo.toml", ".git" }) or vim.fn.getcwd(),
      })

      -- 補完の設定
      vim.bo[args.buf].omnifunc = "v:lua.vim.lsp.omnifunc"

      -- キーマップ
      local opts = { buffer = args.buf, silent = true }
      -- 定義・参照への移動
      vim.keymap.set("n", "<Leader>]g", vim.lsp.buf.definition, opts)     -- 定義へジャンプ
      vim.keymap.set("n", "<Leader>[g", vim.lsp.buf.references, opts)     -- 参照元をリスト表示
      vim.keymap.set("n", "<Leader>gi", vim.lsp.buf.implementation, opts) -- 実装へジャンプ
      vim.keymap.set("n", "K",  vim.lsp.buf.hover, opts)          -- ホバー表示（型やドキュメント）

      -- エラー（診断情報）操作
      vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)   -- 前のエラー/警告へ
      vim.keymap.set("n", "]d", vim.diagnostic.goto_next, opts)   -- 次のエラー/警告へ
      vim.keymap.set("n", "<Leader>ge", vim.diagnostic.open_float, opts)  -- エラー内容を浮動窓で表示
      vim.keymap.set("n", "<Leader>gl", vim.diagnostic.setqflist, opts)   -- 全エラーをリスト化（Quickfix）

      -- 修正・編集
      vim.keymap.set("n", "<Leader>f", function() vim.lsp.buf.format { async = true } end, opts) -- フォーマット
      vim.keymap.set("n", "<Leader>rn", vim.lsp.buf.rename, opts)      -- 変数名などの一括リネーム
      vim.keymap.set("n", "<Leader>ca", vim.lsp.buf.code_action, opts) -- クイックフィックスの実行
    end,
  })

  -- 自動補完のトリガー
  -- vim.api.nvim_create_autocmd("InsertCharPre", {
  --   pattern = "*.rs",
  --   callback = function()
  --     if vim.v.char:match("[%w.:]") then
  --       vim.schedule(function()
  --         if vim.fn.pumvisible() == 0 and vim.bo.omnifunc ~= "" then
  --           pcall(vim.fn.feedkeys, vim.api.nvim_replace_termcodes("<C-x><C-o>", true, false, true), "n")
  --         end
  --       end)
  --     end
  --   end,
  -- })
end

return M
