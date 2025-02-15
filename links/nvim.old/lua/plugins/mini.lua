return {
  { -- Collection of various small independent plugins/modules
    'echasnovski/mini.nvim',
    config = function()
      -- Better Around/Inside textobjects
      --
      -- Examples:
      --  - va)  - [V]isually select [A]round [)]paren
      --  - yinq - [Y]ank [I]nside [N]ext [Q]uote
      --  - ci'  - [C]hange [I]nside [']quote
      require('mini.ai').setup {
        custom_textobjects = {
          -- Disable the 'f' textobject. It's horrible. And it overrides the much nicer vim-go object
          f = false,
        },
        n_lines = 500,
      }

      -- TODO: smear-cursor is _way_ cooler for moving the cursor around, but
      -- animate is more feature rich, and includes things like animated
      -- scrolling and window resizing. I'd like to use both, but prefer
      -- smear-cursor for moving the cursor around.
      require('mini.animate').setup {
        -- Prefer Smear
        cursor = { enable = false },
        -- Prefer Neoscroll
        scroll = { enable = false },
        -- These are for floating windows, but they just seem to slow things down? I'm not really sure what
        -- they're supposed to do.
        open = { enable = false },
        close = { enable = false },
      }

      -- ... and there is more!
      --  Check out: https://github.com/echasnovski/mini.nvim
    end,
  },
}
-- vim: ts=2 sts=2 sw=2 et
