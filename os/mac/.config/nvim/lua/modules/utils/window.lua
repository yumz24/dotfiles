local M = {}
local fn = vim.fn
local keymap_opts = { noremap = true, silent = true }

-- ----------------------------------------------------------------------------
-- リサイズモード機能 (Resize Mode)
-- ----------------------------------------------------------------------------
-- ウィンドウリサイズモードの状態を保持
M.resize_mode = false

-- ウィンドウを指定方向へリサイズ
local function resize_window(direction)
  local commands = {
    h = "vertical resize +2",
    l = "vertical resize -2",
    j = "resize +2",
    k = "resize -2",
  }
  vim.cmd(commands[direction] or "")
end

-- リサイズ用のキーマップを設定 (ローカル関数)
local function set_mappings()
  -- buffer = true を指定して、現在の画面だけで一時的に最強の優先度を持たせる
  local b_opts = vim.tbl_extend("force", keymap_opts, { buffer = true })

  -- リサイズキー
  vim.keymap.set('n', 'h', function() resize_window("h") end, b_opts)
  vim.keymap.set('n', 'j', function() resize_window("j") end, b_opts)
  vim.keymap.set('n', 'k', function() resize_window("k") end, b_opts)
  vim.keymap.set('n', 'l', function() resize_window("l") end, b_opts)

  -- 終了キー (Esc)
  -- 元の <Esc><Esc> などを一時的に無効化し、このトグル関数を割り当てる
  vim.keymap.set('n', '<Esc><Esc>', '<Nop>', b_opts)

  vim.keymap.set('n', '<Esc>', M.toggle_resize_mode, b_opts)
  vim.keymap.set('n', '<C-[>', M.toggle_resize_mode, b_opts)
end

-- リサイズ用のキーマップを解除 (ローカル関数)
local function remove_mappings()
  -- buffer = true のマッピングを削除して元に戻す
  local b_opts = { buffer = true }
  local keys = { '<Esc>', '<C-[>', '<Esc><Esc>', 'h', 'j', 'k', 'l' }
  for _, key in ipairs(keys) do
    pcall(vim.keymap.del, 'n', key, b_opts)
  end

  -- Netrw内にいる場合は、Netrw用の移動キーを再設定する
  if vim.bo.filetype == 'netrw' then
    -- ここで explorer.setup_netrw_autocmd() を再度呼ぶか、必要なキーを再定義
    local exp = require('modules.utils.explorer')
    if exp and exp.setup_netrw_autocmd then
      exp.setup_netrw_autocmd()
    end
  end

  local utils = require('modules.utils')
  if utils and utils.limit_hjkl_repetition then
    utils.limit_hjkl_repetition()
  end
end

-- リサイズモードのトグル関数をエクスポート
function M.toggle_resize_mode()
  if M.resize_mode then
    M.resize_mode = false
    remove_mappings()
    vim.notify("Resize mode OFF", vim.log.levels.INFO)
  else
    M.resize_mode = true
    set_mappings()
    vim.notify("Resize mode ON (hjkl: resize, Esc: exit)", vim.log.levels.INFO)
  end
end

-- 現在のウィンドウを新しいタブに移動
function M.move_window_to_tab()
  vim.cmd("tabnew")    -- 新しいタブを作成
  vim.cmd("wincmd w")  -- 新しいタブに移動
  vim.cmd("buffer #")  -- 直前のバッファ（現在のウィンドウのバッファ）を移動
end

-- 入力したファイル名で新しいタブを開く
function M.open_tab_with_input()
  local ok, filename = pcall(vim.fn.input, "Open File (Tab to complete): ", "", "file")

  if not ok then return end

  if filename ~= "" then
    vim.cmd("tabedit " .. filename)
  end
end

-- Quickfix windowを一番下で表示する
function M.open_qf_at_bottom()
    -- Quickfix が開いていない場合のみ開く
    if vim.fn.getqflist({ winid = 0 }).winid == 0 then
        -- 下に 10 行で開く
        vim.cmd("botright 10 copen")
    else
        -- 既に開いていれば再描画
        vim.cmd("cwindow")
    end
end

-- ターミナルをトグル表示する関数
function M.toggle_term()
  local term_buf = nil

  -- 既存のターミナルバッファを探す
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    -- バッファが有効であり、かつ名前が 'term://' で始まるとき
    if vim.api.nvim_buf_is_valid(buf) and vim.api.nvim_buf_get_name(buf):match("^term://") then
      term_buf = buf
      break
    end
  end

  if term_buf then
    -- 既存ターミナルがあれば、そのバッファを削除（ウィンドウも閉じる）
    vim.cmd("bdelete! " .. term_buf)
  else
    -- なければ下分割で開く
    vim.cmd("botright split | resize 12 | terminal")
  end
end

return M
