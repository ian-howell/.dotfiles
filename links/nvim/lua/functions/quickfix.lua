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

return M
