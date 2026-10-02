#!/usr/bin/env bash
# Serve a directory on 127.0.0.1 in the background and print the URL.
# Responses carry Cache-Control: no-store, so a normal browser refresh always loads edited files.
# Usage: serve.sh <root-dir> [port]   (default port 8765)
#        serve.sh --stop [port]       stop a server started by this script
set -euo pipefail
pidfile() { echo "/tmp/interactive-demo-serve-$1.pid"; }
if [[ "${1:-}" == "--stop" ]]; then
  port="${2:-8765}"
  if [[ -f "$(pidfile "$port")" ]]; then kill "$(cat "$(pidfile "$port")")" 2>/dev/null || true; rm -f "$(pidfile "$port")"; fi
  exit 0
fi
root="${1:?usage: serve.sh <root-dir> [port]}"
port="${2:-8765}"
# Free = nothing listening (a connect is refused). Lingering TIME_WAIT sockets don't count.
if ! python3 -c 'import socket,sys; socket.create_connection(("127.0.0.1", int(sys.argv[1])), timeout=1)' "$port" 2>/dev/null; then
  python3 - "$port" "$root" "$(pidfile "$port")" <<'EOF'
import subprocess, sys
port, root, pidfile = sys.argv[1:]
code = r'''
import functools, http.server, sys
class NoStore(http.server.SimpleHTTPRequestHandler):
    def end_headers(self):
        self.send_header("Cache-Control", "no-store")
        super().end_headers()
    def log_message(self, *a):
        pass
handler = functools.partial(NoStore, directory=sys.argv[2])
http.server.ThreadingHTTPServer(("127.0.0.1", int(sys.argv[1])), handler).serve_forever()
'''
p = subprocess.Popen([sys.executable, "-c", code, port, root], stdin=subprocess.DEVNULL,
                     stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, start_new_session=True)
open(pidfile, "w").write(str(p.pid))
EOF
  sleep 0.5
else
  echo "port $port is already in use; if it is a plain http.server, stop it so no-store headers apply" >&2
fi
echo "http://localhost:$port/"
