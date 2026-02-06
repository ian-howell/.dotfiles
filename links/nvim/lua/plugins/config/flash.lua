-- flash.nvim configuration

require("flash").setup({
  highlight = {
    groups = {
      label = "CustomFlashLabel",
      current = "CustomFlashCurrent",
      match = "CustomFlashMatch",
    },
  },
  jump = {
    history = true,
    register = true,
    nohlsearch = true,
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
