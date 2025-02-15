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
        view_error = 'mini', -- view for errors
        view_warn = 'mini', -- view for warnings
        view_search = false, -- disable the virtual text that shows the search count
      },
      notify = {
        enabled = false, -- again, why is the popup so huge?
      },
      presets = {
        command_palette = true, -- position the cmdline and popupmenu together
      },
    },
    dependencies = {
      'MunifTanjim/nui.nvim',
    },

    vim.keymap.set('n', '<space>nd', '<cmd>NoiceDismiss<CR>', { desc = 'NoiceDismiss' }),
  },
}
