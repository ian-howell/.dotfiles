-- Keymaps and related helper logic.
-- See `:help vim.keymap.set()`

-- Easy access to :split and :vsplit. Use '\' instead of '|' because of Shift.
vim.keymap.set("n", "-", "<cmd>split<CR>", { desc = "Split window horizontally" })
vim.keymap.set("n", "\\", "<cmd>vsplit<CR>", { desc = "Split window vertically" })

vim.keymap.set({ "n", "x", "o" }, "/", function()
  require("flash").jump()
end, { desc = "Flash" })
vim.keymap.set({ "n", "x", "o" }, "?", function()
  require("flash").jump({
    search = {
      forward = false,
    },
  })
end, { desc = "Flash backwards" })

-- Swap s and / for traditional search behavior
vim.keymap.set("n", "s", "/", { desc = "Search forward" })
vim.keymap.set("n", "S", "?", { desc = "Search backward" })
