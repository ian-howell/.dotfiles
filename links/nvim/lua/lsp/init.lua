-- Language Server Protocol setup (servers, diagnostics, formatting).

vim.diagnostic.config({
  underline = true,
  virtual_text = true,
  signs = true,
  update_in_insert = false,
  severity_sort = true,
  float = { border = "rounded", source = "if_many" },
})

vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float)
vim.keymap.set("n", "[d", vim.diagnostic.goto_prev)
vim.keymap.set("n", "]d", vim.diagnostic.goto_next)
vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist)

vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    local opts = { buffer = args.buf }
    local has_snacks, snacks = pcall(require, "snacks")

    vim.bo[args.buf].omnifunc = "v:lua.vim.lsp.omnifunc"

    vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
    vim.keymap.set("n", "gi", snacks.picker.lsp_implementations, opts)
    vim.keymap.set("n", "<C-k>", vim.lsp.buf.signature_help, opts)
    vim.keymap.set("n", "<leader>wa", vim.lsp.buf.add_workspace_folder, opts)
    vim.keymap.set("n", "<leader>wr", vim.lsp.buf.remove_workspace_folder, opts)
    vim.keymap.set("n", "<leader>wl", function()
      print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
    end, opts)
    vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
    vim.keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, opts)
    vim.keymap.set("n", "<leader>f", function()
      vim.lsp.buf.format({ async = true })
    end, opts)

    if has_snacks and snacks.picker then
      vim.keymap.set("n", "gD", snacks.picker.lsp_declarations, opts)
      vim.keymap.set("n", "gd", snacks.picker.lsp_definitions, opts)
      vim.keymap.set("n", "gi", snacks.picker.lsp_implementations, opts)
      vim.keymap.set("n", "<leader>D", snacks.picker.lsp_type_definitions, opts)
      vim.keymap.set("n", "gr", snacks.picker.lsp_references, opts)
    end
  end,
})

require("lsp.servers.gopls")
require("lsp.servers.bashls")
