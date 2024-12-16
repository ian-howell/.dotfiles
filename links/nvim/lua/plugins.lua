-- [[ Configure and install plugins ]]

require('lazy').setup({
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
  --
  -- NOTE: Plugins can specify dependencies.
  --
  -- The dependencies are proper plugin specifications as well - anything
  -- you do for a plugin at the top level, you can do for a dependency.
  --
  -- Use the `dependencies` key to specify the dependencies of a particular plugin

  require 'plugins/aerial', -- ~/.config/nvim/lua/plugins/aerial.lua
  require 'plugins/autocompletion', -- ~/.config/nvim/lua/plugins/autocompletion.lua
  require 'plugins/autoformat', -- ~/.config/nvim/lua/plugins/autoformat.lua
  require 'plugins/autopairs', -- ~/.config/nvim/lua/plugins/autopairs.lua
  require 'plugins/copilot', -- ~/.config/nvim/lua/plugins/copilot.lua
  require 'plugins/gitsigns', -- ~/.config/nvim/lua/plugins/gitsigns.lua
  require 'plugins/lsp', -- ~/.config/nvim/lua/plugins/lsp.lua
  require 'plugins/mini', -- ~/.config/nvim/lua/plugins/mini.lua
  require 'plugins/noice', -- ~/.config/nvim/lua/plugins/noice.lua
  require 'plugins/sleuth', -- ~/.config/nvim/lua/plugins/sleuth.lua
  require 'plugins/smooth', -- ~/.config/nvim/lua/plugins/smooth.lua
  require 'plugins/surround', -- ~/.config/nvim/lua/plugins/surround.lua
  require 'plugins/telescope', -- ~/.config/nvim/lua/plugins/telescope.lua
  require 'plugins/tmux-navigator', -- ~/.config/nvim/lua/plugins/tmux-navigator.lua
  require 'plugins/todo-comments', -- ~/.config/nvim/lua/plugins/todo-comments.lua
  require 'plugins/tokyonight', -- ~/.config/nvim/lua/plugins/tokyonight.lua
  require 'plugins/treesitter', -- ~/.config/nvim/lua/plugins/treesitter.lua
  require 'plugins/go', -- ~/.config/nvim/lua/plugins/go.lua
  require 'plugins/which-key', -- ~/.config/nvim/lua/plugins/which-key.lua
  require 'plugins/zenmode', -- ~/.config/nvim/lua/plugins/zenmode.lua

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
  -- require 'kickstart.plugins.lint',
  -- require 'kickstart.plugins.neo-tree',

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

-- vim: ts=2 sts=2 sw=2 et
