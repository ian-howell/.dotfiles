return {
  {
    "zbirenbaum/copilot.lua",
    dependencies = {
      "copilotlsp-nvim/copilot-lsp", -- (optional) for NES functionality
    },

    opts = {
      panel = { enabled = true },
      suggestion = {
        keymap = {
          -- NOTE: accept_word and accept_line won't work util https://github.com/Saghen/blink.cmp/issues/1498 is addressed
        },
      },
      filetypes = {
        ["*"] = true,
      },
      nes = {
        enabled = true, -- requires copilot-lsp as a dependency
        auto_trigger = true,
        keymap = {
          accept_and_goto = "<leader>ag",
          accept = "<leader>ac",
          dismiss = "<C-]>",
        },
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
          layout = "vertical",
          relative = "win",
          width = 0.5,
        },
        mappings = {
          submit_prompt = {
            insert = "<cr>",
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
      { "<leader>ac", "<cmd>CopilotChatClose<CR>", desc = "close (CopilotChat)", mode = { "n", "v" } },
      { "<leader>af", "<cmd>CopilotChatFix<CR>", desc = "fix (CopilotChat)", mode = { "v" } },
      { "<leader>ar", "<cmd>CopilotChatReview<CR>", desc = "review (CopilotChat)", mode = { "v" } },
      { "<leader>ad", "<cmd>CopilotChatDocs<CR>", desc = "docs (CopilotChat)", mode = { "v" } },
      { "<leader>ae", "<cmd>CopilotChatExplain<CR>", desc = "explain (CopilotChat)", mode = { "v" } },
      {
        "<leader>ao",
        function()
          require("CopilotChat").open({
            window = {
              layout = "vertical",
              relative = "win",
              width = 0.5,
            },
          })
          -- Go to bottom and enter insert mode
          vim.schedule(function()
            vim.cmd("normal! G") -- Go to the last line
            vim.cmd("startinsert!") -- Enter insert mode. The ! makes it work like 'A'
          end)
        end,
        desc = "open (CopilotChat)",
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
        desc = "quick (CopilotChat)",
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
        end,
      })

      chat.setup(opts)
    end,
  },
}
-- vim: ts=2 sts=2 sw=2 et
