local M = {}

function M.toggleQuickFix()
  for _, win in ipairs(vim.fn.getwininfo()) do
    -- TODO: This has some weirdness with location lists
    if win.quickfix == 1 then
      vim.cmd 'cclose | wincmd p'
      return
    end
  end
  vim.cmd 'copen'
end

-- openInSplit opens the current quickfix entry in a split window.
-- It is intended to be called from within a quickfix window.
function M.openInSplit()
  local qf = vim.fn.getqflist()
  if not qf or #qf == 0 then
    return
  end
  local entry = qf[vim.fn.line '.']
  if not entry or not entry.bufnr then
    return
  end
  -- go back to the previous window, split it, and open the buffer to the quickfix entry
  vim.cmd(string.format('wincmd p | split | buffer %d | %d | cclose', entry.bufnr, entry.lnum))
end

-- openInVsplit opens the current quickfix entry in a vsplit window.
-- It is intended to be called from within a quickfix window.
function M.openInVsplit()
  local qf = vim.fn.getqflist()
  if not qf or #qf == 0 then
    return
  end
  local entry = qf[vim.fn.line '.']
  if not entry or not entry.bufnr then
    return
  end
  -- go back to the previous window, vsplit it, and open the buffer to the quickfix entry
  vim.cmd(string.format('wincmd p | vsplit | buffer %d | %d | cclose', entry.bufnr, entry.lnum))
end

return M
