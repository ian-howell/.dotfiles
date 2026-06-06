local M = {}

local function open_current_entry(command)
  local list = vim.fn.getqflist()
  if not list or #list == 0 then
    return
  end

  local entry = list[vim.fn.line(".")]
  if not entry or not entry.bufnr then
    return
  end

  vim.cmd(string.format("wincmd p | %s | buffer %d | %d | cclose", command, entry.bufnr, entry.lnum))
end

function M.open_in_split()
  open_current_entry("split")
end

function M.open_in_vsplit()
  open_current_entry("vsplit")
end

return M
