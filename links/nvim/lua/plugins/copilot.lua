return {
  { -- Copilot
    'zbirenbaum/copilot.lua',
    cmd = 'Copilot',
    event = 'InsertEnter',

    opts = {
      panel = { enabled = false },
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
  },
}
-- vim: ts=2 sts=2 sw=2 et
