-- render-markdown.nvim: in-buffer rendering of headings, code blocks, tables
-- and callouts.

require("render-markdown").setup({
  file_types = { "markdown", "opencode_output" },

  -- I don't use latex, so I don't install latex parsers.
  -- Without this, checkhealth will complain about missing parsers.
  latex = { enabled = false },
})

vim.keymap.set("n", "<leader>um", "<cmd>RenderMarkdown buf_toggle<cr>", { desc = "markdown rendering" })
