-- TODO: figure out how to create directory if it doesn't exist when saving
-- Check out how plugins do it

-- require("config/focus.lua")

-- Fuzzy find files
vim.keymap.set("n", "<space>ff", function() 
	-- TODO: Call fzf and use output as an argument to :e
end
)

-- Reload configuration
vim.keymap.set("n", "<space>V", "<cmd>source $MYVIMRC<cr>")

-- Open help
vim.keymap.set("n", "<space>vh",":vert help ")

-- Open file explorer
vim.keymap.set("n", "fe", "<cmd>15Lexplore<cr>")


-- Window navigation
vim.keymap.set({"n", "x"}, "<c-j>", "<c-w>j")
vim.keymap.set({"n", "x"}, "<c-k>", "<c-w>k")
vim.keymap.set({"n", "x"}, "<c-h>", "<c-w>h")
vim.keymap.set({"n", "x"}, "<c-l>", "<c-w>l")

-- Quickfix

-- vim.o.undo = true
-- vim.o.swap = false
