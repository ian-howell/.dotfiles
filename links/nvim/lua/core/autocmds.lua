-- Autocommands and event-driven behavior.

local groups = {
	focus_enter = vim.api.nvim_create_augroup("focus-enter", { clear = true }),
	focus_leave = vim.api.nvim_create_augroup("focus-leave", { clear = true }),
}

vim.api.nvim_create_autocmd({ "BufLeave", "WinLeave", "FocusLost" }, {
	desc = "Hide focused-only UI when window loses focus",
	group = groups.focus_leave,
	callback = function()
		vim.opt_local.number = false
		vim.opt_local.signcolumn = "no"
		vim.opt_local.cursorline = false
		vim.opt_local.cursorcolumn = false
		vim.opt_local.colorcolumn = ""
	end,
})

vim.api.nvim_create_autocmd({ "BufEnter", "WinEnter", "FocusGained" }, {
	desc = "Show focused-only UI when window gains focus",
	group = groups.focus_enter,
	callback = function()
		vim.opt_local.number = true
		vim.opt_local.signcolumn = "yes"
		vim.opt_local.cursorline = true
		vim.opt_local.cursorcolumn = vim.g.cursorcolumn
		vim.opt_local.colorcolumn = tostring(vim.opt_local.textwidth:get())
	end,
})

return groups
