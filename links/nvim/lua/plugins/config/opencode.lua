-- opencode.nvim: editor context and controls for the OpenCode TUI.

local opencode_cmd = { "opencode", "--port", "--continue", "--auto" }
local terminal_opts = {
  auto_insert = false,
  env = {
    EDITOR = "nvim",
    VISUAL = "nvim",
  },
  win = {
    position = "right",
    width = 0.45,
    on_buf = function(win)
      vim.bo[win.buf].buflisted = true
    end,
  },
}

require("opencode.config").opts.server.start = function()
  require("snacks.terminal").open(opencode_cmd, terminal_opts)
end

require("opencode.config").opts.events.permissions.enabled = false

local opencode = require("opencode")

local function maximize_terminal()
  local terminal = require("snacks.terminal").get(opencode_cmd, terminal_opts)
  terminal:show():focus()
  vim.cmd.stopinsert()
  vim.cmd.only()
end

vim.keymap.set("n", "<leader>oo", maximize_terminal, { desc = "Maximize OpenCode terminal" })

vim.keymap.set({ "n", "x" }, "<leader>ot", function()
  opencode.ask("@this: ")
end, { desc = "Send this to OpenCode" })

vim.keymap.set("n", "<leader>oi", function()
  opencode.ask()
end, { desc = "Send a message to OpenCode" })

vim.keymap.set({ "n", "x" }, "<leader>op", function()
  opencode.select()
end, { desc = "OpenCode menu" })

local function map_command(key, command, desc)
  vim.keymap.set("n", key, function()
    opencode.command(command)
  end, { desc = desc })
end

vim.keymap.set("n", "<leader>os", function()
  require("opencode.server.discovery")
    .get()
    :next(function(server)
      return require("opencode.ui.select_session").select_session(server):next(function(session)
        return server:select_session(session.id)
      end)
    end)
    :catch(function(err)
      if err then
        vim.notify(err, vim.log.levels.ERROR, { title = "opencode" })
      end
    end)
end, { desc = "Select OpenCode session" })

map_command("<leader>ou", "session.undo", "Undo OpenCode action")
map_command("<leader>or", "session.redo", "Redo OpenCode action")
map_command("<leader>og", "session.first", "First OpenCode message")
map_command("<leader>oG", "session.last", "Last OpenCode message")
map_command("<leader>o<Tab>", "agent.cycle", "Cycle OpenCode agent")
