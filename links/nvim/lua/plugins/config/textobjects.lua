-- Treesitter-based motions.
require("nvim-treesitter-textobjects").setup({ move = { set_jumps = true } })

local move = require("nvim-treesitter-textobjects.move")

--   `]f`/`[f` - next/previous function definition start
vim.keymap.set({ "n", "x", "o" }, "]f", function()
  move.goto_next_start({ "@function.outer" }, "textobjects")
end, { desc = "Next function definition" })
vim.keymap.set({ "n", "x", "o" }, "[f", function()
  move.goto_previous_start({ "@function.outer" }, "textobjects")
end, { desc = "Previous function definition" })
