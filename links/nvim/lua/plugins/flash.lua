return {
  "folke/flash.nvim",
  event = "VeryLazy",
  opts = {
    highlight = {
      groups = {
        label = "CustomFlashLabel",
        current = "CustomFlashCurrent",
        match = "CustomFlashMatch",
      },
    },
  },
  config = function(_, opts)
    vim.api.nvim_set_hl(0, "CustomFlashLabel", {
      fg = "#1a1b26", -- Dark background color for contrast
      bg = "#7aa2f7", -- Tokyonight blue for visibility
      bold = true,
    })
    vim.api.nvim_set_hl(0, "CustomFlashCurrent", {
      fg = "#1a1b26", -- Dark text
      bg = "#f7768e", -- Tokyonight red/pink
      bold = true,
    })

    vim.api.nvim_set_hl(0, "CustomFlashMatch", {
      fg = "#c0caf5", -- Light text
      bg = "#414868", -- Darker blue-gray
      bold = true,
    })
    require("flash").setup(opts)
  end,
  -- stylua: ignore
  keys = {
    { "s", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Flash" },
    { "S", mode = { "n", "x", "o" }, function() require("flash").treesitter() end, desc = "Flash Treesitter" },
    { "r", mode = "o", function() require("flash").remote() end, desc = "Remote Flash" },
    { "R", mode = { "o", "x" }, function() require("flash").treesitter_search() end, desc = "Treesitter Search" },
    { "<c-s>", mode = { "c" }, function() require("flash").toggle() end, desc = "Toggle Flash Search" },
  },
}
