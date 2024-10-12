-- Background colors for active vs inactive windows
vim.cmd("highlight link ActiveWindow Normal")
-- NOTE:: "black" here means "transparent"
vim.cmd("highlight InactiveWindow guibg=black")
vim.opt.winhighlight = "Normal:ActiveWindow,NormalNC:InactiveWindow"

-- Change highlight group of active/inactive windows
local function HandleFocusEnter()
  vim.opt.cursorline = true
  vim.opt.cursorcolumn = true
  vim.opt.colorcolumn = "80"
  vim.cmd("setlocal winhighlight=Normal:ActiveWindow,NormalNC:InactiveWindow")
end

local function HandleFocusLeave()
  vim.opt.cursorline = false
  vim.opt.cursorcolumn = false
  vim.opt.colorcolumn = ""
  vim.cmd("setlocal winhighlight=Normal:InactiveWindow,NormalNC:InactiveWindow")
end

-- Only highlight the active window
vim.api.nvim_create_autocmd({ "WinEnter", "FocusGained" }, {
  callback = HandleFocusEnter,
})
vim.api.nvim_create_autocmd({ "WinLeave", "FocusLost" }, {
  callback = HandleFocusLeave,
})
