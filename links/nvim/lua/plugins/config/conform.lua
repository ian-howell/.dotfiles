-- conform.nvim configuration

local conform = give("conform")
if not conform then
  return
end

conform.setup({
  format_on_save = {
    timeout_ms = 500,
    lsp_format = "fallback",
  },
  formatters_by_ft = {
    lua = { "stylua" },
  },
})
