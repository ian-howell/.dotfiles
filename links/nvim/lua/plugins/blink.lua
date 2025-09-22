return {
  "Saghen/blink.cmp",
  opts = {
    cmdline = {
      keymap = {
        preset = "cmdline",

        -- I love context aware ctrl+j/k mappings!
        ["<C-j>"] = { "show", "select_next", "fallback_to_mappings" },
        ["<C-k>"] = { "show", "select_prev", "fallback_to_mappings" },
      },
      completion = { menu = { auto_show = true } },
    },
    keymap = {
      preset = "default",
      ["<C-n>"] = { "show", "select_next", "fallback_to_mappings" },
      ["<C-p>"] = { "show", "select_prev", "fallback_to_mappings" },

      -- I love context aware ctrl+j/k mappings!
      ["<C-j>"] = { "show", "select_next", "fallback_to_mappings" },
      ["<C-k>"] = { "show", "select_prev", "fallback_to_mappings" },
    },
  },
}
