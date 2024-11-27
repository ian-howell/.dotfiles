return {
  { -- Surround
    "kylechui/nvim-surround",
    -- Use for stability; omit to use `main` branch for the latest features
    version = "*",
    event = "VeryLazy",
    config = function()
      require("nvim-surround").setup({})
    end
  },
}
-- vim: ts=2 sts=2 sw=2 et
