-- [[ Focus Settings ]]

-- NOTE: If colors are funky, don't forget to test with the true-color-24-test
vim.opt.termguicolors = true

-- Background colors for active vs inactive windows
vim.cmd.hi 'link ActiveWindow Normal'

-- InactiveWindow is the background color for tokyonight
vim.cmd.hi 'InactiveWindow guibg=#1a1b26'

-- Normally, this would be good enough (and it's still required for startup with multiple splits)...
vim.opt.winhighlight = 'Normal:ActiveWindow,NormalNC:InactiveWindow'
-- ... But since vim always has an "active" window (even in an inactive tmux pane), I need to use autocmds to
-- change the highlight groups based on focus.
vim.api.nvim_create_autocmd({ 'BufLeave', 'WinLeave', 'FocusLost' }, {
  desc = 'Dim the window when it loses focus',
  group = vim.api.nvim_create_augroup('focus-leave', { clear = true }),
  callback = function()
    vim.opt_local.cursorline = false
    vim.opt_local.cursorcolumn = false
    vim.opt_local.colorcolumn = ''
    -- If I've left the window for *any* reason (whether it's to switch buffers or to switch tmux panes),
    -- I want the window to be dimmed.
    vim.opt_local.winhighlight = 'Normal:InactiveWindow,NormalNC:InactiveWindow'
  end,
})

vim.api.nvim_create_autocmd({ 'BufEnter', 'WinEnter', 'FocusGained' }, {
  desc = 'Highlight the window when it gains focus',
  group = vim.api.nvim_create_augroup('focus-enter', { clear = true }),
  callback = function()
    vim.opt_local.cursorline = true
    vim.opt_local.cursorcolumn = true
    vim.opt_local.colorcolumn = '110'
    vim.opt_local.winhighlight = 'Normal:ActiveWindow,NormalNC:InactiveWindow'
  end,
})

-- Turn on highlighting while searching
vim.api.nvim_create_autocmd('CmdlineEnter', {
  desc = 'Highlight while searching',
  group = vim.api.nvim_create_augroup('highlight-while-searching', { clear = true }),
  callback = function()
    if vim.fn.index({ '/', '?' }, vim.fn.getcmdtype()) >= 0 then
      vim.opt.hlsearch = true
    end
  end,
})
