-- Keymaps and related helper logic.
-- See `:help vim.keymap.set()`

-- Easy access to :split and :vsplit. Use '\' instead of '|' because of Shift.
vim.keymap.set("n", "-", "<cmd>split<CR>", { desc = "Split window horizontally" })
vim.keymap.set("n", "\\", "<cmd>vsplit<CR>", { desc = "Split window vertically" })

vim.keymap.set("n", "<leader><leader>", "<C-6>", { desc = "Swap to the last buffer" })
vim.keymap.set("i", "<C-s>", "<C-g>u<Esc>[s1z=`]a<C-g>u", { desc = "Fix the last misspelling" })
vim.keymap.set("n", "<C-n>", "<cmd>bnext<CR>", { desc = "Go to next buffer" })
vim.keymap.set("n", "<C-p>", "<cmd>bprevious<CR>", { desc = "Go to previous buffer" })

vim.g.cursorcolumn = vim.opt.cursorcolumn:get()
vim.keymap.set("n", "<leader>ux", function()
  vim.g.cursorcolumn = not vim.g.cursorcolumn
  vim.opt.cursorcolumn = vim.g.cursorcolumn
  vim.opt_local.cursorcolumn = vim.g.cursorcolumn
end, { desc = "Toggle cursor column" })

vim.keymap.set("n", "<leader>uw", function()
  vim.opt_local.wrap = not vim.opt_local.wrap:get()
end, { desc = "Toggle wrap" })

vim.keymap.set("n", "<leader>gc", function()
  vim.cmd("terminal git commit")
  vim.cmd("startinsert")
end, { desc = "Git commit" })

-- Smart line-edge motions: H/L jump to the first/last non-blank character when
-- the cursor is in the middle of the line, and fall back to their native
-- screen-edge behavior once already at that edge (or when a count is given).
local function smart_home()
  if vim.v.count > 0 then
    return "H"
  end
  local line = vim.fn.getline(".")
  local first_nonblank = vim.fn.match(line, "\\S") -- 0-indexed byte, -1 when blank
  if first_nonblank < 0 or (vim.fn.col(".") - 1) <= first_nonblank then
    return "H"
  end
  return "_"
end

local function smart_end()
  if vim.v.count > 0 then
    return "L"
  end
  local trimmed = (vim.fn.getline("."):gsub("%s+$", ""))
  local last_nonblank = #trimmed -- 1-indexed byte col of last non-blank, 0 when blank
  if last_nonblank == 0 or vim.fn.col(".") >= last_nonblank then
    return "L"
  end
  return "g_"
end

vim.keymap.set({ "n", "x" }, "H", smart_home, { expr = true, desc = "First non-blank char / top of screen" })
vim.keymap.set({ "n", "x" }, "L", smart_end, { expr = true, desc = "Last non-blank char / bottom of screen" })

local yank = require("core.yank")

vim.keymap.set("n", "<leader>yn", function()
  yank.to_clipboard(vim.fn.expand("%:t"))
end, { desc = "Yank filename" })

vim.keymap.set("n", "<leader>yr", function()
  yank.to_clipboard(vim.fn.expand("%"))
end, { desc = "Yank relative path" })

vim.keymap.set("n", "<leader>yp", function()
  yank.to_clipboard(vim.fn.expand("%:p"))
end, { desc = "Yank absolute path" })

vim.keymap.set({ "n", "x" }, "<leader>at", function()
  local path = vim.fn.expand("%:p")
  local mode = vim.fn.mode()

  if mode == "v" or mode == "V" or mode == "\22" then
    local start_pos = vim.fn.getpos("v")
    local end_pos = vim.fn.getpos(".")

    local srow, scol = start_pos[2], start_pos[3]
    local erow, ecol = end_pos[2], end_pos[3]

    if erow < srow or (erow == srow and ecol < scol) then
      srow, erow = erow, srow
      scol, ecol = ecol, scol
    end

    local text
    if srow == erow then
      text = string.format("@%s :L%d:C%d-C%d", path, srow, scol, ecol)
    else
      text = string.format("@%s :L%d:C%d-L%d:C%d", path, srow, scol, erow, ecol)
    end

    vim.fn.setreg("+", text)
    return
  end

  local pos = vim.api.nvim_win_get_cursor(0)
  local row = pos[1]
  local col = pos[2] + 1
  local text = string.format("@%s :L%d:C%d", path, row, col)
  vim.fn.setreg("+", text)
end, { desc = "Copy line and column info" })
