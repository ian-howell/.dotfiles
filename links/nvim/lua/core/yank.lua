-- Shared helper for yanking values to the system clipboard with feedback.

local M = {}

local function set_highlights()
  local light = vim.o.background == "light"
  vim.api.nvim_set_hl(0, "YankMsg", { fg = "#ffffff", bg = light and "#b15c00" or "#ff966c" })
end

set_highlights()
vim.api.nvim_create_autocmd("ColorScheme", {
  desc = "Reset yank notification highlight",
  callback = set_highlights,
})

function M.to_clipboard(value)
  vim.fn.setreg("+", value)
  vim.api.nvim_echo({ { "Yanked: " .. value, "YankMsg" } }, true, {})
end

return M
