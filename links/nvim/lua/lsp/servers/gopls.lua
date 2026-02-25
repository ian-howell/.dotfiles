local function root_dir(bufnr)
  return vim.fs.root(bufnr, { "go.mod", ".git" }) or vim.fs.dirname(vim.api.nvim_buf_get_name(bufnr))
end

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "go", "gomod", "gowork", "gotmpl" },
  callback = function(args)
    vim.lsp.start({
      name = "gopls",
      cmd = { "gopls" },
      root_dir = root_dir(args.buf),
    })
  end,
})
