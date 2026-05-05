local M = {}

function M.setup()
  local group = vim.api.nvim_create_augroup("CoreAutocmds", { clear = true })

  -- Terminal mode settings
  vim.api.nvim_create_autocmd("TermOpen", {
    group = group,
    callback = function(args)
      -- バッファが表示されているウィンドウIDを取得
      local bufnr = args.buf

      local wo = vim.wo[0]
      wo.number = true
      wo.relativenumber = true
      wo.signcolumn = 'no'
      vim.keymap.set('t', '<Esc>', [[<C-\><C-n>]], {
        buffer = bufnr,
        nowait = true,
        desc = "Exit terminal mode with Esc"
      })
    end,
    desc = "Apply settings for terminal buffers"
  })

  vim.api.nvim_create_autocmd("TermClose", {
    group = group,
    pattern = "*",
    callback = function()
      -- 外部でのファイル変更を同期
      vim.cmd("checktime")
      -- 前のウィンドウにフォーカスを戻す
      vim.cmd("wincmd p")
    end,
    desc = "Return to previous window and check file updates on terminal close.",
  })

  -- --- [ Language Specific Loader ]
  -- 各言語（FileType）に対応する lib/lang/*.lua を自動で読み込む
  vim.api.nvim_create_autocmd("FileType", {
    group = group,
    pattern = { "html", "markdown", },
    callback = function(args)
      local ft = args.match
      local ok, lang = pcall(require, "lib.lang." .. ft)
      if ok and lang.setup then
        lang.setup()
      end
    end,
    desc = "Load language specific settings from lib/lang/"
  })
  -- Netrwの自動設定を起動
  vim.api.nvim_create_autocmd("filetype", {
    pattern = "netrw",
    callback = function()
      local exp = require('lib.feature.explorer')
      exp.setup_netrw_settings()
    end
  })

  vim.api.nvim_create_autocmd("TextChangedI", {
    callback = function()
      -- LSPがないなら何もしない
      if #vim.lsp.get_clients({ bufnr = 0 }) == 0 then
        return
      end

      -- すでにポップアップ出てたら無視
      if vim.fn.pumvisible() == 1 then
        return
      end

      -- 英数字入力時だけ
      local line = vim.api.nvim_get_current_line()
      local col = vim.fn.col(".")
      local char = line:sub(col - 1, col - 1)

      if char:match("[%w_]") then
        vim.lsp.completion.get()
      end
    end,
  })
end

return M
