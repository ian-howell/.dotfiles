# remote-bridge

Lets a remote Linux host reached from WSL open things in the desktop browser and use the
desktop clipboard, the way `wslview` and `powershell.exe` do inside WSL.

`remote-bridge` runs in WSL as a systemd user service and listens on
`~/.local/state/remote-bridge/server.sock`. SSH forwards that socket to the remote's
`~/.local/state/remote-bridge/bridge.sock`. On the remote, the commands in `shims/` call it:

- `xdg-open`, `wslview`, `tabopen` (`bridge-open`): open a URL, or open a file through a local web server
  (port 8766, `REMOTE_BRIDGE_FILE_PORT`) that serves its directory.
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
systemctl --user enable --now remote-bridge.service
```

`REMOTE_BRIDGE_HOST` in the unit names the SSH host whose control master carries the port
forwards. That host's SSH config needs one shared connection and the socket forward:

```sshconfig
ControlMaster auto
ControlPath ~/.ssh/control-%C
ControlPersist 10m
RemoteForward /home/ian/.local/state/remote-bridge/bridge.sock /home/ian/.local/state/remote-bridge/server.sock
RemoteForward /home/ian/.local/state/remote-bridge/mcp.sock /home/ian/.local/state/remote-bridge/mcp-server.sock
```

On the remote, opt in and let a new connection replace a stale socket:

```sh
install -d -m 700 ~/.local/state/remote-bridge
echo 'StreamLocalBindUnlink yes' | sudo tee /etc/ssh/sshd_config.d/remote-bridge.conf
sudo sshd -t && sudo systemctl reload ssh
```
