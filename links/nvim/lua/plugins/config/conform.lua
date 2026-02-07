-- conform.nvim configuration

local ok, conform = pcall(require, "conform")
if not ok then
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
