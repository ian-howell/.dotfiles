-- Plugin manager setup and plugin configuration.
-- Uses vim.pack to manage plugins in the dedicated pack directory.

local specs = require("plugins.specs")

vim.pack.add(specs)

require("plugins.config.tokyonight")
