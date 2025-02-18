-- See `:help vim.keymap.set()`

-- Easy access to :split and :vsplit. Use '\' instead of '|' because of Shift.
vim.keymap.set("n", "-", "<cmd>split<CR>", { desc = "Split window horizontally" })
vim.keymap.set("n", "\\", "<cmd>vsplit<CR>", { desc = "Split window vertically" })

-- Swap between buffers
vim.keymap.set("n", "<space><space>", "<C-6>", { desc = "[ ] Swap to the last buffer" })

-- vim: ts=2 sts=2 sw=2 et
