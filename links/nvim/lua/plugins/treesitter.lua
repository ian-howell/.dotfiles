return {
  "nvim-treesitter/nvim-treesitter",
  opts = function(_, opts)
    vim.treesitter.language.register("typespec", "typespec")

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

    opts.ensure_installed = opts.ensure_installed or {}
    table.insert(opts.ensure_installed, "typespec")
  end,
}
