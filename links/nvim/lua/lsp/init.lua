-- Language Server Protocol setup (servers, diagnostics, formatting).

vim.diagnostic.config({
  underline = {
    severity = { min = vim.diagnostic.severity.ERROR },
  },
  virtual_text = {
    severity = { min = vim.diagnostic.severity.ERROR },
    source = "if_many",
  },
  signs = {
    severity = { min = vim.diagnostic.severity.ERROR },
  },
  update_in_insert = false,
  severity_sort = true,
  float = { border = "rounded", source = "if_many" },
})

vim.keymap.set("n", "[d", function()
  vim.diagnostic.jump({ count = -1, severity = vim.diagnostic.severity.ERROR })
end, { desc = "Previous error diagnostic" })

vim.keymap.set("n", "]d", function()
  vim.diagnostic.jump({ count = 1, severity = vim.diagnostic.severity.ERROR })
end, { desc = "Next error diagnostic" })

vim.keymap.set("n", "<leader>K", function()
  vim.diagnostic.open_float()
end, { desc = "Show diagnostics at cursor" })

-- Map escape to close floating windows, like diagnostics and hover previews
local open_floating_preview = vim.lsp.util.open_floating_preview
vim.lsp.util.open_floating_preview = function(contents, syntax, opts, ...)
  opts = opts or {}
  opts.max_width = opts.max_width or math.floor(vim.o.columns * 0.8)
  opts.max_height = opts.max_height or math.floor(vim.o.lines * 0.8)
  opts.wrap = false
  local bufnr, winid = open_floating_preview(contents, syntax, opts, ...)
  -- Core returns early when focusing an already-open float, so re-assert the
  -- window options here to cover both the create and focus (repeat K) paths.
  if winid and vim.api.nvim_win_is_valid(winid) then
    vim.wo[winid].wrap = false -- honor nowrap even after focusing in
    vim.wo[winid].conceallevel = 1 -- core forces 2; we prefer 1
    vim.wo[winid].concealcursor = "n" -- keep markdown concealed on the cursor line
  end
  vim.keymap.set("n", "<Esc>", "<cmd>close<CR>", { buffer = bufnr })
  return bufnr, winid
end

vim.lsp.config("gopls", {
  settings = {
    gopls = {
      analyses = {
        ST1003 = false,
      },
    },
  },
})

vim.lsp.config("lua_ls", {
  on_init = function(client)
    if client.workspace_folders then
      local path = client.workspace_folders[1].name
      if
        path ~= vim.fn.stdpath("config")
        and (vim.uv.fs_stat(path .. "/.luarc.json") or vim.uv.fs_stat(path .. "/.luarc.jsonc"))
      then
        return
      end
    end

    client.config.settings.Lua = vim.tbl_deep_extend("force", client.config.settings.Lua, {
      runtime = {
        version = "LuaJIT",
        path = {
          "lua/?.lua",
          "lua/?/init.lua",
        },
      },
      workspace = {
        checkThirdParty = false,
        library = {
          vim.env.VIMRUNTIME,
          vim.api.nvim_get_runtime_file("lua/lspconfig", false)[1],
        },
      },
    })
  end,
  settings = {
    Lua = {},
  },
})

vim.lsp.enable({ "gopls", "bashls", "lua_ls" })

vim.api.nvim_create_autocmd("LspAttach", {
  desc = "LSP keymaps",
  group = vim.api.nvim_create_augroup("lsp-attach", { clear = true }),
  callback = function(args)
    vim.keymap.set("n", "gd", function()
      require("lsp.goto-definition").definition_or_implementation_picker()
    end, { buffer = args.buf, desc = "Definition" })
  end,
})
