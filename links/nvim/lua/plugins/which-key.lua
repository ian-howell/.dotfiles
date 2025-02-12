return {
  { -- Useful plugin to show you pending keybinds.
    'folke/which-key.nvim',
    -- Sets the loading event to 'VimEnter'
    event = 'VimEnter',
    opts = {
      icons = {
        -- Set icon mappings to true if you have a Nerd Font
        mappings = vim.g.have_nerd_font,
        -- If you are using a Nerd Font: set icons.keys to an empty table which will use the
        -- default whick-key.nvim defined Nerd Font icons, otherwise define a string table
        keys = vim.g.have_nerd_font and {} or {
          Up = '<Up> ',
          Down = '<Down> ',
          Left = '<Left> ',
          Right = '<Right> ',
          C = '<C-…> ',
          M = '<M-…> ',
          D = '<D-…> ',
          S = '<S-…> ',
          CR = '<CR> ',
          Esc = '<Esc> ',
          ScrollWheelDown = '<ScrollWheelDown> ',
          ScrollWheelUp = '<ScrollWheelUp> ',
          NL = '<NL> ',
          BS = '<BS> ',
          Space = '<Space> ',
          Tab = '<Tab> ',
          F1 = '<F1>',
          F2 = '<F2>',
          F3 = '<F3>',
          F4 = '<F4>',
          F5 = '<F5>',
          F6 = '<F6>',
          F7 = '<F7>',
          F8 = '<F8>',
          F9 = '<F9>',
          F10 = '<F10>',
          F11 = '<F11>',
          F12 = '<F12>',
        },

        separator = '┝',
      },

      -- Document existing key chains
      spec = {
        { '<space>c', group = 'code', mode = { 'n', 'x' } },
        { '<space>cc', group = 'calls' },
        { '<space>d', group = 'document' },
        { '<space>r', group = 'rename' },
        { '<space>s', group = 'search' },
        { '<space>w', group = 'workspace' },
        { '<space>t', group = 'toggle' },
        { '<space>g', group = 'git', mode = { 'n', 'v' } },
        { '<space>q', group = 'quickfix' },
        { '<space>G', group = 'go', mode = { 'n', 'v' } },
        { '<space>C', group = 'copilot' },
      },
    },
  },
}
-- vim: ts=2 sts=2 sw=2 et
