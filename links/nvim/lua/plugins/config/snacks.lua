-- Snacks configuration (picker focused, fzf-lua compatible bindings).

local snacks = give("snacks")
if not snacks then
  return
end

local default_layout = {
  layout = {
    width = 0.95,
    height = 0.95,
  },
}

snacks.setup({
  explorer = {
    replace_netrw = true,
  },
  picker = {
    layout = default_layout,
    win = {
      input = {
        keys = {
          ["<space>-"] = { "edit_split", mode = { "n", "i" } },
          ["<space>\\"] = { "edit_vsplit", mode = { "n", "i" } },
        },
      },
    },
    sources = {
      files = {
        hidden = true,
      },
    },
  },
})

local keymaps_snacks = give("core.keymaps-snacks")
if keymaps_snacks then
  keymaps_snacks.setup()
end

vim.api.nvim_create_autocmd("FileType", {
  pattern = "snacks_picker_list",
  callback = function(args)
    vim.opt_local.number = false
    vim.opt_local.relativenumber = false
    vim.keymap.set("n", "q", "<cmd>q<CR>", { buffer = args.buf, silent = true })
  end,
})
