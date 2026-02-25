-- Language Server Protocol setup (servers, diagnostics, formatting).

vim.diagnostic.config({
  underline = true,
  virtual_text = true,
  signs = true,
  update_in_insert = false,
  severity_sort = true,
  float = { border = "rounded", source = "if_many" },
})

-- Map escape to close floating windows, like diagnostics and hover previews
local open_floating_preview = vim.lsp.util.open_floating_preview
vim.lsp.util.open_floating_preview = function(contents, syntax, opts, ...)
  local bufnr, winid = open_floating_preview(contents, syntax, opts, ...)
  vim.keymap.set("n", "<Esc>", "<cmd>close<CR>", { buffer = bufnr })
  return bufnr, winid
end

give("lsp.servers.bashls")
