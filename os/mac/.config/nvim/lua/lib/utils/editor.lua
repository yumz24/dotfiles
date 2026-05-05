local M = {}

--- [ Private Helpers ] ---

-- 専用の表示用バッファを作成し、下部にスプリットで表示する
local function open_output_buffer(lines, buf_name, height)
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

  if buf_name then
    vim.api.nvim_buf_set_name(buf, buf_name)
  end

  vim.cmd('botright ' .. height .. 'split')
  local win = vim.api.nvim_get_current_win()
  vim.api.nvim_win_set_buf(win, buf)

  -- 基本的なバッファ設定
  vim.bo[buf].buftype = 'nofile'
  vim.bo[buf].bufhidden = 'wipe'
  vim.bo[buf].swapfile = false
  vim.bo[buf].modifiable = false

  -- 'q' で閉じれるように設定
  vim.keymap.set('n', 'q', '<cmd>close<CR>', { buffer = buf, nowait = true })

  return buf, win
end

--- [ Tools: Viewers ] ---

-- キーマップを複数行対応で一覧表示
function M.show_keymaps()
  local utils = require("lib.utils")
  local modes = { 'n', 'i', 'v', 't', 'c' }
  local lines = {}
  local w_mode, w_lhs, w_rhs, w_desc = 5, 15, 30, 40

  table.insert(lines, "--- All Keymaps (q: close) " .. string.rep("-", 50))
  table.insert(lines,
    string.format("%-" .. w_mode .. "s | %-" .. w_lhs .. "s | %-" .. w_rhs .. "s | %s", "MODE", "LHS", "RHS", "DESC"))
  table.insert(lines, string.rep("-", 100))

  local active_maps = {}
  for _, mode in ipairs(modes) do
    local maps = vim.api.nvim_get_keymap(mode)
    local buf_maps = vim.api.nvim_buf_get_keymap(0, mode)

    local function process(m_list)
      for _, map in ipairs(m_list) do
        if not map.lhs:match('^<Plug>') then
          table.insert(active_maps, {
            mode = mode:upper(),
            lhs = map.lhs:gsub(" ", "<Leader>"),
            rhs = map.rhs or (map.callback and "Lua: Function" or "---"),
            desc = (map.desc and map.desc ~= "") and map.desc or "---"
          })
        end
      end
    end
    process(maps)
    process(buf_maps)
  end

  table.sort(active_maps, function(a, b)
    if a.mode ~= b.mode then return a.mode < b.mode end
    return a.lhs:lower() < b.lhs:lower()
  end)

  for _, m in ipairs(active_maps) do
    local rhs_l = utils.wrap_text(m.rhs, w_rhs)
    local desc_l = utils.wrap_text(m.desc, w_desc)
    for i = 1, math.max(#rhs_l, #desc_l) do
      table.insert(lines, string.format("%-" .. w_mode .. "s | %-" .. w_lhs .. "s | %-" .. w_rhs .. "s | %s",
        (i == 1 and m.mode or ""), (i == 1 and m.lhs or ""), (rhs_l[i] or ""), (desc_l[i] or "")))
    end
  end

  open_output_buffer(lines, "[Keymaps]", 20)
end

-- メッセージ表示バッファ
function M.show_messages()
  local buf_name = "[Vim Messages]"

  -- 既存のメッセージバッファを削除してリフレッシュ
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_get_name(buf):find(buf_name, 1, true) then
      vim.api.nvim_buf_delete(buf, { force = true })
    end
  end

  local messages = vim.api.nvim_exec("messages", true)
  local home = os.getenv("HOME")
  if home then
    messages = messages:gsub(home:gsub("([^%w])", "%%%1"), "~")
  end

  local lines = vim.split(messages, "\n")
  local _, win = open_output_buffer(lines, buf_name, 12)

  -- 最新メッセージが見えるように最下行へスクロール
  vim.api.nvim_win_set_cursor(win, { #lines, 0 })
end

--- [ Operations: Quickfix & Terminal ] ---

function M.clear_quickfix()
  vim.fn.setqflist({}, 'r')
  vim.cmd('cclose')
  vim.notify('Quickfix cleared.')
end

function M.toggle_term()
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_valid(buf) and vim.api.nvim_buf_get_name(buf):match("^term://") then
      vim.cmd("bdelete! " .. buf)
      return
    end
  end
  vim.cmd("botright split | resize 12 | terminal")
end

return M
