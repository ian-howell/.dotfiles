return {
  "Saghen/blink.cmp",
  opts = {
    keymap = {
      preset = "default",
      ["<C-p>"] = { "show", "select_prev", "fallback_to_mappings" },
      ["<C-n>"] = { "show", "select_next", "fallback_to_mappings" },
    },
  },
}
