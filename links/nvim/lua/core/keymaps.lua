-- Keymaps and related helper logic.
-- See `:help vim.keymap.set()`

-- Easy access to :split and :vsplit. Use '\' instead of '|' because of Shift.
vim.keymap.set("n", "-", "<cmd>split<CR>", { desc = "Split window horizontally" })
vim.keymap.set("n", "\\", "<cmd>vsplit<CR>", { desc = "Split window vertically" })

vim.g.cursorcolumn = vim.opt.cursorcolumn:get()
vim.keymap.set("n", "<leader>ux", function()
  vim.g.cursorcolumn = not vim.g.cursorcolumn
  vim.opt.cursorcolumn = vim.g.cursorcolumn
  vim.opt_local.cursorcolumn = vim.g.cursorcolumn
end, { desc = "Toggle cursor column" })
