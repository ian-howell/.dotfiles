---
name: neovim-config
description: "Use when changing Ian's Neovim config (keymaps, plugins) or reading a live Neovim from tmux/scripts."
---

# Neovim config

Config lives in `~/.dotfiles/links/nvim` and uses Neovim's built-in package manager (vim.pack).
Plugin sources are in `~/.local/share/nvim/site/pack/core/opt/<plugin>`; per-plugin config is in
`links/nvim/lua/plugins/config/<name>.lua`.

## Procedure

1. Find every config file that binds the keys involved (search for the key string, e.g.
   `<leader>e`) plus the plugin's default mappings.
2. Run `git log -p -- <file>` on any custom override block before touching it. Overrides
   (monkeypatched actions, wrapped keymaps) are deliberate; the commit message records why.
   Never delete one to "restore defaults" without asking.
3. Read the plugin's source before claiming how it behaves; don't rely on memory. Before blaming
   the plugin, check upstream (`git -C <plugin> fetch && git log HEAD..origin/HEAD`).
4. For "make X behave like Y", write a per-key table of what each does now. Bring the side that
   diverges from what the user wants up to match, keeping deliberate custom code; ask if unclear.
   Cross-reference the sibling file in a comment so the two stay in parity.
5. When a key behaves differently between windows, check which mapping fires in each buffer with
   `maparg(lhs, 'n', false, true).desc`. Buffer-local maps from another plugin can shadow the
   expected ones (e.g. gitsigns attaches to real-file panes inside diff tools).
6. Edit in the file's comment style (explain why above each block), verify headlessly, and
   report what was and wasn't tested.
7. If a setting must stay a certain way to avoid an upstream bug, add a `REQUIRED:` comment: must
   not be changed, the upstream function/file and affected version, the mechanism and symptom.

For reading a running Neovim from tmux or another tool (socket discovery, selection capture,
tmux keybinding rules), see `references/live-nvim-and-tmux.md`.

## Headless verification

Call the mapping's callback directly; `feedkeys` inside `-c`/`defer_fn` can hang or not move the
cursor. Always wrap in `timeout`, and write results to stderr with a marker to grep:

```
timeout 20 nvim --headless +'lua vim.defer_fn(function()
  local cb = vim.fn.maparg(vim.g.mapleader.."e", "n", false, true).callback; cb()
  vim.defer_fn(function() io.stderr:write("RES "..vim.bo.filetype.."\n"); vim.cmd("qa!") end, 300)
end, 500)' 2>&1 | grep RES
```

Use `defer_fn` delays because plugins open windows asynchronously. For git-diff plugins, build a
scratch repo under `$TMPDIR` (`seq 1 100`, commit, edit lines 10/50/90), run `:CodeDiff`, and
wait about 4 s before probing.

## Debugging flicker or nondeterminism

- Suspect `pairs()` first: inserting or removing keys while iterating a table is undefined in
  Lua. Prove it from the plugin dir with
  `timeout 30 nvim --headless --clean -u NONE +'set rtp+=.' +'lua ...'`, building the same
  structure many times with unrelated table churn in between and counting differing outputs.
- Check whether upstream already fixed it, then offer options (local override, disable the
  option, upstream report) and let the user pick. Don't vendor code silently.

## Pitfalls

- `wrapscan` is on by default and gitsigns `nav_hunk` follows it, so it wraps unless
  `wrap = false` is passed.
- CodeDiff `explorer.flatten_dirs` must stay `false`: `flatten_tree()` in
  `ui/explorer/nodes.lua` mutates a table while iterating it, which makes the tree flicker.

## Parity pair: fyler drawer and CodeDiff explorer

Both should behave the same:

- `<leader>e` focuses the drawer; pressed inside it, hides the drawer and returns to the window
  you came from.
- `<leader>E` toggles the drawer without moving focus.
- `Enter` on a file opens it and hides the drawer; on a directory it toggles.

CodeDiff does this by wrapping `panes.focus_explorer` and `explorer_keymaps.setup` in
`plugins/config/codediff.lua`; fyler uses a remembered return window and `select` args
`{ pick = true, close = true }`.
