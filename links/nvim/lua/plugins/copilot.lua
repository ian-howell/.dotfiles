return {
  {
    "zbirenbaum/copilot.lua",
    opts = {
      suggestion = {
        enabled = true,
        auto_trigger = true,
        trigger_on_accept = true,
        keymap = {
          accept = "<C-y>",
          accept_word = "<C-f>",
          accept_line = "<C-l>",
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
          -- Copilot still receives document updates; Neovim sends full text changes
          -- instead of incremental diffs for this client only.
          allow_incremental_sync = false,
        },
      },
      nes = {
        enabled = false,
      },
    },

    init = function()
      local function copilot_accept(method, fallback)
        return function()
          local suggestion = require("copilot.suggestion")
          if suggestion.is_visible() then
            suggestion[method]()
            return ""
          end

          return vim.api.nvim_replace_termcodes(fallback, true, false, true)
        end
      end

      -- copilot.lua can show ghost text before its buffer-local accept mappings are
      -- installed. Install our own small passthrough mappings when the Copilot LSP
      -- client attaches so <C-y>/<C-f>/<C-l> always work with visible suggestions.
      -- TODO: I'm pretty sure that I don't need this, but it should stick
      -- around until I've cleared out LayzVim
      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("user_copilot_keymaps", { clear = true }),
        callback = function(args)
          local client = vim.lsp.get_client_by_id(args.data.client_id)
          if not client or client.name ~= "copilot" then
            return
          end

          local map = function(lhs, method, desc)
            vim.keymap.set("i", lhs, copilot_accept(method, lhs), {
              buffer = args.buf,
              desc = desc,
              expr = true,
              silent = true,
            })
          end

          map("<C-y>", "accept", "Accept Copilot suggestion")
          map("<C-f>", "accept_word", "Accept Copilot word")
          map("<C-l>", "accept_line", "Accept Copilot line")
        end,
      })

      -- TODO: This just doesn't work. It doesn't even appear to work when I run the command directly. It
      -- works more like 'Copilot disable'
      -- vim.keymap.set('n', '<leader>tc', '<cmd>Copilot toggle<CR>', { desc = 'Toggle Copilot' })
      vim.keymap.set("n", "<leader>ad", "<cmd>Copilot disable<CR>", { desc = "disable (Copilot)" })
      vim.keymap.set("n", "<leader>ae", "<cmd>Copilot enable<CR>", { desc = "enable (Copilot)" })
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
          local path = vim.fn.expand("%:p")
          local pos = vim.api.nvim_win_get_cursor(0)
          local row = pos[1]
          local col = pos[2] + 1
          local text = string.format("@%s :L%d:C%d", path, row, col)
          vim.fn.setreg("+", text)
        end,
        mode = { "n", "x" },
        desc = "Copy location as {this}",
      },
      {
        "<leader>av",
        function()
          -- visual selection range
          local path = vim.fn.expand("%:p")
          local start_pos = vim.fn.getpos("v")
          local end_pos = vim.fn.getpos(".")

          local srow, scol = start_pos[2], start_pos[3]
          local erow, ecol = end_pos[2], end_pos[3]

          -- normalize order
          if erow < srow or (erow == srow and ecol < scol) then
            srow, erow = erow, srow
            scol, ecol = ecol, scol
          end

          local text
          if srow == erow then
            text = string.format("@%s :L%d:C%d-C%d", path, srow, scol, ecol)
          else
            text = string.format("@%s :L%d:C%d-L%d:C%d", path, srow, scol, erow, ecol)
          end

          vim.fn.setreg("+", text)
        end,
        mode = { "x" },
        desc = "Copy range as {selection}",
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
            if input and #input > 0 then
              vim.fn.setreg("+", input)
            end
          end)
        end,
        desc = "Copy input to clipboard",
      },
    },
  },
}
