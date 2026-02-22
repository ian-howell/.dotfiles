-- Autocommands and event-driven behavior.

local groups = {
  focus_enter = vim.api.nvim_create_augroup("focus-enter", { clear = true }),
  focus_leave = vim.api.nvim_create_augroup("focus-leave", { clear = true }),
  lsp_attach = vim.api.nvim_create_augroup("lsp-attach", { clear = true }),
  quickfix = vim.api.nvim_create_augroup("quickfix-maps", { clear = true }),
  on_save = vim.api.nvim_create_augroup("on-save", { clear = true }),
}

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
  desc = "Close quickfix/location lists with q",
  group = groups.quickfix,
  pattern = { "qf", "help" },
  callback = function(args)
    vim.keymap.set("n", "q", "<cmd>q<CR>", { buffer = args.buf, silent = true })
  end,
})

-- ---------------------------------------------------------------------------
-- LSP Attach
-- ---------------------------------------------------------------------------
vim.api.nvim_create_autocmd("LspAttach", {
  desc = "Set LSP-specific keymaps on attach",
  group = groups.lsp_attach,
  callback = function(args)
    vim.keymap.set("n", "gd", function()
      require("lsp.goto-definition").definition_or_implementation_picker()
    end, { buffer = args.buf, desc = "definition" })

    vim.keymap.set("n", "<leader>ld", vim.diagnostic.open_float, { desc = "Open diagnostics float" })

    local snacks = give("snacks")
    if snacks then
      vim.keymap.set(
        "n",
        "<leader>li",
        snacks.picker.lsp_implementations,
        { buffer = args.buf, desc = "implementations" }
      )
      vim.keymap.set("n", "<leader>lr", snacks.picker.lsp_references, { buffer = args.buf, desc = "references" })
      vim.keymap.set("n", "<leader>ls", snacks.picker.lsp_symbols, { buffer = args.buf, desc = "symbols" })
    end
  end,
})

-- ---------------------------------------------------------------------------
-- On Save
-- ---------------------------------------------------------------------------
vim.api.nvim_create_autocmd("BufWritePre", {
  desc = "Strip Windows CRLF characters on save",
  group = groups.on_save,
  callback = function()
    if vim.fn.search("\\r$", "nw") == 0 then
      return
    end
    local view = vim.fn.winsaveview()
    vim.cmd([[silent! keepjumps keeppatterns %s/\r$//e]])
    vim.fn.winrestview(view)
  end,
})

return groups
