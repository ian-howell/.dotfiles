-- quicker.nvim configuration
--
-- This thing is _soo_ friggin cool. Not only does it allow you to delete items
-- from the quickfix list, but it also allows you to actually modify the files
-- themselves. So for example, running :%s/foo/bar/g will change all instances
-- of foo to bar in _every_ file in the quickfix list.
--
-- Further, when I hit > it expands the context around the search term.
--
-- Plus it looks gorgeous.

local quicker = require("quicker")

quicker.setup({
  -- Widen the filename column so long paths aren't truncated with a leading "…".
  -- The filename is real buffer text (not virtual text), so when quicker chops
  -- the leading directories to fit its default cap (min(95, columns / 2)), those
  -- segments are gone from the buffer and can no longer be matched by a `/`
  -- search or an editable `:%s/` across the quickfix list. Raising the cap keeps
  -- realistic paths fully visible and searchable, while still bounding a single
  -- pathological deep path from running off unpredictably.
  max_filename_width = function()
    return math.max(vim.o.columns - 40, 95)
  end,
  keys = {
    {
      ">",
      function()
        quicker.expand({ before = 2, after = 2, add_to_existing = true })
      end,
      desc = "Expand quickfix context",
    },
    {
      "<",
      function()
        quicker.collapse()
      end,
      desc = "Collapse quickfix context",
    },
  },
})
