local M = {}

function M.setup()
  local bufnr = vim.api.nvim_get_current_buf()

  -- leader + h でテンプレート挿入
  vim.keymap.set("n", "<leader>h", function()
    local lines = {
      '<!DOCTYPE html>',
      '<html lang="ja">',
      '<head>',
      '  <meta charset="UTF-8">',
      '  <meta name="viewport" content="width=device-width, initial-scale=1.0">',
      '  <title>Document</title>',
      '</head>',
      '<body>',
      '',
      '</body>',
      '</html>',
    }
    -- バッファの先頭に挿入
    vim.api.nvim_buf_set_lines(bufnr, 0, 0, false, lines)
    -- カーソルを <body> の中（9行目付近）へ移動
    vim.api.nvim_win_set_cursor(0, { 9, 0 })
  end, { buffer = bufnr, desc = "Insert HTML template" })

  -- エンターキーでの自動閉じタグ挿入
  vim.keymap.set("i", "<CR>", function()
    local line = vim.api.nvim_get_current_line()
    local col = vim.api.nvim_win_get_cursor(0)[2]
    local before_cursor = line:sub(1, col)

    -- 直前のタグ名を取得する正規表現 (例: <div> -> div)
    local tag = before_cursor:match("<([%w%-]+)[^>]*>$")

    if tag then
      local indent = before_cursor:match("^%s*") or ""
      vim.schedule(function()
        -- 1行目: 開始タグのある行
        -- 2行目: インデントされた空行
        -- 3行目: 閉じタグ
        vim.api.nvim_put({
          "",
          indent .. "  ",
          indent .. "</" .. tag .. ">"
        }, "c", true, true)

        -- カーソルを真ん中の空行（インデント位置）へ移動
        local row, _ = table.unpack(vim.api.nvim_win_get_cursor(0))
        vim.api.nvim_win_set_cursor(0, { row - 1, #indent + 2 })
      end)
      -- デフォルトの改行を抑制するために空を返す
      return ""
    else
      -- タグ直後でなければ通常の改行
      return "<CR>"
    end
  end, { buffer = bufnr, expr = true, desc = "Auto close HTML tag on Enter" })
end

return M
