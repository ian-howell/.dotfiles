local M = {}

local markers = {
  "go.work",
  "go.mod",
  "package.json",
  "pyproject.toml",
  "Cargo.toml",
  "Makefile",
  ".git",
}

function M.get(bufnr)
  bufnr = bufnr or 0
  return vim.fs.root(bufnr, markers) or vim.uv.cwd()
end

function M.cwd()
  return vim.uv.cwd()
end

return M
