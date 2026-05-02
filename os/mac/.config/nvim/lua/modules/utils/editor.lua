local M = {}
local fn = vim.fn
local keymap_opts = { noremap = true, silent = true }

-- カスタムタブライン関数
---@return string
function M.tabline()
    local s = ''
    -- 1からタブページ数($)までループ
    for i = 1, fn.tabpagenr('$') do
        local current = i == fn.tabpagenr()
        
        -- 現在選択中のタブは TabLineSel、その他は TabLine を使用
        local hl = current and '%#TabLineSel#' or '%#TabLine#'
        
        -- タブジャンプ用のID (%1T, %2T など)
        local id = '%' .. tostring(i) .. 'T'
        
        -- ラベル内容の生成
        local label = (function()
                -- そのタブページでアクティブなウィンドウのバッファ名を取得
                local buflist = fn.tabpagebuflist(i)
                local winnr = fn.tabpagewinnr(i)
                local name = fn.bufname(buflist[winnr]) or ""

                -- タブ内のウィンドウ数が1つでない場合、カウントを表示 (選択タブでは表示しない)
                local count = ''
                if not current then
                    count = #buflist == 1 and '' or ' (' .. #buflist .. ')'
                end
                
                -- ファイル名のみを抽出 (':t'修飾子)
                local filename = fn.fnamemodify(name, ':t')
                if filename == "" then filename = "[No Name]" end

                return ' ' .. filename .. count .. ' '
            end)()

        -- セグメントを結合 (ハイライトグループ + タブID + ラベル)
        s = s .. hl .. id .. label .. "%*" -- %* でハイライトを明示的に終了
    end
    
    -- タブバーの右側の余白部分 (%T は TabLineSel を終端する役割もある)
    return s .. '%#TabLineFill#%T'
end

-- hjklの連打を制限する設定
-- function M.limit_hjkl_repetition()
--   if vim.bo.filetype == "netrw" then return end
--
--   local moves = { h = 0, j = 0, k = 0, l = 0 }
--   local threshold = 500 -- ミリ秒
--
--   for key, _ in pairs(moves) do
--     vim.keymap.set("n", key, function()
--       if vim.v.count > 0 then
--         moves[key] = 0
--         return key
--       end
--
--       local now = vim.uv.now()
--       if now - moves[key] < threshold then
--         moves[key] = now
--         return ""
--       end
--
--       moves[key] = now
--
--       if key == "j" then return "gj" end
--       if key == "k" then return "gk" end
--       return key
--     end, { expr = true, silent = true, buffer = true })
--   end
-- end

function M.clear_quickfix()
    vim.fn.setqflist({}, 'r', {})
    vim.cmd('cclose')
    vim.notify('Quickfix list cleared.', vim.log.levels.INFO)
end

-- すべてのモードのキーマップを一覧表示する
function M.show_keymaps()
  -- 取得したいモードのリスト
  local modes = { 'n', 'i', 'v', 't', 'c' }
  local lines = {}
  
  -- ヘッダー (MODE列を追加)
  table.insert(lines, "--- All Keymaps --------------------------------------------------------------")
  table.insert(lines, string.format("%-5s | %-12s | %-18s | %s", "MODE", "LHS (キー)", "RHS (動作)", "DESC (説明)"))
  table.insert(lines, "------------------------------------------------------------------------------")

  local active_maps = {}

  -- 各モードごとにキーマップを収集
  for _, mode in ipairs(modes) do
    local keymaps = vim.api.nvim_get_keymap(mode)
    
    for _, map in ipairs(keymaps) do
      -- プラグイン内部用(<Plug>)以外を対象にする
      if not map.lhs:match('^<Plug>') then
        
        -- スペースを <Leader> 表記に変換
        local lhs_display = map.lhs:gsub(" ", "<Leader>")
        
        -- RHS（実行内容）の整形
        local rhs_display = map.rhs or (map.callback and "Lua: function" or "None")
        if #rhs_display > 18 then
          rhs_display = rhs_display:sub(1, 15) .. "..."
        end

        -- 説明 (desc) の整形
        local desc_display = (map.desc and map.desc ~= "") and map.desc or "---"

        table.insert(active_maps, {
          mode = mode:upper(), -- 小文字を大文字(N, I, V...)に変換
          lhs = lhs_display,
          rhs = rhs_display,
          desc = desc_display
        })
      end
    end
  end

  table.sort(active_maps, function(a, b)
    if a.mode ~= b.mode then
      return a.mode < b.mode
    end
    return a.lhs:lower() < b.lhs:lower()
  end)

  -- リスト化
  for _, m in ipairs(active_maps) do
    table.insert(lines, string.format("%-5s | %-12s | %-18s | %s", m.mode, m.lhs, m.rhs, m.desc))
  end

  -- 表示用バッファの作成と設定
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  
  -- ウィンドウ分割して表示
  vim.cmd('botright 15split')
  vim.api.nvim_set_current_buf(buf)
  
  -- バッファオプション
  vim.bo[buf].filetype = 'keymaps'
  vim.bo[buf].buftype = 'nofile'
  vim.bo[buf].bufhidden = 'wipe'
  vim.bo[buf].buflisted = false
  vim.bo[buf].modifiable = false
end

return M
