-- Lua resources:
--  - https://learnxinyminutes.com/docs/lua/
--  - :help lua-guide (or HTML version): https://neovim.io/doc/user/lua-guide.html

vim.g.have_nerd_font = true

require 'options'        -- ~/.config/nvim/lua/options.lua

require 'keymaps'        -- ~/.config/nvim/lua/keymaps.lua

require 'autocommands'   -- ~/.config/nvim/lua/autocommands.lua

require 'focus'          -- ~/.config/nvim/lua/focus.lua

require 'lazy-bootstrap' -- ~/.config/nvim/lua/lazy-bootstrap.lua

require 'plugins'        -- ~/.config/nvim/lua/plugins.lua

-- vim: ts=2 sts=2 sw=2 et
