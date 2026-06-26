-- Autocommands and event-driven behavior.

local groups = {
  focus_enter = vim.api.nvim_create_augroup("focus-enter", { clear = true }),
  focus_leave = vim.api.nvim_create_augroup("focus-leave", { clear = true }),
  quickfix = vim.api.nvim_create_augroup("quickfix-maps", { clear = true }),
  on_save = vim.api.nvim_create_augroup("on-save", { clear = true }),
  filetype_settings = vim.api.nvim_create_augroup("filetype-settings", { clear = true }),
}

-- Treat bare gitconfig files like .gitconfig.
vim.filetype.add({
  filename = {
    gitconfig = "gitconfig",
  },
})

vim.api.nvim_create_autocmd("BufWinEnter", {
  desc = "Start empty git commit messages in insert mode",
  group = vim.api.nvim_create_augroup("gitcommit-insert", { clear = true }),
  pattern = "*.git/COMMIT_EDITMSG",
  callback = function()
    if vim.fn.getline(1) == "" then
      vim.cmd("startinsert!")
    end
  end,
})

-- ---------------------------------------------------------------------------
-- Focus UI
-- ---------------------------------------------------------------------------
vim.api.nvim_create_autocmd({ "BufLeave", "WinLeave", "FocusLost" }, {
  desc = "Hide focused-only UI when window loses focus",
  group = groups.focus_leave,
  callback = function()
    vim.opt_local.number = false
    vim.opt_local.signcolumn = "no"
    vim.opt_local.cursorline = false
    vim.opt_local.cursorcolumn = false
    vim.opt_local.colorcolumn = ""
  end,
})

vim.api.nvim_create_autocmd({ "BufEnter", "WinEnter", "FocusGained" }, {
  desc = "Show focused-only UI when window gains focus",
  group = groups.focus_enter,
  callback = function()
    local filetype = vim.bo.filetype
    if filetype == "snacks_picker_list" then
      return
    end
    vim.opt_local.number = true
    vim.opt_local.signcolumn = "yes"
    vim.opt_local.cursorline = true
    vim.opt_local.cursorcolumn = vim.g.cursorcolumn
    vim.opt_local.colorcolumn = tostring(vim.opt_local.textwidth:get())
  end,
})

-- ---------------------------------------------------------------------------
-- Quickfix
-- ---------------------------------------------------------------------------
vim.api.nvim_create_autocmd("FileType", {
  desc = "Quickfix window maps and Cfilter/Lfilter commands",
  group = groups.quickfix,
  pattern = "qf",
  callback = function(args)
    vim.cmd.packadd("cfilter")
    local quickfix = require("functions.quickfix")
    vim.keymap.set("n", "q", "<cmd>q<CR>", { buffer = args.buf, silent = true })
    vim.keymap.set("n", "-", quickfix.open_in_split, {
      buffer = args.buf,
      desc = "Open quickfix entry in split",
    })
    vim.keymap.set("n", "\\", quickfix.open_in_vsplit, {
      buffer = args.buf,
      desc = "Open quickfix entry in vsplit",
    })
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  desc = "Close help with q",
  group = groups.quickfix,
  pattern = "help",
  callback = function(args)
    vim.keymap.set("n", "q", "<cmd>q<CR>", { buffer = args.buf, silent = true })
  end,
})

vim.api.nvim_create_autocmd("BufEnter", {
  desc = "Do not continue comments with o/O",
  callback = function()
    vim.bo.formatoptions = vim.bo.formatoptions:gsub("o", "")
  end,
})

vim.api.nvim_create_autocmd("CmdlineEnter", {
  desc = "Highlight while searching",
  group = vim.api.nvim_create_augroup("highlight-while-searching", { clear = true }),
  callback = function()
    if vim.fn.index({ "/", "?" }, vim.fn.getcmdtype()) >= 0 then
      vim.opt.hlsearch = true
    end
  end,
})

vim.api.nvim_create_autocmd("TextYankPost", {
  desc = "Briefly highlight yanked text",
  group = vim.api.nvim_create_augroup("highlight-yank", { clear = true }),
  callback = function()
    -- TODO: switch to vim.hl.hl_op() once on Neovim 0.13+, where
    -- vim.hl.on_yank() becomes deprecated in its favor.
    vim.hl.on_yank()
  end,
})

local function set_autoformat(pattern, enabled)
  vim.api.nvim_create_autocmd("FileType", {
    desc = "Set buffer autoformat preference",
    group = groups.filetype_settings,
    pattern = pattern,
    callback = function()
      vim.b.autoformat = enabled
    end,
  })
end

set_autoformat("go", true)
set_autoformat("lua", true)
set_autoformat("markdown", false)
set_autoformat("sh", false)
set_autoformat("yaml", false)

local function set_textwidth(pattern, textwidth)
  vim.api.nvim_create_autocmd("FileType", {
    desc = "Set buffer textwidth",
    group = groups.filetype_settings,
    pattern = pattern,
    callback = function()
      vim.bo.textwidth = textwidth
    end,
  })
end

set_textwidth("go", 110)
set_textwidth("markdown", 100)
set_textwidth("lua", 80)
set_textwidth("sh", 80)

-- ---------------------------------------------------------------------------
-- On Save
-- ---------------------------------------------------------------------------
vim.api.nvim_create_autocmd("BufWritePre", {
  desc = "Strip Windows CRLF characters on save",
  group = groups.on_save,
  callback = function(args)
    if vim.bo[args.buf].buftype ~= "" then
      return
    end

    local has_cr = false
    for _, line in ipairs(vim.api.nvim_buf_get_lines(args.buf, 0, -1, true)) do
      if line:find("\r", 1, true) then
        has_cr = true
        break
      end
    end
    if not has_cr then
      return
    end

    local view = vim.fn.winsaveview()
    local lines = vim.api.nvim_buf_get_lines(args.buf, 0, -1, true)
    for index, line in ipairs(lines) do
      lines[index] = line:gsub("\r", "")
    end
    vim.api.nvim_buf_set_lines(args.buf, 0, -1, true, lines)
    vim.fn.winrestview(view)
  end,
})

return groups
