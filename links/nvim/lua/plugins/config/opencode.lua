-- opencode.nvim: editor context and controls for the OpenCode TUI.

local opencode_cmd = { "opencode", "--port", "--continue", "--auto" }
local terminal_opts = {
  env = {
    EDITOR = "nvim",
    VISUAL = "nvim",
  },
  win = {
    position = "right",
    width = 0.45,
  },
}

require("opencode.config").opts.server.start = function()
  require("snacks.terminal").open(opencode_cmd, terminal_opts)
end

local opencode = require("opencode")

local function toggle_terminal()
  require("snacks.terminal").toggle(opencode_cmd, terminal_opts)
end

vim.keymap.set("n", "<leader>ot", toggle_terminal, { desc = "Toggle OpenCode terminal" })

vim.keymap.set({ "n", "x" }, "<leader>oa", function()
  opencode.ask("@this: ")
end, { desc = "Ask OpenCode about this" })

vim.keymap.set({ "n", "x" }, "<leader>om", function()
  opencode.select()
end, { desc = "OpenCode menu" })
