-- vi-mode.lua — render a captured tmux pane inside neovim.
--
-- Loaded via `nvim +luafile` against a temp file holding a pane snapshot. The
-- raw file contains ANSI colour escapes; this script replays those bytes into a
-- terminal buffer so the output renders with its original colours, while still
-- allowing vim motions/search/yank over it.

-- The file's lines start as a normal buffer; pull them out, then drop trailing
-- blank lines so the capture doesn't end in a wedge of empty rows.
local orig_buf = vim.api.nvim_get_current_buf()
local lines = vim.api.nvim_buf_get_lines(orig_buf, 0, -1, false)
while #lines > 0 and vim.trim(lines[#lines]) == "" do
  lines[#lines] = nil
end

-- Create the scratch buffer and DISPLAY it before opening the terminal. Order is
-- load-bearing: nvim_open_term sizes the pty to the window showing the buffer, so
-- the buffer must be visible and the UI finalised (gutter/statusline/cmdline gone)
-- first. Opening the terminal while the buffer is hidden makes the pty taller than
-- the final window, leaving unreachable blank rows below the content.
local buf = vim.api.nvim_create_buf(false, true)
vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
vim.api.nvim_set_current_buf(buf)
vim.api.nvim_open_term(buf, {})

-- Strip all gutter/decoration so the capture lines up cell-for-cell with the
-- original pane.
local function strip_ui()
  vim.opt_local.number = false
  vim.opt_local.relativenumber = false
  vim.opt_local.signcolumn = "no"
  vim.opt_local.statuscolumn = ""
  vim.opt_local.foldcolumn = "0"
  vim.opt_local.cursorcolumn = false
  vim.opt_local.colorcolumn = ""
  vim.opt_local.list = false
  vim.o.laststatus = 0
  vim.o.cmdheight = 0
end
strip_ui()

-- core/autocmds.lua re-enables number/signcolumn/cursorline/colorcolumn on focus
-- events; re-run strip_ui after those so the gutter stays gone. Defined later than
-- that autocmd, so it wins for the same event.
vim.api.nvim_create_autocmd({ "BufEnter", "WinEnter", "FocusGained" }, {
  buffer = buf,
  callback = strip_ui,
})

-- q quits the whole capture window.
vim.keymap.set("n", "q", "<cmd>qa!<cr>", { silent = true, buffer = buf })
-- so does <Esc> in normal mode, but not in visual mode.
vim.keymap.set("n", "<Esc>", "<cmd>qa!<cr>", { silent = true, buffer = buf })
-- and enter in visual mode copies then quits, just like the default tmux copy-mode binding.
vim.keymap.set("x", "<cr>", function()
  vim.cmd('normal! "vy') -- yank the visual selection

  -- The below is required to avoid a race condition: `"+y` hands the text to
  -- nvim's clipboard provider, which launches the clipboard tool (e.g. xclip)
  -- as a background job and returns IMMEDIATELY — it does not wait. The
  -- following `:qa!` then kills nvim's child jobs, including that tool. If the
  -- kill wins the race the copy is lost.
  -- To fix this, we hand the selection to `tmux load-buffer`, which blocks.
  vim.fn.system({ "tmux", "load-buffer", "-w", "-" }, vim.fn.getreg("v"))
  vim.cmd("qa!")
end, { silent = true, buffer = buf })

vim.opt_local.cursorline = true

-- Initial cursor placement + action, set by the key that opened the capture (see
-- use-vim-for-tmux-copy-mode). Deferred so the terminal has finished painting.
local action = vim.env.VICOPY_ACTION or "normal"
vim.defer_fn(function()
  -- Restore the pane's cursor in every mode. The visible screen is the last
  -- pane_height rows of the capture, so the buffer row is the scrollback above
  -- the screen plus cursor_y. orig_buf still holds the untrimmed capture.
  local cy = tonumber(vim.env.VICOPY_CY) or 0
  local cx = tonumber(vim.env.VICOPY_CX) or 0
  local ph = tonumber(vim.env.VICOPY_PH) or 0
  local total = vim.api.nvim_buf_line_count(orig_buf)
  local row = math.min(math.max(0, total - ph) + cy + 1, vim.api.nvim_buf_line_count(buf))
  pcall(vim.api.nvim_win_set_cursor, 0, { row, cx })

  if action == "flash" then
    pcall(function()
      require("flash").jump()
    end)
  elseif action == "search" then
    vim.api.nvim_feedkeys("/", "n", false) -- interactive forward search
  end
end, 10)
