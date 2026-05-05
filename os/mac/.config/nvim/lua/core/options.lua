local opt = vim.opt

-- --- [ エンコーディング ] ---
vim.scriptencoding = 'utf-8'
-- neovimだと非推奨の設定らしい
-- opt.encoding = 'utf-8'
-- opt.fileencoding = 'utf-8'

-- --- [ 表示 / 外観 ] ---
opt.termguicolors = true
opt.number = true
opt.relativenumber = true
opt.signcolumn = "yes"
opt.cursorline = true
-- ウィンドウを分割してもステータスラインを1本に統合
opt.laststatus = 3
opt.cmdheight = 1
opt.showtabline = 2
-- カーソル周りの余白
opt.scrolloff = 8
opt.sidescrolloff = 8

-- --- [ テキスト編集 / 折り返し ] ---
opt.wrap = true          -- 行を折り返す
opt.linebreak = true     -- 単語の途中で切れないように折り返す
opt.breakindent = true   -- 折り返し後のインデントを維持する

-- --- [ インデント / タブ ] ---
opt.expandtab = true
opt.shiftwidth = 2
opt.tabstop = 2
opt.smartindent = true

-- --- [ 検索 ] ---
opt.ignorecase = true
opt.smartcase = true
opt.hlsearch = true
opt.inccommand = "split"
opt.shortmess:remove('S')

-- --- [ 挙動 / システム ] ---
opt.mouse = "a"
-- クリップボード: unnamedplus を推奨（OSの標準レジスタと同期）
-- opt.clipboard:append("unnamedplus")
opt.clipboard = "unnamedplus"
opt.timeoutlen = 500
opt.updatetime = 200
opt.swapfile = false
opt.backup = false
opt.writebackup = false
-- 永続Undo: ファイルを閉じても変更履歴を保持
opt.undofile = true

-- --- [ 補完 / ファイル操作 ] ---
opt.shortmess:append("c")
opt.completeopt = { "menuone", "noselect", "noinsert" }
opt.wildmode = "longest:full,full"
opt.path:append("**")
opt.wildmenu = true
opt.hidden = true
opt.wildmode = "list:longest,full"
opt.wildoptions = "pum"
opt.isfname:append("@-@")

-- --- [ Netrw (標準ファイラ) ] ---
vim.g.netrw_browse_split = 0
vim.g.netrw_altv = 1
vim.g.netrw_banner = 0
vim.g.netrw_liststyle = 3
