-- See `:help vim.keymap.set()`

-- Easy access to :split and :vsplit. Use '\' instead of '|' because of Shift.
vim.keymap.set("n", "-", "<cmd>split<CR>", { desc = "Split window horizontally" })
vim.keymap.set("n", "\\", "<cmd>vsplit<CR>", { desc = "Split window vertically" })

-- Swap between buffers
vim.keymap.set("n", "<space><space>", "<C-6>", { desc = "[ ] Swap to the last buffer" })

-- Fix the last misspelling
vim.keymap.set("i", "<C-s>", "<C-g>u<Esc>[s1z=`]a<C-g>u", { desc = "Fix the last mispelling" })

-- LazyVim uses H and L to move between buffers. Silly LazyVim, that's useless.
-- This re-enables the much more useful defaults.
vim.keymap.del("n", "<S-h>")
vim.keymap.del("n", "<S-l>")

-- vim: ts=2 sts=2 sw=2 et
