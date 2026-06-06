-- conform.nvim configuration

local conform = require("conform")

conform.setup({
  format_on_save = function(bufnr)
    if vim.b[bufnr].autoformat == false then
      return nil
    end

    return { timeout_ms = 500, lsp_format = "fallback" }
  end,
  formatters_by_ft = {
    lua = { "stylua" },
    go = { "gofmt", "goimports" },
  },
})

vim.keymap.set({ "n", "x" }, "<leader>cf", function()
  conform.format({ async = true, lsp_format = "fallback" })
end, { desc = "Format" })
