return {
  { -- Sneak
    'justinmk/vim-sneak',
    config = function()
      -- Switch out the default behavior of 'f' to use sneak's 1-character enhanced 'f'.
      vim.keymap.set({ 'n', 'x' }, 'f', '<Plug>Sneak_f', { silent = true })
      vim.keymap.set({ 'n', 'x' }, 'F', '<Plug>Sneak_f', { silent = true })

      -- Switch out the default behavior of 't' to use sneak's 1-character enhanced 't'.
      vim.keymap.set({ 'n', 'x' }, 't', '<Plug>Sneak_t', { silent = true })
      vim.keymap.set({ 'n', 'x' }, 'T', '<Plug>Sneak_T', { silent = true })
    end,
  },
}
