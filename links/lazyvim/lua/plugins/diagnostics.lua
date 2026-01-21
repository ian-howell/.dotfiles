return {
  "neovim/nvim-lspconfig",
  event = { "BufReadPre", "BufNewFile" },
  opts = {
    -- Configure diagnostics to show only errors
    diagnostics = {
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
    },
  },
}
