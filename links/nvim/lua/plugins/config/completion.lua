-- Insert-mode completion via blink.cmp.
--
-- Behaviour goals:
--   * The completion menu never appears automatically while typing. It is only
--     shown by explicitly pressing <C-n>/<C-p>.
--   * Copilot ghost text is always on (configured in plugins/config/copilot.lua)
--     EXCEPT while the completion menu is open, where the two would fight.
--   * <C-n>/<C-p> open the menu, insert the first item, then cycle+insert.
--   * <C-y> accepts the selected item, <C-e> cancels and restores typed text.
--   * Outside the menu, <C-y>/<C-f>/<C-l>/<C-e> drive Copilot ghost text
--     (accept / accept word / accept line / dismiss). See copilot.lua.

--- Accept the visible Copilot suggestion via the given method, if any.
--- Returns true when it handled the key (so blink stops falling through).
---@param method "accept"|"accept_word"|"accept_line"
---@return boolean|nil
local function copilot_accept(method)
  local ok, suggestion = pcall(require, "copilot.suggestion")
  if ok and suggestion.is_visible() then
    suggestion[method]()
    return true
  end
end

require("blink.cmp").setup({
  cmdline = { enabled = true },
  term = { enabled = false },

  -- Use the pure-Lua fuzzy matcher so installing the plugin never has to fetch a
  -- prebuilt binary (vim.pack does not run cargo build hooks). Swap to
  -- "prefer_rust_with_warning" if you later wire up a build step.
  fuzzy = { implementation = "lua" },

  sources = {
    default = { "lsp", "path", "buffer" },
    providers = {
      -- By default blink only shows buffer completions when the LSP source
      -- returns nothing. Clearing fallbacks makes buffer words always merge in,
      -- matching the old native `complete` behaviour.
      lsp = { fallbacks = {} },
    },
  },

  completion = {
    -- The menu is explicit-only.
    menu = { auto_show = false },
    trigger = {
      show_on_keyword = false,
      show_on_trigger_character = false,
      show_on_insert = false,
      show_on_accept_on_trigger_character = false,
      show_on_insert_on_trigger_character = false,
      show_on_backspace = false,
      show_on_backspace_in_keyword = false,
      show_on_backspace_after_accept = false,
      show_on_backspace_after_insert_enter = false,
      prefetch_on_insert = false,
    },
    -- Preselect the first item and preview-insert it, so the first <C-n>/<C-p>
    -- both shows the menu and inserts item 1.
    list = { selection = { preselect = true, auto_insert = true } },
    -- Copilot owns ghost text; blink must not draw its own.
    ghost_text = { enabled = false },
    documentation = { auto_show = false },
  },

  keymap = {
    preset = "none",

    -- Enter completion mode / cycle. When the menu is closed these show it and
    -- insert the first item; when it is open they move+insert.
    ["<C-n>"] = { "insert_next" },
    ["<C-p>"] = { "insert_prev" },

    -- Accept selected completion item, else accept Copilot suggestion, else the
    -- native key.
    ["<C-y>"] = {
      "accept",
      function()
        return copilot_accept("accept")
      end,
      "fallback",
    },

    -- Cancel completion (restoring typed text), else dismiss Copilot ghost text,
    -- else the native key.
    ["<C-e>"] = {
      "cancel",
      function()
        local ok, suggestion = pcall(require, "copilot.suggestion")
        if ok and suggestion.is_visible() then
          suggestion.dismiss()
          return true
        end
      end,
      "fallback",
    },

    -- Copilot word / line acceptance (only meaningful when ghost text is visible,
    -- which is never while the menu is open since Copilot is hidden then).
    ["<C-f>"] = {
      function()
        return copilot_accept("accept_word")
      end,
      "fallback",
    },
    ["<C-l>"] = {
      function()
        return copilot_accept("accept_line")
      end,
      "fallback",
    },
  },
})

-- Hide Copilot ghost text while the completion menu is open, and let it come
-- back once the menu closes. Copilot's own auto_trigger re-requests a suggestion
-- on the cursor movement that follows accepting/cancelling.
local group = vim.api.nvim_create_augroup("user-completion-copilot", { clear = true })

vim.api.nvim_create_autocmd("User", {
  group = group,
  pattern = "BlinkCmpMenuOpen",
  callback = function()
    local ok, suggestion = pcall(require, "copilot.suggestion")
    if ok then
      suggestion.dismiss()
    end
    vim.b.copilot_suggestion_hidden = true
  end,
})

vim.api.nvim_create_autocmd("User", {
  group = group,
  pattern = "BlinkCmpMenuClose",
  callback = function()
    vim.b.copilot_suggestion_hidden = false
  end,
})
