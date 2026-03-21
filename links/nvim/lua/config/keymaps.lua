-- See `:help vim.keymap.set()`

-- Easy access to :split and :vsplit. Use '\' instead of '|' because of Shift.
vim.keymap.set("n", "-", "<cmd>split<CR>", { desc = "Split window horizontally" })
vim.keymap.set("n", "\\", "<cmd>vsplit<CR>", { desc = "Split window vertically" })

-- Swap between buffers
vim.keymap.set("n", "<leader><leader>", "<C-6>", { desc = "[ ] Swap to the last buffer" })

-- Fix the last misspelling
vim.keymap.set("i", "<C-s>", "<C-g>u<Esc>[s1z=`]a<C-g>u", { desc = "Fix the last mispelling" })

-- LazyVim uses H and L to move between buffers. Silly LazyVim, that's useless.
-- This re-enables the much more useful defaults configures more idiomatic
-- bindings to accomplish the same thing.
vim.keymap.del("n", "<S-h>")
vim.keymap.del("n", "<S-l>")
vim.keymap.set("n", "<c-n>", "<cmd>bnext<CR>", { desc = "Go to next buffer" })
vim.keymap.set("n", "<c-p>", "<cmd>bprevious<CR>", { desc = "Go to previous buffer" })

vim.g.cursorcolumn = false
vim.keymap.set("n", "<leader>ux", function()
  vim.g.cursorcolumn = not vim.g.cursorcolumn
  vim.opt_local.cursorcolumn = vim.g.cursorcolumn
end, { desc = "Toggle cursor column" })

-- Git commit in a new window
vim.keymap.set("n", "<leader>gc", function()
  vim.cmd("terminal git commit")
  vim.cmd("startinsert")
end, { desc = "git commit" })

-- Snacks Explorer keymaps
-- Swap these from the LazyVim defaults:
-- - `<leader>fe` should open from project root
-- - `<leader>fE` should open from current buffer dir
vim.keymap.set("n", "<leader>fe", function()
  Snacks.explorer({ cwd = vim.uv.cwd() })
end, { desc = "Explorer (root dir)" })
vim.keymap.set("n", "<leader>fE", function()
  Snacks.explorer({ cwd = LazyVim.root() })
end, { desc = "Explorer (cwd)" })

-- Yank file path to system clipboard
-- If you change colorschemes, update the hex values to match your new palette.
local function set_yank_highlights()
  vim.api.nvim_set_hl(0, "YankMsg", { fg = "#ffffff", bg = "#ff966c" }) -- white text on bright orange
end
set_yank_highlights()
vim.api.nvim_create_autocmd("ColorScheme", {
  callback = set_yank_highlights,
})

vim.keymap.set("n", "<leader>yn", function()
  local name = vim.fn.expand("%:t")
  vim.fn.setreg("+", name)
  vim.api.nvim_echo({ { "Yanked: " .. name, "YankMsg" } }, true, {})
end, { desc = "Yank filename" })
vim.keymap.set("n", "<leader>yr", function()
  local rel = vim.fn.expand("%")
  vim.fn.setreg("+", rel)
  vim.api.nvim_echo({ { "Yanked: " .. rel, "YankMsg" } }, true, {})
end, { desc = "Yank relative path" })
vim.keymap.set("n", "<leader>yp", function()
  local abs = vim.fn.expand("%:p")
  vim.fn.setreg("+", abs)
  vim.api.nvim_echo({ { "Yanked: " .. abs, "YankMsg" } }, true, {})
end, { desc = "Yank absolute path" })

require("which-key").add({
  { "<leader>yn", icon = "󰈔" },
  { "<leader>yr", icon = "󰈔" },
  { "<leader>yp", icon = "󰈔" },
})

-- vim: ts=2 sts=2 sw=2 et
