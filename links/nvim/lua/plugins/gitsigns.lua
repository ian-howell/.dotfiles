return {
  { -- Git signs
    "lewis6991/gitsigns.nvim",
    opts = {
      signs = {
        add = { text = "+" },
        change = { text = "~" },
        delete = { text = "_" },
        topdelete = { text = "‾" },
        changedelete = { text = "~" },
      },
      current_line_blame = true,
      current_line_blame_opts = {
        virt_text = true,
        virt_text_pos = "eol", -- 'eol' | 'overlay' | 'right_align'
        delay = 0,
        ignore_whitespace = false,
        virt_text_priority = 100,
        -- Enable only when buffer is in focus
        use_focus = true,
      },
      on_attach = function(bufnr)
        local gitsigns = require("gitsigns")

        local function map(mode, l, r, opts)
          opts = opts or {}
          opts.buffer = bufnr
          vim.keymap.set(mode, l, r, opts)
        end

        -- Navigation
        map("n", "]h", function()
          if vim.wo.diff then
            vim.cmd.normal({ "]h", bang = true })
          else
            gitsigns.nav_hunk("next")
          end
        end, { desc = "Jump to next git hunk" })

        map("n", "[h", function()
          if vim.wo.diff then
            vim.cmd.normal({ "[h", bang = true })
          else
            gitsigns.nav_hunk("prev")
          end
        end, { desc = "Jump to previous git hunk" })

        -- Actions
        -- visual mode
        map("v", "<space>gs", function()
          gitsigns.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
        end, { desc = "stage hunk" })
        map("v", "<space>gr", function()
          gitsigns.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
        end, { desc = "reset hunk" })
        -- normal mode
        map("n", "<space>gs", gitsigns.stage_hunk, { desc = "stage hunk" })
        map("n", "<space>gr", gitsigns.reset_hunk, { desc = "reset hunk" })
        map("n", "<space>gS", gitsigns.stage_buffer, { desc = "stage buffer" })
        map("n", "<space>gu", gitsigns.undo_stage_hunk, { desc = "undo stage hunk" })
        map("n", "<space>gR", gitsigns.reset_buffer, { desc = "reset buffer" })
        map("n", "<space>gp", gitsigns.preview_hunk, { desc = "preview hunk" })
        map("n", "<space>gb", gitsigns.blame_line, { desc = "blame line" })
        map({ "n", "x" }, "<space>go", function()
          Snacks.gitbrowse({ what = "permalink" })
        end, { desc = "open in browser" })
        map("n", "<space>gd", function()
          vim.cmd("CodeDiff file HEAD")
        end, { desc = "diff against index" })
        map("n", "<space>gD", function()
          local merge_base = vim.fn.system("git merge-base origin/main HEAD"):gsub("%s+", "")
          if vim.v.shell_error == 0 and merge_base ~= "" then
            vim.cmd("CodeDiff file " .. merge_base .. " HEAD")
          else
            vim.notify("Could not find merge-base with origin/main", vim.log.levels.WARN)
          end
        end, { desc = "diff against merge-base with main" })

        -- Toggles
        map("n", "<space>tb", gitsigns.toggle_current_line_blame, { desc = "inline blame" })
        -- TODO: Figure out what this does
        map("n", "<space>tD", gitsigns.toggle_deleted, { desc = "deleted lines from index" })
      end,
    },
  },
}

-- vim: ts=2 sts=2 sw=2 et
