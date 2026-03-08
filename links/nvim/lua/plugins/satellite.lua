return {
  {
    "lewis6991/satellite.nvim",
    event = "BufReadPost",
    opts = {
      handlers = {
        gitsigns = { enable = true },
        diagnostic = { enable = true },
        search = { enable = true },
        marks = { enable = false },
        quickfix = { enable = false },
      },
    },
  },
}

-- vim: ts=2 sts=2 sw=2 et
