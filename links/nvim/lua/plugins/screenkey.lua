return {
  "NStefan002/screenkey.nvim",
  lazy = false,
  version = "*",
  init = function()
    vim.keymap.set("n", "<leader>uk", "<cmd>Screenkey<cr>", {
      desc = "Toggle on-screen key display",
    })
  end,
}
