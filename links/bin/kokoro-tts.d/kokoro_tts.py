#!/usr/bin/env python3
"""Synthesize speech with Kokoro: kokoro-tts <input_text_file> <output_path> [voice] [speed].

The first call starts a background server that keeps the model loaded, so later calls skip the
model load. A call that finds no server synthesizes in-process while the server starts.
"""
import json
import os
import socket
import subprocess
import sys

DATA = os.path.expanduser("~/.local/share/kokoro")
SOCKET = os.path.join(os.environ.get("XDG_RUNTIME_DIR") or DATA, "kokoro-tts.sock")


def load():
    from kokoro_onnx import Kokoro
    return Kokoro(f"{DATA}/kokoro-v1.0.onnx", f"{DATA}/voices-v1.0.bin")


def synthesize(kokoro, req: dict) -> None:
    import soundfile
    with open(req["text_path"], encoding="utf-8") as f:
        text = f.read()
    samples, rate = kokoro.create(text, voice=req["voice"], speed=req["speed"], lang="en-us")
    soundfile.write(req["out_path"], samples, rate)


def serve() -> None:
    kokoro = load()
    if os.path.exists(SOCKET):
        os.unlink(SOCKET)
    server = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
    server.bind(SOCKET)
    server.listen()
    while True:
        conn, _ = server.accept()
        with conn:
            try:
                synthesize(kokoro, json.loads(conn.makefile().readline()))
                conn.sendall(b"ok\n")
            except Exception as e:  # report to the client, keep serving
                conn.sendall(f"error: {e}\n".encode())


def request(req: dict) -> bool:
    """Synthesize via the server; False when no server is listening."""
    try:
        with socket.socket(socket.AF_UNIX, socket.SOCK_STREAM) as conn:
            conn.connect(SOCKET)
            conn.sendall((json.dumps(req) + "\n").encode())
            reply = conn.makefile().readline().strip()
    except (FileNotFoundError, ConnectionRefusedError):
        return False
    if reply != "ok":
        sys.exit(f"kokoro-tts server: {reply}")
    return True


def main() -> None:
    if sys.argv[1:] == ["--serve"]:
        serve()
        return
    req = {
        "text_path": os.path.abspath(sys.argv[1]),
        "out_path": os.path.abspath(sys.argv[2]),
        "voice": sys.argv[3] if len(sys.argv) > 3 and sys.argv[3] else "af_bella",
        "speed": float(sys.argv[4]) if len(sys.argv) > 4 and sys.argv[4] else 1.0,
    }
    if request(req):
        return
    subprocess.Popen([sys.executable, os.path.abspath(__file__), "--serve"],
                     stdin=subprocess.DEVNULL, stdout=subprocess.DEVNULL,
                     stderr=subprocess.DEVNULL, start_new_session=True)
    synthesize(load(), req)


if __name__ == "__main__":
    main()
