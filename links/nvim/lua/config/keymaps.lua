-- See `:help vim.keymap.set()`

-- Easy access to :split and :vsplit. Use '\' instead of '|' because of Shift.
vim.keymap.set("n", "-", "<cmd>split<CR>", { desc = "Split window horizontally" })
vim.keymap.set("n", "\\", "<cmd>vsplit<CR>", { desc = "Split window vertically" })

-- Swap between buffers
vim.keymap.set("n", "<space><space>", "<C-6>", { desc = "[ ] Swap to the last buffer" })

-- Fix the last misspelling
vim.keymap.set("i", "<C-s>", "<C-g>u<Esc>[s1z=`]a<C-g>u", { desc = "Fix the last mispelling" })

-- LazyVim uses H and L to move between buffers. Silly LazyVim, that's useless.
-- This re-enables the much more useful defaults configures more idiomatic
-- bindings to accomplish the same thing.
vim.keymap.del("n", "<S-h>")
vim.keymap.del("n", "<S-l>")
vim.keymap.set("n", "<c-n>", "<cmd>bnext<CR>", { desc = "Go to next buffer" })
vim.keymap.set("n", "<c-p>", "<cmd>bprevious<CR>", { desc = "Go to previous buffer" })

vim.g.cursorcolumn = false
vim.keymap.set("n", "<space>ux", function()
  vim.g.cursorcolumn = not vim.g.cursorcolumn
  vim.opt_local.cursorcolumn = vim.g.cursorcolumn
end, { desc = "Toggle cursor column" })

-- vim: ts=2 sts=2 sw=2 et
