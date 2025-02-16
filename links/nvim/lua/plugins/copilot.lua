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
      vim.keymap.set("n", "<space>C", "", { desc = "+Copilot" })
      vim.keymap.set("n", "<space>Cd", "<cmd>Copilot disable<CR>", { desc = "disable" })
      vim.keymap.set("n", "<space>Ce", "<cmd>Copilot enable<CR>", { desc = "enable" })
      vim.keymap.set("n", "<space>Cp", "<cmd>Copilot panel<CR>", { desc = "open panel" })
    end,
  },
  {
    "CopilotC-Nvim/CopilotChat.nvim",
    init = function()
      vim.keymap.set("n", "<space>C", "", { desc = "+Copilot" })
      vim.keymap.set({ "n", "x" }, "<space>Cc", "<cmd>CopilotChat<CR>", { desc = "Open Copilot Chat" })
    end,
  },
}
-- vim: ts=2 sts=2 sw=2 et
