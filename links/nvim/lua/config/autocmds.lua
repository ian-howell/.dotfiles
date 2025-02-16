-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")
--
-- See `:help lua-guide-autocommands`

-- When creating a new git commit, start in insert mode
vim.api.nvim_create_autocmd("BufWinEnter", {
  pattern = "*.git/COMMIT_EDITMSG",
  desc = "Start git commit messages in insert mode",
  group = vim.api.nvim_create_augroup("gitcommit-insert", { clear = true }),
  callback = function()
    -- If it's a new commit, start in insert mode, otherwise start in normal mode
    if vim.fn.getline(1) == "" then
      vim.cmd("startinsert!")
    end
  end,
})

local quickfix = require("functions/quickfix") -- ~/.config/nvim/lua/functions/quickfix.lua
vim.api.nvim_create_autocmd({ "FileType" }, {
  pattern = "qf",
  desc = "Setup keybindings for the quickfix window",
  group = vim.api.nvim_create_augroup("quickfix_mapping", { clear = true }),
  callback = function()
    vim.keymap.set("n", "-", quickfix.openInSplit, {
      buffer = true,
      desc = "Open quickfix in split",
    })
    vim.keymap.set("n", "\\", quickfix.openInVsplit, {
      buffer = true,
      desc = "Open quickfix in vsplit",
    })
  end,
})

-- When entering a new file, set the formatoptions to *not* insert comment characters when I press `o` or `O`.
-- NOTE: This is needed here because formatoptions ise set by the filetype plugin, which happens after all of
-- my settings. This causes my custom settings to be overridden.
-- stuff overrides my settings.
vim.api.nvim_create_autocmd("BufEnter", {
  callback = function()
    vim.bo.formatoptions = vim.bo.formatoptions:gsub("o", "")
  end,
})

-- vim: ts=2 sts=2 sw=2 et
