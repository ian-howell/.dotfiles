return {
  { -- Smear cursor when moving between buffers
    'sphamba/smear-cursor.nvim',

    opts = {
      -- Smear cursor when switching buffers
      smear_between_buffers = true,

      -- Use floating windows to display smears outside buffers.
      -- May have performance issues with other plugins.
      use_floating_windows = true,

      -- Attempt to hide the real cursor when smearing.
      hide_target_hack = true,
    },
  },
  { -- Smooth scrolling
    "karb94/neoscroll.nvim",
    config = function()
      require('neoscroll').setup({
        mappings = {
          '<C-u>', '<C-d>',
          '<C-b>', '<C-f>',
          'zt', 'zz', 'zb',
        },
      })
    end
  },
}
-- vim: ts=2 sts=2 sw=2 et
