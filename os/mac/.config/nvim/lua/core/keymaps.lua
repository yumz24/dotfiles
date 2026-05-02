local M = {}
local map = vim.keymap.set

local function opts(desc, extra_opts)
  local base = { noremap = true, silent = true, desc = desc }
  if extra_opts then
    -- extra_opts (exprなど) があれば統合する
    base = vim.tbl_extend("force", base, extra_opts)
  end
  return base
end

local ft_keymaps = {
  python = { run = "RunPython", lint = "LintPython" },
  rust = { run = "RunRust", lint = "LintRust", fmt = "FmtRust", },
}

function M.setup()
  local utils = require('modules.utils')
  if type(utils) ~= 'table' then return end

  -- --- [ 基本操作 ] ---
  map("n", "<Esc><Esc>", ":nohlsearch<CR>", opts("Clear search highlights"))
  map("n", "x", '"_x', opts("Delete character without saving to register"))
  map("n", "<leader>d", '"_dd', opts("Delete line without saving to register"))
  map("v", "<leader>d", '"_d', opts("Delete selection without saving to register"))
  map("n", "<space><CR>", "o<esc>", opts("Insert a new line below"))
  map("n", "+", "<C-a>", opts("Increment"))
  map("n", "-", "<C-x>", opts("Decrement"))
  map("n", "U", "<c-r>", opts("Redo"))

  -- --- [ ファイル / 保存 ] ---
  map("n", "<leader>w", ':w<CR>', opts("Save File"))
  map("n", "<leader>q", ':q<CR>', opts("Quit Buffer"))
  map("n", "<leader>Q", ':qa!<CR>', opts("Quit All (Force)"))

  -- --- [ Quickfix ] ---
  map("n", "]q", ":cnext<CR>", opts("Quickfix: Next error"))
  map("n", "[q", ":cprevious<CR>", opts("Quickfix: Previous error"))
  map("n", "cq", ":copen<CR>", opts("Quickfix: Open List"))
  map("n", "cQ", ":cclose<CR>", opts("Quickfix: Close List"))
  map("n", "<leader>c<space>", ':QfClear<CR>', opts("Quickfix: Clear List"))

  -- --- [ ツール (Netrw / Terminal) ] ---
  map("n", "<leader>e", function() utils.toggle_netrw(true, 25) end, opts("Toggle Netrw"))
  map("n", "<leader>t", utils.toggle_term, opts("Toggle terminal (Bottom)"))
  map("n", "<leader>T", utils.toggle_term, opts("Toggle terminal (Alias)"))

  -- --- [ ウィンドウ操作 (S + ...) ] ---
  map("n", "Sh", "<C-w>h", opts("Move to left window"))
  map("n", "Sj", "<C-w>j", opts("Move to below window"))
  map("n", "Sk", "<C-w>k", opts("Move to above window"))
  map("n", "Sl", "<C-w>l", opts("Move to right window"))
  map("n", "Sw", "<C-w>w", opts("Move to next window"))
  map("n", "Sq", "<C-w>q", opts("Close window"))
  map("n", "Ss", "<C-w>s", opts("Split horizontal"))
  map("n", "Sv", "<C-w>v", opts("Split vertical"))
  map("n", "Sr", utils.toggle_resize_mode, opts("Toggle resize mode"))
  map("n", "St", utils.move_window_to_tab, opts("Move window to new tab"))

  -- --- [ タブ操作 (g + ...) ] ---
  map("n", "gh", "gT", opts("Previous tab"))
  map("n", "gl", "gt", opts("Next tab"))
  map("n", "gk", ":tabedit <CR>", opts("New tab"))
  map("n", "gK", utils.open_tab_with_input, opts("New tab with input"))
  map("n", "gj", ":bdelete<CR>", opts("Close buffer/tab"))
  map("n", "gJ", ":bdelete!<CR>", opts("Force close buffer/tab"))

  -- --- [ 移動 / スクロール ] ---
  map("n", "j", "gj", opts("Move by display line"))
  map("n", "k", "gk", opts("Move by display line"))
  map("n", "H", "^", opts("Move to start of line"))
  map("n", "L", "$", opts("Move to end of line"))
  map("n", "W", "b", opts("Move back word"))
  map("n", "E", "ge", opts("Move back word end"))
  map("n", "zk", "zb", opts("Scroll to bottom"))
  map("n", "zj", "zt", opts("Scroll to top"))
  map("n", "<C-d>", "<C-d>zz", opts("Scroll down and center"))
  map("n", "<C-u>", "<C-u>zz", opts("Scroll up and center"))
  map("n", "n", "nzzzv", opts("Search next and center"))
  map("n", "N", "Nzzzv", opts("Search prev and center"))

  -- --- [ タグ ] ---
  map("n", "tl", "<C-]>", opts("Jump to tag"))
  map("n", "th", "<C-T>", opts("Jump back from tag"))

  -- --- [ Git (External) ] ---
  -- ファイルパスをクォートで囲むことでスペースに対応
  local current_file = '"' .. vim.fn.expand('%:p') .. '"'
  map("n", "<Leader>gb", ":tabnew | read !git blame -L <C-R>=line('.')<CR>,<C-R>=line('.')<CR> " .. current_file .. "<CR>", opts("Git blame line"))
  map("n", "<Leader>gB", ":tabnew | read !git blame " .. current_file .. "<CR>", opts("Git blame file"))
  map("n", "<Leader>gl", ":tabnew | read !git log --oneline -- " .. current_file .. "<CR>", opts("Git log file"))

  -- --- [ モード別 / その他 ] ---
  map('v', 'v', '<C-v>', opts("Visual block mode"))
  map('v', ',', '<Esc>ggVG', opts("Select all"))
  map('i', 'jj', '<Esc>', opts("Exit insert mode"))

  -- Enterではコメント継続しない
  -- map("i", "<Enter>", function()
  --   vim.opt.formatoptions:remove("r")
  --   return "<Enter>"
  -- end, opts("Insert mode Enter"))
  --
  -- コメント継続用 Enter（明示的）
  map( "i", "<C-j>", "<Esc>o", opts("comment: continue comment with newline"))

  -- --- [ 補完メニュー操作 ] ---
  local comp_extra = { expr = true, replace_keycodes = true }
  map('i', '<Tab>', function()
    return vim.fn.pumvisible() ~= 0 and "<C-y>" or "<Tab>"
  end, opts("Confirm selection", comp_extra))

  map('i', '<Esc>', function()
    if vim.fn.pumvisible() ~= 0 then
      return "<C-e><Esc>"
    end
    return "<Esc>"
  end, opts("Close completion menu or Return to Normal mode", comp_extra))

  -- メッセージ表示バッファ
  map('n', '<Leader>m', function()
    local buf_name = "[Vim Messages]"
    local desired_height = 12
    
    -- すでに同名のバッファが開いているウィンドウがあれば閉じる、
    -- またはバッファ自体を削除してクリーンにする
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
      if vim.api.nvim_buf_get_name(buf):find(buf_name, 1, true) then
        vim.api.nvim_buf_delete(buf, { force = true })
      end
    end

    -- 新しいバッファを作成して開く
    vim.cmd("belowright" .. desired_height .. "new")
    local cur_buf = vim.api.nvim_get_current_buf()
    local cur_win = vim.api.nvim_get_current_win()

    vim.api.nvim_buf_set_name(cur_buf, buf_name)
    
    -- オプション設定
    vim.bo[cur_buf].buftype = "nofile"
    vim.bo[cur_buf].bufhidden = "wipe"
    vim.bo[cur_buf].swapfile = false
    vim.wo[cur_win].wrap = false
    
    -- メッセージを取得
    local messages = vim.api.nvim_exec("messages", true)
    
    -- パス短縮処理 (既存ロジック)
    local home = os.getenv("HOME")
    if home then
      local escaped_home = home:gsub("([^%w])", "%%%1")
      messages = messages:gsub(escaped_home, "~")
    end

    -- 書き込み
    local lines = vim.split(messages, "\n")
    vim.api.nvim_buf_set_lines(cur_buf, 0, -1, false, lines)
    
    -- 最下行にスクロール (最新メッセージが見えるように)
    vim.cmd("normal! G")
  end, opts("View Vim messages with path shortening"))

  vim.api.nvim_create_autocmd("FileType", {
    callback = function(ev)
      local cfg = ft_keymaps[ev.match]
      if not cfg then return end
      local b_opts = { buffer = ev.buf, noremap = true, silent = true }
      
      if cfg.run then map("n", "<F5>", ":" .. cfg.run .. "<CR>", vim.tbl_extend("force", b_opts, { desc = "Run file" })) end
      if cfg.lint then map("n", "<Leader>l", ":" .. cfg.lint .. "<CR>", vim.tbl_extend("force", b_opts, { desc = "Lint file" })) end
      if cfg.fmt then map("n", "<Leader>f", ":" .. cfg.fmt .. "<CR>", vim.tbl_extend("force", b_opts, { desc = "Format file" })) end
    end
  })
end

return M
