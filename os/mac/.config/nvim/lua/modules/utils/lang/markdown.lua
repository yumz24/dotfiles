local M = {}

-- プレビューの内容を更新し、スクロール位置を同期する関数
function M.refresh_glow_preview(preview_buf, preview_win)
  if not preview_win or not vim.api.nvim_win_is_valid(preview_win) then return end
  if not preview_buf or not vim.api.nvim_buf_is_valid(preview_buf) then return end

  -- 現在のバッファの全内容（未保存分を含む）を取得
  local content = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  -- 現在のカーソル行番号を取得
  local current_line = vim.api.nvim_win_get_cursor(0)[1]

  -- 標準入力（-）からテキストを受け取る設定でGlowを非同期実行
  local job = vim.system({ "glow", "-p", "-" }, { stdin = true, text = true }, function(obj)
    vim.schedule(function()
      if obj.code == 0 and obj.stdout then
        local lines = vim.split(obj.stdout, "\n", { plain = true })
        
        -- プレビューバッファの中身を書き換え
        vim.api.nvim_buf_set_option(preview_buf, 'modifiable', true)
        vim.api.nvim_buf_set_lines(preview_buf, 0, -1, false, lines)
        vim.api.nvim_buf_set_option(preview_buf, 'modifiable', false)

        -- スクロール同期処理
        local max_lines = vim.api.nvim_buf_line_count(preview_buf)
        local target_line = math.min(current_line, max_lines)
        
        -- プレビュー側のカーソル位置を調整し、表示をトップに合わせる
        vim.api.nvim_win_set_cursor(preview_win, { target_line, 0 })
        vim.api.nvim_buf_call(preview_buf, function()
          vim.cmd("normal! zt")
        end)
      end
    end)
  end)

  -- Glowの標準入力に現在のテキストを流し込む
  job:write(table.concat(content, "\n"))
  job:write(nil) 
end

-- メインの設定関数
function M.setup_markdown()
  local preview_buf = nil
  local preview_win = nil

  -- プレビュー起動コマンド
  vim.api.nvim_create_user_command("GlowPreview", function()
    local current_win = vim.api.nvim_get_current_win()
    
    -- バッファがなければ作成
    if not preview_buf or not vim.api.nvim_buf_is_valid(preview_buf) then
      preview_buf = vim.api.nvim_create_buf(false, true)
    end
    -- ウィンドウがなければ右側に作成
    if not preview_win or not vim.api.nvim_win_is_valid(preview_win) then
      vim.cmd("botright vsplit")
      preview_win = vim.api.nvim_get_current_win()
      vim.api.nvim_win_set_buf(preview_win, preview_buf)
    end

    -- バッファの属性を設定
    vim.api.nvim_buf_set_option(preview_buf, 'buftype', 'nofile')
    vim.api.nvim_buf_set_option(preview_buf, 'filetype', 'markdown')

    -- 最初の描画を実行
    M.refresh_glow_preview(preview_buf, preview_win)
    -- フォーカスを編集画面に固定
    vim.api.nvim_set_current_win(current_win)
  end, { desc = "Real-time Glow Preview" })

  -- テキスト変更、挿入モードでの入力、カーソル移動のたびにプレビューを更新
  vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI", "CursorMoved" }, {
    buffer = vim.api.nvim_get_current_buf(),
    callback = function()
      M.refresh_glow_preview(preview_buf, preview_win)
    end,
  })

  -- キーマップ設定
  local opts = { buffer = true, silent = true }
  vim.keymap.set("n", "<Leader>p", ":GlowPreview<CR>", opts)
end

return M
