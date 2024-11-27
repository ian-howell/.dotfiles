return {
  { -- Color scheme
    'folke/tokyonight.nvim',

    -- Make sure to load this before all the other start plugins.
    priority = 1000,
    init = function()
      vim.cmd.colorscheme 'tokyonight'

      -- Comments are italicized by default in tokyonight, and it's ugly.
      vim.cmd.hi 'Comment gui=none'
    end,
  },
}
-- vim: ts=2 sts=2 sw=2 et
