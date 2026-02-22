-- Snacks configuration (picker focused, fzf-lua compatible bindings).

local snacks = give("snacks")

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

give("core.keymaps-snacks").setup()

vim.api.nvim_create_autocmd("FileType", {
  pattern = "snacks_picker_list",
  callback = function(args)
    vim.opt_local.number = false
    vim.opt_local.relativenumber = false
    vim.keymap.set("n", "q", "<cmd>q<CR>", { buffer = args.buf, silent = true })
  end,
})
