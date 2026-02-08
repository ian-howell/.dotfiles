-- Snacks configuration (picker focused, fzf-lua compatible bindings).

local ok, snacks = pcall(require, "snacks")
if not ok then
  return
end

local default_layout = {
  layout = {
    width = 0.95,
    height = 0.95,
  },
}

local git_layout = {
  preset = "default",
  layout = {
    width = 0.95,
    height = 0.95,
    box = "vertical",
    { win = "input", height = 1 },
    { win = "list", height = 0.3 },
    { win = "preview", height = 0.7 },
  },
}

local explorer_layout = {
  layout = {
    preset = "sidebar",
    preview = false,
    width = 40,
  },
}

snacks.setup({
  explorer = {
    replace_netrw = true,
  },
  picker = {
    layout = default_layout,
    win = {
      input = {
        keys = {
          ["<space>-"] = { "edit_split", mode = { "n", "i" } },
          ["<space>\\"] = { "edit_vsplit", mode = { "n", "i" } },
        },
      },
    },
    sources = {
      files = {
        hidden = true,
      },
    },
  },
})

local ok_which_key, which_key = pcall(require, "which-key")
if ok_which_key then
  which_key.add({
    { "<leader>f", group = "find" },
    { "<leader>g", group = "git" },
    { "<leader>b", group = "buffers" },
    { "<leader>u", group = "UI" },
  })
end

snacks.toggle.option("wrap", { name = "Wrap" }):map("<leader>uw")
snacks.toggle.diagnostics():map("<leader>ud")

vim.keymap.set("n", "<leader>fe", function()
  snacks.explorer.open({
    layout = explorer_layout,
  })
end, { desc = "explorer" })

vim.api.nvim_create_autocmd("FileType", {
  pattern = "snacks_picker_list",
  callback = function(args)
    vim.opt_local.number = false
    vim.opt_local.relativenumber = false
    vim.keymap.set("n", "q", "<cmd>q<CR>", { buffer = args.buf, silent = true })
  end,
})

local function repo_root()
  local root = vim.fs.root(0, { ".git" })
  if root and root ~= "" then
    return root
  end

  return vim.loop.cwd()
end

local function merge_base()
  local output = vim.fn.system("git merge-base origin/main HEAD")
  return vim.trim(output or "")
end

vim.keymap.set("n", "<leader>ff", function()
  snacks.picker.files({ cwd = vim.loop.cwd() })
end, { desc = "files (cwd)" })

vim.keymap.set("n", "<leader>fF", function()
  snacks.picker.files({ cwd = repo_root() })
end, { desc = "files (root)" })

vim.keymap.set("n", "<leader>fh", function()
  snacks.picker.help()
end, { desc = "help" })

vim.keymap.set("n", "<leader>fk", function()
  snacks.picker.keymaps()
end, { desc = "keymaps" })

vim.keymap.set("n", "<leader>fp", function()
  snacks.picker()
end, { desc = "picker" })

vim.keymap.set("n", "<leader>/", function()
  snacks.picker.grep()
end, { desc = "grep" })

vim.keymap.set({ "n", "x" }, "<leader>*", function()
  snacks.picker.grep_word()
end, { desc = "word under the cursor" })

vim.keymap.set("n", "<leader>fd", function()
  snacks.picker.diagnostics_buffer()
end, { desc = "diagnostics (file)" })

vim.keymap.set("n", "<leader>fD", function()
  snacks.picker.diagnostics()
end, { desc = "diagnostics (project)" })

vim.keymap.set("n", "<leader>fr", function()
  snacks.picker.resume()
end, { desc = "resume" })

vim.keymap.set("n", "<leader>ft", function()
  snacks.picker.treesitter()
end, { desc = "treesitter" })

vim.keymap.set("n", "<leader>fq", function()
  snacks.picker.qflist()
end, { desc = "quickfix" })

vim.keymap.set("n", "<leader>fQ", function()
  snacks.picker.qflist()
end, { desc = "previous quickfix lists" })

vim.keymap.set("n", "<leader>fL", function()
  snacks.picker.grep_buffers()
end, { desc = "all buffer lines" })

vim.keymap.set("n", "<leader>fl", function()
  snacks.picker.lines()
end, { desc = "current buffer lines" })

vim.keymap.set("n", "<leader>bb", function()
  snacks.picker.buffers({
    focus = "list",
    matcher = {
      cwd_bonus = false, -- give bonus for matching files in the cwd
      frecency = false, -- frecency bonus
      history_bonus = false, -- give more weight to chronological order
    },
  })
end, { desc = "buffers" })

local default_git_opts = {
  layout = git_layout,
  focus = "list",
}

vim.keymap.set("n", "<leader>fg", function()
  snacks.picker.git_status(default_git_opts)
end, { desc = "git files" })

vim.keymap.set("n", "<leader>gl", function()
  snacks.picker.git_log(default_git_opts)
end, { desc = "git log" })

vim.keymap.set("n", "<leader>gh", function()
  snacks.picker.git_log_file(default_git_opts)
end, { desc = "git log for file" })

vim.keymap.set("n", "<leader>gc", function()
  snacks.terminal.open({ "git", "commit" }, { cwd = repo_root() })
end, { desc = "git commit" })

vim.keymap.set("n", "<leader>fG", function()
  local opts = default_git_opts
  local base = merge_base()
  if base ~= "" then
    opts.base = base
  end
  snacks.picker.git_diff(opts)
end, { desc = "git diff since branching from main" })
