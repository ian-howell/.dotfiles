-- [[ Keymaps ]]
-- See `:help vim.keymap.set()`

-- Toggle highlights
vim.keymap.set('n', '<space>th', '<cmd>set hlsearch!<CR>')

-- Easy access to :split and :vsplit. Use '\' instead of '|' because of Shift.
vim.keymap.set('n', '-', '<cmd>split<CR>', { desc = 'Split window horizontally' })
vim.keymap.set('n', '\\', '<cmd>vsplit<CR>', { desc = 'Split window vertically' })

-- Window resizing
local window = require 'functions/window' -- ~/.config/nvim/lua/functions/window.lua
vim.keymap.set('n', '<C-Up>', window.expand_up, { desc = 'Increase window height (upwards)' })
vim.keymap.set('n', '<C-Down>', window.expand_down, { desc = 'Increase window height (downwards)' })
vim.keymap.set('n', '<C-Left>', window.expand_left, { desc = 'Increase window width (leftwards)' })
vim.keymap.set('n', '<C-Right>', window.expand_right, { desc = 'Increase window width (rightwards)' })

-- Quickfix Mappings

do
  local toggleQuickFix = function()
    for _, win in ipairs(vim.fn.getwininfo()) do
      -- TODO: This has some weirdness with location lists
      if win.quickfix == 1 then
        vim.cmd 'cclose | wincmd p'
        return
      end
    end
    vim.cmd 'copen'
  end
  vim.keymap.set('n', '<space>qt', toggleQuickFix, { desc = 'toggle' })
end
vim.keymap.set('n', '<space>qo', '<cmd>copen<CR>', { desc = 'open' })
vim.keymap.set('n', '<space>qn', '<cmd>cnext<CR>', { desc = 'next' })
vim.keymap.set('n', '<space>qN', '<cmd>cnfile<CR>', { desc = 'next' })
vim.keymap.set('n', '<space>qp', '<cmd>cprevious<CR>', { desc = 'previous' })
vim.keymap.set('n', '<space>qP', '<cmd>cpfile<CR>', { desc = 'previous' })
vim.keymap.set('n', '<space>qf', '<cmd>cfirst<CR>', { desc = 'first' })
vim.keymap.set('n', '<space>ql', '<cmd>clast<CR>', { desc = 'last' })

-- Swap between buffers
vim.keymap.set('n', '<space><space>', '<C-6>', { desc = '[ ] Swap to the last buffer' })

-- TODO: Figure out how to get put this with the GitSigns config
-- vim.keymap.set('n', '<space>tg', '<cmd>Gitsigns toggle_linehl<cr>', { desc = 'git diff' })
vim.keymap.set('n', '<space>tg', function()
  vim.cmd 'Gitsigns toggle_linehl'
end, { desc = 'git diff' })

-- vim: ts=2 sts=2 sw=2 et
