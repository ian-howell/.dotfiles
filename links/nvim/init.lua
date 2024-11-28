-- Lua resources:
--  - https://learnxinyminutes.com/docs/lua/
--  - :help lua-guide (or HTML version): https://neovim.io/doc/user/lua-guide.html

-- Set <space> as the leader key
-- NOTE: Must happen before plugins are loaded (otherwise wrong leader will be used)
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Set to true if you have a Nerd Font installed and selected in the terminal
vim.g.have_nerd_font = true

-- [[ Setting options ]]
-- See `:help vim.opt`
-- For more options, you can see `:help option-list`

-- Make line numbers default
vim.opt.number = true

-- Enable mouse mode, can be useful for resizing splits for example!
vim.opt.mouse = 'a'

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

-- Sets how neovim will display certain whitespace characters in the editor.
--  See `:help 'list'` and `:help 'listchars'`
vim.opt.list = true
vim.opt.listchars = { tab = '  ', trail = '·', nbsp = '␣' }

-- Preview substitutions live, as you type!
vim.opt.inccommand = 'split'

-- TODO: Most of these flags should just go into the global rg config file
vim.opt.grepprg = 'rg --vimgrep --hidden -i -S'

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

-- Floating windows (e.g. which-key) should be slightly transparent
vim.opt.winblend = 10

-- Wrap text at 110 characters
vim.opt.textwidth = 110

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
-- Turn off highlighting when done searching
vim.api.nvim_create_autocmd('CmdlineLeave', {
  desc = 'Stop highlighting after searching',
  group = vim.api.nvim_create_augroup('stop-highlighting-after-search', { clear = true }),
  callback = function()
    vim.opt.hlsearch = false
  end,
})

-- [[ Basic Keymaps ]]
-- See `:help vim.keymap.set()`

-- Toggle highlights
vim.keymap.set('n', '<leader>th', '<cmd>set hlsearch!<CR>')

-- Easy access to :split and :vsplit. Use '\' instead of '|' because of Shift.
vim.keymap.set('n', '-', ':split<CR>', { desc = 'Split window horizontally' })
vim.keymap.set('n', '\\', ':vsplit<CR>', { desc = 'Split window vertically' })

-- Use CTRL+<hjkl> to switch between windows
--
-- See `:help wincmd` for a list of all window commands
vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })

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

-- Cooler Grep
vim.keymap.set('n', '<space>/', function()
  local query = vim.fn.input '/'
  if query ~= '' then
    vim.cmd('silent! grep! ' .. query)
    vim.cmd 'cwindow'

    -- Check if the quickfix list is empty
    local qf_list = vim.fn.getqflist()
    if vim.tbl_isempty(qf_list) then
      -- vim.api.nvim_err_writeln 'rg: no results found.'
      vim.api.nvim_err_writeln(vim.opt.grepprg:get() .. ' ' .. query .. ': no results found.')
    end
  end
end, { desc = 'Grep' })

-- Swap between buffers
vim.keymap.set('n', '<leader><leader>', '<C-6>', { desc = '[ ] Swap to the last buffer' })

-- TODO: Figure out how to get put this with the GitSigns config
-- vim.keymap.set('n', '<space>tg', ':Gitsigns toggle_linehl<cr>', { desc = 'git diff' })
vim.keymap.set('n', '<space>tg', function()
  vim.cmd 'Gitsigns toggle_linehl'
end, { desc = 'git diff' })

-- [[ Basic Autocommands ]]
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

  -- TODO: This is not working as expected
  if vim.bo.ft == 'gitcommit' then
    return -- We don't want to do this for git commit messages
  end

  vim.cmd 'normal! g`"' -- Jump to the last known cursor position
end

vim.api.nvim_create_autocmd('BufReadPost', {
  desc = 'Recall cursor position',
  group = vim.api.nvim_create_augroup('recall-position', { clear = true }),
  callback = RecallLastPosition,
})

-- [[ Install `lazy.nvim` plugin manager ]]
require 'lazy-bootstrap' -- ~/.config/nvim/lua/lazy-bootstrap.lua

-- [[ Configure and install plugins ]]
require('lazy').setup({
  -- Detect tabstop and shiftwidth automatically
  'tpope/vim-sleuth',

  -- NOTE: Plugins can also be added by using a table,
  -- with the first argument being the link and the following
  -- keys can be used to configure plugin behavior/loading/etc.
  --
  -- Use `opts = {}` to force a plugin to be loaded.
  --

  -- Here is a more advanced example where we pass configuration
  -- options to `gitsigns.nvim`. This is equivalent to the following Lua:
  --    require('gitsigns').setup({ ... })
  --
  -- See `:help gitsigns` to understand what the configuration keys do
  { -- Adds git related signs to the gutter, as well as utilities for managing changes
    'lewis6991/gitsigns.nvim',
    opts = {
      -- Change the highlight of the signs column if there's git changes
      numhl = true,
      -- Since we're using numhl, we don't need gitsigns to open the sign column
      signcolumn = false,
    },
  },

  -- NOTE: Plugins can also be configured to run Lua code when they are loaded.
  --
  -- This is often very useful to both group configuration, as well as handle
  -- lazy loading plugins that don't need to be loaded immediately at startup.
  --
  -- For example, in the following configuration, we use:
  --  event = 'VimEnter'
  --
  -- which loads which-key before all the UI elements are loaded. Events can be
  -- normal autocommands events (`:help autocmd-events`).
  --
  -- Then, because we use the `config` key, the configuration only runs
  -- after the plugin has been loaded:
  --  config = function() ... end

  require 'plugins/which-key', -- ~/.config/nvim/lua/plugins/which-key.lua

  -- NOTE: Plugins can specify dependencies.
  --
  -- The dependencies are proper plugin specifications as well - anything
  -- you do for a plugin at the top level, you can do for a dependency.
  --
  -- Use the `dependencies` key to specify the dependencies of a particular plugin

  require 'plugins/telescope',      -- ~/.config/nvim/lua/plugins/telescope.lua

  require 'plugins/lsp',            -- ~/.config/nvim/lua/plugins/lsp.lua

  require 'plugins/autocompletion', -- ~/.config/nvim/lua/plugins/autocompletion.lua

  require 'plugins/tokyonight',     -- ~/.config/nvim/lua/plugins/tokyonight.lua

  require 'plugins/todo-comments',  -- ~/.config/nvim/lua/plugins/todo-comments.lua

  require 'plugins/mini',           -- ~/.config/nvim/lua/plugins/mini.lua

  require 'plugins/smooth',         -- ~/.config/nvim/lua/plugins/smooth.lua

  require 'plugins/treesitter',     -- ~/.config/nvim/lua/plugins/treesitter.lua

  require 'plugins/surround',       -- ~/.config/nvim/lua/plugins/surround.lua

  require 'plugins/tmux-navigator', -- ~/.config/nvim/lua/plugins/tmux-navigator.lua

  require 'plugins/copilot',        -- ~/.config/nvim/lua/plugins/copilot.lua

  require 'plugins/aerial',         -- ~/.config/nvim/lua/plugins/aerial.lua

  {                                 -- Vim-go
    'fatih/vim-go',
    ft = { 'go', 'gomod', },
  },
  {
    -- TODO: Look into this one, it looks cool.
    -- But for right now, it's breaking normal keybindings in quickfix windows...
    -- {
    --   'kevinhwang91/nvim-bqf',
    --   opts = {
    --     auto_enable = true,
    --     auto_resize_height = true,
    --   },
    -- },
  },

  -- The following comments only work if you have downloaded the kickstart repo, not just copy pasted the
  -- init.lua. If you want these files, they are in the repository, so you can just download them and
  -- place them in the correct locations.

  -- NOTE: Next step on your Neovim journey: Add/Configure additional plugins for Kickstart
  --
  --  Here are some example plugins that I've included in the Kickstart repository.
  --  Uncomment any of the lines below to enable them (you will need to restart nvim).
  --
  -- require 'kickstart.plugins.debug',
  -- require 'kickstart.plugins.indent_line',
  -- require 'kickstart.plugins.lint',
  -- require 'kickstart.plugins.autopairs',
  -- require 'kickstart.plugins.neo-tree',
  -- require 'kickstart.plugins.gitsigns', -- adds gitsigns recommend keymaps

  -- NOTE: The import below can automatically add your own plugins, configuration, etc from `lua/custom/plugins/*.lua`
  --    This is the easiest way to modularize your config.
  --
  --  Uncomment the following line and add your plugins to `lua/custom/plugins/*.lua` to get going.
  -- { import = 'custom.plugins' },
  --
  -- For additional information with loading, sourcing and examples see `:help lazy.nvim-🔌-plugin-spec`
  -- Or use telescope!
  -- In normal mode type `<space>sh` then write `lazy.nvim-plugin`
  -- you can continue same window with `<space>sr` which resumes last telescope search
}, {
  ui = {
    -- If you are using a Nerd Font: set icons to an empty table which will use the
    -- default lazy.nvim defined Nerd Font icons, otherwise define a unicode icons table
    icons = vim.g.have_nerd_font and {} or {
      cmd = '⌘',
      config = '🛠',
      event = '📅',
      ft = '📂',
      init = '⚙',
      keys = '🗝',
      plugin = '🔌',
      runtime = '💻',
      require = '🌙',
      source = '📄',
      start = '🚀',
      task = '📌',
      lazy = '💤 ',
    },
  },
})

-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et
