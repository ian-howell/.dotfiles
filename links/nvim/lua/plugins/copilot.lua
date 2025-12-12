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
      nes = {
        enabled = false,
      },
      cli = {
        mux = {
          enabled = true,
          backend = "tmux",
        },
        -- Predefined prompts for <leader>ap or :Sidekick cli prompt.
        prompts = {
          -- === Core custom prompts ===
          refactor_readability = "Refactor {this} to improve readability and maintainability while preserving behavior.",
          explain_code = "Explain {this} in clear, concise terms as if to an experienced engineer new to this codebase.",
          summarize_file = "Summarize the purpose, main responsibilities, and key entry points of {file}.",
          add_docs = "Add concise, high-signal documentation comments for {this}. Focus on intent, important invariants, and side effects.",
          write_tests = "Write tests for {this}. Prefer small, focused cases with descriptive names.",
          find_bugs = "Review {this} for potential bugs, edge cases, and error handling gaps. Propose concrete fixes.",
          optimize_perf = "Look for pragmatic performance improvements in {this}. Avoid premature micro-optimizations; focus on clear wins.",
          simplify_logic = "Simplify {this} while keeping behavior identical. Prefer early returns, smaller helpers, and reduced branching.",
          improve_naming = "Suggest clearer, more consistent names for identifiers in {this}. Explain the rationale briefly.",
          idiomatic_style = "Rewrite {this} in idiomatic, modern style for its language, following common community conventions.",
          add_logging = "Suggest minimal, high-signal logging for {this}. Include context that would help debug issues in production.",
          security_review = "Review {this} and related {file} context for security vulnerabilities or unsafe patterns.",
          edge_cases = "List important edge cases that {this} should handle. Call out which are currently missing.",
          todo_cleanup = "Turn any implicit TODOs or hacks in {this} into clear next steps or small refactors.",
          custom_context = function(ctx)
            return "Current file: "
              .. ctx.buf
              .. " at line "
              .. ctx.row
              .. ". Describe what this region appears to do and how it fits into the rest of the file."
          end,

          -- === Selected & tweaked built-in prompts ===
          changes = "Can you review my recent changes in {file} and point out any issues or improvements?",
          diagnostics = "Explain the current diagnostics for this buffer and show concrete fixes directly in {this}.",
          diagnostics_all = "Review diagnostics across the workspace and suggest an order to fix them, starting with the most impactful.",
          explain = "Explain {this} step by step.",
          fix = "Can you fix {this}? Keep the changes minimal but correct.",
          optimize = "How can {this} be optimized without sacrificing clarity?",
          review = "Can you review {file} for any issues or improvements?",
          tests = "Can you write tests for {this}?",

          -- === Context-only prompts ===
          buffers = "{buffers}",
          file = "{file}",
          line = "{line}",
          position = "{position}",
          quickfix = "{quickfix}",
          selection = "{selection}",
          ["function"] = "{function}",
          class = "{class}",
        },
      },
    },

    config = function(_, opts)
      require("sidekick").setup(opts)
      local cfg = require("sidekick.config")
      if opts.cli and opts.cli.prompts then
        cfg.cli.prompts = opts.cli.prompts
      end
    end,

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
      {
        "<leader>af",
        function()
          return ("sidekick.cli").send({
            msg = "Finish the pattern located at {this}. If there is existing code that comes after {this}, change it to match the pattern set by {this}",
            submit = true,
          })
        end,
        mode = { "n", "x" },
        desc = "Finish the Pattern",
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
