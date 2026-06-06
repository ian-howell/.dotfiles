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

vim.api.nvim_set_hl(0, "CustomFlashLabel", {
  fg = "#1a1b26",
  bg = "#7aa2f7",
  bold = true,
})

vim.api.nvim_set_hl(0, "CustomFlashCurrent", {
  fg = "#1a1b26",
  bg = "#f7768e",
  bold = true,
})

vim.api.nvim_set_hl(0, "CustomFlashMatch", {
  fg = "#c0caf5",
  bg = "#414868",
  bold = true,
})

vim.keymap.set({ "n", "x", "o" }, "s", function()
  require("flash").jump()
end, { desc = "Flash" })

vim.keymap.set({ "n", "x", "o" }, "S", function()
  require("flash").treesitter()
end, { desc = "Flash Treesitter" })

vim.keymap.set("o", "r", function()
  require("flash").remote()
end, { desc = "Remote Flash" })

vim.keymap.set({ "o", "x" }, "R", function()
  require("flash").treesitter_search()
end, { desc = "Treesitter Search" })

vim.keymap.set("c", "<C-s>", function()
  require("flash").toggle()
end, { desc = "Toggle Flash Search" })
