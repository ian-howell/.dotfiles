return {
  { -- Copilot
    'github/copilot.vim',

    config = function()
      -- The following lines need to stay together.
      -- Combined, they replace 'Tab' with <c-e> to accept a suggestion
      vim.keymap.set('i', '<C-E>', 'copilot#Accept("")', {
        expr = true,
        -- NOTE: Setting expr = true implicitly sets replace_keycodes = true.
        -- For some reason, when replace_keycodes is true, I get weird characters
        -- when I accept a suggestion.
        -- See https://github.com/orgs/community/discussions/29817#discussioncomment-4217615
        replace_keycodes = false,
        desc = 'Accept the current suggestion',
      })
      vim.g.copilot_no_tab_map = true

      -- Navigate through different suggestions
      vim.keymap.set('i', '<C-J>', '<Plug>(copilot-next)')
      vim.keymap.set('i', '<C-K>', '<Plug>(copilot-previous)')

      -- Accept the next word in the suggestion
      vim.keymap.set('i', '<C-F>', '<Plug>(copilot-accept-word)')

      -- Enable copilot for all filetypes
      vim.b.copilot_enabled = true
    end,
  },
}
-- vim: ts=2 sts=2 sw=2 et
