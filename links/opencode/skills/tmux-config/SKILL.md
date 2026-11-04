---
name: tmux-config
description: "Use when changing Ian's tmux config: keybindings, options, themes, status line."
---

# Configuring tmux

The config lives in `links/tmux` in the dotfiles repo, linked to `~/.config/tmux`. `tmux.conf`
sources the fragments in `config/` in order, then the optional work overlay
`~/.config/work/tmux.conf`.

## Rules
- Adding a keybinding: work-tool bindings go in `~/.config/work/tmux.conf` (loaded by the base
  `links/tmux/tmux.conf` via `source -q`, so the base works without the overlay); generic ones go in
  `links/tmux/config/keybindings.conf` under the matching section with `bind -N "custom: ..."`.
  Popups follow the existing style: `display-popup -w 90% -h 90% -E -b "rounded" "<cmd>"`. Check
  `tmux list-keys -T prefix <key>` first and tell Ian what default you override (e.g. `P` was
  `paste-buffer`). Verify on a scratch server (next rule).
- Testing tmux config changes: never change Ian's live server while working. That means no
  `bind`/`unbind`/`set` against it and no `source-file` of a single fragment. Fragments assume they
  run in `tmux.conf` order: `keybindings.conf` alone resets keys the work overlay rebinds later
  (e.g. `P`, `C-b`). Verify on an isolated server instead:
  `tmux -L scratch -f ~/.config/tmux/tmux.conf new -d -s t`, then
  `tmux -L scratch list-keys`/`show -g`/`display-message`, then `tmux -L scratch kill-server`. Apply
  to the live server only when Ian asks, and always with the full config:
  `tmux source-file ~/.config/tmux/tmux.conf`.
- Window names and user-facing labels use the `@pane-program` format in
  `links/tmux/config/options.conf` (`tmux display -p -t <pane> '#{E:@pane-program}'`); reuse it
  rather than a separate `pane_current_command` check. After changing it, check every window with
  `list-windows -a` on a scratch server that has a few windows running different programs.
