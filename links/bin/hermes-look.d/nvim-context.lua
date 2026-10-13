-- Describe what the user sees in Neovim: file, cursor, selection, visible lines.
-- Evaluated via `nvim --remote-expr 'luaeval("dofile(...)")'`; returns markdown.
local mode = vim.fn.mode()
local ft = vim.bo.filetype
local out = {
  "File: " .. vim.fn.expand("%:p"),
  "Mode: " .. mode,
  ("Cursor: line %d, col %d"):format(vim.fn.line("."), vim.fn.col(".")),
  "",
}

local live = mode:match("^[vV\22]") ~= nil
local p1 = vim.fn.getpos(live and "v" or "'<")
local p2 = vim.fn.getpos(live and "." or "'>")
if p1[2] > 0 and p2[2] > 0 then
  local vtype = live and mode or vim.fn.visualmode()
  if vtype == "" then vtype = "v" end
  table.insert(out, ("%s (lines %d-%d):"):format(live and "Selection" or "Last visual selection",
    math.min(p1[2], p2[2]), math.max(p1[2], p2[2])))
  table.insert(out, "```" .. ft)
  vim.list_extend(out, vim.fn.getregion(p1, p2, { type = vtype }))
  table.insert(out, "```")
  table.insert(out, "")
end

local top, bot = vim.fn.line("w0"), vim.fn.line("w$")
table.insert(out, ("Visible window (lines %d-%d):"):format(top, bot))
table.insert(out, "```" .. ft)
vim.list_extend(out, vim.api.nvim_buf_get_lines(0, top - 1, bot, false))
table.insert(out, "```")
return table.concat(out, "\n")
