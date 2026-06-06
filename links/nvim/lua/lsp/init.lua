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

-- Map escape to close floating windows, like diagnostics and hover previews
local open_floating_preview = vim.lsp.util.open_floating_preview
vim.lsp.util.open_floating_preview = function(contents, syntax, opts, ...)
  local bufnr, winid = open_floating_preview(contents, syntax, opts, ...)
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
  desc = "LSP keymaps and manual completion",
  group = vim.api.nvim_create_augroup("lsp-attach", { clear = true }),
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)

    vim.keymap.set("n", "gd", function()
      require("lsp.goto-definition").definition_or_implementation_picker()
    end, { buffer = args.buf, desc = "Definition" })

    if client and vim.lsp.completion then
      vim.lsp.completion.enable(true, client.id, args.buf, { autotrigger = false })
      vim.keymap.set("i", "<C-Space>", function()
        vim.lsp.completion.get()
      end, { buffer = args.buf, desc = "Trigger LSP completion" })
    end
  end,
})
