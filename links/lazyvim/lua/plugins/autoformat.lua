return {
  "stevearc/conform.nvim",
  event = { "BufWritePre" },
  cmd = { "ConformInfo" },
  keys = {
    {
      "<space>cf",
      function()
        require("conform").format({ async = true, lsp_format = "fallback" })
      end,
      mode = "",
      desc = "format",
    },
  },
  opts = {
    formatters_by_ft = {
      lua = { "stylua" },
      -- Conform can run multiple formatters sequentially
      go = { "gofmt", "goimports" },
      python = { "isort", "black" },
    },
  },
}

-- vim: ts=2 sts=2 sw=2 et
