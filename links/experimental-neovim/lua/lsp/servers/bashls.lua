local function root_dir(bufnr)
  return vim.fs.root(bufnr, { ".git" })
    or vim.fs.dirname(vim.api.nvim_buf_get_name(bufnr))
end

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "sh", "bash", "zsh" },
  callback = function(args)
    vim.lsp.start({
      name = "bashls",
      cmd = { "bash-language-server", "start" },
      root_dir = root_dir(args.buf),
    })
  end,
})
