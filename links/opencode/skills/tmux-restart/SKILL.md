---
name: tmux-restart
description: "Use when Ian wants to restart or upgrade the tmux server, or recover sessions after tmux died, without losing in-flight work."
---

# Restarting tmux without losing work

`tmux-restart` (`links/bin/tmux-restart.d/tmux-restart`) snapshots the server and rebuilds it:
sessions, windows, panes, layouts, working directories and active window/pane. It relaunches
programs it knows how to resume:

- **opencode**: `--session <id>` from the pane's `@opencode-session` option (set by the
  `tmux-status` plugin), else a unique title match in `opencode session list`. Conversations
  live in the OpenCode service, outside tmux, so they survive the restart either way.
- **nvim**: `:mksession` over RPC, reopened with `nvim -S` (files, splits, tabs, cursors).
  Terminal buffers are left out. Unsaved file buffers abort the snapshot.
- **k9s, lazygit**: original arguments.

Everything else returns as a shell in the same directory; the snapshot report lists those
panes so Ian knows what to restart by hand.

## Commands

- `tmux-restart`: confirm, snapshot, then kill and rebuild the server from a systemd transient
  unit (`tmux-restart-<timestamp>`). Clients drop out; Ian reattaches with `tmux attach` after
  a few seconds. Log: `journalctl --user -u tmux-restart-<timestamp>`.
- `tmux-restart save`: snapshot only. Run it before anything that might kill tmux.
- `tmux-restart restore [DIR]`: rebuild from a snapshot (default: latest). Sessions that
  already exist are skipped, so it is safe to rerun.
- `tmux-restart list`: snapshots under `~/.local/state/tmux-restart/`.

## Rules for agents

- Ian runs `tmux-restart` himself: it kills the pane the agent runs in. Do not run it.
- `save`, `list` and `restore` are safe to run; `restore` only adds sessions.
- Never delete snapshot directories, and never use globs that could match them.
- Test changes against a separate server: `TMUX_RESTART_SOCKET=<name>` makes every tmux call
  use `-L <name>`; point `XDG_STATE_HOME` at a temp dir so test snapshots stay out of the real
  state directory.
