return {
  { -- Lualine
    "nvim-lualine/lualine.nvim",
    dependencies = {
      "nvim-tree/nvim-web-devicons",
      "yavorski/lualine-macro-recording.nvim",
    },
    event = "VimEnter",

    opts = {
      winbar = {
        lualine_a = {
          {
            "filename",
            path = 1, -- Relative path
            symbols = {
              modified = "Δ", -- Text to show when the file is modified.
              readonly = "", -- Text to show when the file is non-modifiable or readonly.
            },
          },
        },
      },
      inactive_winbar = {
        lualine_a = {
          {
            "filename",
            path = 1, -- Relative path
            symbols = {
              modified = "Δ", -- Text to show when the file is modified.
              readonly = "", -- Text to show when the file is non-modifiable or readonly.
            },
          },
        },
      },
      extensions = { "aerial", "quickfix" },
    },
  },
}
