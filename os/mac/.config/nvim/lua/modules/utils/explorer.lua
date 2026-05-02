local M = {}
local fn = vim.fn
local keymap_opts = { noremap = true, silent = true }

-- ----------------------------------------------------------------------------
-- Netrw トグル (File Explorer)
-- ----------------------------------------------------------------------------

local function is_netrw_open()
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local buf = vim.api.nvim_win_get_buf(win)
    -- バッファが有効であることとファイルタイプを確認
    if vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].filetype == "netrw" then
      return true, win
    end
  end
  return false
end

---@param vertical boolean 垂直分割 (Vsplit) で開くかどうか
---@param width number ウィンドウ幅 (デフォルト25)
function M.toggle_netrw(vertical, width)
  local netrw_open, netrw_win = is_netrw_open()

  if netrw_open then
    if #vim.api.nvim_list_wins() == 1 then
      vim.cmd("enew") -- Netrwが唯一のウィンドウの場合、新しい空バッファを開く
    elseif netrw_win then
      vim.api.nvim_win_close(netrw_win, true)
    end
  else
    if vertical then
      -- Netrwを配置(topleft: 一番左, botright: 一番右)
      vim.cmd("botright vsplit")
      vim.cmd("Explore")
      vim.g.netrw_browse_split = 4
    else
      -- Lexplore にすると、カレントウィンドウの左側にNetrwが開く
      vim.cmd("Lexplore")
      vim.g.netrw_browse_split = 0
    end
    vim.cmd("vertical resize " .. (width or 25))
  end
end

-- Netrw用キーマップ設定
function M.setup_netrw_autocmd()
  vim.api.nvim_create_autocmd("filetype", {
    pattern = "netrw",
    callback = function()
      -- 基本的なバインド用（標準機能を呼び出すもの）
      local bind = function(lhs, rhs)
        vim.keymap.set("n", lhs, rhs, { remap = true, buffer = true })
      end

      local function force_map(mode, lhs, rhs)
        vim.keymap.set(mode, lhs, rhs, { buffer = true, noremap = true, nowait = true, silent = true })
      end

      -- 既存の競合マッピングを削除
      pcall(vim.keymap.del, 'n', 'i', { buffer = true })
      pcall(vim.keymap.del, 'n', 'I', { buffer = true })

      force_map("n", "i", function()
        vim.bo.readonly = false
        vim.bo.modifiable = true
        local original_dir = vim.b.netrw_curdir

        -- %%を実行
        vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("%%", true, false, true), "m", false)

        -- BufEnterではなく、より広範囲なWinEnterと、少しの遅延(10ms)で確実に捕まえる
        vim.api.nvim_create_autocmd({ "WinEnter", "BufWinEnter" }, {
          once = true,
          callback = function()
            vim.defer_fn(function()
              -- Netrw以外のバッファに入っていたら処理開始
              if vim.bo.filetype ~= "netrw" then
                vim.opt.lazyredraw = true
                
                -- 保存、バッファ消去、ディレクトリ再表示
                vim.cmd("silent! write")
                vim.cmd("bwipeout!") 
                if original_dir then
                  vim.cmd("edit " .. original_dir)
                end
                
                vim.opt.lazyredraw = false
                vim.cmd("redraw!")
                -- 残像消去
                vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", false)
              end
            end, 10) -- 10ミリ秒だけ待つことで、Netrwの「バッファ表示」を完了させる
          end
        })
      end)

      force_map("n", "I", function()
        vim.bo.readonly = false
        vim.bo.modifiable = true
        -- Netrwのディレクトリ作成(d)を呼び出す
        vim.api.nvim_feedkeys("d", "m", false)
      end)

      force_map("n", "r", "R")    -- リフレッシュ

      -- ナビゲーション (直感的な移動)
      bind("h", "-")      -- 上の階層へ
      bind("l", "<CR>")   -- 開く
      bind(".", "gh")     -- 隠しファイルの表示切り替え

      local utils = require('modules.utils')
      bind("Sh", "<C-w>h")
      bind("Sj", "<C-w>j")
      bind("Sk", "<C-w>k")
      bind("Sl", "<C-w>l")
      bind("Sq", "<C-w>q")
      bind("Ss", "<C-w>s")
      bind("Sv", "<C-w>v")
      bind("Sw", utils.toggle_resize_mode)
      bind("St", utils.move_window_to_tab)
    end
  })
end

-- 関数を有効化
M.setup_netrw_autocmd()

return M
