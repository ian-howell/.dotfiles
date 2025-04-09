return {
  {
    "zbirenbaum/copilot.lua",

    opts = {
      panel = { enabled = true },
      suggestion = {
        keymap = {
          -- LazyVim's defaults here are actually pretty nice, since they more or less match vim defaults
          accept_word = "<C-f>",
          accept_line = "<C-l>",
        },
      },
      filetypes = {
        ["*"] = true,
      },
    },

    init = function()
      -- TODO: This just doesn't work. It doesn't even appear to work when I run the command directly. It
      -- works more like 'Copilot disable'
      -- vim.keymap.set('n', '<space>tc', '<cmd>Copilot toggle<CR>', { desc = 'Toggle Copilot' })
      vim.keymap.set("n", "<space>ad", "<cmd>Copilot disable<CR>", { desc = "disable (Copilot)" })
      vim.keymap.set("n", "<space>ae", "<cmd>Copilot enable<CR>", { desc = "enable (Copilot)" })
      vim.keymap.set("n", "<space>ap", "<cmd>Copilot panel<CR>", { desc = "open panel (Copilot)" })
    end,
  },
  {
    "CopilotC-Nvim/CopilotChat.nvim",
    -- TODO: Fix this...
    -- model = "gpt-4.5-preview",
    init = function()
      vim.keymap.set("n", "<space>ac", "<cmd>CopilotChatCommit<CR>", { desc = "(CopilotChat)" })

      -- TODO: Add mappings for these
      --       Commit│
      -- Fix │ │
      -- Tests │
      -- Review│
      -- Docs│ │
      -- Explain
      -- Optimize
    end,
  },
}
-- vim: ts=2 sts=2 sw=2 et
