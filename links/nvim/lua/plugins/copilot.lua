return {
  {
    "zbirenbaum/copilot.lua",
    opts = {
      suggestion = {
        keymap = {
          -- NOTE: accept_word and accept_line won't work util https://github.com/Saghen/blink.cmp/issues/1498 is addressed
        },
      },
      filetypes = {
        ["*"] = true,
      },
      nes = {
        enabled = false,
      },
    },

    init = function()
      -- TODO: This just doesn't work. It doesn't even appear to work when I run the command directly. It
      -- works more like 'Copilot disable'
      -- vim.keymap.set('n', '<space>tc', '<cmd>Copilot toggle<CR>', { desc = 'Toggle Copilot' })
      vim.keymap.set("n", "<space>ad", "<cmd>Copilot disable<CR>", { desc = "disable (Copilot)" })
      vim.keymap.set("n", "<space>ae", "<cmd>Copilot enable<CR>", { desc = "enable (Copilot)" })
    end,
  },
  {
    "olimorris/codecompanion.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    opts = {
      display = {
        chat = {
          auto_scroll = false,
        },
      },
    },
    keys = {
      { "<leader>a", "", desc = "+ai", mode = { "n", "v" } },
      {
        "<leader>aa",
        "<cmd>CodeCompanionChat Toggle<CR>",
        desc = "toggle chat (CodeCompanion)",
        mode = { "n", "v" },
      },
      {
        "<leader>af",
        "<cmd>CodeCompanion Identify the problem in this code and fix it. You may use the #{buffer} if necesary, but please focus specifically on the provided code.<CR>",
        desc = "fix (CodeCompanion)",
        mode = { "v" },
      },
      {
        "<leader>ar",
        "<cmd>CodeCompanionChat Please review this code. You may use the #{buffer} if necesary, but please focus specifically on the provided code.<CR>",
        desc = "review (CodeCompanion)",
        mode = { "v" },
      },
      {
        "<leader>ad",
        "<cmd>CodeCompanion Please add documentation to this code. If the selected code contains a function, class, or struct header, please add the appropriate doc string, adhering to idiomatic standards for the programming language<CR>",
        desc = "docs (CodeCompanion)",
        mode = { "v" },
      },
      {
        "<leader>ae",
        "<cmd>CodeCompanionChat Could you explain what this code does?. You may use the #{buffer} if necesary, but please focus specifically on the provided code.<CR>",
        desc = "explain (CodeCompanion)",
        mode = { "v" },
      },
      {
        "<leader>aq",
        ":CodeCompanionChat ",
        desc = "quick (CodeCompanion)",
        mode = { "n", "v" },
      },
    },
  },
}
-- vim: ts=2 sts=2 sw=2 et
