return {
  { -- Quicker
    -- This thing is _soo_ friggin cool. Not only does it allow you to
    -- delete items from the quickfix list, but it also allows you to
    -- actually modify the files themselves. So for example, running
    -- :%s/foo/bar/g will change all instances of foo to bar in _every_
    -- file in the quickfix list.
    --
    -- Further, when I hit > it expands the context around the search term.
    --
    -- Plus it looks gorgeous.
    'stevearc/quicker.nvim',
    event = 'FileType qf',
    config = function()
      local quicker = require 'quicker'
      quicker.setup {
        keys = {
          {
            '>',
            function()
              require('quicker').expand { before = 2, after = 2, add_to_existing = true }
            end,
            desc = 'expand quickfix context',
          },
          {
            '<',
            function()
              require('quicker').collapse()
            end,
            desc = 'collapse quickfix context',
          },
        },
      }

      vim.keymap.set('n', '<space>q', function()
        require('quicker').toggle()
      end, {
        desc = 'toggle quickfix',
      })
      vim.keymap.set('n', '<space>l', function()
        require('quicker').toggle { loclist = true }
      end, {
        desc = 'toggle loclist',
      })
    end,
  },
}
