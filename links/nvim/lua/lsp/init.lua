-- Language Server Protocol setup (servers, diagnostics, formatting).

vim.diagnostic.config({
  underline = true,
  virtual_text = true,
  signs = true,
  update_in_insert = false,
  severity_sort = true,
  float = { border = "rounded", source = "if_many" },
})

-- Override the default floating preview to use rounded borders.
local open_floating_preview = vim.lsp.util.open_floating_preview
vim.lsp.util.open_floating_preview = function(contents, syntax, opts, ...)
  opts = opts or {}
  opts.border = opts.border or "rounded"
  return open_floating_preview(contents, syntax, opts, ...)
end

require("lsp.servers.gopls")
require("lsp.servers.bashls")
