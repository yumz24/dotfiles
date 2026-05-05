local M = {}

-- Netrwが開いているか確認
local function is_netrw_open()
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local buf = vim.api.nvim_win_get_buf(win)
    if vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].filetype == "netrw" then
      return true, win
    end
  end
  return false
end

-- Netrwのトグル
function M.toggle_netrw(vertical, width)
  local netrw_open, netrw_win = is_netrw_open()
  if netrw_open then
    if #vim.api.nvim_list_wins() == 1 then
      vim.cmd("enew")
    elseif netrw_win then
      vim.api.nvim_win_close(netrw_win, true)
    end
  else
    if vertical then
      vim.cmd("botright vsplit | Explore")
    else
      vim.cmd("Lexplore")
    end
    vim.cmd("vertical resize " .. (width or 25))
  end
end

-- Netrw専用のキーバインド設定
function M.setup_netrw_settings()
  local bind = function(lhs, rhs) 
    vim.keymap.set("n", lhs, rhs, { remap = true, buffer = true }) 
  end
  
  -- 直感的な移動
  bind("h", "-")     -- 左で戻る
  bind("l", "<CR>")  -- 右で入る
  bind(".", "gh")    -- ドットで隠しファイル
end

return M
