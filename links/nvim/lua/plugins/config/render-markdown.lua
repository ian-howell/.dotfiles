-- render-markdown.nvim: in-buffer rendering of headings, code blocks, tables
-- and callouts.

require("render-markdown").setup({
  file_types = { "markdown", "opencode_output" },

  -- I don't use latex, so I don't install latex parsers.
  -- Without this, checkhealth will complain about missing parsers.
  latex = { enabled = false },
})

-- Tone down the inline code background (default links to a fairly loud
-- ColorColumn). Use a muted background close to the editor background.
vim.api.nvim_set_hl(0, "RenderMarkdownCodeInline", { bg = "#2a2b3c" })

vim.keymap.set("n", "<leader>um", "<cmd>RenderMarkdown buf_toggle<cr>", { desc = "markdown rendering" })
