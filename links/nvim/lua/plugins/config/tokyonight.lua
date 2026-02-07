-- Tokyonight colorscheme configuration.

local ok, tokyonight = pcall(require, "tokyonight")
if not ok then
  return
end

local groups = require("core.autocmds")

tokyonight.setup({
  -- dimming inactive windows is cool, but it doesn't dim any windows when I
  -- switch tmux panes, so I'll use my own custom config to do that.
  -- dim_inactive = true,

  style = "moon",

  on_highlights = function(highlights)
    highlights.ColorColumn = {
      -- Make the colorcolumn the same color as the default background.
      -- This way, it will only be visible on the current line (thanks to the cursorline setting).
      bg = highlights.Normal.bg,
    }
  end,
})

vim.cmd.colorscheme("tokyonight")

-- Background colors for active vs inactive windows
-- vim.cmd.hi("link ActiveWindow Normal")

-- InactiveWindow is the background color for tokyonight
vim.cmd.hi("InactiveWindow guibg=#1a1b26")

-- Normally, this would be good enough (and it's still required for startup with multiple splits)...
-- vim.opt.winhighlight = "Normal:ActiveWindow,NormalNC:InactiveWindow"
-- ... But since vim always has an "active" window (even in an inactive tmux pane),
-- I use focus-based autocmds here to update winhighlight per window.

vim.api.nvim_create_autocmd({ "BufLeave", "WinLeave", "FocusLost" }, {
  desc = "Dim the window when it loses focus",
  group = groups.focus_leave,
  callback = function()
    -- If I've left the window for *any* reason (whether it's to switch buffers or to switch tmux panes),
    -- I want the window to be dimmed.
    vim.opt_local.winhighlight = "Normal:InactiveWindow,NormalNC:InactiveWindow"
  end,
})

vim.api.nvim_create_autocmd({ "BufEnter", "WinEnter", "FocusGained" }, {
  desc = "Highlight the window when it gains focus",
  group = groups.focus_enter,
  callback = function()
    vim.opt_local.winhighlight = "Normal:ActiveWindow,NormalNC:InactiveWindow"
  end,
})
