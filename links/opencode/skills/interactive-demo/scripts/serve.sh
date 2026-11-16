#!/usr/bin/env bash
# Serve a directory on 127.0.0.1 in the background and print the URL.
# Responses carry Cache-Control: no-store, and served HTML gets a live-reload snippet injected
# (in the response only; files on disk are untouched), so an open tab reloads itself on save.
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
import functools, http.server, io, os, sys, urllib.parse
# Live reload for iteration only: HTML is patched in the response, never on disk,
# so the files stay self-contained deliverables.
RELOAD = b"""<script>/* live reload (injected by serve.sh) */(() => {
  let seen = null;
  setInterval(async () => {
    try {
      const r = await fetch('/__mtime?p=' + encodeURIComponent(location.pathname), { cache: 'no-store' });
      const t = await r.text();
      if (seen !== null && t !== seen) location.reload();
      seen = t;
    } catch {}
  }, 700);
})();</script>"""
class NoStore(http.server.SimpleHTTPRequestHandler):
    def end_headers(self):
        self.send_header("Cache-Control", "no-store")
        super().end_headers()
    def log_message(self, *a):
        pass
    def do_GET(self):
        url = urllib.parse.urlparse(self.path)
        if url.path == "/__mtime":
            p = self.translate_path(urllib.parse.parse_qs(url.query).get("p", ["/"])[0])
            if os.path.isdir(p):
                p = os.path.join(p, "index.html")
            body = str(os.stat(p).st_mtime_ns if os.path.exists(p) else 0).encode()
            return self._send(body, "text/plain")
        p = self.translate_path(url.path)
        if os.path.isdir(p) and url.path.endswith("/"):
            p = os.path.join(p, "index.html")
        if p.endswith(".html") and os.path.isfile(p):
            data = open(p, "rb").read()
            i = data.lower().rfind(b"</body>")
            data = data[:i] + RELOAD + data[i:] if i >= 0 else data + RELOAD
            return self._send(data, "text/html; charset=utf-8")
        return super().do_GET()
    def _send(self, body, ctype):
        self.send_response(200)
        self.send_header("Content-Type", ctype)
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)
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
