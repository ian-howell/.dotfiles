# Tmux troubleshooting

## Held keys lag, and movement continues after release

Press **Ctrl-Space, Shift-R** to reconnect just the invoking client to its current
session. This resets the terminal connection without restarting the tmux server,
panes, or programs. Ctrl-Space, Ctrl-R is still config reload.

The reconnect binding passes the invoking socket, client, and session ID explicitly,
so it also works on named servers and does not reconnect other attached clients.
It is a recovery action, not an established prevention fix.

### What the September 2026 investigation established

- Configured and clean Neovim both lagged on the original connection.
- Clean Neovim outside tmux was smooth.
- Fresh tmux servers with defaults and with the full config were smooth.
- A fresh terminal client attached to the original server was smooth.
- Reconnecting the original client fixed the lag without restarting Windows
  Terminal, the tmux server, or Neovim.

Versions were tmux 3.7c and Windows Terminal 1.24.11911.0. The original client had
been attached about 29 hours and its `client_written` counter was about 7.35 GB.
That is cumulative output, **not queued bytes**. `client_discarded` was zero;
there was no evidence of tmux's normal output-discard throttle. Host CPU/memory
pressure and terminal XON/XOFF flow control were not observed.

Tmux 3.7c's `tty_close`, `tty_open`, `tty_stop_tty`, and `tty_start_tty` in
[`tty.c`](https://github.com/tmux/tmux/blob/3.7c/tty.c) show why reconnect is a
broad reset: it replaces per-client I/O buffers and key parsing state, cancels
timers, restores/reapplies terminal modes, leaves/re-enters the alternate screen,
and flushes terminal output on startup. The recovery therefore isolates the
fault to the old client/terminal path but does not distinguish a parser problem,
queued I/O, or terminal rendering state. The pre-reset state was not traced.

### If it happens again

Before reconnecting, if practical:

1. Note the affected terminal tab and whether the cursor really keeps moving
   after release, or only the display is catching up.
2. From a healthy client on the same server, record:

   ```sh
   tmux list-clients -F '#{client_name} pid=#{client_pid} created=#{client_created} size=#{client_width}x#{client_height} flags=#{client_flags} features=#{client_termfeatures} written=#{client_written} discarded=#{client_discarded}'
   tmux show-messages -T
   ```

3. Watch the same affected session in a fresh client. If it stops moving there
   immediately while the original display keeps catching up, that points to
   output/rendering rather than queued input to Neovim.
4. Try `tmux refresh-client -t /dev/pts/N` for the **affected client**. If a redraw
   fixes it, record that before using the stronger reconnect reset.
5. If still reproducible, collect a short tmux/Windows Terminal trace before
   resetting it. Avoid leaving tmux verbose logging on permanently: it can
   itself slow rendering and can record terminal contents/keystrokes.

There is no confirmed preventive setting yet. Keep tmux and Windows Terminal
current. Do not automatically reconnect on a timer or change renderer/key
protocol settings based solely on this incident; a recurrence captured before
reset is needed to select and verify a targeted fix.
