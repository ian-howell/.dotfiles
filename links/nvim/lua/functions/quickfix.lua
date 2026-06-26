local M = {}

local function open_current_entry(command)
  local list = vim.fn.getqflist()
  if not list or #list == 0 then
    return
  end

  local entry = list[vim.fn.line(".")]
  if not entry or not entry.bufnr then
    return
  end

  vim.cmd(string.format("wincmd p | %s | buffer %d | %d | cclose", command, entry.bufnr, entry.lnum))
end

function M.open_in_split()
  open_current_entry("split")
end

function M.open_in_vsplit()
  open_current_entry("vsplit")
end

-- Toggle the quickfix window open/closed.
function M.toggle()
  local is_open = vim.iter(vim.fn.getwininfo()):any(function(win)
    return win.quickfix == 1 and win.loclist == 0
  end)
  if is_open then
    vim.cmd("cclose")
  else
    vim.cmd("copen")
  end
end

-- Prompt for a pattern and filter the quickfix or location list in place using
-- the distributed cfilter package (:Cfilter / :Lfilter). `list` is "quickfix"
-- or "location"; when `invert` is true, entries that do NOT match are kept.
function M.filter(list, invert)
  vim.cmd.packadd("cfilter")
  local command = list == "location" and "Lfilter" or "Cfilter"
  local prompt = command .. (invert and "!" or "") .. " pattern: "
  local pat = vim.fn.input(prompt)
  if pat == "" then
    return
  end
  vim.cmd({ cmd = command, args = { pat }, bang = invert or false })
end

return M
