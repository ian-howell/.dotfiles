require("copilot").setup({
  suggestion = {
    enabled = true,
    auto_trigger = true,
    trigger_on_accept = true,
    -- blink.cmp's keymap layer (plugins/config/completion.lua) dispatches
    -- <C-y>/<C-f>/<C-l>/<C-e> to Copilot when its ghost text is visible, so
    -- Copilot must not install its own buffer-local mappings for these keys.
    keymap = {
      accept = false,
      accept_word = false,
      accept_line = false,
      dismiss = false,
    },
  },
  panel = {
    enabled = true,
    auto_refresh = true,
  },
  filetypes = {
    ["*"] = true,
  },
  server_opts_overrides = {
    flags = {
      -- Work around Neovim 0.12.2 incremental sync assertions in Copilot buffers.
      allow_incremental_sync = false,
    },
  },
  nes = {
    enabled = false,
  },
})

vim.keymap.set("n", "<leader>ad", "<cmd>Copilot disable<CR>", { desc = "Disable Copilot" })
vim.keymap.set("n", "<leader>ae", "<cmd>Copilot enable<CR>", { desc = "Enable Copilot" })
