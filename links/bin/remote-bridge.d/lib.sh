# Sourced by the shims: talks to the desktop's remote-bridge through the forwarded socket.
socket=${XDG_STATE_HOME:-$HOME/.local/state}/remote-bridge/bridge.sock

bridge() {
	curl -fsS --max-time 20 --unix-socket "$socket" "$@"
}
