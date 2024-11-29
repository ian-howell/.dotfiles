-- [[ Keymaps ]]
-- See `:help vim.keymap.set()`

-- Toggle highlights
vim.keymap.set('n', '<leader>th', '<cmd>set hlsearch!<CR>')

-- Easy access to :split and :vsplit. Use '\' instead of '|' because of Shift.
vim.keymap.set('n', '-', ':split<CR>', { desc = 'Split window horizontally' })
vim.keymap.set('n', '\\', ':vsplit<CR>', { desc = 'Split window vertically' })

-- Quickfix Mappings
-- TODO: Is this the right way to define a function?
local toggleQuickFix = function()
  for _, win in ipairs(vim.fn.getwininfo()) do
    if win.quickfix == 1 then
      vim.cmd 'cclose | wincmd p'
      return
    end
  end
  vim.cmd 'copen'
end

vim.keymap.set('n', '<space>qt', toggleQuickFix, { desc = 'toggle' })
vim.keymap.set('n', '<space>qo', ':copen<CR>', { desc = 'open' })
vim.keymap.set('n', '<space>qn', ':cnext<CR>', { desc = 'next' })
vim.keymap.set('n', '<space>qN', ':cnfile<CR>', { desc = 'next' })
vim.keymap.set('n', '<space>qp', ':cprevious<CR>', { desc = 'previous' })
vim.keymap.set('n', '<space>qP', ':cpfile<CR>', { desc = 'previous' })
vim.keymap.set('n', '<space>qf', ':cfirst<CR>', { desc = 'first' })
vim.keymap.set('n', '<space>ql', ':clast<CR>', { desc = 'last' })

-- Swap between buffers
vim.keymap.set('n', '<leader><leader>', '<C-6>', { desc = '[ ] Swap to the last buffer' })

-- TODO: Figure out how to get put this with the GitSigns config
-- vim.keymap.set('n', '<space>tg', ':Gitsigns toggle_linehl<cr>', { desc = 'git diff' })
vim.keymap.set('n', '<space>tg', function()
  vim.cmd 'Gitsigns toggle_linehl'
end, { desc = 'git diff' })

-- vim: ts=2 sts=2 sw=2 et
