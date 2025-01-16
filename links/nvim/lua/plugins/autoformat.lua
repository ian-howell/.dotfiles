return {
  { -- Autoformat
    'stevearc/conform.nvim',
    event = { 'BufWritePre' },
    cmd = { 'ConformInfo' },
    keys = {
      {
        '<space>cf',
        function()
          require('conform').format { async = true, lsp_format = 'fallback' }
        end,
        mode = '',
        desc = 'format',
      },
    },
    opts = {
      notify_on_error = false,
      format_on_save = function(bufnr)
        local enable_filetypes = { lua = true }
        local lsp_format_opt
        if enable_filetypes[vim.bo[bufnr].filetype] then
          lsp_format_opt = 'fallback'
        else
          lsp_format_opt = 'never'
        end
        return {
          timeout_ms = 500,
          lsp_format = lsp_format_opt,
        }
      end,
      formatters_by_ft = {
        lua = { 'stylua' },
        -- Conform can also run multiple formatters sequentially
        go = { 'gofmt', 'goimports' },
        python = { 'isort', 'black' },
        --
        -- You can use 'stop_after_first' to run the first available formatter from the list
        -- javascript = { "prettierd", "prettier", stop_after_first = true },
      },
    },
  },
}

-- vim: ts=2 sts=2 sw=2 et
