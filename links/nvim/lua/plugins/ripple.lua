return {
  -- For dev purposes, use the 'dir' rather than the url
  -- dir = "~/projects/ripple.nvim",
  "ian-howell/ripple.nvim",
  keys = {
    "<C-Up>",
    "<C-Down>",
    "<C-Left>",
    "<C-Right>",
  },
  opts = {
    -- TODO: These are broken with LazyVim...
    --   vertical_step_size = 2,
    --   horizontal_step_size = 5,
  },
}
