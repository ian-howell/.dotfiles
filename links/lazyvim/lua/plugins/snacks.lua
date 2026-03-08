return {
  {
    "folke/snacks.nvim",
    keys = (function()
      local git_layout = {
        layout = {
          preset = "default",
          layout = {
            width = 0.95,
            height = 0.95,
            box = "vertical",
            { win = "input",   height = 1   },
            { win = "list",    height = 0.3 },
            { win = "preview", height = 0.7 },
          },
        },
        focus = "list",
      }

      return {
        -- files: cwd vs root are swapped from LazyVim defaults
        { "<leader>ff", function() Snacks.picker.files({ cwd = vim.uv.cwd() }) end, desc = "files (cwd)" },
        { "<leader>fF", function() Snacks.picker.files({ cwd = LazyVim.root() }) end, desc = "files (root)" },
        -- projects (LazyVim default behavior)
        { "<leader>fp", function() Snacks.picker.projects() end, desc = "projects" },
        -- meta picker (list of all pickers)
        { "<leader>fP", function() Snacks.picker() end, desc = "pickers" },
        -- resume
        { "<leader>fc", function() Snacks.picker.resume() end, desc = "continue (resume picker)" },
        -- git pickers
        { "<leader>fg", function() Snacks.picker.git_status(git_layout) end, desc = "git status (changed files)" },
        -- disable LazyVim snacks_picker extra mappings we don't want
        { "<leader>gs", false },
        { "<leader>gd", false },
        { "<leader>ub", false },
        { "<leader>fT", false },
        { "<leader>fG", function()
          local base = vim.trim(vim.fn.system("git merge-base origin/main HEAD") or "")
          local opts = vim.tbl_deep_extend("force", {}, git_layout)
          if base ~= "" then opts.base = base end
          Snacks.picker.git_diff(opts)
        end, desc = "git diff (vs merge-base)" },
        { "<leader>gl", function() Snacks.picker.git_log(git_layout) end, desc = "git log" },
        { "<leader>gh", function() Snacks.picker.git_log_file(git_layout) end, desc = "git log (file)" },
        -- diagnostics aliases
        { "<leader>fd", function() Snacks.picker.diagnostics_buffer() end, desc = "diagnostics (buffer)" },
        { "<leader>fD", function() Snacks.picker.diagnostics() end, desc = "diagnostics (workspace)" },
        -- misc pickers
        { "<leader>fq", function() Snacks.picker.qflist() end, desc = "quickfix list" },
        { "<leader>fQ", function() Snacks.picker.qflist() end, desc = "quickfix list (prev)" },
        { "<leader>fl", function() Snacks.picker.lines() end, desc = "buffer lines" },
        { "<leader>fs", function() Snacks.picker.lsp_symbols() end, desc = "lsp symbols" },
        -- grep word (override LazyVim's <leader>sw)
        { "<leader>*", function() Snacks.picker.grep_word() end, desc = "grep word", mode = { "n", "x" } },
      }
    end)(),
    opts = {
      picker = {
        layout = { width = 0.95, height = 0.95 },
        win = {
          input = {
            keys = {
              ["<space>-"]  = { "edit_split",  mode = { "n", "i" } },
              ["<space>\\"] = { "edit_vsplit", mode = { "n", "i" } },
            },
          },
        },
        sources = { files = { hidden = true } },
      },
      dashboard = { enabled = false },
      gitbrowse = {
        url_patterns = {
          ["dev%.azure%.com"] = {
            branch = "?version=GB{branch}",
            file = "?path=/{file}&version=GB{branch}&line={line_start}&lineEnd={line_end}&lineStartColumn=1&lineEndColumn=9999&lineStyle=plain&_a=contents",
            permalink = "?path=/{file}&version=GC{commit}&line={line_start}&lineEnd={line_end}&lineStartColumn=1&lineEndColumn=9999&lineStyle=plain&_a=contents",
            commit = "/commit/{commit}",
          },
        },
      },
      lazygit = {
        config = {
          os = {
            -- Custom edit commands to use --remote instead of --remote-tab
            -- This makes files open in the current buffer instead of a new tab
            edit = '[ -z "$NVIM" ] && (nvim -- {{filename}}) || (nvim --server "$NVIM" --remote-send "q" && nvim --server "$NVIM" --remote {{filename}})',
            editAtLine = '[ -z "$NVIM" ] && (nvim +{{line}} -- {{filename}}) || (nvim --server "$NVIM" --remote-send "q" && nvim --server "$NVIM" --remote {{filename}} && nvim --server "$NVIM" --remote-send ":{{line}}<CR>")',
            editAtLineAndWait = "nvim +{{line}} {{filename}}",
            openDirInEditor = '[ -z "$NVIM" ] && (nvim -- {{dir}}) || (nvim --server "$NVIM" --remote-send "q" && nvim --server "$NVIM" --remote {{dir}})',
          },
        },
      },
    },
  },
}
