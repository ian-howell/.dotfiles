return {
  { -- Fuzzy Finder (files, lsp, etc)
    'nvim-telescope/telescope.nvim',
    event = 'VimEnter',
    branch = '0.1.x',
    dependencies = {
      'nvim-lua/plenary.nvim',
      { -- If encountering errors, see telescope-fzf-native README for installation instructions
        'nvim-telescope/telescope-fzf-native.nvim',

        -- `build` is used to run some command when the plugin is installed/updated.
        -- This is only run then, not every time Neovim starts up.
        build = 'make',

        -- `cond` is a condition used to determine whether this plugin should be
        -- installed and loaded.
        cond = function()
          return vim.fn.executable 'make' == 1
        end,
      },
      { 'nvim-telescope/telescope-ui-select.nvim' },

      -- Useful for getting pretty icons, but requires a Nerd Font.
      { 'nvim-tree/nvim-web-devicons', enabled = vim.g.have_nerd_font },
    },
    config = function()
      -- See `:help telescope` and `:help telescope.setup()`
      require('telescope').setup {
        -- You can put your default mappings / updates / etc. in here
        --  All the info you're looking for is in `:help telescope.setup()`
        --
        defaults = {
          layout_strategy = 'vertical',
          layout_config = {
            vertical = {
              width = 0.9,
              height = 0.9,
              preview_height = 0.75,
              prompt_position = 'bottom',
            },
          },
          mappings = {
            i = {
              ['<space><cr>'] = 'to_fuzzy_refine',
              ['<space>\\'] = 'select_vertical',
              ['<space>-'] = 'select_horizontal',
            },
            n = {
              ['<space>\\'] = 'select_vertical',
              ['<space>-'] = 'select_horizontal',
            },
          },
          -- Make the picker window slightly transparent
          winblend = 10,
          -- No need to put a title on the "Results" window
          results_title = false,

          -- This is more or less the defaults, except that we add hidden files
          -- Several of these are simply required for telescope to work correctly.
          -- See `:help telescope.defaults.vimgrep_arguments` for details
          -- TODO: find out if this will just work with the default rg settings
          vimgrep_arguments = {
            'rg',
            '--color=never',
            '--no-heading',
            '--with-filename',
            '--line-number',
            '--column',
            '--smart-case',
            '--hidden',
          },
          file_ignore_patterns = { '.git/' },
        },
        pickers = {
          find_files = {
            hidden = true,
          },
        },
        extensions = {
          ['ui-select'] = {
            require('telescope.themes').get_dropdown(),
          },
        },
      }

      -- Enable Telescope extensions if they are installed
      pcall(require('telescope').load_extension, 'fzf')
      pcall(require('telescope').load_extension, 'ui-select')

      -- See `:help telescope.builtin`
      local builtin = require 'telescope.builtin'
      vim.keymap.set('n', '<space>sh', builtin.help_tags, { desc = 'help' })
      vim.keymap.set('n', '<space>sk', builtin.keymaps, { desc = 'keymaps' })
      vim.keymap.set('n', '<space>ff', builtin.find_files, { desc = 'files' })
      vim.keymap.set('n', '<space>ss', builtin.builtin, { desc = 'select telescope' })
      vim.keymap.set('n', '<space>*', builtin.grep_string, { desc = 'word under the cursor' })
      vim.keymap.set('n', '<space>/', builtin.live_grep, { desc = 'grep' })
      vim.keymap.set('n', '<space>sd', builtin.diagnostics, { desc = 'diagnostics' })
      vim.keymap.set('n', '<space>sr', builtin.resume, { desc = 'resume' })
      vim.keymap.set('n', '<space>fr', builtin.oldfiles, { desc = 'recent files ("." for repeat)' })
      vim.keymap.set('n', '<space>bb', builtin.buffers, { desc = 'buffers' })

      -- It's also possible to pass additional configuration options.
      --  See `:help telescope.builtin.live_grep()` for information about particular keys
      vim.keymap.set('n', '<space>b/', function()
        builtin.live_grep {
          grep_open_files = true,
          prompt_title = 'Grep in Buffers',
        }
      end, { desc = 'grep in buffers' })

      -- Shortcut for searching your Neovim configuration files
      vim.keymap.set('n', '<space>sn', function()
        builtin.find_files { cwd = vim.fn.stdpath 'config' }
      end, { desc = 'neovim files' })

      vim.api.nvim_create_autocmd('User', {
        pattern = 'TelescopePreviewerLoaded',
        callback = function()
          vim.api.nvim_set_option_value('number', true, { scope = 'local' })
        end,
      })
    end,
  },
}
-- vim: ts=2 sts=2 sw=2 et
