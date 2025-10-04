-- Automatically create missing directories on save
vim.api.nvim_create_autocmd("BufWritePre", {
  callback = function(event)
    local file = event.match
    if file:match("^%w%w+://") then return end -- skip URIs
    local dir = vim.fn.fnamemodify(file, ":p:h")
    if dir ~= "" and vim.fn.isdirectory(dir) == 0 then
      vim.fn.mkdir(dir, "p")
    end
  end,
})

-- require("config/focus.lua")

-- TODO: Fuzzy find files

-- Reload configuration
vim.keymap.set("n", "<space>V", "<cmd>source $MYVIMRC<cr>")

-- Open help
vim.keymap.set("n", "<space>vh", ":vert help ")

-- Open file explorer
vim.keymap.set("n", "fe", "<cmd>15Lexplore<cr>")

-- Window navigation
vim.keymap.set({"n", "x"}, "<c-j>", "<c-w>j")
vim.keymap.set({"n", "x"}, "<c-k>", "<c-w>k")
vim.keymap.set({"n", "x"}, "<c-h>", "<c-w>h")
vim.keymap.set({"n", "x"}, "<c-l>", "<c-w>l")

-- Undo / swap settings
vim.o.undofile = true
vim.o.swapfile = false

-- TODO: Figure this one out
vim.o.botright = true
