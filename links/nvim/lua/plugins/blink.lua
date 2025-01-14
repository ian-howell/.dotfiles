return {
  { -- Blink
    'saghen/blink.cmp',

    -- use a release tag to download pre-built binaries
    version = 'v0.*',

    ---@module 'blink.cmp'
    ---@type blink.cmp.Config
    opts = {
      keymap = {
        preset = 'default',
        ['<C-n>'] = { 'select_next' },
        ['<C-p>'] = { 'select_prev' },
        ['<C-e>'] = { 'cancel', 'fallback' },
        ['<C-y>'] = { 'accept', 'fallback' },
      },
      appearance = {
        -- Set to 'mono' for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
        -- Adjusts spacing to ensure icons are aligned
        nerd_font_variant = 'mono',
      },
      -- Default list of enabled providers defined so that you can extend it
      -- elsewhere in your config, without redefining it, due to `opts_extend`
      sources = {
        default = { 'lsp', 'path', 'buffer' },
      },

      completion = {
        -- Show documentation when selecting a completion item
        documentation = {
          -- Show documentation in a floating window
          auto_show = true,
          -- But wait a bit before showing it
          auto_show_delay_ms = 500,
          window = {
            border = 'rounded',
            -- windblend doesn't work :(
            --  I'm going to leave it here in case it starts working in a future version
            winblend = 90,
          },
        },

        list = {
          selection = {
            -- No items will be selected until I press <C-n> or <C-p>
            preselect = false,
            -- When I *do* select an item, it will be inserted automatically.
            -- That is, I don't have to press <C-y> to accept the selection.
            -- If nothing is selected, <C-y> will use its fallback action (i.e., insert copilot suggestion)
            auto_insert = true,
          },
        },

        menu = {
          border = 'rounded',
          winblend = 10,
          draw = {
            treesitter = { 'lsp' },
            columns = {
              { 'label', 'label_description', gap = 1 },
              { 'kind_icon', 'kind', gap = 1 },
            },
          },
        },
      },
    },
    opts_extend = { 'sources.default' },
  },
}
