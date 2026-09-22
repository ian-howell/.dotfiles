-- flash.nvim configuration

require("flash").setup({
  highlight = {
    groups = {
      label = "CustomFlashLabel",
      current = "CustomFlashCurrent",
      match = "CustomFlashMatch",
    },
  },
})

require("core.theme").highlights()

vim.keymap.set({ "n", "x", "o" }, "s", function()
  require("flash").jump()
end, { desc = "Flash" })

vim.keymap.set("o", "r", function()
  require("flash").remote()
end, { desc = "Remote Flash" })

vim.keymap.set({ "o", "x" }, "R", function()
  require("flash").treesitter_search()
end, { desc = "Treesitter Search" })

vim.keymap.set("c", "<C-s>", function()
  require("flash").toggle()
end, { desc = "Toggle Flash Search" })
