-- Language Server Protocol setup (servers, diagnostics, formatting).

vim.diagnostic.config({
  underline = {
    severity = { min = vim.diagnostic.severity.ERROR },
  },
  virtual_lines = {
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

-- Two-stage float: the first press uses Neovim's default opener; a second press
-- enlarges it to ~80% of the editor and moves the cursor inside. This is needed
-- to work around the differences in how markdown is rendered in the first vs.
-- second float
local function hover_or_enlarge(open_default)
  local buf = vim.api.nvim_get_current_buf()
  local win = vim.b[buf].lsp_floating_preview
  if win and vim.api.nvim_win_is_valid(win) then
    local width = math.floor(vim.o.columns * 0.8)
    local height = math.floor(vim.o.lines * 0.8)
    vim.api.nvim_win_set_config(win, {
      relative = "editor",
      row = math.floor((vim.o.lines - height) / 2),
      col = math.floor((vim.o.columns - width) / 2),
      width = width,
      height = height,
      border = "rounded",
    })
    vim.wo[win].wrap = true
    vim.wo[win].conceallevel = 0
    vim.api.nvim_set_current_win(win)
  else
    open_default()
  end
end

vim.keymap.set("n", "<leader>K", function()
  hover_or_enlarge(function()
    vim.diagnostic.open_float()
  end)
end, { desc = "Show diagnostics at cursor (press again to enlarge)" })

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

    vim.keymap.set("n", "K", function()
      hover_or_enlarge(function()
        vim.lsp.buf.hover()
      end)
    end, { buffer = args.buf, desc = "Hover (press again to enlarge)" })
  end,
})
