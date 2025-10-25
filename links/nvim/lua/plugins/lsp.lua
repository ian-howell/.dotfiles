return {
  "neovim/nvim-lspconfig",
  opts = {
    inlay_hints = {
      -- LazyVim turns this on by default, and it's really pretyy cluttered...
      enabled = false,
    },
    diagnostics = {
      virtual_text = {
        source = "if_many",
      },
    },
    servers = {
      gopls = {
        settings = {
          gopls = {
            analyses = {
              -- Disable ST1003: naming convention checks
              ST1003 = false,
            },
          },
        },
      },
    },
  },
}
