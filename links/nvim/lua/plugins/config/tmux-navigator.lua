-- Seamless navigation between neovim and tmux panes.

vim.g.tmux_navigator_no_mappings = 1

vim.keymap.set("n", "<c-h>", "<cmd>TmuxNavigateLeft<cr>", { desc = "Tmux navigate left" })
vim.keymap.set("n", "<c-j>", "<cmd>TmuxNavigateDown<cr>", { desc = "Tmux navigate down" })
vim.keymap.set("n", "<c-k>", "<cmd>TmuxNavigateUp<cr>", { desc = "Tmux navigate up" })
vim.keymap.set("n", "<c-l>", "<cmd>TmuxNavigateRight<cr>", { desc = "Tmux navigate right" })
vim.keymap.set("n", "<c-\\>", "<cmd>TmuxNavigatePrevious<cr>", { desc = "Tmux navigate previous" })

vim.keymap.set("t", "<c-h>", "<C-w><cmd>TmuxNavigateLeft<cr>", { desc = "Tmux navigate left" })
vim.keymap.set("t", "<c-j>", "<C-w><cmd>TmuxNavigateDown<cr>", { desc = "Tmux navigate down" })
vim.keymap.set("t", "<c-k>", "<C-w><cmd>TmuxNavigateUp<cr>", { desc = "Tmux navigate up" })
vim.keymap.set("t", "<c-l>", "<C-w><cmd>TmuxNavigateRight<cr>", { desc = "Tmux navigate right" })
vim.keymap.set("t", "<c-\\>", "<C-w><cmd>TmuxNavigatePrevious<cr>", { desc = "Tmux navigate previous" })
