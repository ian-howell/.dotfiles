require("copilot").setup({
  suggestion = {
    enabled = true,
    auto_trigger = true,
    trigger_on_accept = true,
    keymap = {
      accept = "<C-y>",
      accept_word = "<C-f>",
      accept_line = "<C-l>",
    },
  },
  panel = {
    enabled = true,
    auto_refresh = true,
  },
  filetypes = {
    ["*"] = true,
  },
  server_opts_overrides = {
    flags = {
      -- Work around Neovim 0.12.2 incremental sync assertions in Copilot buffers.
      allow_incremental_sync = false,
    },
  },
  nes = {
    enabled = false,
  },
})

local function copilot_accept(method, fallback)
  return function()
    local suggestion = require("copilot.suggestion")
    if suggestion.is_visible() then
      suggestion[method]()
      return ""
    end

    return vim.api.nvim_replace_termcodes(fallback, true, false, true)
  end
end

vim.api.nvim_create_autocmd("LspAttach", {
  desc = "Install Copilot accept fallback mappings",
  group = vim.api.nvim_create_augroup("user-copilot-keymaps", { clear = true }),
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if not client or client.name ~= "copilot" then
      return
    end

    local function map(lhs, method, desc)
      vim.keymap.set("i", lhs, copilot_accept(method, lhs), {
        buffer = args.buf,
        desc = desc,
        expr = true,
        silent = true,
      })
    end

    map("<C-y>", "accept", "Accept Copilot suggestion")
    map("<C-f>", "accept_word", "Accept Copilot word")
    map("<C-l>", "accept_line", "Accept Copilot line")
  end,
})

vim.keymap.set("n", "<leader>ad", "<cmd>Copilot disable<CR>", { desc = "Disable Copilot" })
vim.keymap.set("n", "<leader>ae", "<cmd>Copilot enable<CR>", { desc = "Enable Copilot" })
