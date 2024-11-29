-- Lua resources:
--  - https://learnxinyminutes.com/docs/lua/
--  - :help lua-guide (or HTML version): https://neovim.io/doc/user/lua-guide.html

-- Set <space> as the leader key
-- NOTE: Must happen before plugins are loaded (otherwise wrong leader will be used)
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Set to true if you have a Nerd Font installed and selected in the terminal
vim.g.have_nerd_font = true

require 'options'        -- ~/.config/nvim/lua/options.lua

require 'keymaps'        -- ~/.config/nvim/lua/keymaps.lua

require 'autocommands'   -- ~/.config/nvim/lua/autocommands.lua

require 'focus'          -- ~/.config/nvim/lua/focus.lua

require 'lazy-bootstrap' -- ~/.config/nvim/lua/lazy-bootstrap.lua

require 'plugins'        -- ~/.config/nvim/lua/plugins.lua

-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et
