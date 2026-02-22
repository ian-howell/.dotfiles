local M = {}

function M.setup(bufnr)
  vim.keymap.set("n", "gd", function()
    require("lsp.goto-definition").definition_or_implementation_picker()
  end, { buffer = bufnr, desc = "definition" })

  vim.keymap.set("n", "<leader>ld", vim.diagnostic.open_float, { buffer = bufnr, desc = "Open diagnostics float" })

  local snacks = give("snacks")
  vim.keymap.set("n", "<leader>li", snacks.picker.lsp_implementations, { buffer = bufnr, desc = "implementations" })
  vim.keymap.set("n", "<leader>lr", snacks.picker.lsp_references, { buffer = bufnr, desc = "references" })
  vim.keymap.set("n", "<leader>ls", snacks.picker.lsp_symbols, { buffer = bufnr, desc = "symbols" })
end

return M
