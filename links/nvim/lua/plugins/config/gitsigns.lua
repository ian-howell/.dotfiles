-- Git signs configuration and keymaps.

local gitsigns = give("gitsigns")
if not gitsigns then
  return
end

gitsigns.setup({
  signs = {
    add = { text = "+" },
    change = { text = "~" },
    delete = { text = "_" },
    topdelete = { text = "~" },
    changedelete = { text = "~" },
  },
  current_line_blame = true,
  current_line_blame_opts = {
    virt_text = true,
    virt_text_pos = "eol",
    delay = 0,
    ignore_whitespace = false,
    virt_text_priority = 100,
    use_focus = true,
  },

  on_attach = function(bufnr)
    local function map(mode, lhs, rhs, opts)
      opts = opts or {}
      opts.buffer = bufnr
      vim.keymap.set(mode, lhs, rhs, opts)
    end

    map("n", "]h", function()
      gitsigns.nav_hunk("next")
    end, { desc = "Jump to next git hunk" })
    map("n", "[h", function()
      gitsigns.nav_hunk("prev")
    end, { desc = "Jump to previous git hunk" })

    map("v", "<leader>gs", function()
      gitsigns.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
    end, { desc = "stage hunk" })

    map("v", "<leader>gr", function()
      gitsigns.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
    end, { desc = "reset hunk" })

    -- Common gitsigns actions.
    -- Docs: https://github.com/lewis6991/gitsigns.nvim#actions
    map("n", "<leader>gr", gitsigns.reset_hunk, { desc = "reset hunk" })
    map("n", "<leader>gR", gitsigns.reset_buffer, { desc = "reset buffer" })
    map("n", "<leader>gs", gitsigns.stage_hunk, { desc = "stage hunk" })
    map("n", "<leader>gS", gitsigns.stage_buffer, { desc = "stage buffer" })
    map("n", "<leader>gp", gitsigns.preview_hunk, { desc = "preview hunk" })
    map("n", "<leader>gi", gitsigns.preview_hunk_inline, { desc = "preview hunk (in line)" })
    map("n", "<leader>gb", gitsigns.blame, { desc = "blame" })

    map("n", "<leader>gd", function()
      vim.cmd("CodeDiff file HEAD")
    end, { desc = "diff against index" })
    map("n", "<leader>gD", "<cmd>CodeDiff file origin/main...<CR>", { desc = "diff against merge-base with main" })

    map("n", "<leader>ub", gitsigns.toggle_current_line_blame, { desc = "toggle inline blame" })
  end,
})
