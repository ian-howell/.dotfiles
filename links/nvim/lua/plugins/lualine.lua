return {
  { -- Lualine
    'nvim-lualine/lualine.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    event = 'VimEnter',

    opts = {
      icons_enabled = true,
      theme = 'auto',
      component_separators = { left = '', right = '' },
      section_separators = { left = '', right = '' },
      disabled_filetypes = {
        statusline = {},
        winbar = {},
      },
      ignore_focus = {},
      always_divide_middle = true,
      always_show_tabline = true,
      globalstatus = true,
      refresh = {
        statusline = 100,
        tabline = 100,
        winbar = 100,
      },
      sections = {
        lualine_a = { 'mode' },
        lualine_b = { 'diff', 'diagnostics' },
        lualine_c = {},
        lualine_x = { 'searchcount', 'selectioncount' },
        lualine_y = { 'progress' },
        lualine_z = { 'location' },
      },
      inactive_sections = {
        lualine_a = {},
        lualine_b = {},
        lualine_c = {},
      },
      tabline = {},
      winbar = {
        lualine_a = {
          {
            'filename',
            path = 1, -- Relative path
            symbols = {
              modified = 'Δ', -- Text to show when the file is modified.
              readonly = '', -- Text to show when the file is non-modifiable or readonly.
            },
          },
        },
      },
      inactive_winbar = {
        lualine_a = {
          {
            'filename',
            path = 1, -- Relative path
            symbols = {
              modified = 'Δ', -- Text to show when the file is modified.
              readonly = '', -- Text to show when the file is non-modifiable or readonly.
            },
          },
        },
      },
      extensions = { 'aerial', 'quickfix' },
    },
  },
}
