local function ApprenticeOverrides()
  vim.cmd("highlight LineNr guifg=#5e5e5e guibg=default")
  vim.cmd("highlight StatusLine guifg=#5e5e5e guibg=#303030")
  -- NOTE: black means transparent
  vim.cmd("highlight WinSeparator guifg=#5e5e5e guibg=black")
end

vim.api.nvim_create_autocmd("ColorScheme", {
  pattern = "apprentice",
  callback = ApprenticeOverrides,
  group = vim.api.nvim_create_augroup("apprentice_overrides", { clear = true }),
})

return {
  { "romainl/Apprentice" },

  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "apprentice",
    },
  },
}
