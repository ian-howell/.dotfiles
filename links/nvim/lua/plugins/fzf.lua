return {
  { -- Fuzzy Finder (files, lsp, etc)
    "ibhagwan/fzf-lua",
    event = "VimEnter",
    keys = {
      { "<space>ff", "<cmd>FzfLua files cwd<cr>", desc = "files (cwd)" },
      {
        "<space>fF",
        function()
          FzfLua.files({ cwd = LazyVim.root() })
        end,
        desc = "files (root)",
      },
      { "<space>fh", "<cmd>FzfLua help_tags<cr>", desc = "help" },
      { "<space>fk", "<cmd>FzfLua keymaps<cr>", desc = "keymaps" },
      { "<space>fp", "<cmd>FzfLua builtin<cr>", desc = "picker" },
      { "<space>/", "<cmd>FzfLua live_grep<cr>", desc = "grep" },
      { "<space>*", "<cmd>FzfLua grep_cword<cr>", desc = "word under the cursor", mode = "n" },
      { "<space>*", "<cmd>FzfLua grep_visual<cr>", desc = "grep", mode = "x" },
      { "<space>fd", "<cmd>FzfLua diagnostics_document<cr>", desc = "diagnostics (file)" },
      { "<space>fD", "<cmd>FzfLua diagnostics_workspace<cr>", desc = "diagnostics (project)" },
      { "<space>fr", "<cmd>FzfLua resume<cr>", desc = "resume" },
      { "<space>ft", "<cmd>FzfLua treesitter<cr>", desc = "treesitter" },
      { "<space>fq", "<cmd>FzfLua quickfix<cr>", desc = "quickfix" },
      { "<space>fQ", "<cmd>FzfLua quickfix_stack<cr>", desc = "previous quickfix lists" },
      { "<space>fL", "<cmd>FzfLua lines<cr>", desc = "all buffer lines" },
      { "<space>fl", "<cmd>FzfLua blines<cr>", desc = "current buffer lines" },
      { "<space>bb", "<cmd>FzfLua buffers<cr>", desc = "buffers" },
      { "<space>fg", "<cmd>FzfLua git_status<cr>", desc = "git files" },
      { "<space>gl", "<cmd>FzfLua git_commits<cr>", desc = "git log" },
      { "<space>gh", "<cmd>FzfLua git_bcommits<cr>", desc = "git log for file" },
      {
        "<space>fG",
        function()
          local mergeBase = vim.fn.system("git merge-base origin/main HEAD")
          mergeBase = vim.trim(mergeBase) -- Remove trailing newline
          require("fzf-lua").git_diff({ ref = mergeBase })
        end,
        desc = "git diff since branching from main",
      },
    },
    config = function()
      local fzf = require("fzf-lua")
      local actions = require("fzf-lua").actions

      fzf.setup({
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
            ["enter"] = actions.file_edit_or_qf,
            -- These are mapped below using on_create. I can only use singular keys in this section
            -- ['<space>-'] = actions.file_split,
            -- ['<space>\\'] = actions.file_vsplit,
            ["ctrl-t"] = actions.file_tabedit,
            ["ctrl-q"] = {
              -- Move all selected items to quickfix list
              fn = actions.file_edit_or_qf,
              prefix = "select-all+",
            },
          },
        },

        winopts = {
          fullscreen = true,
          on_create = function()
            vim.keymap.set("t", "<space>-", "<c-s>", { desc = "split" })
            vim.keymap.set("t", "<space>\\", "<c-v>", { desc = "vsplit" })
            vim.keymap.set("t", "<c-j>", "<c-n>", { desc = "next item" })
            vim.keymap.set("t", "<c-k>", "<c-p>", { desc = "previous item" })
          end,
        },

        fzf_opts = {
          ["--header"] = "<alt-i>: ignore  <alt-h>: hidden\n<c-q>: all -> qf  <alt-q>: selected -> qf",
          ["--header-first"] = true,
        },

        defaults = {
          git_icons = true,
          file_icons = false,
        },

        files = {
          hidden = true,
        },
      })
    end,
  },
}
-- vim: ts=2 sts=2 sw=2 et
