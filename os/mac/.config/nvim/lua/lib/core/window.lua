local M = {}

M.resize_mode = false

function M.toggle_resize_mode()
  local b_opts = { buffer = true, noremap = true, silent = true }
  if M.resize_mode then
    M.resize_mode = false
    pcall(vim.keymap.del, 'n', 'h', { buffer = true })
    pcall(vim.keymap.del, 'n', 'j', { buffer = true })
    pcall(vim.keymap.del, 'n', 'k', { buffer = true })
    pcall(vim.keymap.del, 'n', 'l', { buffer = true })
    pcall(vim.keymap.del, 'n', '<Esc>', { buffer = true })
    vim.notify("Resize mode OFF")
  else
    M.resize_mode = true
    vim.keymap.set('n', 'h', ":vertical resize +2<CR>", b_opts)
    vim.keymap.set('n', 'j', ":resize +2<CR>", b_opts)
    vim.keymap.set('n', 'k', ":resize -2<CR>", b_opts)
    vim.keymap.set('n', 'l', ":vertical resize -2<CR>", b_opts)
    vim.keymap.set('n', '<Esc>', M.toggle_resize_mode, b_opts)
    vim.notify("Resize mode ON (hjkl: resize, Esc: exit)")
  end
end

return M
