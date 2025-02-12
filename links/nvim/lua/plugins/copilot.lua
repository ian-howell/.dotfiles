return {
  { -- Copilot
    'zbirenbaum/copilot.lua',
    cmd = 'Copilot',
    event = 'InsertEnter',

    opts = {
      suggestion = {
        enabled = true,
        auto_trigger = true,
        hide_during_completion = true,
        debounce = 75,
        keymap = {
          -- This is the same as normal completion.
          accept = '<C-y>',
          accept_word = '<C-f>',
          accept_line = '<C-l>',
          -- We can't use <C-n> (or <C-p>) because those are the triggers for normal completion.
          next = '<C-j>',
          prev = '<C-k>',
          -- This is the same as normal completion.
          dismiss = '<C-e>',
        },
      },
      filetypes = {
        ['*'] = true,
      },
      copilot_node_command = 'node', -- Node.js version must be > 18.x
      server_opts_overrides = {},
    },

    init = function()
      -- Toggle
      -- TODO: This just doesn't work. It doesn't even appear to work when I run the command directly. It
      -- works more like 'Copilot disable'
      -- vim.keymap.set('n', '<space>tc', '<cmd>Copilot toggle<CR>', { desc = 'Toggle Copilot' })
      vim.keymap.set('n', '<space>C', '', { desc = '+Copilot' })
      vim.keymap.set('n', '<space>Cd', '<cmd>Copilot disable<CR>', { desc = 'disable' })
      vim.keymap.set('n', '<space>Ce', '<cmd>Copilot enable<CR>', { desc = 'enable' })
      vim.keymap.set('n', '<space>Cp', '<cmd>Copilot panel<CR>', { desc = 'open panel' })
    end,
  },
  {
    'CopilotC-Nvim/CopilotChat.nvim',
    dependencies = {
      { 'zbirenbaum/copilot.lua' },
      { 'nvim-lua/plenary.nvim', branch = 'master' }, -- for curl, log and async functions
    },
    build = 'make tiktoken',
    opts = function()
      local user = vim.env.USER or 'User'
      user = user:sub(1, 1):upper() .. user:sub(2)
      return {
        auto_insert_mode = true,
        question_header = '  ' .. user .. ' ',
        answer_header = '  Copilot ',
        window = {
          width = 0.4,
        },
      }
    end,
    init = function()
      vim.keymap.set('n', '<space>C', '', { desc = '+Copilot' })
      vim.keymap.set({ 'n', 'x' }, '<space>Cc', '<cmd>CopilotChat<CR>', { desc = 'Open Copilot Chat' })
    end,
  },
}
-- vim: ts=2 sts=2 sw=2 et
