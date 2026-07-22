-- Editor options and defaults.
-- See `:help vim.opt`
-- For more options, you can see `:help option-list`

vim.opt.termguicolors = true

vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.g.snacks_animate = false

vim.opt.number = true
vim.opt.relativenumber = false
vim.opt.signcolumn = "yes"

-- Enable mouse mode, can be useful for resizing splits for example!
vim.opt.mouse = "a"

-- Don't show the mode, since it's already in the status line
vim.opt.showmode = false

-- Enable break indent
vim.opt.breakindent = true

-- Wrap lines. This is needed because copilot's suggestions can be very long, and they force the
-- screen to jump around if wrap is disabled.
vim.opt.wrap = true

-- Save undo history
vim.opt.undofile = true

-- Always use the system clipboard; can be slow over SSH
vim.opt.clipboard = "unnamedplus"

-- Case-insensitive searching UNLESS \C or one or more capital letters in the search term
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- Decrease update time
vim.opt.updatetime = 250

-- Decrease mapped sequence wait time
-- Displays which-key popup sooner
vim.opt.timeoutlen = 300
vim.opt.ttimeoutlen = 50

-- Configure how new splits should be opened
vim.opt.splitright = true
vim.opt.splitbelow = true
-- Keep splits anchored to the cursor for "split and go to definition" (-gd).
vim.opt.splitkeep = "cursor"

-- Sets how neovim will display certain whitespace characters in the editor.
--  See `:help 'list'` and `:help 'listchars'`
vim.opt.list = true
vim.opt.listchars = { tab = "| ", trail = "·", nbsp = "␣" }

-- Preview substitutions live, as you type!
vim.opt.inccommand = "split"

-- TODO: Most of these flags should just go into the global rg config file
vim.opt.grepprg = "rg --vimgrep --hidden -i -S"

-- Floating windows (e.g. which-key) should be slightly transparent
vim.opt.winblend = 0

-- Wrap text at 100 characters
vim.opt.textwidth = 100
vim.opt.laststatus = 3

vim.opt.tabstop = 4
vim.opt.expandtab = true

-- omg swap files are the worst
vim.opt.swapfile = false
vim.opt.scrolloff = 0
vim.opt.conceallevel = 0

vim.opt.completeopt = { "menuone", "popup", "noinsert" }

-- floating windows should have a borderby default
vim.o.winborder = "rounded"

-- Treesitter-based folding
vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.opt.foldlevelstart = 99 -- open all folds when opening a file
vim.opt.foldenable = true
vim.opt.foldtext = "" -- preserve syntax highlighting on the fold line
