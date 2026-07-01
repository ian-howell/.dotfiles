-- mini.ai configuration
--
-- Textobjects:
--   `af`/`if` - function call (mini.ai builtin, Lua-pattern based)
--   `aF`/`iF` - function definition (treesitter @function.outer/inner)
--   `ac`      - comment block: consecutive line comments are merged into one
--               block (a `/* */` block is already a single node)
--   `ic`      - inner content of a single comment node (treesitter @comment.inner)
--
-- Treesitter captures come from nvim-treesitter-textobjects' query files.

local ai = require("mini.ai")
local ts = ai.gen_spec.treesitter

-- Reuse the treesitter spec to fetch and normalize comment regions, then merge
-- adjacent ones so `ac` selects a whole run of line comments as one block.
--
-- The lookup is wrapped in pcall because languages that define `@comment.outer`
-- but not `@comment.inner` (e.g. Go, Bash) make mini.ai fall back to injected
-- child languages (like Go's `printf`) and raise a "Can not get query" error.
-- Degrade that to "no textobject found" instead of erroring.
local comment_ts = ts({ a = "@comment.outer", i = "@comment.inner" })
local function comment_block(ai_type, id, opts)
  local ok, regions = pcall(comment_ts, ai_type, id, opts)
  if not ok or type(regions) ~= "table" then
    return {}
  end
  if ai_type ~= "a" then
    return regions
  end

  table.sort(regions, function(a, b)
    if a.from.line == b.from.line then
      return a.from.col < b.from.col
    end
    return a.from.line < b.from.line
  end)

  local merged = {}
  for _, r in ipairs(regions) do
    local last = merged[#merged]
    if last and r.from.line <= last.to.line + 1 then
      if r.to.line > last.to.line or (r.to.line == last.to.line and r.to.col > last.to.col) then
        last.to = r.to
      end
    else
      table.insert(merged, { from = r.from, to = r.to })
    end
  end
  return merged
end

ai.setup({
  custom_textobjects = {
    F = ts({ a = "@function.outer", i = "@function.inner" }),
    c = comment_block,
  },
  mappings = {
    around = "a",
    inside = "i",
    -- Disabled so Neovim's `an`/`in` incremental selection stays intact.
    around_next = "",
    inside_next = "",
    around_last = "",
    inside_last = "",
    goto_left = "",
    goto_right = "",
  },
  search_method = "cover_or_next",
})
