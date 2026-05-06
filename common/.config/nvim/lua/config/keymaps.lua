-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
local map = vim.keymap.set

map("v", ",", "<Esc>ggVG", { noremap = true, silent = true, desc = "Select all in this file" })
map("v", "v", "<C-v>", { noremap = true, silent = true, desc = "Visual block" })
