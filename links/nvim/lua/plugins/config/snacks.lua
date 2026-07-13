local Snacks = require("snacks")
local root = require("core.root")

local git_layout = {
  layout = {
    fullscreen = true,
    preset = "default",
    layout = {
      width = 0,
      height = 0,
      box = "vertical",
      { win = "input", height = 1 },
      { win = "list", height = 0.3 },
      { win = "preview", height = 0.7 },
    },
  },
  focus = "list",
}

Snacks.setup({
  picker = {
    focus = "list",
    hidden = true,
    ignored = true,
    layout = {
      fullscreen = true,
      layout = { width = 0, height = 0 },
    },
    win = {
      input = {
        keys = {
          ["<leader>-"] = { "edit_split", mode = { "n", "i" } },
          ["<leader>\\"] = { "edit_vsplit", mode = { "n", "i" } },
        },
      },
    },
    sources = {
      explorer = {
        jump = { close = true },
        layout = {
          fullscreen = true,
          preview = true,
          layout = {
            width = 0,
            height = 0,
            box = "horizontal",
            {
              box = "vertical",
              width = 0.35,
              { win = "input", height = 1, border = true, title = "{title} {live} {flags}", title_pos = "center" },
              { win = "list", border = "none" },
            },
            { win = "preview", title = "{preview}", border = "left", width = 0.65 },
          },
        },
      },
      files = { focus = "input" },
      grep = { focus = "input" },
      grep_buffers = { focus = "input" },
      grep_word = { focus = "input" },
    },
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
        edit = '[ -z "$NVIM" ] && (nvim -- {{filename}}) || (nvim --server "$NVIM" --remote-send "q" && nvim --server "$NVIM" --remote {{filename}})',
        editAtLine = '[ -z "$NVIM" ] && (nvim +{{line}} -- {{filename}}) || (nvim --server "$NVIM" --remote-send "q" && nvim --server "$NVIM" --remote {{filename}} && nvim --server "$NVIM" --remote-send ":{{line}}<CR>")',
        editAtLineAndWait = "nvim +{{line}} {{filename}}",
        openDirInEditor = '[ -z "$NVIM" ] && (nvim -- {{dir}}) || (nvim --server "$NVIM" --remote-send "q" && nvim --server "$NVIM" --remote {{dir}})',
      },
    },
  },
})

vim.keymap.set("n", "<leader>ff", function()
  Snacks.picker.files({ cwd = vim.uv.cwd() })
end, { desc = "Files cwd" })

vim.keymap.set("n", "<leader>fF", function()
  Snacks.picker.files({ cwd = root.get() })
end, { desc = "Files root" })

vim.keymap.set("n", "<leader>fp", function()
  Snacks.picker.projects()
end, { desc = "Projects" })

vim.keymap.set("n", "<leader>fP", function()
  Snacks.picker()
end, { desc = "Pickers" })

vim.keymap.set("n", "<leader>fc", function()
  Snacks.picker.resume()
end, { desc = "Continue picker" })

vim.keymap.set("n", "<leader>fr", function()
  Snacks.picker.recent()
end, { desc = "Recent files" })

vim.keymap.set("n", "<leader>fg", function()
  Snacks.picker.git_status(git_layout)
end, { desc = "Git status" })

vim.keymap.set("n", "<leader>fG", function()
  local base = vim.trim(vim.fn.system("git merge-base origin/main HEAD") or "")
  local opts = vim.tbl_deep_extend("force", {}, git_layout)
  if base ~= "" then
    opts.base = base
  end
  Snacks.picker.git_diff(opts)
end, { desc = "Git diff vs merge-base" })

vim.keymap.set("n", "<leader>gl", function()
  Snacks.picker.git_log(git_layout)
end, { desc = "Git log" })

vim.keymap.set("n", "<leader>gh", function()
  Snacks.picker.git_log_file(git_layout)
end, { desc = "Git log file" })

vim.keymap.set("n", "<leader>fd", function()
  Snacks.picker.diagnostics_buffer()
end, { desc = "Diagnostics buffer" })

vim.keymap.set("n", "<leader>fD", function()
  Snacks.picker.diagnostics()
end, { desc = "Diagnostics workspace" })

vim.keymap.set("n", "<leader>fq", function()
  Snacks.picker.qflist()
end, { desc = "Quickfix list" })

vim.keymap.set("n", "<leader>fQ", function()
  Snacks.picker.qflist()
end, { desc = "Quickfix list prev" })

vim.keymap.set("n", "<leader>fl", function()
  Snacks.picker.lines()
end, { desc = "Buffer lines" })

vim.keymap.set("n", "<leader>fs", function()
  Snacks.picker.lsp_symbols()
end, { desc = "LSP symbols" })

vim.keymap.set("n", "<leader>/", function()
  Snacks.picker.grep({ cwd = root.get() })
end, { desc = "Grep root" })

vim.keymap.set({ "n", "x" }, "<leader>*", function()
  Snacks.picker.grep_word()
end, { desc = "Grep word" })

vim.keymap.set("n", "<leader>fe", function()
  Snacks.explorer({ cwd = vim.uv.cwd() })
end, { desc = "Explorer cwd" })

vim.keymap.set("n", "<leader>fE", function()
  Snacks.explorer({ cwd = root.get() })
end, { desc = "Explorer root" })
