local ok, treesitter = pcall(require, "nvim-treesitter")
if not ok then
  return
end

treesitter.setup({})

local uv = vim.uv or vim.loop
local function parser_dir()
  return vim.fs.joinpath(vim.fn.stdpath("data"), "site", "parser")
end

local function dir_empty(path)
  local stat = uv.fs_stat(path)
  if not stat or stat.type ~= "directory" then
    return true
  end
  local handle = uv.fs_scandir(path)
  if not handle then
    return true
  end
  return uv.fs_scandir_next(handle) == nil
end

vim.api.nvim_create_autocmd("VimEnter", {
  desc = "Run TSUpdate after first install",
  once = true,
  callback = function()
    if dir_empty(parser_dir()) then
      vim.schedule(function()
        pcall(vim.cmd, "TSUpdate")
      end)
    end
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  desc = "Enable treesitter highlighting",
  callback = function(args)
    if vim.bo[args.buf].buftype ~= "" then
      return
    end
    pcall(vim.treesitter.start, args.buf)
  end,
})
