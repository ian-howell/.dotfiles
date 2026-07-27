-- fyler.nvim - manipulate the filesystem by editing a tree buffer.
local fyler = require("fyler")
local Snacks = require("snacks")

fyler.setup({
  -- Window style. One of "floating", "replace", "split_above",
  -- "split_above_all", "split_below", "split_below_all", "split_left",
  -- "split_left_most", "split_right", "split_right_most". "split_left_most"
  -- is a full-height sidebar pinned to the far left of the tabpage.
  kind = "split_left_most",

  -- Per-kind overrides, merged on top of the top-level options.
  kind_presets = {
    split_left_most = {
      -- Sidebar width. A "%" string is relative to total columns; a plain
      -- number is an absolute column count.
      width = "50",
    },
  },

  -- Move the cursor onto the current file's entry (expanding parents as
  -- needed) whenever you switch buffers.
  follow_current_file = true,

  -- When true, :tcd the tab to the tree root on open and back to the global
  -- cwd on close.
  follow_root_dir = false,

  -- Delete netrw's FileExplorer autocmds and open fyler for directory
  -- buffers, so `nvim .`, `:e src/` and `:Ex` all land in fyler.
  use_as_default_explorer = true,

  -- Skip the write-confirmation dialog for "simple" mutations, defined as
  -- copy <= 1 and create <= 5 and delete <= 0 and move <= 1. Left off so
  -- every filesystem change is confirmed.
  auto_confirm_simple_mutation = false,

  -- Keep the cursor within the editable part of each line so indent guides
  -- and icons cannot be edited by accident.
  bound_cursor = true,

  -- Window-local options, applied after fyler's own window defaults. Note that
  -- these options are limited, e.g. setting signcolumn here does not work.
  -- (see the FileType autocmd below for a workaround).
  win_opts = {
    cursorline = true,
  },

  -- Optional feature modules, keyed by name. Each takes an `enabled` boolean.
  extensions = {
    -- Per-entry git status icons, propagated up to parent directories.
    -- `inline = false` right-aligns them instead of placing them by the name.
    git = { enabled = true, inline = false },
    -- Delete to the XDG trash (~/.local/share/Trash) rather than unlinking.
    trash = { enabled = true },
    -- Watch the filesystem and refresh when files change outside Neovim.
    watcher = { enabled = true },
  },

  -- External plugins fyler delegates to.
  integrations = {
    -- Icon provider: "mini_icons", "nvim_web_devicons" or "vim_nerdfont".
    -- Leaving this unset renders no icons at all.
    icon = "mini_icons",

    -- Function returning a window id (or nil) deciding where <CR> opens a
    -- file. Snacks returns immediately when only one candidate window
    -- exists and shows a letter overlay otherwise. The filter excludes the
    -- fyler sidebar itself and any Snacks window.
    window_picker = function()
      return Snacks.picker.util.pick_win({
        filter = function(_, buf)
          local ft = vim.bo[buf].filetype
          return ft ~= "fyler_finder" and not ft:find("^snacks")
        end,
      })
    end,
  },

  -- Callbacks fired after fyler has applied a filesystem change.
  hooks = {},

  ui = {
    -- Draw a vertical guide at each indent level. Boolean.
    indent_guides = true,

    -- Which entries are hidden. fyler has no gitignore support; filtering is
    -- Lua patterns matched against the full path.
    hidden_items = {
      -- Named toggles, flipped by `g.`. The only builtin is "dotfiles", which
      -- hides names starting with ".". Left empty so hidden files are always
      -- visible.
      -- With this and patterns both empty, `g.` is a no-op.
      switches = {},
      -- Extra Lua patterns hidden alongside the switches, also toggled by `g.`.
      patterns = {},
      -- Always shown, even when a switch or pattern would hide them. Lua
      -- patterns matched against the full path.
      always_visible = {},
      -- Always hidden, even when a switch would show them. Lua patterns
      -- matched against the full path.
      always_hidden = {
        -- "/%.git$" matches paths ending in "/.git".
        "/%.git$",
      },
    },
  },

  -- Buffer-local keymaps inside the tree, keyed by mode. Each names a builtin
  -- action plus its args; `disabled = true` removes a default. Defaults
  -- include `-` parent, `.` enter dir, `=` visit, `<CR>` open, `<C-S>`/`<C-V>`
  -- split/vsplit, `<C-T>` tab, `<C-R>` refresh, `g.` hidden, `gi` guides,
  -- `q` close.
  mappings = {
    n = {
      ["<leader>-"] = { action = "select", args = { split = true } },
      ["<leader>\\"] = { action = "select", args = { vsplit = true } },
    },
  },
})

-- fyler hardcodes signcolumn=yes after both win_opts and the FileType event, so
-- neither can turn it off; deferring past Finder:open is the earliest point the
-- value sticks. Nothing renders there - git status is virtual text and the
-- buffer places no signs - so it is pure wasted padding.
-- core/autocmds.lua must also ignore this filetype, or the focus-UI autocmd
-- switches it back on at the next WinEnter.
vim.api.nvim_create_autocmd("FileType", {
  pattern = "fyler_finder",
  desc = "Drop the unused signcolumn from the fyler window",
  callback = function(args)
    local win = vim.api.nvim_get_current_win()
    vim.schedule(function()
      if vim.api.nvim_win_is_valid(win) and vim.api.nvim_win_get_buf(win) == args.buf then
        vim.wo[win].signcolumn = "no"
      end
    end)
  end,
})

-- Focus the explorer, opening a new split if necessary
vim.keymap.set("n", "<leader>e", function()
  fyler.open({ root_path = vim.uv.cwd() })
end, { desc = "Explorer focus" })

-- Toggle the explorer split
vim.keymap.set("n", "<leader>E", function()
  local origin = vim.api.nvim_get_current_win()
  fyler.toggle({ root_path = vim.uv.cwd() })
  if vim.api.nvim_win_is_valid(origin) and vim.api.nvim_get_current_win() ~= origin then
    vim.api.nvim_set_current_win(origin)
  end
end, { desc = "Explorer toggle" })
