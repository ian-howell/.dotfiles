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
    opts = {
      model = "gpt-4o",
      -- model = "gpt-4.5-preview",
    },
    keys = {
      {
        "<space>ac",
        "<cmd>CopilotChatCommit<CR>",
        desc = "commit (CopilotChat)",
        mode = { "n", "v" },
      },
      {
        "<space>af",
        "<cmd>CopilotChatFix<CR>",
        desc = "fix (CopilotChat)",
        mode = { "n", "v" },
      },
      {
        "<space>at",
        "<cmd>CopilotChatTests<CR>",
        desc = "tests (CopilotChat)",
        mode = { "n", "v" },
      },
      {
        "<space>ar",
        "<cmd>CopilotChatReview<CR>",
        desc = "review (CopilotChat)",
        mode = { "n", "v" },
      },
      {
        "<space>ad",
        "<cmd>CopilotChatDocs<CR>",
        desc = "docs (CopilotChat)",
        mode = { "n", "v" },
      },
      {
        "<space>ae",
        "<cmd>CopilotChatExplain<CR>",
        desc = "explain (CopilotChat)",
        mode = { "n", "v" },
      },
      {
        "<space>ao",
        "<cmd>CopilotChatOptimize<CR>",
        desc = "optimize (CopilotChat)",
        mode = { "n", "v" },
      },
    },
  },
}
-- vim: ts=2 sts=2 sw=2 et
