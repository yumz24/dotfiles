local M = {}

function M.setup()
  local utils = require('modules.utils')
  if type(utils) ~= 'table' then return end

  local timer = vim.loop.new_timer()

  -- メインの autocmd グループ
  local group = vim.api.nvim_create_augroup("ModuleAutocmds", { clear = true })

  -- ターミナルウィンドウ設定 (開いた時)
  vim.api.nvim_create_autocmd("TermOpen", {
    group = group,
    callback = function()
      vim.opt_local.number = true
      vim.opt_local.relativenumber = false
      vim.opt_local.signcolumn = 'no'
      -- <Esc> でノーマルモードに戻る
      vim.api.nvim_buf_set_keymap(0, 't', '<Esc>', [[<C-\><C-n>]], { noremap = true })
    end
  })

  -- ターミナルウィンドウ設定 (閉じた時)
  vim.api.nvim_create_autocmd("TermClose", {
    group = group,
    pattern = "*",
    callback = function()
      vim.cmd("checktime")
      vim.cmd("wincmd p")
    end,
    desc = "Return to previous window and check file updates on terminal close.",
  })

  -- HTML 関連設定 (utils/lang/html.lua に逃がした関数を呼ぶ)
  vim.api.nvim_create_autocmd("FileType", {
    group = group,
    pattern = "html",
    callback = function()
      utils.setup_html_mappings()
      utils.setup_html_autoclose()
    end
  })

  vim.api.nvim_create_autocmd("FileType", {
    group = group,
    pattern = "markdown",
    callback = function()
      utils.setup_markdown()
    end
  })

  -- エディタ操作制限 (utils/editor.lua に逃がした関数を呼ぶ)
  -- vim.api.nvim_create_autocmd("FileType", {
  --   group = group,
  --   callback = utils.limit_hjkl_repetition
  -- })

  -- [Template] 新規ファイル読み込み時の基本設定
  vim.api.nvim_create_autocmd({ "BufNewFile", "BufReadPost" }, {
    group = group,
    callback = function()
      -- 必要に応じて追加
    end,
  })

  -- 自動補完リスト表示
  vim.api.nvim_create_autocmd("InsertCharPre", {
    callback = function()
      -- 補完中なら何もしない
      if vim.fn.pumvisible() ~= 0 then return end

      -- 入力中の文字が「空白以外」なら補完
      if vim.v.char:match("%S") then
        vim.schedule(function()
          if vim.api.nvim_get_mode().mode == 'i' and vim.fn.pumvisible() == 0 then
            vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<C-n>", true, false, true), "n", true)
          end
        end)
      end
    end,
  })

  vim.api.nvim_create_autocmd("TextChangedI", {
    callback = function()
      -- 既存のメニュー表示中やマクロ実行中は即座に抜ける（最速パス）
      if vim.fn.pumvisible() ~= 0 or vim.fn.reg_recording() ~= "" then return end

      -- タイマーをリセット（打ち続けている間は発動させない）
      timer:stop()
      timer:start(80, 0, vim.schedule_wrap(function() -- 80ms待機
        if vim.api.nvim_get_mode().mode ~= 'i' then return end

        local line = vim.api.nvim_get_current_line()
        local col = vim.api.nvim_win_get_cursor(0)[2]
        local prefix = line:sub(1, col)

        -- 末尾が「英数字・ドット・コロン」かつ「2文字以上」の場合のみ発動
        if not prefix:match("[%w.:][%w.:]$") then return end

        local keys = ""
        local ft = vim.bo.filetype
        if ft == "rust" then
          if vim.bo.omnifunc ~= "" then
            keys = "<C-x><C-o>"
          end
        else
          keys = "<C-x><C-n>"
        end

        if keys ~= "" then
          vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(keys, true, false, true), "in", false)
        end
      end))
    end,
  })
end

return M
