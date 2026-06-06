local opts = {
  highlights = {
    line_insert = "DiffAdd",
    line_delete = "DiffDelete",
    char_insert = nil,
    char_delete = nil,
    char_brightness = nil,
    conflict_sign = nil,
    conflict_sign_resolved = nil,
    conflict_sign_accepted = nil,
    conflict_sign_rejected = nil,
  },
  diff = {
    layout = "side-by-side",
    disable_inlay_hints = true,
    max_computation_time_ms = 5000,
    ignore_trim_whitespace = false,
    hide_merge_artifacts = false,
    original_position = "left",
    conflict_ours_position = "right",
    conflict_result_position = "bottom",
    conflict_result_height = 30,
    conflict_result_width_ratio = { 1, 1, 1 },
    cycle_next_hunk = false,
    cycle_next_file = false,
    jump_to_first_change = false,
    highlight_priority = 100,
    compute_moves = false,
  },
  explorer = {
    position = "left",
    width = 40,
    height = 15,
    indent_markers = true,
    initial_focus = "explorer",
    view_mode = "tree",
    flatten_dirs = true,
    file_filter = { ignore = { ".git/**" } },
    focus_on_select = true,
    status_right_margin = 1,
    visible_groups = {
      staged = true,
      unstaged = true,
      conflicts = true,
    },
  },
  history = {
    position = "bottom",
    width = 40,
    height = 15,
    initial_focus = "history",
    view_mode = "list",
  },
  keymaps = {
    view = {
      show_help = "g?",
      quit = "q",
      toggle_explorer = "<leader>E",
      focus_explorer = "<leader>e",
      next_hunk = "]h",
      prev_hunk = "[h",
      next_file = "]H",
      prev_file = "[H",
      diff_get = "do",
      diff_put = "dp",
      open_in_prev_tab = "gf",
      close_on_open_in_prev_tab = true,
      hunk_textobject = "ih",
      align_move = "gm",
      toggle_layout = "<leader>gt",
      stage_hunk = nil,
      unstage_hunk = nil,
      discard_hunk = nil,
      toggle_stage = "<leader>gs",
    },
    explorer = {
      select = "<CR>",
      hover = "K",
      refresh = "R",
      toggle_view_mode = "t",
      stage_all = "a",
      unstage_all = "U",
      restore = "X",
      toggle_changes = "gu",
      toggle_staged = "gs",
      fold_open = "zo",
      fold_open_recursive = "zO",
      fold_close = "zc",
      fold_close_recursive = "zC",
      fold_toggle = "za",
      fold_toggle_recursive = "zA",
      fold_open_all = "zR",
      fold_close_all = "zM",
    },
    history = {
      select = "<CR>",
      toggle_view_mode = "i",
      refresh = "R",
      fold_open = "zo",
      fold_open_recursive = "zO",
      fold_close = "zc",
      fold_close_recursive = "zC",
      fold_toggle = "za",
      fold_toggle_recursive = "zA",
      fold_open_all = "zR",
      fold_close_all = "zM",
    },
    conflict = {
      accept_incoming = "<leader>ct",
      accept_current = "<leader>co",
      accept_both = "<leader>cb",
      discard = "<leader>cx",
      accept_all_incoming = "<leader>cT",
      accept_all_current = "<leader>cO",
      accept_all_both = "<leader>cB",
      discard_all = "<leader>cX",
      next_conflict = "]x",
      prev_conflict = "[x",
      diffget_incoming = "2do",
      diffget_current = "3do",
    },
  },
}

require("codediff").setup(opts)

vim.keymap.set("n", "<leader>gd", "<cmd>CodeDiff<CR>", { desc = "Git diff" })
vim.keymap.set("n", "<leader>gD", function()
  local merge_base = vim.fn.system("git merge-base origin/main HEAD"):gsub("%s+", "")
  if vim.v.shell_error == 0 and merge_base ~= "" then
    vim.cmd("CodeDiff main...HEAD")
  else
    vim.notify("Could not find merge-base with origin/main", vim.log.levels.WARN)
  end
end, { desc = "Git diff against merge-base" })

vim.api.nvim_create_autocmd("User", {
  pattern = { "CodeDiffOpen", "CodeDiffFileSelect" },
  callback = function(args)
    require("review.ado_pr_comments").setup(args.data.tabpage)
  end,
})
