-- opencode.nvim: editor context and controls for the OpenCode TUI.

local opencode_cmd = { "opencode", "--continue", "--auto" }
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

vim.g.opencode_opts = {
  server = {
    start = function()
      require("snacks.terminal").open(opencode_cmd, terminal_opts)
    end,
  },
  ask = {
    snacks = {
      win = {
        relative = "editor",
        width = 150,
        max_width = 150,
        height = 8,
        wo = {
          wrap = true,
          linebreak = false,
        },
      },
    },
  },
  events = {
    permissions = {
      enabled = false,
    },
  },
}

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
