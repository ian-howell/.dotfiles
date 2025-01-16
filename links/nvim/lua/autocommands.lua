-- [[ Autocommands ]]
--  See `:help lua-guide-autocommands`

-- Highlight the yanked text
--  See `:help vim.highlight.on_yank()`
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})

-- When editing a file, always jump to the last known cursor position (if it's valid).
-- Ignores commit messages (it's likely a different one than last time).
RecallLastPosition = function()
  if vim.fn.line '\'"' < 1 then
    return -- We've never opened this file before
  end

  if vim.fn.line '\'"' > vim.fn.line '$' then
    return -- The file has shrunk since we last edited it
  end

  if vim.bo.ft == 'gitcommit' then
    return -- We don't want to do this for git commit messages
  end

  vim.cmd 'normal! g`"' -- Jump to the last known cursor position
end

vim.api.nvim_create_autocmd('BufWinEnter', {
  desc = 'Recall cursor position',
  group = vim.api.nvim_create_augroup('recall-position', { clear = true }),
  callback = RecallLastPosition,
})

local quickfix = require 'functions/quickfix' -- ~/.config/nvim/lua/functions/quickfix.lua
vim.api.nvim_create_autocmd({ 'FileType' }, {
  pattern = 'qf',
  desc = 'Setup keybindings for the quickfix window',
  group = vim.api.nvim_create_augroup('quickfix_mapping', { clear = true }),
  callback = function()
    vim.keymap.set('n', '-', quickfix.openInSplit, {
      buffer = true,
      desc = 'Open quickfix in split',
    })
    vim.keymap.set('n', '\\', quickfix.openInVsplit, {
      buffer = true,
      desc = 'Open quickfix in vsplit',
    })
  end,
})

-- vim: ts=2 sts=2 sw=2 et
