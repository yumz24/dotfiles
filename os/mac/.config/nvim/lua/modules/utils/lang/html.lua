local M = {}

-- leader + h でテンプレート挿入
function M.setup_html_mappings()
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
        vim.api.nvim_buf_set_lines(0, 0, 0, false, lines)
    end, { buffer = 0, noremap = true, silent = true })
end

-- エンターキーでの自動閉じタグ挿入
function M.setup_html_autoclose()
    vim.keymap.set("i", "<CR>", function()
      local line = vim.api.nvim_get_current_line()
      local col = vim.api.nvim_win_get_cursor(0)[2]
      local before_cursor = line:sub(1, col)
      
      if m then
        local indent = before_cursor:match("^%s*") or ""
            vim.schedule(function()
                vim.api.nvim_set_current_line(before_cursor)
                vim.api.nvim_put(
                    { 
                      indent .. "  ", 
                      indent .. "</" .. m .. ">"
                    },
                    "l",
                    true,
                    true
                )
                vim.api.nvim_win_set_cursor(
                  0, 
                  {
                      vim.api.nvim_win_get_cursor(0)[1] - 1, #indent + 2
                  }
                )
            end)
            return ""
        else
            return "\n"
        end
    end, { buffer = 0, expr = true, noremap = true })
end

return M
