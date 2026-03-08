require("oil").setup({
  default_file_explorer = true,
  delete_to_trash = false,
  skip_confirm_for_simple_edits = true,
  win_options = {
    signcolumn = "yes:2",
  },
  view_options = {
    show_hidden = true,
  },
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = "oil",
  callback = function(args)
    vim.keymap.set("n", "<BS>", "-", {
      buffer = args.buf,
      desc = "Oil: Up a directory",
      remap = true,
    })
    vim.keymap.set("n", "q", "<cmd>q<CR>", { buffer = args.buf, silent = true })
  end,
})
