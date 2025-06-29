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
    branch = "main",
    cmd = "CopilotChat",
    opts = function()
      return {
        model = "claude-sonnet-4",
        auto_insert_mode = false,
        question_header = "  Ian ",
        answer_header = "  Copilot ",
        highlight_headers = true, -- Highlight headers in chat, disable if using markdown renderers (like render-markdown.nvim)
        show_help = true,
        auto_follow_cursor = false,
        window = {
          layout = "horizontal",
          relative = "win",
          width = 1,
          height = 0.4,
          row = 10000, -- The first row is 1. This puts the bottom of the window at the bottom of the screen
        },
        mappings = {
          submit_prompt = {
            insert = "<C-d>",
          },
          reset = {
            normal = "gx",
            insert = nil,
          },
          accept_diff = {
            normal = "ga",
            insert = nil,
          },
        },
      }
    end,
    keys = {
      { "<leader>a", "", desc = "+ai", mode = { "n", "v" } },
      { "<leader>ac", "<cmd>CopilotChatCommit<CR>", desc = "commit (CopilotChat)", mode = { "n", "v" } },
      { "<leader>af", "<cmd>CopilotChatFix<CR>", desc = "fix (CopilotChat)", mode = { "n", "v" } },
      { "<leader>ar", "<cmd>CopilotChatReview<CR>", desc = "review (CopilotChat)", mode = { "n", "v" } },
      { "<leader>ad", "<cmd>CopilotChatDocs<CR>", desc = "docs (CopilotChat)", mode = { "v" } },
      { "<leader>ae", "<cmd>CopilotChatExplain<CR>", desc = "explain (CopilotChat)", mode = { "n", "v" } },
      { "<leader>ao", "<cmd>CopilotChatOptimize<CR>", desc = "optimize (CopilotChat)", mode = { "n", "v" } },
      {
        "<leader>aa",
        function()
          local window = require("CopilotChat").chat
          if window and window:visible() then
            window:close()
            return
          end
          require("CopilotChat").open({
            window = {
              layout = "horizontal",
              relative = "win",
              width = 1,
              height = 0.4,
              row = 10000, -- The first row is 1. This puts the bottom of the window at the bottom of the screen
            },
          })
        end,
        desc = "Toggle (CopilotChat)",
        mode = { "n", "v" },
      },
      {
        "<leader>aF",
        function()
          local window = require("CopilotChat").chat
          if window and window:visible() then
            require("CopilotChat").close()
          end

          require("CopilotChat").open({
            window = {
              layout = "replace",
            },
          })
        end,
        desc = "Fullscreen (CopilotChat)",
        mode = { "n", "v" },
      },
      {
        "<leader>ax",
        function()
          return require("CopilotChat").reset()
        end,
        desc = "Clear (CopilotChat)",
        mode = { "n", "v" },
      },
      {
        "<leader>as",
        function()
          return require("CopilotChat").stop()
        end,
        desc = "Stop (CopilotChat)",
        mode = { "n", "v" },
      },
      {
        "<leader>aq",
        function()
          vim.ui.input({
            prompt = "Quick Chat: ",
          }, function(input)
            if input ~= "" then
              require("CopilotChat").ask(input)
            end
          end)
        end,
        desc = "Quick Chat (CopilotChat)",
        mode = { "n", "v" },
      },
    },
    config = function(_, opts)
      local chat = require("CopilotChat")

      vim.api.nvim_create_autocmd("BufEnter", {
        pattern = "copilot-chat",
        callback = function()
          vim.opt_local.relativenumber = false
          vim.opt_local.number = false
          vim.opt_local.conceallevel = 0
        end,
      })

      chat.setup(opts)
    end,
  },
}
-- vim: ts=2 sts=2 sw=2 et
