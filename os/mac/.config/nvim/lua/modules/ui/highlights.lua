local M = {}

-- ハイライトグループの色定義 (全体で共通の色を定義)
local COLORS = {
  fg_default = "#d0d0d0",  -- 標準文字色 (未選択タブの文字色)
  fg_comment = "#8090a3",  -- コメント色
  fg_cyan = "#86cffc",     -- ソフトシアン/水色系 (選択タブの背景色, ファイル名強調)
  fg_green = "#50c878",    -- 緑系 (Keyword/Statement)
  fg_purple = "#b4b4ff",   -- 薄紫系 (Number/Boolean)
  fg_yellow = "#ffcc66",   -- 警告/TODO色 (オレンジ/黄色)
  bg_status = "#555555",   -- 濃い灰色 (ステータスライン/タブラインの背景色)
  bg_zenkaku = "#4a5568",  -- 全角スペースの背景色
}

local text_color = COLORS.fg_default
local hi = function(g, o) vim.api.nvim_set_hl(0, g, o) end

-- ============================================================================
-- ハイライトグループの定義
-- ============================================================================

--- ステータスラインとタブラインのハイライトグループを定義する
local function define_statusline_and_tabline_highlights()
  local dark_gray_bg = COLORS.bg_status
  local cyan_fg = COLORS.fg_cyan

  -- StatusLine / TabLine (共通の背景色)
  hi("StatusLine", { fg = "white", bg = dark_gray_bg })
  hi("StatusLineNC", { fg = "gray", bg = dark_gray_bg })
  hi("TabLine", { fg = text_color, bg = dark_gray_bg })
  hi("TabLineFill", { fg = "NONE", bg = "#000000" })
  hi("TabLineSel", { fg = "#000000", bg = cyan_fg, bold = true })

  -- StatusLine セグメント
  hi("StatusLineMode", { fg = "black", bg = "#398bb0", bold = true })
  hi("StatusLineGit", { fg = cyan_fg, bg = dark_gray_bg })
  hi("StatusLineFile", { fg = cyan_fg, bg = dark_gray_bg })
  hi("StatusLinePos", { fg = cyan_fg, bg = dark_gray_bg })

  -- 全角スペースとTodoに必要なハイライトもここで定義
  hi("ZenkakuSpace", { fg = "#ffffff", bg = COLORS.bg_zenkaku, nocombine = true })
  hi("Todo", { fg = COLORS.fg_yellow, bg = "NONE", bold = true })
end

--- 構文ハイライトグループを定義/上書きする
local function define_syntax_highlights()
  local error_highlight_color = COLORS.fg_yellow

  -- ベースカラー
  hi("Normal", { fg = COLORS.fg_default, bg = "NONE" })

  -- 構文グループの基本設定
  hi("Comment", { fg = COLORS.fg_comment, italic = true })
  hi("String", { fg = COLORS.fg_cyan })
  hi("Identifier", { fg = "#c7cfd8" })
  hi("Function", { fg = "#64b5f6", bold = true })
  hi("Keyword", { fg = COLORS.fg_green, bold = true })
  hi("Statement", { fg = COLORS.fg_green })
  hi("Conditional", { fg = COLORS.fg_green })
  hi("Repeat", { fg = COLORS.fg_green })
  hi("Type", { fg = "#93e1d8" })
  hi("Constant", { fg = "#93e1d8" })
  hi("Number", { fg = COLORS.fg_purple })
  hi("Boolean", { fg = COLORS.fg_purple, bold = true })
  hi("Operator", { fg = COLORS.fg_default })
  hi("Delimiter", { fg = "#cfcfcf" })
  hi("PreProc", { fg = COLORS.fg_green, bold = true })

  -- 言語固有の調整
  hi("pythonException", { fg = "#44b86a", bold = true })
  hi("pythonStatement", { fg = "#FF00FF" })
  hi("pythonDocString", { fg = "#8dd8ff", italic = true })
  hi("luaFunction", { link = "Function" })
  hi("luaBuiltin", { fg = "#93e1d8", bold = true })
  hi("luaConstant", { fg = "#93e1d8" })
  hi("luaStatement", { link = "Keyword" })
  hi("luaString", { link = "String" })
  hi("luaComment", { link = "Comment" })

  -- Markdown/スペルチェック
  vim.cmd("hi clear markdownError")
  hi("markdownError", { fg = error_highlight_color, sp = error_highlight_color, undercurl = true, bg = "NONE" })
  vim.cmd("hi clear markdownListMarker")
  hi("markdownListMarker", { fg = "#c7cfd8", bg = "NONE" })
  vim.cmd("hi clear markdownItalic")
  hi("markdownItalic", { fg = "#c7cfd8", bg = "NONE", italic = true })
  vim.cmd("hi clear markdownBold")
  hi("markdownBold", { fg = "#c7cfd8", bg = "NONE", bold = true })
  hi("SpellBad", { sp = COLORS.fg_yellow, undercurl = true })
end


-- ============================================================================
-- 実行時機能のセットアップ (自動コマンド)
-- ============================================================================
--- 全角スペース可視化機能のロジック
local function setup_zenkaku_highlighting()
  local zenkaku_match_id = nil

  local function highlight_zenkaku_space()
    if zenkaku_match_id and zenkaku_match_id > 0 then
      pcall(vim.fn.matchdelete, zenkaku_match_id)
      zenkaku_match_id = nil
    end
    -- ZenkakuSpace ハイライトグループを使用
    zenkaku_match_id = vim.fn.matchadd("ZenkakuSpace", [[\%u3000]], 10)
  end

  local grp_zenkaku = vim.api.nvim_create_augroup("HighlightZenkakuSpace", { clear = true })
  vim.api.nvim_create_autocmd(
    { "VimEnter", "WinEnter", "BufReadPost", "BufWinEnter", "InsertLeave", "ColorScheme" },
    { group = grp_zenkaku, callback = highlight_zenkaku_space }
  )
end

--- コメント内の TODO/FIXME/NOTE 強調機能のロジック
local function setup_todo_highlighting()
  local comment_prefix = [[(^\s*(#|//|--|;)\s*)]]
  local keywords = [[(TODO|FIXME|NOTE)]]
  local todo_pattern = ([[\v\c%s\zs%s]]):format(comment_prefix, keywords)

  local grp_todo = vim.api.nvim_create_augroup("HighlightTodo", { clear = true })
  vim.api.nvim_create_autocmd(
    { "VimEnter", "BufReadPost", "BufNewFile", "WinEnter", "ColorScheme" },
    {
      group = grp_todo,
      callback = function()
        if vim.b.todo_match then
          pcall(vim.fn.matchdelete, vim.b.todo_match)
        end
        -- Todo ハイライトグループを使用
        vim.b.todo_match = vim.fn.matchadd("Todo", todo_pattern, 10)
      end
    }
  )
end


-- ============================================================================
-- メインセットアップ関数
-- ============================================================================
function M.setup()
  -- ハイライトグループの定義
  define_statusline_and_tabline_highlights()
  define_syntax_highlights()

  -- 動的な機能のセットアップ
  setup_zenkaku_highlighting()
  setup_todo_highlighting()
end

return M
