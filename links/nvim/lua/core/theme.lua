local M = {}
local state = (vim.env.DOTFILES_THEME_STATE or (vim.fn.expand("~") .. "/.local/state/dotfiles/theme")) .. "/mode"
local current
local timer

function M.refresh()
  local file = io.open(state, "r")
  local mode = file and file:read("*l") or "dark"
  if file then
    file:close()
  end
  if mode ~= "light" and mode ~= "dark" then
    return
  end
  if current == mode then
    return
  end
  current = mode
  vim.o.background = mode
  vim.cmd.colorscheme(mode == "light" and "tokyonight-day" or "tokyonight-moon")
end

function M.highlights()
  local light = vim.o.background == "light"
  local colors = require("tokyonight.colors").setup({ style = light and "day" or "moon" })
  vim.api.nvim_set_hl(0, "ActiveWindow", { link = "Normal" })
  vim.api.nvim_set_hl(0, "InactiveWindow", { fg = colors.fg, bg = light and colors.bg_dark or "#1a1b26" })
  vim.api.nvim_set_hl(
    0,
    "CustomFlashLabel",
    { fg = light and colors.bg or "#1a1b26", bg = light and colors.blue or "#7aa2f7", bold = true }
  )
  vim.api.nvim_set_hl(
    0,
    "CustomFlashCurrent",
    { fg = light and colors.bg or "#1a1b26", bg = light and colors.red or "#f7768e", bold = true }
  )
  vim.api.nvim_set_hl(
    0,
    "CustomFlashMatch",
    { fg = light and colors.fg or "#c0caf5", bg = light and colors.bg_visual or "#414868", bold = true }
  )
  vim.api.nvim_set_hl(0, "RenderMarkdownCodeInline", { bg = light and colors.bg_highlight or "#2a2b3c" })
end

function M.setup()
  local group = vim.api.nvim_create_augroup("DotfilesTheme", { clear = true })
  vim.api.nvim_create_autocmd("ColorScheme", { group = group, callback = M.highlights })
  vim.api.nvim_create_autocmd("FocusGained", { group = group, callback = M.refresh })
  M.refresh()
  -- Poll one tiny local file: handles atomic replacement, absent state at startup,
  -- and inactive instances without sockets or injected editor keystrokes.
  if timer then
    timer:stop()
    timer:close()
  end
  timer = vim.uv.new_timer()
  timer:start(500, 500, vim.schedule_wrap(M.refresh))
  vim.api.nvim_create_autocmd("VimLeavePre", {
    group = group,
    callback = function()
      timer:stop()
      timer:close()
      timer = nil
    end,
  })
end

return M
