return {
  { -- Vim-go
    'fatih/vim-go',
    config = function()
      -- The lsp hover popup is soo much cooler with Noice
      vim.g.go_doc_keywordprg_enabled = 0
    end,
  },
}

-- vim: ts=2 sts=2 sw=2 et
