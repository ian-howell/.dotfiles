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
      globalstatus = false,
      refresh = {
        statusline = 100,
        tabline = 100,
        winbar = 100,
      },
      sections = {
        lualine_a = {
          {
            'mode',
            fmt = function(str)
              return str:sub(1, 1)
            end,
          },
        },
        lualine_b = {
          {
            'filename',
            path = 4, -- show the parent directory
            symbols = {
              modified = 'Δ', -- Text to show when the file is modified.
              readonly = '', -- Text to show when the file is non-modifiable or readonly.
            },
          },
        },
        lualine_c = { 'diff', 'diagnostics' },
        lualine_x = { 'searchcount', 'selectioncount' },
        lualine_y = { 'progress' },
        lualine_z = { 'location' },
      },
      inactive_sections = {
        lualine_a = {},
        lualine_b = {},
        lualine_c = {
          {
            'filename',
            path = 4, -- show the parent directory
            symbols = {
              modified = 'Δ', -- Text to show when the file is modified.
              readonly = '', -- Text to show when the file is non-modifiable or readonly.
            },
          },
        },
        lualine_x = { 'location' },
        lualine_y = {},
        lualine_z = {},
      },
      tabline = {},
      winbar = {},
      inactive_winbar = {},
      extensions = { 'aerial', 'quickfix' },
    },
  },
}
