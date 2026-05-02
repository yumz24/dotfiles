local M = {}
local fn = vim.fn
local keymap_opts = { noremap = true, silent = true }

-- Pythonファイルの実行
function M.run_python()
    local current_file = fn.expand("%:p")
    if current_file == "" then
        vim.notify("ファイルを保存してから実行してください。", vim.log.levels.WARN)
        return
    end

    vim.cmd("w") -- 実行前に保存を保証

    -- ユーザーが指定したロジック: 下分割、高さ12、python3で実行
    vim.cmd("botright split | resize 12 | terminal python3 " .. fn.shellescape(current_file))
    vim.notify(string.format("実行コマンド: python3 %s", current_file), vim.log.levels.INFO)
end

function M.setup()
  vim.api.nvim_create_autocmd("LspAttach", {
      callback = function(ev)
          local client = vim.lsp.get_client_by_id(ev.data.client_id)
          if client:supports_method("textDocument/completion") then
              vim.lsp.completion.enable(true, client.id, ev.buf, { autotrigger = true })
          end
      end,
  })

  vim.api.nvim_create_autocmd("FileType", {
    pattern = "python",
    callback = function(args)
      -- 1. Pyright (Microsoft製LSP: 型チェック・補完・定義ジャンプ)
      if fn.executable("pyright-langserver") == 1 then
        vim.lsp.start({
          name = "pyright",
          cmd = { "pyright-langserver", "--stdio" },
          root_dir = vim.fs.root(args.buf, { "pyproject.toml", "setup.py", "requirements.txt", ".git" }) or fn.getcwd(),
          settings = {
            python = {
              analysis = {
                autoSearchPaths = true,
                useLibraryCodeForTypes = true,
                typeCheckingMode = "basic",
              },
            },
          },
        })
      end

      -- 2. Ruff (高速リンター & フォーマッタ)
      if fn.executable("ruff") == 1 then
        vim.lsp.start({
          name = "ruff",
          cmd = { "ruff", "server" },
          root_dir = vim.fs.root(args.buf, { "pyproject.toml", "ruff.toml", ".git" }),
        })
      end

      -- 補完の設定
      vim.bo[args.buf].omnifunc = "v:lua.vim.lsp.omnifunc"

      -- キーマップ（Rustの設定と共通化）
      local opts = { buffer = args.buf, silent = true }
      
      -- 移動・表示
      vim.keymap.set("n", "<Leader>]g", vim.lsp.buf.definition, opts)     -- 定義へジャンプ
      vim.keymap.set("n", "<Leader>[g", vim.lsp.buf.references, opts)     -- 参照
      vim.keymap.set("n", "K",          vim.lsp.buf.hover, opts)          -- ドキュメント表示

      -- 診断 (以前の lint_python の役割を自動化)
      vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)           -- 前のエラー
      vim.keymap.set("n", "]d", vim.diagnostic.goto_next, opts)           -- 次のエラー
      vim.keymap.set("n", "<Leader>ge", vim.diagnostic.open_float, opts)  -- 浮動窓で詳細表示
      vim.keymap.set("n", "<Leader>gl", vim.diagnostic.setqflist, opts)   -- 全エラーをリスト化

      -- 修正
      vim.keymap.set("n", "<Leader>f", function() vim.lsp.buf.format { async = true } end, opts) -- フォーマット
      vim.keymap.set("n", "<Leader>rn", vim.lsp.buf.rename, opts)         -- リネーム
      vim.keymap.set("n", "<Leader>ca", vim.lsp.buf.code_action, opts)    -- クイックフィックス

      -- 実行 (Leader + r)
      vim.keymap.set("n", "<Leader>r", M.run_python, opts)
    end,
  })
end

return M
