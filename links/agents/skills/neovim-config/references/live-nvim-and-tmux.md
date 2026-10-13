# Reading a live Neovim from tmux / outside tools

Use when a script or agent needs what Ian is looking at in a running Neovim (file, cursor,
selection, visible lines), or when adding tmux keybindings that drive other panes.

## Find the right Neovim

- Each nvim listens on `$XDG_RUNTIME_DIR/nvim.<pid>.0`. Map a tmux pane to it by walking the
  process tree from `#{pane_pid}` (`pgrep -P`) until a matching socket exists, so you get the
  nvim in the pane Ian was driving, not another instance.
- Pass the source pane from the binding (`run-shell -b "script '#{pane_id}'"`).
- Find a Hermes pane by child process args containing `hermes_cli.main` (pane_current_command
  is only `python3`/`zsh`); prefer the same window, then most recent activity.

## Query it

- Put the query in a Lua companion file and run
  `nvim --server $sock --remote-expr "luaeval('dofile(\"$here/x.lua\")')"`, returning a string.
  Multi-line Vimscript in `--remote-expr` fails with E15 because newlines break the expression.
- Selection: in visual mode use `getpos('v')`/`getpos('.')` with `mode()`; otherwise the last
  selection via `'<`/`'>` and `visualmode()`; extract with `getregion()`. Include the visible
  window `line('w0')..line('w$')` too.
- Non-Neovim panes: `tmux capture-pane -p -J -t <pane>`.

## Key pressed from the Hermes pane itself

- The active pane is then Hermes, so resolve the source as the previously used pane. Use
  a focus trail, not `{last}`/`#{pane_last}`: those don't reliably reflect the pane Ian came
  from and returned the Hermes pane during testing.
- Focus trail: `set-hook -g pane-focus-in[N] 'run-shell -b "script --trail #{pane_id}"'`
  appends one line per move (time, session:window, pane, command, cwd) and trims to the last
  200. It costs about 50 ms in the background, so typing isn't delayed. Include the last ~15
  lines in each capture so Hermes sees recent movement. Needs `focus-events on`.

## tmux keybinding rules

- Grep `links/tmux/config/keybindings.conf` for the key before binding; report a conflict to
  Ian instead of overwriting it.
- Ian wants prefix chords he can press while holding Ctrl throughout (`C-Space C-a`, not
  `C-Space a`), so bind the `C-` variant.
- Reload with `tmux source-file ~/.config/tmux/tmux.conf`; confirm with `tmux list-keys | grep`.
- Test scripts that send keys to other panes with the `send-keys` line stripped, so testing
  doesn't trigger side effects in a live session.
- Check Ian's latest capture before replying to a voice turn: when he says "this", "here", or "what
  I'm looking at", or asks what you saw, read `~/.hermes/cache/look.md` and `look-trail.log`.
  Say what the trail can't show: it records which pane he moved to, not where he went inside
  Neovim.

Working example: `links/bin/hermes-look.d/` (C-Space C-a writes pane context to
`~/.hermes/cache/look.md` and starts Hermes voice recording).
