return {
  -- For dev purposes, use the 'dir' rather than the url
  -- dir = "~/ripple.nvim",
  "ian-howell/ripple.nvim",
  keys = {
    "<C-Up>",
    "<C-Down>",
    "<C-Right>",
    "<C-Down>",
  },
  opts = {
    keys = {
      -- TODO: The desc doesn't do anything right now. Figure out the "idiomatic" way to define keybinds for
      -- plugins
      { "<C-Up>", "expand_up", desc = "Increase window height (upwards)" },
      { "<C-Down>", "expand_down", desc = "Increase window height (downwards)" },
      { "<C-Left>", "expand_left", desc = "Increase window width (leftwards)" },
      { "<C-Right>", "expand_right", desc = "Increase window width (rightwards)" },
    },
  },
}
