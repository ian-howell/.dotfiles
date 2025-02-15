return {
  'folke/tokyonight.nvim',

  -- Make sure to load this before all the other start plugins.
  priority = 1000,
  lazy = false,
  opts = {
    -- dimming inactive windows is cool, but it doesn't dim any windows when I switch tmux panes. This is a
    -- non-starter, so I'll use my own custom config to do that.
    -- dim_inactive = true,

    on_highlights = function(highlights)
      -- Comments are italicized by default in tokyonight, and it's ugly.
      -- vim.cmd 'hi! Comment gui=none'

      highlights.ColorColumn = {
        -- Make the colorcolumn the same color as the default background.
        -- This way, it will only be visible on the current line (thanks to the cursorline setting).
        bg = highlights.Normal.bg,
      }
    end,
  },
}
-- vim: ts=2 sts=2 sw=2 et
