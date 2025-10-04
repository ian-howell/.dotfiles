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
    },
  },
}
