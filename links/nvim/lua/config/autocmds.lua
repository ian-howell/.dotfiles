-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")
--
-- See `:help lua-guide-autocommands`

-- When creating a new git commit, start in insert mode
vim.api.nvim_create_autocmd("BufWinEnter", {
  pattern = "*.git/COMMIT_EDITMSG",
  desc = "Start git commit messages in insert mode",
  group = vim.api.nvim_create_augroup("gitcommit-insert", { clear = true }),
  callback = function()
    -- If it's a new commit, start in insert mode, otherwise start in normal mode
    if vim.fn.getline(1) == "" then
      vim.cmd("startinsert!")
    end
  end,
})

local quickfix = require("functions/quickfix") -- ~/.config/nvim/lua/functions/quickfix.lua
vim.api.nvim_create_autocmd({ "FileType" }, {
  pattern = "qf",
  desc = "Setup keybindings for the quickfix window",
  group = vim.api.nvim_create_augroup("quickfix_mapping", { clear = true }),
  callback = function()
    vim.keymap.set("n", "-", quickfix.openInSplit, {
      buffer = true,
      desc = "Open quickfix in split",
    })
    vim.keymap.set("n", "\\", quickfix.openInVsplit, {
      buffer = true,
      desc = "Open quickfix in vsplit",
    })
  end,
})

-- When entering a new file, set the formatoptions to *not* insert comment characters when I press `o` or `O`.
-- NOTE: This is needed here because formatoptions ise set by the filetype plugin, which happens after all of
-- my settings. This causes my custom settings to be overridden.
-- stuff overrides my settings.
vim.api.nvim_create_autocmd("BufEnter", {
  callback = function()
    vim.bo.formatoptions = vim.bo.formatoptions:gsub("o", "")
  end,
})

-- Focus Settings
-- TODO: Figure out where to put this

-- NOTE: If colors are funky, don't forget to test with the true-color-24-test
vim.opt.termguicolors = true

-- Background colors for active vs inactive windows
vim.cmd.hi("link ActiveWindow Normal")

-- InactiveWindow is the background color for tokyonight
vim.cmd.hi("InactiveWindow guibg=#1a1b26")

-- Normally, this would be good enough (and it's still required for startup with multiple splits)...
vim.opt.winhighlight = "Normal:ActiveWindow,NormalNC:InactiveWindow"
-- ... But since vim always has an "active" window (even in an inactive tmux pane), I need to use autocmds to
-- change the highlight groups based on focus.
vim.api.nvim_create_autocmd({ "BufLeave", "WinLeave", "FocusLost" }, {
  desc = "Dim the window when it loses focus",
  group = vim.api.nvim_create_augroup("focus-leave", { clear = true }),
  callback = function()
    vim.opt_local.cursorline = false
    vim.opt_local.cursorcolumn = false
    vim.opt_local.colorcolumn = ""
    -- If I've left the window for *any* reason (whether it's to switch buffers or to switch tmux panes),
    -- I want the window to be dimmed.
    vim.opt_local.winhighlight = "Normal:InactiveWindow,NormalNC:InactiveWindow"
  end,
})

vim.api.nvim_create_autocmd({ "BufEnter", "WinEnter", "FocusGained" }, {
  desc = "Highlight the window when it gains focus",
  group = vim.api.nvim_create_augroup("focus-enter", { clear = true }),
  callback = function()
    vim.opt_local.cursorline = true
    vim.opt_local.cursorcolumn = true
    vim.opt_local.colorcolumn = tostring(vim.opt_local.textwidth:get())
    vim.opt_local.winhighlight = "Normal:ActiveWindow,NormalNC:InactiveWindow"
  end,
})

-- Turn on highlighting while searching
vim.api.nvim_create_autocmd("CmdlineEnter", {
  desc = "Highlight while searching",
  group = vim.api.nvim_create_augroup("highlight-while-searching", { clear = true }),
  callback = function()
    if vim.fn.index({ "/", "?" }, vim.fn.getcmdtype()) >= 0 then
      vim.opt.hlsearch = true
    end
  end,
})

-- Autoformat setting
local set_autoformat = function(pattern, bool_val)
  vim.api.nvim_create_autocmd({ "FileType" }, {
    pattern = { pattern },
    callback = function()
      vim.b.autoformat = bool_val
    end,
  })
end

set_autoformat("go", true)
set_autoformat("lua", true)
set_autoformat("markdown", false)
set_autoformat("sh", false)
set_autoformat("yaml", false)

-- Textwidth setting
local set_textwidth = function(pattern, textwidth)
  vim.api.nvim_create_autocmd({ "FileType" }, {
    pattern = { pattern },
    callback = function()
      vim.bo.textwidth = textwidth
    end,
  })
end

set_textwidth("go", 110)
set_textwidth("markdown", 80)
set_textwidth("lua", 80)
set_textwidth("sh", 80)

-- vim: ts=2 sts=2 sw=2 et
