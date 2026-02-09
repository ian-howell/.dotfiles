-- Keymaps and related helper logic.
-- See `:help vim.keymap.set()`

-- Easy access to :split and :vsplit. Use '\' instead of '|' because of Shift.
vim.keymap.set("n", "-", "<cmd>split<CR>", { desc = "Split window horizontally" })
vim.keymap.set("n", "\\", "<cmd>vsplit<CR>", { desc = "Split window vertically" })

vim.g.cursorcolumn = vim.opt.cursorcolumn:get()
vim.keymap.set("n", "<leader>ux", function()
  vim.g.cursorcolumn = not vim.g.cursorcolumn
  vim.opt.cursorcolumn = vim.g.cursorcolumn
  vim.opt_local.cursorcolumn = vim.g.cursorcolumn
end, { desc = "Toggle cursor column" })

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
