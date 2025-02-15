return {
  { -- Fuzzy Finder (files, lsp, etc)
    'ibhagwan/fzf-lua',
    event = 'VimEnter',
    config = function()
      local fzf = require 'fzf-lua'
      local actions = require('fzf-lua').actions

      fzf.setup {
        actions = {
          -- Below are the default actions, setting any value in these tables will override
          -- the defaults, to inherit from the defaults change [1] from `false` to `true`
          files = {
            true, -- uncomment to inherit all the below in your custom config
            -- Pickers inheriting these actions:
            --   files, git_files, git_status, grep, lsp, oldfiles, quickfix, loclist,
            --   tags, btags, args, buffers, tabs, lines, blines
            -- `file_edit_or_qf` opens a single selection or sends multiple selection to quickfix
            -- replace `enter` with `file_edit` to open all files/bufs whether single or multiple
            -- replace `enter` with `file_switch_or_edit` to attempt a switch in current tab first
            ['enter'] = actions.file_edit_or_qf,
            -- These are mapped below using on_create. I can only use singular keys in this section
            -- ['<space>-'] = actions.file_split,
            -- ['<space>\\'] = actions.file_vsplit,
            ['ctrl-t'] = actions.file_tabedit,
            ['ctrl-q'] = {
              -- Move all selected items to quickfix list
              fn = actions.file_edit_or_qf,
              prefix = 'select-all+',
            },
          },
        },

        winopts = {
          fullscreen = true,
          on_create = function()
            vim.keymap.set('t', '<space>-', '<c-s>', { desc = 'split' })
            vim.keymap.set('t', '<space>\\', '<c-v>', { desc = 'vsplit' })
          end,
        },

        defaults = {
          git_icons = true,
          file_icons = false,
        },
      }

      vim.keymap.set('n', '<space>ff', fzf.files, { desc = 'files' })
      vim.keymap.set('n', '<space>fh', fzf.help_tags, { desc = 'help' })
      vim.keymap.set('n', '<space>fk', fzf.keymaps, { desc = 'keymaps' })
      vim.keymap.set('n', '<space>fp', fzf.builtin, { desc = 'picker' })
      vim.keymap.set('n', '<space>/', fzf.live_grep, { desc = 'grep' })
      vim.keymap.set('n', '<space>*', fzf.grep_cword, { desc = 'word under the cursor' })
      vim.keymap.set('x', '<space>*', fzf.grep_visual, { desc = 'grep' })
      vim.keymap.set('n', '<space>fd', fzf.diagnostics_document, { desc = 'diagnostics (file)' })
      vim.keymap.set('n', '<space>fD', fzf.diagnostics_workspace, { desc = 'diagnostics (project)' })
      vim.keymap.set('n', '<space>fr', fzf.resume, { desc = 'resume' })
      vim.keymap.set('n', '<space>ft', fzf.treesitter, { desc = 'treesitter' })
      vim.keymap.set('n', '<space>fq', fzf.quickfix, { desc = 'quickfix' })
      vim.keymap.set('n', '<space>fQ', fzf.quickfix_stack, { desc = 'previous quickfix lists' })
      vim.keymap.set('n', '<space>fL', fzf.lines, { desc = 'all buffer lines' })
      vim.keymap.set('n', '<space>fl', fzf.blines, { desc = 'current buffer lines' })
      vim.keymap.set('n', '<space>bb', fzf.buffers, { desc = 'buffers' })

      vim.keymap.set('n', '<space>fg', fzf.git_status, { desc = 'git files' })
      vim.keymap.set('n', '<space>gl', fzf.git_commits, { desc = 'git log' })
      vim.keymap.set('n', '<space>gh', fzf.git_bcommits, { desc = 'git log for file' })
    end,
  },
}
-- vim: ts=2 sts=2 sw=2 et
