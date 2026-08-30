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

local function map_command(key, command, desc)
  vim.keymap.set("n", key, function()
    opencode.command(command)
  end, { desc = desc })
end

map_command("<leader>os", "session.select", "Select OpenCode session")
map_command("<leader>on", "session.new", "New OpenCode session")
map_command("<leader>oi", "session.interrupt", "Interrupt OpenCode session")
map_command("<leader>ou", "session.undo", "Undo OpenCode action")
map_command("<leader>or", "session.redo", "Redo OpenCode action")
map_command("<leader>og", "session.first", "First OpenCode message")
map_command("<leader>oG", "session.last", "Last OpenCode message")
map_command("<leader>o<Tab>", "agent.cycle", "Cycle OpenCode agent")
