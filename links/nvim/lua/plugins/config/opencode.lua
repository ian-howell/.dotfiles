-- opencode.nvim: chat panel for the opencode CLI agent.

require("opencode").setup({
  -- snacks is detected last in the plugin's picker priority order; pin it.
  preferred_picker = "snacks",
  keymap = {
    input_window = {
      -- Submit from insert mode with Ctrl-Enter (in addition to the default
      -- Shift-Enter). Requires a terminal that distinguishes <C-cr> from <cr>.
      ["<C-cr>"] = { "submit_input_prompt", mode = { "n", "i" } },
      -- Tab always cycles through the configured agents/modes (replaces the
      -- default toggle_pane). No defer_to_completion: Tab is never a completion
      -- key here, so it should never be swallowed by the completion menu.
      ["<tab>"] = { "switch_mode", mode = { "n", "i" } },
    },
  },
  ui = {
    position = "right",
    window_width = 0.40,

    input = {
      -- Makes the plugin set wrap + linebreak on the input window, so long
      -- prompts wrap at word boundaries. Applied on every window show, which a
      -- FileType autocmd would not survive.
      text = { wrap = true },
    },
  },
})

local group = vim.api.nvim_create_augroup("user-opencode", { clear = true })

vim.api.nvim_create_autocmd("FileType", {
  desc = "Markdown highlighting in opencode windows",
  group = group,
  pattern = { "opencode", "opencode_output" },
  callback = function(args)
    pcall(vim.treesitter.start, args.buf, "markdown")
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  desc = "Buffer configuration for Opencode",
  group = group,
  pattern = "opencode",
  callback = function(args)
    -- Kill auto hard-wrapping in the prompt: the global textwidth=100 plus
    -- Neovim's default 't'/'c' formatoptions insert real line breaks as you
    -- type. linebreak is needed to "soft-wrap" text.
    vim.bo[args.buf].textwidth = 0
    vim.bo[args.buf].formatoptions = vim.bo[args.buf].formatoptions:gsub("[tc]", "")

    -- Completion for @ (mentions), / (commands) and # (context items) is served by
    -- an in-process LSP client the plugin attaches to its input buffer, using LSP
    -- trigger characters. I've configured completion to be explicit-only, so the
    -- menu would only open when requested (via <c-n>). Rather than loosening that
    -- config, an InsertCharPre autocmd scoped to the input buffer opens the menu on
    -- those characters.
    vim.api.nvim_create_autocmd("InsertCharPre", {
      group = group,
      buffer = args.buf,
      callback = function()
        if vim.v.char:match("[@/#]") then
          vim.schedule(function()
            require("blink.cmp").show()
          end)
        end
      end,
    })
  end,
})
