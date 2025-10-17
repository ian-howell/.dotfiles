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
    "folke/sidekick.nvim",
    opts = {
      cli = {
        mux = {
          enabled = true,
          backend = "tmux",
        },
        -- Example of how to add a prompt for use with <leader>ap or :Sidekick cli prompt.
        -- prompts = {
        --   refactor = "Please refactor {this} to be more maintainable",
        --   security = "Review {file} for security vulnerabilities",
        --   custom = function(ctx)
        --     return "Current file: " .. ctx.buf .. " at line " .. ctx.row
        --   end,
        -- },
      },
    },

    event = "VeryLazy",

    keys = {
      {
        "<tab>",
        function()
          -- if there is a next edit, jump to it, otherwise apply it if any
          if require("sidekick").nes_jump_or_apply() then
            return -- jumped or applied
          end

          -- if you are using Neovim's native inline completions
          if vim.lsp.inline_completion.get() then
            return
          end

          -- any other things (like snippets) you want to do on <tab> go here.

          -- fall back to normal tab
          return "<tab>"
        end,
        mode = { "i", "n" },
        expr = true,
        desc = "Goto/Apply Next Edit Suggestion",
      },
      {
        "<leader>aa",
        function()
          require("sidekick.cli").toggle()
        end,
        desc = "Sidekick Toggle CLI",
      },
      {
        "<leader>at",
        function()
          require("sidekick.cli").send({ msg = "{this}" })
        end,
        mode = { "x", "n" },
        desc = "Send This",
      },
      {
        "<leader>av",
        function()
          require("sidekick.cli").send({ msg = "{selection}" })
        end,
        mode = { "x" },
        desc = "Send Visual Selection",
      },
      {
        "<leader>ap",
        function()
          require("sidekick.cli").prompt()
        end,
        mode = { "n", "x" },
        desc = "Sidekick Select Prompt",
      },
      {
        "<c-.>",
        function()
          require("sidekick.cli").focus()
        end,
        mode = { "n", "x", "i", "t" },
        desc = "Sidekick Switch Focus",
      },

      -- Context & Navigation
      {
        "<leader>af",
        function()
          require("sidekick.cli").send({ msg = "{file}", submit = true })
        end,
        desc = "Send Entire File",
      },
      {
        "<leader>ab",
        function()
          require("sidekick.cli").send({ msg = "{buffer}", submit = true })
        end,
        desc = "Send Current Buffer",
      },
      {
        "<leader>aD",
        function()
          require("sidekick.cli").send({ msg = "Fix diagnostics in {this}", submit = true })
        end,
        desc = "Fix Diagnostics",
      },

      -- Specific Prompt Actions
      {
        "<leader>ar",
        function()
          require("sidekick.cli").send({ msg = "Refactor {this} for better readability", submit = true })
        end,
        mode = { "n", "x" },
        desc = "Refactor This",
      },
      {
        "<leader>aR",
        function()
          require("sidekick.cli").send({ msg = "Review {this} for bugs and improvements", submit = true })
        end,
        mode = { "n", "x" },
        desc = "Review This",
      },
      {
        "<leader>ax",
        function()
          require("sidekick.cli").send({ msg = "Explain {this} in simple terms", submit = true })
        end,
        mode = { "n", "x" },
        desc = "Explain This",
      },
      {
        "<leader>aT",
        function()
          require("sidekick.cli").send({ msg = "Write tests for {this}", submit = true })
        end,
        mode = { "n", "x" },
        desc = "Write Tests",
      },
      {
        "<leader>ad",
        function()
          require("sidekick.cli").send({ msg = "Add documentation for {this}", submit = true })
        end,
        mode = { "n", "x" },
        desc = "Document This",
      },

      -- Chat Management
      {
        "<leader>ac",
        function()
          require("sidekick.cli").clear()
        end,
        desc = "Clear Chat History",
      },
      {
        "<leader>an",
        function()
          require("sidekick.cli").new()
        end,
        desc = "New Chat Session",
      },
      {
        "<leader>ai",
        function()
          vim.ui.input({ prompt = "Ask Sidekick: " }, function(input)
            if input then
              require("sidekick.cli").send({ msg = input })
            end
          end)
        end,
        desc = "Quick Input",
      },
    },
  },
}
