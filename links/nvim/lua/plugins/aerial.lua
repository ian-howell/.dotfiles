return {
  { -- Aerial
    'stevearc/aerial.nvim',
    opts = {},
    -- Optional dependencies.
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-tree/nvim-web-devicons"
    },

    vim.keymap.set("n", "<c-n>", "<cmd>AerialNext<CR>", { desc = "next" }),
    vim.keymap.set("n", "<c-p>", "<cmd>AerialPrev<CR>", { desc = "prev" }),
    vim.keymap.set("n", "<space>ta", "<cmd>AerialToggle!<CR>", { desc = "Aerial" }),
  },
}
-- vim: ts=2 sts=2 sw=2 et
