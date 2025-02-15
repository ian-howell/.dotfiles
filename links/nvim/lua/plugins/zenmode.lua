return {
  { -- Zoom in on the current window
    'folke/zen-mode.nvim',
    opts = {
      window = { width = 0.7, height = 1.0 },
    },

    vim.keymap.set('n', '<space>z', '<cmd>ZenMode<CR>', { desc = 'ZenMode' }),
  },
}

-- vim: ts=2 sts=2 sw=2 et
