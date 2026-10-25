-- Send the cursor line or visual selection to Raven (~/src/raven) as an `@file:Lx-y` reference.
-- Same idea as opencode.nvim's prompt references: Raven reads the range itself, so nothing here
-- needs to quote code. Raven tags its tmux pane with @raven; prefer one in this window.
local M = {}

-- Pane ids of Raven panes, current window first. Empty outside tmux or when Raven isn't running.
local function raven_panes()
  if not vim.env.TMUX then
    return {}
  end
  local win = vim.trim(vim.fn.system({ "tmux", "display", "-p", "#{window_id}" }))
  local out = vim.fn.systemlist({ "tmux", "list-panes", "-a", "-F", "#{@raven} #{window_id} #{pane_id}" })
  local here, other = {}, {}
  for _, line in ipairs(out) do
    local tag, w, pane = line:match("^(%S*) (%S+) (%S+)$")
    if tag == "1" then
      table.insert(w == win and here or other, pane)
    end
  end
  return vim.list_extend(here, other)
end

-- `@/abs/file:L12-30` plus any diagnostics in that range, on one line (a newline would submit).
function M.reference(first, last)
  local file = vim.api.nvim_buf_get_name(0)
  local ref = ("@%s:L%d"):format(file, first) .. (last ~= first and ("-" .. last) or "")
  local diags = {}
  for _, d in ipairs(vim.diagnostic.get(0)) do
    if d.lnum + 1 >= first and d.lnum + 1 <= last then
      local msg = d.message:gsub("%s+", " ")
      table.insert(diags, ("L%d %s: %s"):format(d.lnum + 1, vim.diagnostic.severity[d.severity], msg))
    end
  end
  if #diags > 0 then
    ref = ref .. " (diagnostics: " .. table.concat(diags, "; ") .. ")"
  end
  return ref .. " "
end

function M.send()
  local first, last = vim.fn.line("."), vim.fn.line(".")
  if vim.fn.mode():match("[vV\22]") then
    first, last = vim.fn.line("v"), vim.fn.line(".")
    if first > last then
      first, last = last, first
    end
    vim.api.nvim_feedkeys(vim.keycode("<Esc>"), "nx", false)
  end
  local pane = raven_panes()[1]
  if not pane then
    vim.notify("No Raven pane found (start `raven` in tmux)", vim.log.levels.WARN)
    return
  end
  -- Typed, not submitted: Ian finishes the question in Raven. Focus moves there on purpose,
  -- because he pressed the key to go ask something.
  vim.fn.system({ "tmux", "send-keys", "-t", pane, "-l", M.reference(first, last) })
  vim.fn.system({ "tmux", "select-window", "-t", pane })
  vim.fn.system({ "tmux", "select-pane", "-t", pane })
end

vim.keymap.set({ "n", "x" }, "<leader>rt", M.send, { desc = "Send line/selection to Raven" })

return M
