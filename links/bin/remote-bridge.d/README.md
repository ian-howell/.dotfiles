# remote-bridge

Lets a remote Linux host reached from WSL open things in the desktop browser and use the
desktop clipboard, the way `wslview` and `powershell.exe` do inside WSL.

`remote-bridge` runs in WSL as a systemd user service and listens on
`~/.local/state/remote-bridge/server.sock`. `remote-bridge-tunnel`, a second user service, holds
one SSH connection to the remote that forwards that socket to the remote's
`~/.local/state/remote-bridge/bridge.sock`. It owns every forward the bridge needs, so an
interactive session ending or reconnecting never takes them down. It fails fast when a forward
does not bind, notices a dead connection within 45 seconds, and systemd reconnects it.

The tunnel's SSH is the control master for `~/.local/state/remote-bridge/control-HOST`, through
which the bridge adds on-demand port forwards. Before connecting, the tunnel removes a control
socket no master answers, left by an SSH that died; it exits, and systemd retries, when no
master answers within 40 seconds of starting. The bridge records each port it forwards in
`~/.local/state/remote-bridge/forwards`, and the tunnel re-adds them on every connect, so a page
open in the browser keeps working after a reconnect. Ports not requested for a week are dropped.
When a forward fails because no master answers, the bridge restarts the tunnel and retries once.

On the remote, the commands in `shims/` call the bridge:

- `xdg-open`, `wslview`, `tabopen` (`bridge-open`): open a URL, or open a file through
  `remote-bridge-files`, a web server on the remote (port 8766, `REMOTE_BRIDGE_FILE_PORT`) that
  serves its directory. The tunnel always forwards that port, so an open page still reloads after
  a reconnect.
  `localhost` ports in the URL, including an OAuth `redirect_uri`, are forwarded from the
  remote first, so dev servers and `az login` callbacks reach the remote. Only http and https
  URLs are opened. When the bridge is unreachable they print the target instead.
- `xclip`: copies and pastes the desktop clipboard (text, or PNG with `-t image/png -o`).

On the remote, `tmux.conf` sends every tmux copy and every OSC 52 clipboard write from an
application to the desktop clipboard through `bridge-copy`. In an OpenCode pane, Ctrl+V runs
`bridge-paste`, which saves a desktop screenshot as a PNG and pastes its path; OpenCode attaches
pasted image paths, and it reads images only from the clipboard of the host it runs on.

`remote-mcp NAME COMMAND...` runs an MCP server for OpenCode. In WSL it runs the command; on a
remote host the bridge runs the desktop's command registered under `NAME` in
`~/.config/remote-bridge/mcp.conf` (`name command...` per line) and relays its stdio.

zshrc puts `shims/` first on `PATH` and points `BROWSER` at it, and tmux sources `tmux.conf`, on
hosts that are not WSL and have the `~/.local/state/remote-bridge` directory.

## Setup

In WSL:

```sh
ln -sfn ~/.dotfiles/links/bin/remote-bridge.d/remote-bridge.service ~/.config/systemd/user/
ln -sfn ~/.dotfiles/links/bin/remote-bridge.d/remote-bridge-tunnel.service ~/.config/systemd/user/
systemctl --user daemon-reload
systemctl --user enable --now remote-bridge.service remote-bridge-tunnel.service
```

`REMOTE_BRIDGE_HOST` in both units names the remote's SSH host. The tunnel runs SSH with
`BatchMode`, so that host must log in without prompting. Its SSH config must not add
`RemoteForward` lines for these sockets; the tunnel creates them. Check it with
`systemctl --user status remote-bridge-tunnel` and `journalctl --user -u remote-bridge-tunnel`.

On the remote, opt in, run the file server, and let a new connection replace a stale socket:

```sh
install -d -m 700 ~/.local/state/remote-bridge
ln -sfn ~/.dotfiles/links/bin/remote-bridge.d/remote-bridge-files.service ~/.config/systemd/user/
systemctl --user daemon-reload
systemctl --user enable --now remote-bridge-files.service
echo 'StreamLocalBindUnlink yes' | sudo tee /etc/ssh/sshd_config.d/remote-bridge.conf
sudo sshd -t && sudo systemctl reload ssh
```
