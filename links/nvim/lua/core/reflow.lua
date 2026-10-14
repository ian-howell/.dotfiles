-- Reflow text one step narrower or wider than it is now.
--
-- The target width is the widest line in the range plus or minus the count (default 1),
-- moved further in the same direction until the text actually changes, so every press does
-- something. Each line's prefix is its indent plus the filetype's comment
-- leader when present; consecutive lines with the same prefix are joined and rewrapped
-- together, so a doc comment and the code under it stay separate. Blank lines and bare
-- leader lines (`//`) separate paragraphs. Wrapping is done in Lua with nvim_buf_set_lines
-- rather than `gw`, so `.` repeats this operator instead of the inner `gw`.
local M = {}

-- The leader comes from the commentstring of the language at the cursor, so code blocks
-- injected into markdown use their own language's leader, like Neovim's `gc` does.
local function comment_leader(lnum)
  local cs = vim.bo.commentstring
  local ok, parser = pcall(vim.treesitter.get_parser, 0)
  if ok and parser then
    local line = vim.api.nvim_buf_get_lines(0, lnum - 1, lnum, false)[1]
    local col = #line:match("^%s*")
    local lang = parser:language_for_range({ lnum - 1, col, lnum - 1, col + 1 }):lang()
    for _, ft in ipairs(vim.treesitter.language.get_filetypes(lang)) do
      local ft_cs = vim.filetype.get_option(ft, "commentstring")
      if ft_cs ~= "" then
        cs = ft_cs
        break
      end
    end
  end
  local leader = cs:match("^%s*(.-)%s*%%s")
  if leader == nil or leader == "" then
    return nil
  end
  return leader
end

-- Split a line into its prefix (indent plus any comment leader) and the remaining text.
local function split_line(line, leader)
  local indent, rest = line:match("^(%s*)(.*)$")
  if leader and rest:sub(1, #leader) == leader then
    return indent .. leader, vim.trim(rest:sub(#leader + 1))
  end
  return indent, vim.trim(rest)
end

-- Greedily wrap words to width under prefix and append the lines to out.
local function wrap_paragraph(out, prefix, words, width)
  local sep = prefix:match("%S$") and " " or ""
  local line
  for _, word in ipairs(words) do
    local candidate = line and (line .. " " .. word) or (prefix .. sep .. word)
    if line and vim.fn.strdisplaywidth(candidate) > width then
      table.insert(out, line)
      line = prefix .. sep .. word
    else
      line = candidate
    end
  end
  if line then
    table.insert(out, line)
  end
end

-- Rewrap lines to width and return the new lines.
local function wrap(lines, leader, width)
  local out = {}
  local prefix
  local words = {}
  local function flush()
    if #words > 0 then
      wrap_paragraph(out, prefix, words, width)
    end
    words = {}
  end
  for _, line in ipairs(lines) do
    local p, text = split_line(line, leader)
    if text == "" then
      flush()
      table.insert(out, line)
    else
      if p ~= prefix then
        flush()
        prefix = p
      end
      vim.list_extend(words, vim.split(text, "%s+", { trimempty = true }))
    end
  end
  flush()
  return out
end

-- Reflow lines first..last (1-based, inclusive) and return the new last line.
local function reflow(first, last, delta)
  local lines = vim.api.nvim_buf_get_lines(0, first - 1, last, false)
  local widest = 0
  for _, line in ipairs(lines) do
    widest = math.max(widest, vim.fn.strdisplaywidth(line))
  end
  local leader = comment_leader(first)
  -- Keep stepping past widths that change nothing (e.g. widening by one column rarely fits
  -- another word), so every press visibly reflows until the text can't go further.
  local step = delta < 0 and -1 or 1
  local min_width, max_width = 10, widest + #table.concat(lines, " ")
  -- Lines already narrower than the minimum can't narrow further; leave them alone rather
  -- than rewrapping them wider.
  if widest + delta < min_width then
    return last
  end
  local width = widest + delta
  local wrapped = wrap(lines, leader, width)
  while vim.deep_equal(wrapped, lines) and width > min_width and width < max_width do
    width = width + step
    wrapped = wrap(lines, leader, width)
  end
  vim.api.nvim_buf_set_lines(0, first - 1, last, false, wrapped)
  return last + #wrapped - #lines
end

local pending = { delta = 0, reselect = false }

-- 'operatorfunc' only resolves global v:lua names, not `require'mod'.fn`.
function _G.ReflowOperatorfunc()
  local first = vim.api.nvim_buf_get_mark(0, "[")[1]
  local last = vim.api.nvim_buf_get_mark(0, "]")[1]
  local new_last = reflow(first, last, pending.delta)
  -- Reselect after a visual g</g> so the key can be pressed again; `.` doesn't reselect.
  if pending.reselect then
    pending.reselect = false
    vim.cmd(string.format("normal! %dGV%dG", first, new_last))
  end
end

-- `g<ip`, `3g>ip`, or g</g> on a visual selection. Both go through g@ so `.` repeats them
-- with the same step: over the same motion in normal mode, or the same line count after a
-- visual selection.
function M.operator(sign)
  return function()
    pending.delta = sign * vim.v.count1
    pending.reselect = vim.fn.mode():match("^[vV\22]") ~= nil
    vim.o.operatorfunc = "v:lua.ReflowOperatorfunc"
    -- A count must not reach g@: `10g<ip` would mean `g@` over 10 paragraphs. <Esc> drops it
    -- in normal mode; in visual mode <Esc> would end the selection, so reselect with gv.
    if vim.v.count == 0 then
      return "g@"
    end
    return pending.reselect and "<Esc>gvg@" or "<Esc>g@"
  end
end

return M
