local treesitter = require("nvim-treesitter")
local treesitter_source = debug.getinfo(treesitter.install, "S").source:sub(2)
local treesitter_root = vim.fs.dirname(vim.fs.dirname(vim.fs.dirname(treesitter_source)))
local treesitter_runtime = vim.fs.joinpath(treesitter_root, "runtime")

if vim.uv.fs_stat(treesitter_runtime) then
  vim.opt.runtimepath:prepend(treesitter_runtime)
end

vim.treesitter.language.register("typespec", "typespec")
vim.treesitter.language.register("bash", { "sh", "bash" })

local parser_config = require("nvim-treesitter.parsers")
parser_config.typespec = {
  install_info = {
    url = "https://github.com/happenslol/tree-sitter-typespec",
    files = { "src/parser.c", "src/scanner.c" },
    branch = "main",
    revision = "395bef1e1eb4dd18365401642beb534e8a244056",
    generate_requires_npm = false,
    requires_generate_from_grammar = false,
  },
  filetype = "typespec",
}

local ensure_installed = {
  "bash",
  "go",
  "gomod",
  "gowork",
  "json",
  "lua",
  "make",
  "markdown",
  "markdown_inline",
  "python",
  "query",
  "typescript",
  "typespec",
  "vim",
  "vimdoc",
  "yaml",
  "zsh",
}

vim.api.nvim_create_autocmd("VimEnter", {
  desc = "Install missing Treesitter parsers",
  once = true,
  callback = function()
    vim.schedule(function()
      local ok, err = pcall(function()
        treesitter.install(ensure_installed):wait(300000)
      end)
      if not ok then
        vim.notify("Treesitter parser install check failed: " .. err, vim.log.levels.WARN)
      end
    end)
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  desc = "Enable treesitter highlighting",
  group = vim.api.nvim_create_augroup("treesitter-start", { clear = true }),
  callback = function(args)
    if vim.bo[args.buf].buftype ~= "" then
      return
    end

    local ok, err = pcall(vim.treesitter.start, args.buf)
    if not ok and not tostring(err):find("Parser could not be created", 1, true) then
      error(err)
    end
  end,
})
