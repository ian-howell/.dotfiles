return {
  { -- TMUX Navigation
    'christoomey/vim-tmux-navigator',
    vim.keymap.set('n', '<c-h>', ':TmuxNavigateLeft<cr>', { silent = true }),
    vim.keymap.set('n', '<c-j>', ':TmuxNavigateDown<cr>', { silent = true }),
    vim.keymap.set('n', '<c-k>', ':TmuxNavigateUp<cr>', { silent = true }),
    vim.keymap.set('n', '<c-l>', ':TmuxNavigateRight<cr>', { silent = true }),
  },
}
-- vim: ts=2 sts=2 sw=2 et
