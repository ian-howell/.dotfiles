return {
  { -- Quicker
    -- This thing is _soo_ friggin cool. Not only does it allow you to
    -- delete items from the quickfix list, but it also allows you to
    -- actually modify the files themselves. So for example, running
    -- :%s/foo/bar/g will change all instances of foo to bar in _every_
    -- file in the quickfix list.
    --
    -- Plus it looks gorgeous.
    --
    -- TODO: Read this: https://github.com/k?tab=readme-ov-file
    'stevearc/quicker.nvim',
    event = 'FileType qf',
    ---@module "quicker"
    ---@type quicker.SetupOptions
    opts = {},
  },
}
