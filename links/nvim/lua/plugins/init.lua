-- Plugin manager setup and plugin configuration.
-- Keep one early vim.pack.add() call; vim.pack installs missing plugins and
-- loads them immediately, so plugin globals that affect runtime/plugin scripts
-- must be set before this point.

vim.g.tmux_navigator_no_mappings = 1
vim.g.go_gopls_enabled = 0
vim.g.go_code_completion_enabled = 0

vim.api.nvim_create_autocmd("PackChanged", {
  desc = "Update Treesitter parsers when nvim-treesitter changes",
  callback = function(ev)
    local name = ev.data and ev.data.spec and ev.data.spec.name
    local kind = ev.data and ev.data.kind
    if name ~= "nvim-treesitter" or (kind ~= "install" and kind ~= "update") then
      return
    end

    vim.schedule(function()
      local ok, err = pcall(function()
        if not ev.data.active then
          vim.cmd.packadd("nvim-treesitter")
        end
        require("nvim-treesitter").update():wait(300000)
      end)
      if not ok then
        vim.notify("Treesitter parser update failed: " .. err, vim.log.levels.WARN)
      end
    end)
  end,
})

local specs = require("plugins.specs")

vim.pack.add(specs, { load = true })

vim.api.nvim_create_user_command("PackClean", function()
  local orphans = vim.iter(vim.pack.get())
    :filter(function(p)
      return not p.active
    end)
    :map(function(p)
      return p.spec.name
    end)
    :totable()

  if vim.tbl_isempty(orphans) then
    vim.notify("No unused plugins to remove", vim.log.levels.INFO)
    return
  end

  local prompt = "Remove unused plugins?\n  " .. table.concat(orphans, "\n  ")
  vim.ui.select({ "Yes", "No" }, { prompt = prompt }, function(choice)
    if choice == "Yes" then
      vim.pack.del(orphans)
    end
  end)
end, { desc = "Remove plugins not in the current spec list" })

require("lsp")
require("plugins.config.tokyonight")
require("plugins.config.tmux-navigator")
require("plugins.config.which-key")
require("plugins.config.snacks")
require("plugins.config.gitsigns")
require("plugins.config.codediff")
require("plugins.config.flash")
require("plugins.config.conform")
require("plugins.config.copilot")
require("plugins.config.treesitter")
require("plugins.config.ripple")
require("plugins.config.ripple-on-save")
require("plugins.config.surround")
require("plugins.config.go")
