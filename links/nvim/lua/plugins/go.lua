return {
  { -- Vim-go
    'fatih/vim-go',
    config = function()
      -- The lsp hover popup is soo much cooler with Noice
      vim.g.go_doc_keywordprg_enabled = 0

      vim.keymap.set('n', '<space>Gc', '<cmd>:GoCoverage<CR>', { desc = 'Show test coverage' })
      vim.keymap.set('n', '<space>GC', '<cmd>:GoCoverageToggle<CR>', { desc = 'Toggle test coverage' })
      vim.keymap.set('n', '<space>Ga', '<cmd>:GoAlternate<CR>', { desc = 'Alternate between test and implementation' })
      vim.keymap.set('n', '<space>Gt', '<cmd>:GoTestFunc<CR>', { desc = 'Run the test under the cursor' })
      vim.keymap.set('n', '<space>GT', '<cmd>:GoTestFile<CR>', { desc = 'Run the tests in the current file' })
    end,
  },
}

-- vim: ts=2 sts=2 sw=2 et
