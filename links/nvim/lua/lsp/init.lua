-- Language Server Protocol setup (servers, diagnostics, formatting).

vim.diagnostic.config({
  underline = true,
  virtual_text = true,
  signs = true,
  update_in_insert = false,
  severity_sort = true,
  float = { border = "rounded", source = "if_many" },
})

give("lsp.servers.gopls")
give("lsp.servers.bashls")
