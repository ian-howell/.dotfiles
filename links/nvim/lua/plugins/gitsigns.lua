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
      on_attach = function(bufnr)
        local gitsigns = require("gitsigns")

        local function map(mode, l, r, opts)
          opts = opts or {}
          opts.buffer = bufnr
          vim.keymap.set(mode, l, r, opts)
        end

        -- Navigation
        map("n", "]c", function()
          if vim.wo.diff then
            vim.cmd.normal({ "]c", bang = true })
          else
            gitsigns.nav_hunk("next")
          end
        end, { desc = "Jump to next git change" })

        map("n", "[c", function()
          if vim.wo.diff then
            vim.cmd.normal({ "[c", bang = true })
          else
            gitsigns.nav_hunk("prev")
          end
        end, { desc = "Jump to previous git change" })

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
        map("n", "<space>gd", gitsigns.diffthis, { desc = "diff against index" })
        map("n", "<space>gD", function()
          gitsigns.diffthis("@")
        end, { desc = "diff against last commit" })

        -- Toggles
        map("n", "<space>tb", gitsigns.toggle_current_line_blame, { desc = "inline blame" })
        -- TODO: Figure out what this does
        map("n", "<space>tD", gitsigns.toggle_deleted, { desc = "deleted lines from index" })
      end,
    },
  },
}

-- vim: ts=2 sts=2 sw=2 et
