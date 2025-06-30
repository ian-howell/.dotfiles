return {
  "neovim/nvim-lspconfig",
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    -- Configure diagnostics to show only errors
    vim.diagnostic.config({
      severity_sort = true,
      signs = {
        severity = { min = vim.diagnostic.severity.ERROR },
      },
      virtual_text = {
        severity = { min = vim.diagnostic.severity.ERROR },
      },
      underline = {
        severity = { min = vim.diagnostic.severity.ERROR },
      },
    })
  end,
}
