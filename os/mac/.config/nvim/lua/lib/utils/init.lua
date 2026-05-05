local M = {}
local fn = vim.fn

-- タブライン生成ロジック
function M.tabline()
  local s = ''
  for i = 1, fn.tabpagenr('$') do
    local current = i == fn.tabpagenr()
    local hl = current and '%#TabLineSel#' or '%#TabLine#'
    local id = '%' .. i .. 'T'
    
    local buflist = fn.tabpagebuflist(i)
    local winnr = fn.tabpagewinnr(i)
    local name = fn.bufname(buflist[winnr]) or ""
    local filename = fn.fnamemodify(name, ':t')
    if filename == "" then filename = "[No Name]" end

    local count = (not current and #buflist > 1) and ' (' .. #buflist .. ')' or ''
    s = s .. hl .. id .. ' ' .. filename .. count .. ' ' .. '%*'
  end
  return s .. '%#TabLineFill#%T'
end

-- テキスト折り返し用ヘルパー（show_keymapsで使用）
function M.wrap_text(text, width)
  local lines = {}
  for i = 1, #text, width do
    table.insert(lines, text:sub(i, i + width - 1))
  end
  return lines
end



return M

