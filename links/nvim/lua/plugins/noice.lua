return {
  { -- Noice

    'folke/noice.nvim',
    event = 'VeryLazy',
    opts = {
      lsp = {
        -- override markdown rendering so that **cmp** and other plugins use **Treesitter**
        override = {
          ['vim.lsp.util.convert_input_to_markdown_lines'] = true,
          ['vim.lsp.util.stylize_markdown'] = true,
          ['cmp.entry.get_documentation'] = true, -- requires hrsh7th/nvim-cmp
        },
      },
      messages = {
        view = 'mini', -- use the mini view for messages. The huge popup is annoying.
        view_search = false, -- disable the virtual text that shows the search count
      },
      notify = {
        enabled = false, -- again, why is the popup so huge?
      },
      presets = {
        command_palette = true, -- position the cmdline and popupmenu together
        long_message_to_split = true, -- long messages will be sent to a split
        inc_rename = false, -- enables an input dialog for inc-rename.nvim
        lsp_doc_border = true, -- add a border to hover docs and signature help
      },
    },
    dependencies = {
      'MunifTanjim/nui.nvim',
      'rcarriga/nvim-notify',
    },

    vim.keymap.set('n', '<space>nd', '<cmd>NoiceDismiss<CR>', { desc = 'NoiceDismiss' }),
  },
}
