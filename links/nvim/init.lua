-- Tokyonight colorscheme
do
  vim.pack.add({
    { name = "tokyonight", src = "https://github.com/folke/tokyonight.nvim", checkout = "4d159616aee17796c2c94d2f5f87d2ee1a3f67c7"},
  })
  require("tokyonight").setup({
    style = "storm",
    on_highlights = function(hl)
      -- ColorColumn should be invisible except on the active cursor line (using cursorline)
      hl.ColorColumn = { bg = hl.Normal.bg }
    end,
  })
  vim.cmd.colorscheme("tokyonight")
end

-- TODO: plugins

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
-- TODO: :help :restart has hints on sessions and plugins
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

-- Quickfix
vim.keymap.set("n", "<space>qo", "<cmd>copen<cr>")
-- TODO: Figure out how to do this with just 'q' when you're in the qflist
vim.keymap.set("n", "<space>qc", "<cmd>cclose<cr>")

-- Undo / swap settings
vim.o.undofile = true
vim.o.swapfile = false

-- Window placement: open splits to the right / below
vim.o.splitright = true
vim.o.splitbelow = true
