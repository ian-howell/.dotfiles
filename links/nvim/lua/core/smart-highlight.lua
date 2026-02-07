-- Smart search highlight management.
-- Highlights appear when you finish a search and stay on while pressing n/N.
-- Any other key clears the highlights.

-- Track whether we're in the middle of a search navigation (n/N)
local searching = false

-- Create autocmd group
local group = vim.api.nvim_create_augroup("smart-highlight", { clear = true })

-- Override n to enable hlsearch and mark as searching
vim.keymap.set("n", "n", function()
  vim.opt.hlsearch = true
  searching = true
  local ok, err = pcall(vim.cmd, "normal! n")
  if not ok then
    if err:match("E486") then
      vim.notify("Pattern not found", vim.log.levels.WARN)
    end
  end
end, { desc = "Next search result" })

-- Override N to enable hlsearch and mark as searching
vim.keymap.set("n", "N", function()
  vim.opt.hlsearch = true
  searching = true
  local ok, err = pcall(vim.cmd, "normal! N")
  if not ok then
    if err:match("E486") then
      vim.notify("Pattern not found", vim.log.levels.WARN)
    end
  end
end, { desc = "Previous search result" })

-- Clear hlsearch on cursor movement from non-search keys
vim.api.nvim_create_autocmd("CursorMoved", {
  desc = "Clear hlsearch on non-search movement",
  group = group,
  callback = function()
    -- Make sure that hlsearch is off unless a "searching" command was issued
    if not searching then
      vim.opt.hlsearch = false
    end
    searching = false
  end,
})

-- When leaving search command line, enable hlsearch
-- NOTE: hitting '/' or '/' and them immediately hitting 'esc' turns on hlsearch
vim.api.nvim_create_autocmd("CmdlineLeave", {
  desc = "Enable hlsearch after search",
  group = group,
  callback = function()
    local cmdtype = vim.fn.getcmdtype()
    if cmdtype ~= "/" and cmdtype ~= "?" then
      return
    end

    searching = true
    vim.opt.hlsearch = true
  end,
})
