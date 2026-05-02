" --- 基本ブートストラップ ----------------------------------------------------
let mapleader = " "

set nocompatible            " vi互換を切る
syntax enable               " シンタックスハイライト
filetype plugin on          " ファイルタイプ検出＋内蔵プラグイン有効化
set hidden                  " バッファ切替時の未保存でも保持
set number                  " 行番号
set relativenumber          " 相対行番号
set ruler                   " ステータスに行/列表示
set showcmd                 " 入力中コマンドを右下に表示
set laststatus=2            " ステータスライン常時表示
set autoread                " 外部更新されたファイルを自動再読込
" set undofile                " 永続アンドゥ
set mouse=a                 " マウス有効（不要なら削除）
set noswapfile              " swapfile無効化
set nobackup                " バックアップファイル作らない
set nowritebackup           " 上書き時もバックアップ作らない
set noundofile              " Undoファイルを作成しない

" --- Fuzzy File Search: :find 強化 -----------------------------------------
set path+=**                " サブディレクトリ再帰探索
set wildmenu
set wildmode=full
set wildignore=.git,.DS_Store,*node_modules/*,*vendor/*

" --- バッファ・タグ --------------------------------------------------------
set tags=./tags,tags;/      " タグファイル探索順
" タグジャンプ / 戻り
nnoremap <silent> ]q :cnext<CR>
nnoremap <silent> [q :cprevious<CR>
nnoremap <silent> cq :copen<CR>
nnoremap <silent> cQ :cclose<CR>

" --- Insert-mode Completion -------------------------------------------------
set completeopt=menu,menuone,noselect

" --- netrw 設定 -----------------------------------------------------------
let g:netrw_banner = 0
let g:netrw_liststyle = 3
let g:netrw_browse_split = 3
let g:netrw_altv = 1
let g:netrw_use_errorwindow = 0
let g:netrw_keepdir = 0
nnoremap <leader>e :Explore<CR>

" --- Snippets風（:readでテンプレ挿入） ------------------------------------
" nnoremap <silent> ,html :read ~/.vim/skeletons/skeleton.html<CR>3jwfa
" nnoremap <silent> ,py :read ~/.vim/skeletons/skeleton.py<CR>
" nnoremap <silent> ,rb :read ~/.vim/skeletons/skeleton.rb<CR>

" --- クリップボード ---------------------------------------------------------
set clipboard+=unnamed

" --- 検索・編集の快適設定 -----------------------------------------------
set ignorecase
set smartcase
set incsearch
set hlsearch
set expandtab               " タブをスペースに変換
set shiftwidth=2            " 自動インデント幅
set tabstop=2               " タブ幅表示
set smartindent
" ノーマルモードで Esc を2回押すと :nohlsearch 実行
nnoremap <Esc><Esc> :nohlsearch<CR>

" --- 表示・操作 ---------------------------------------------------------
set cursorline              " カーソル行をハイライト
set showmatch               " 括弧対応表示
set scrolloff=3             " カーソル周りの余白（3行分）
set sidescrolloff=5         " 横スクロール余白
set numberwidth=4           " 行番号幅

" --- バックアップ / 履歴 -------------------------------------------------
" set backup                   " バックアップファイルを作る
" set backupdir=~/.vim/backup
" set history=1000             " コマンド履歴保存数
" set undodir=~/.vim/undo      " 永続アンドゥ保存先

" --- 検索 ---------------------------------------------------------------
set wrap                    " 行を折り返す（不要なら off）
set linebreak               " 折り返し時に単語単位で改行

" 全角スペースを視認しやすくハイライト
" ハイライトグループを定義（背景を薄赤、文字を白など。色は好みで調整）
highlight ZenkakuSpace ctermfg=White ctermbg=LightRed guifg=#ffffff guibg=#ff8a8a

" 画面内の全角スペース（U+3000）にハイライトを適用
" \%u3000 は 'very nomagic' でのUnicodeコードポイント指定
augroup HighlightZenkakuSpace
  autocmd!
  " すべてのバッファで適用。必要に応じて filetype 条件で絞る
  autocmd VimEnter,WinEnter,BufReadPost,BufWinEnter * call s:highlight_zenkaku_space()
  " 行編集後の再描画で崩れないよう、InsertLeaveでも再適用
  autocmd InsertLeave * call s:highlight_zenkaku_space()
augroup END

function! s:highlight_zenkaku_space() abort
  " 既存のハイライトを重複作成しないように一度クリア
  call s:clear_zenkaku_space()
  " 画面全体に対して全角スペースをマッチさせる
  " \%u3000 は1文字の全角スペース。必要なら末尾/行頭のみなどに制限可能。
  let s:zenkaku_match_id = matchadd('ZenkakuSpace', '\%u3000', 10)
endfunction

function! s:clear_zenkaku_space() abort
  if exists('s:zenkaku_match_id') && s:zenkaku_match_id > 0
    try
      call matchdelete(s:zenkaku_match_id)
    catch /.*/
      " すでに削除済み等は無視
    endtry
    unlet s:zenkaku_match_id
  endif
endfunction

" --- フォールバック / 高速化 ---------------------------------------------
" 巨大リポジトリでは path/wildignore調整や `:set lazyredraw` などを検討

" --- よく使うキーバインド -----------------------------------------------
" タグジャンプ       Ctrl-]
" タグ候補一覧       g Ctrl-]
" タグ戻り           Ctrl-T
" 補完（総合）       Ctrl-N / Ctrl-P
" 補完（このバッファ）Ctrl-X Ctrl-N
" 補完（ファイル名）  Ctrl-X Ctrl-F
" Quickfix 次/前      :cnext / :cprevious
" Quickfix リスト     :copen / :cclose
" Netrw               :Edit . → ツリー操作
