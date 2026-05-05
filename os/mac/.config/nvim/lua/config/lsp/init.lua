local M = {}

function M.setup()
  -- 共通のオンアタッチ設定（キーマップなど）
  vim.api.nvim_create_autocmd('LspAttach', {
    callback = function(args)
      local opts = { buffer = args.buf, silent = true }

      vim.keymap.set("n", "]g", vim.lsp.buf.definition, opts)             -- 定義へジャンプ
      vim.keymap.set("n", "[g", vim.lsp.buf.references, opts)             -- 参照元をリスト表示
      vim.keymap.set("n", "<leader>gi", vim.lsp.buf.implementation, opts) -- 実装へジャンプ

      vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)           -- 前のエラー/警告へ
      vim.keymap.set("n", "]d", vim.diagnostic.goto_next, opts)           -- 次のエラー/警告へ
      vim.keymap.set("n", "<leader>de", function()
        vim.diagnostic.open_float({ scope = "line" })
      end, opts)                                                        -- エラー内容を浮動窓で表示
      vim.keymap.set("n", "<leader>dl", vim.diagnostic.setqflist, opts) -- 全エラーをリスト化（Quickfix）

      vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)

      vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, opts)
      vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, opts)

      -- 自動整形
      vim.keymap.set('n', '<leader>f', function()
        vim.lsp.buf.format { async = true }
      end, opts)

      -- 補完有効化（LspAttach内）
      local client = vim.lsp.get_client_by_id(args.data.client_id)
      if client and client.server_capabilities.completionProvider then
        vim.lsp.completion.enable(true, client.id, args.buf)
      end

      -- 手動トリガー
      vim.keymap.set("i", "<C-Space>", function()
        vim.lsp.completion.get()
      end, { buffer = args.buf })

      vim.keymap.set("i", "<Tab>", function()
        if vim.fn.pumvisible() == 1 then
          return "<C-y>"
        else
          return "<Tab>"
        end
      end, { expr = true })
    end,
  })
  -- 言語サーバーのリストと設定の紐付け
  local servers = {
    rust_analyzer = require("config.lsp.rust"),
    pyright       = require("config.lsp.python"),
    lua_rs        = require("config.lsp.lua"),
    html          = require("config.lsp.html"),
    cssls         = require("config.lsp.css"),
    ts_ls         = require("config.lsp.typescript"),
  }

  -- サーバーの一括登録と有効化
  for name, config in pairs(servers) do
    vim.lsp.config(name, config)
    vim.lsp.enable(name)
  end

  vim.o.completefunc = "v:lua.vim.lsp.omnifunc"
end

return M
