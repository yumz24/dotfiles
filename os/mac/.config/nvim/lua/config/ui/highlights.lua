local M = {}

-- ============================================================================
-- ハイライトグループの色定義
-- ============================================================================
local COLORS = {
  fg_default = "#d0d0d0",
  fg_comment = "#8090a3",
  fg_cyan    = "#86cffc",
  fg_green   = "#50c878",
  fg_purple  = "#b4b4ff",
  fg_yellow  = "#ffcc66",
  bg_status  = "#555555",
  bg_zenkaku = "#4a5568",
}

local hi = function(g, o) vim.api.nvim_set_hl(0, g, o) end

-- ============================================================================
-- セクション定義
-- ============================================================================

local function define_ui_highlights()
  local bg = COLORS.bg_status
  local cyan = COLORS.fg_cyan

  hi("StatusLine", { fg = "white", bg = bg })
  hi("StatusLineNC", { fg = "gray", bg = bg })
  hi("TabLine", { fg = COLORS.fg_default, bg = bg })
  hi("TabLineFill", { fg = "NONE", bg = "#000000" })
  hi("TabLineSel", { fg = "#000000", bg = cyan, bold = true })

  hi("StatusLineMode", { fg = "black", bg = "#398bb0", bold = true })
  hi("StatusLineGit", { fg = cyan, bg = bg })
  hi("StatusLineFile", { fg = cyan, bg = bg })
  hi("StatusLinePos", { fg = cyan, bg = bg })

  hi("ZenkakuSpace", { fg = "#ffffff", bg = COLORS.bg_zenkaku, nocombine = true })
  hi("Todo", { fg = COLORS.fg_yellow, bg = "NONE", bold = true })
end

local function define_syntax_highlights()
  -- 標準ハイライト
  hi("Normal", { fg = COLORS.fg_default, bg = "NONE" })
  hi("Comment", { fg = COLORS.fg_comment, italic = true })
  hi("String", { fg = COLORS.fg_cyan })
  hi("Function", { fg = "#64b5f6", bold = true })
  hi("Keyword", { fg = COLORS.fg_green, bold = true })
  hi("Statement", { fg = COLORS.fg_green })
  hi("Type", { fg = "#93e1d8" })
  hi("Number", { fg = COLORS.fg_purple })
  hi("Boolean", { fg = COLORS.fg_purple, bold = true })
  hi("Constant", { fg = "#93e1d8" })
  hi("Identifier", { fg = "#c7cfd8" })
  hi("Delimiter", { fg = "#cfcfcf" })

  -- Treesitter 汎用
  hi("@variable", { fg = COLORS.fg_default })
  hi("@variable.builtin", { fg = "#93e1d8", bold = true })
  hi("@function", { link = "Function" })
  hi("@function.builtin", { fg = "#64b5f6", bold = true })
  hi("@keyword", { link = "Keyword" })
  hi("@string", { link = "String" })
  hi("@number", { link = "Number" })
  hi("@boolean", { link = "Boolean" })
  hi("@comment", { link = "Comment" })
  hi("@type", { link = "Type" })
  hi("@constant", { link = "Constant" })
  hi("@operator", { fg = COLORS.fg_default })
  hi("@punctuation", { fg = "#cfcfcf" })

  -- 言語別明示 (Lua)
  hi("@keyword.lua", { fg = COLORS.fg_green, bold = true })
  hi("@variable.lua", { fg = COLORS.fg_default })

  -- Markdown (G検定の学習ノート用)
  hi("@markup.heading", { fg = COLORS.fg_cyan, bold = true })
  hi("@markup.list", { fg = "#c7cfd8" })
  hi("@markup.link.label", { fg = COLORS.fg_cyan, underline = true })
end

-- ============================================================================
-- 自動実行ロジック (Treesitter & 動的強調)
-- ============================================================================

local function setup_behavior()
  local group = vim.api.nvim_create_augroup("AppBehavior", { clear = true })

  -- 1. Treesitterの遅延起動ロジック
  local function start_ts()
    vim.schedule(function()
      if vim.api.nvim_buf_is_valid(0) then
        pcall(vim.treesitter.start)
      end
    end)
  end

  -- 2. 全角スペース / TODO 強調ロジック
  local function apply_dynamic()
    if not vim.api.nvim_buf_is_valid(0) then return end

    if vim.w.zenkaku_match then pcall(vim.fn.matchdelete, vim.w.zenkaku_match) end
    vim.w.zenkaku_match = vim.fn.matchadd("ZenkakuSpace", [[\%u3000]], 10)

    if vim.b.todo_match then pcall(vim.fn.matchdelete, vim.b.todo_match) end
    local todo_pattern = [[\v\c%(^\s*%(\#|\/\/|\-\-|\;)\s*)@<=\zs%(TODO|FIXME|NOTE)]]
    vim.b.todo_match = vim.fn.matchadd("Todo", todo_pattern, 11)
  end

  -- イベント登録
  vim.api.nvim_create_autocmd({ "BufWinEnter", "FileType" }, {
    group = group,
    callback = start_ts,
  })

  vim.api.nvim_create_autocmd({ "WinEnter", "BufReadPost", "InsertLeave" }, {
    group = group,
    callback = apply_dynamic,
  })

  -- 起動時、現在のバッファにも一回だけ適用
  start_ts()
  apply_dynamic()
end

-- ============================================================================
-- セットアップ
-- ============================================================================

function M.setup()
  define_ui_highlights()
  define_syntax_highlights()
  setup_behavior()
end

return M
