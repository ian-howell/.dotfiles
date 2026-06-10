-- Git signs configuration and keymaps.

local gitsigns = require("gitsigns")
local yank = require("core.yank")

-- Yank the full hash of the last commit that touched the current line.
-- Uses `--contents -` so locally-modified lines report as uncommitted rather
-- than yanking a misleading hash.
local function yank_line_commit()
  local file = vim.api.nvim_buf_get_name(0)
  if file == "" then
    vim.notify("No file for the current buffer", vim.log.levels.WARN)
    return
  end

  local line = vim.fn.line(".")
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  local result = vim.system({
    "git",
    "blame",
    "--porcelain",
    "--contents",
    "-",
    "-L",
    line .. "," .. line,
    "--",
    file,
  }, {
    cwd = vim.fn.fnamemodify(file, ":h"),
    stdin = table.concat(lines, "\n") .. "\n",
  }):wait()

  if result.code ~= 0 then
    vim.notify("git blame failed: " .. (result.stderr or ""), vim.log.levels.ERROR)
    return
  end

  local hash = (result.stdout or ""):match("^(%x+)")
  if not hash then
    vim.notify("Could not parse commit hash from git blame", vim.log.levels.ERROR)
    return
  end

  if hash:match("^0+$") then
    vim.notify("Line is not yet committed", vim.log.levels.WARN)
    return
  end

  yank.to_clipboard(hash)
end

gitsigns.setup({
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

    map("v", "<leader>gs", function()
      gitsigns.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
    end, { desc = "stage hunk" })

    map("v", "<leader>gr", function()
      gitsigns.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
    end, { desc = "reset hunk" })

    map("n", "<leader>gs", gitsigns.stage_hunk, { desc = "stage hunk" })
    map("n", "<leader>gr", gitsigns.reset_hunk, { desc = "reset hunk" })
    map("n", "<leader>gS", gitsigns.stage_buffer, { desc = "stage buffer" })
    map("n", "<leader>gu", gitsigns.undo_stage_hunk, { desc = "undo stage hunk" })
    map("n", "<leader>gR", gitsigns.reset_buffer, { desc = "reset buffer" })
    map("n", "<leader>gp", gitsigns.preview_hunk, { desc = "preview hunk" })
    map("n", "<leader>gb", gitsigns.blame_line, { desc = "blame line" })
    map({ "n", "x" }, "<leader>go", function()
      require("snacks").gitbrowse({ what = "file", branch = "main" })
    end, { desc = "open in browser (main)" })
    map({ "n", "x" }, "<leader>gO", function()
      require("snacks").gitbrowse({ what = "permalink" })
    end, { desc = "open permalink in browser" })
    map({ "n", "x" }, "<leader>gY", function()
      require("snacks").gitbrowse({
        what = "permalink",
        notify = false,
        open = function(url)
          yank.to_clipboard(url)
        end,
      })
    end, { desc = "yank permalink" })
    map("n", "<leader>gy", yank_line_commit, { desc = "yank line commit hash" })
    map("n", "<leader>ub", gitsigns.toggle_current_line_blame, { desc = "inline blame" })
  end,
})
