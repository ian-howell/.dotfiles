-- vim: foldmethod=marker foldlevel=0

-- LSP Configuration {{{1

vim.api.nvim_create_autocmd('LspAttach', {
    callback = function(args)
      local client = vim.lsp.get_client_by_id(args.data.client_id)
      -- if client.supports_method('textDocument/implementation') then
      --     -- Create a keymap for vim.lsp.buf.implementation
      -- end

      if client.supports_method('textDocument/formatting') then
          -- Format the current buffer on save
          vim.api.nvim_create_autocmd('BufWritePre', {
          buffer = args.buf,
          callback = function()
              vim.lsp.buf.format({bufnr = args.buf, id = client.id})
          end,
          })
      end

      -- gd to go to definition
      if client.supports_method('textDocument/definition') then
          vim.api.nvim_buf_set_keymap(
              args.buf, 'n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>',
              {noremap = true, silent = true}
          )
      end

      -- gD to go to type definition
      if client.supports_method('textDocument/typeDefinition') then
          vim.api.nvim_buf_set_keymap(
              args.buf, 'n', 'gD', '<cmd>lua vim.lsp.buf.type_definition()<CR>',
              {noremap = true, silent = true}
          )
      end

      -- K to show hover information
      if client.supports_method('textDocument/hover') then
          vim.api.nvim_buf_set_keymap(
              args.buf, 'n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>',
              {noremap = true, silent = true}
          )
      end

      -- <space>rn to rename
      if client.supports_method('textDocument/rename') then
          vim.api.nvim_buf_set_keymap(
              args.buf, 'n', '<space>rn', '<cmd>lua vim.lsp.buf.rename()<CR>',
              {noremap = true, silent = true}
          )
      end

      -- <space>ca to code action
      if client.supports_method('textDocument/codeAction') then
          vim.api.nvim_buf_set_keymap(
              args.buf, 'n', '<space>ca', '<cmd>lua vim.lsp.buf.code_action()<CR>',
              {noremap = true, silent = true}
          )
      end

      -- gi to go to implementation
      if client.supports_method('textDocument/implementation') then
          vim.api.nvim_buf_set_keymap(
              args.buf, 'n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>',
              {noremap = true, silent = true}
          )
      end

    end
})

-- Go Language Server Configuration {{{1
vim.api.nvim_create_autocmd('FileType', {
  pattern = 'go',
  callback = function(args)
    vim.lsp.start({
      name = 'gopls',
      cmd = { 'gopls' },
    })
  end,
})

