-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- See `:help vim.opt`
-- For more options, you can see `:help option-list`

-- Make line numbers default
vim.opt.number = true

-- Turn off relative numbers
vim.opt.relativenumber = false

-- Keep signcolumn on by default
vim.opt.signcolumn = "yes"

-- Enable mouse mode, can be useful for resizing splits for example!
vim.opt.mouse = "a"

-- Don't show the mode, since it's already in the status line
vim.opt.showmode = false

-- Enable break indent
vim.opt.breakindent = true

-- Don't wrap lines
vim.opt.wrap = false

-- Save undo history
vim.opt.undofile = true

-- Case-insensitive searching UNLESS \C or one or more capital letters in the search term
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- Decrease update time
vim.opt.updatetime = 250

-- Decrease mapped sequence wait time
-- Displays which-key popup sooner
vim.opt.timeoutlen = 300

-- Configure how new splits should be opened
vim.opt.splitright = true
vim.opt.splitbelow = true
-- LazyVim uses 'screen', which is really cool, but it breaks my muscle memory
-- for "split and go to definition" (-gd)
vim.opt.splitkeep = "cursor"

-- Sets how neovim will display certain whitespace characters in the editor.
--  See `:help 'list'` and `:help 'listchars'`
vim.opt.list = true
vim.opt.listchars = { tab = "  ", trail = "·", nbsp = "␣" }

-- Preview substitutions live, as you type!
vim.opt.inccommand = "split"

-- TODO: Most of these flags should just go into the global rg config file
vim.opt.grepprg = "rg --vimgrep --hidden -i -S"

-- Floating windows (e.g. which-key) should be slightly transparent
vim.opt.winblend = 10

-- Wrap text at 80 characters
vim.opt.textwidth = 80

-- Show only a single status line (at the bottom). LuaLine will handle the rest.
vim.opt.laststatus = 3

vim.opt.tabstop = 8

-- snacks is laaaaggggyyy
vim.g.snacks_animate = false

-- vim: ts=2 sts=2 sw=2 et
