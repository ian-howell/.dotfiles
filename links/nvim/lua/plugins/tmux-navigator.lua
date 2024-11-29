return {
  { -- TMUX Navigation
    'christoomey/vim-tmux-navigator',
    vim.keymap.set('n', '<c-h>', '<cmd>TmuxNavigateLeft<cr>', {
      silent = true,
      desc = 'Move to the left pane',
    }),
    vim.keymap.set('n', '<c-j>', '<cmd>TmuxNavigateDown<cr>', {
      silent = true,
      desc = 'Move to the lower pane',
    }),
    vim.keymap.set('n', '<c-k>', '<cmd>TmuxNavigateUp<cr>', {
      silent = true,
      desc = 'Move to the upper pane',
    }),
    vim.keymap.set('n', '<c-l>', '<cmd>TmuxNavigateRight<cr>', {
      silent = true,
      desc = 'Move to the right pane',
    }),
  },
}

-- vim: ts=2 sts=2 sw=2 et
