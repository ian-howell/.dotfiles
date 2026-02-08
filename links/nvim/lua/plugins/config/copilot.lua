require("copilot").setup({
  suggestion = {
    enabled = true,
    auto_trigger = true,
    keymap = {
      accept = "<C-y>",
      accept_word = "<C-f>",
      accept_line = "<C-l>",
    },
  },
  panel = { enabled = true },
})
