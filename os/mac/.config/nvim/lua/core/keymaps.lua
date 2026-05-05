local M = {}

local map = vim.keymap.set

local function opts(desc, extra_opts)
  local base = { noremap = true, silent = true, desc = desc }
  if extra_opts then
    base = vim.tbl_extend("force", base, extra_opts)
  end
  return base
end

function M.setup()
  -- --- [ Editing ] ---
  -- ビジュアルブロックモードへの切り替え
  map("v", "v", "<C-v>", opts("Visual block mode"))
  -- 全選択
  map("v", ",", "<Esc>ggVG", opts("Select all"))
  -- インサートモード脱出
  -- map("i", "jj", "<Esc>", opts("Exit insert mode"))
  -- インデント後に選択状態を維持
  map("v", "<", "<gv", opts("Indent left and reselect"))
  map("v", ">", ">gv", opts("Indent right and reselect"))
  -- 選択行の上下移動
  map("v", "J", ":m '>+1<CR>gv=gv", opts("Move selection down"))
  map("v", "K", ":m '<-2<CR>gv=gv", opts("Move selection up"))
  -- 全体のインデントを整形
  map("n", "<leader>fi", "gg=G<C-o>", opts("Fix indentation"))

  -- --- [ System Clipboard ] ---
  -- システムクリップボードとのやり取り
  map("n", "<leader>y", '"+y', opts("Yank to system clipboard"))
  map("v", "<leader>y", '"+y', opts("Yank selection to system clipboard"))
  map("n", "<leader>p", '"+p', opts("Paste from system clipboard"))

  -- --- [ Registers / Safe Delete ] ---
  -- map("n", "dd", '"_dd', opts("Delete line (no yank to register)"))
  -- map("n", "dw", '"_dw', opts("Delete word (no yank to register)"))
  -- map("n", "D", '"_D', opts("Delete to end of line (no yank to register)"))
  map("n", "x", '"_x', opts("Delete character (no yank to register)"))
  -- map("v", "d", '"_d', opts("Delete selection (no yank to register)"))
  -- map("v", "x", '"_x', opts("Delete selection via x (no yank to register)"))
  -- ビジュアルモードでペーストした時にレジスタを上書きしない
  map("v", "p", '"_dP', opts("Paste without overwriting register"))

  -- --- [ Navigation / Scroll ] ---
  -- スクロール時にカーソルを中央に固定
  map("n", "<C-d>", "<C-d>zz", opts("Scroll down and center"))
  map("n", "<C-u>", "<C-u>zz", opts("Scroll up and center"))
  -- 検索移動時にカーソルを中央に固定
  map("n", "n", "nzzzv", opts("Search next and center"))
  map("n", "N", "Nzzzv", opts("Search prev and center"))
  -- 検索ハイライトの消去
  map("n", "<Esc><Esc>", ":nohlsearch<CR>", opts("Clear search highlights"))
  -- ジャンプリスト移動（戻る・進む）
  map("n", "[j", "<C-o>", opts("Jump backward"))
  map("n", "]j", "<C-i>", opts("Jump forward"))

  -- --- [ Buffer Management ] ---
  -- バッファ移動
  map("n", "[b", ":bprevious<CR>", opts("Previous buffer"))
  map("n", "]b", ":bnext<CR>", opts("Next buffer"))
  -- 直前のバッファに戻る
  map("n", "<leader>bb", "<C-^>", opts("Switch to last buffer"))
  -- バッファ一覧を表示して選択待ちにする
  map("n", "<leader>bl", ":ls<CR>:b ", opts("List and open buffer"))

  -- --- [ Quickfix ] ---
  map("n", "]q", ":cnext<CR>", opts("Quickfix: Next item"))
  map("n", "[q", ":cprevious<CR>", opts("Quickfix: Previous item"))
  -- Quickfixの開閉トグル
  map("n", "<leader>q", function()
    local qf_exists = false
    for _, win in pairs(vim.fn.getwininfo()) do
      if win["quickfix"] == 1 then qf_exists = true end
    end
    if qf_exists then vim.cmd("cclose") else vim.cmd("copen") end
  end, opts("Toggle Quickfix window"))
  map("n", "<leader>qx", ":QfClear<CR>", opts("Quickfix: Clear list"))

  -- --- [ Search & Replace ] ---
  -- カーソル下の単語を即座に置換モードへ
  map("n", "<leader>rs", ":%s/\\<<C-r><C-w>\\>/", { desc = "Replace word under cursor" })

  -- --- [ Tag / Symbol ] ---
  -- タブジャンプ（定義ジャンプ等）
  map("n", "]t", "<C-]>", opts("Jump to tag"))
  map("n", "[t", "<C-T>", opts("Jump back from tag"))

  -- --- [ Tab & External ] ---
  -- URLやファイルパスを外部ブラウザ/アプリで開く
  map("n", "gx", '<Cmd>execute "silent !open " . shellescape(expand("<cfile>"), 1)<CR>', opts("Open URL/File"))
  -- タブ操作
  map("n", "gh", "gT", opts("Previous tab"))
  map("n", "gl", "gt", opts("Next tab"))
  map("n", "gk", ":tabedit <CR>", opts("New tab"))
  -- map("n", "gK", utils.open_tab_with_input, opts("New tab with input"))

  -- バッファ/タブを閉じる
  map("n", "gj", ":bdelete<CR>", opts("Close buffer"))
  map("n", "gJ", ":bdelete!<CR>", opts("Force close buffer"))

  -- lib/utils からの呼び出し (関数の実体は lib に隠蔽)
  map('n', '<Leader>t', function()
    require("lib.utils.editor").toggle_term()
  end, opts("Toggle terminal"))

  map('n', '<C-w>r', function()
    require("lib.core.window").toggle_resize_mode()
  end, opts("Toggle terminal"))

  -- 標準ファイラ (netrw)
  map("n", "<leader>e", function()
    require("lib.feature.explorer").toggle_netrw(true)
  end, opts("Toggle Explorer"))

  -- メッセージ表示バッファ
  map('n', '<Leader>m', function()
    require("lib.utils.editor").show_messages()
  end, opts("View Vim messages with path shortening"))
end

return M
