"""Read 16 kHz mono s16le audio from stdin until stopped, transcribe it, and
type the text into a tmux pane.

Usage: listen.py PANE STATE_DIR
"""

import os
import subprocess
import sys
import time

import numpy as np

RATE = 16000
CHUNK = RATE // 10  # 100 ms of samples
SILENCE_STOP = 2.0
NO_SPEECH_STOP = 15.0
MAX_SECONDS = 180.0
MODEL = os.environ.get("DICTATE_MODEL", "base")


def say(msg):
    subprocess.run(["tmux", "display-message", "-d", "3000", f"dictate: {msg}"], check=False)


def record(state):
    stop = os.path.join(state, "stop")
    chunks, levels = [], []
    threshold = float(os.environ.get("DICTATE_RMS", 0))
    spoke, quiet = False, 0.0
    while True:
        raw = sys.stdin.buffer.read(CHUNK * 2)
        if not raw:
            break
        chunk = np.frombuffer(raw, dtype=np.int16)
        chunks.append(chunk)
        rms = float(np.sqrt(np.mean(chunk.astype(np.float32) ** 2)))
        levels.append(rms)
        # Calibrate against the first half second, which is usually room noise.
        if not threshold and len(levels) == 5:
            threshold = max(150.0, 3 * float(np.median(levels)))
        if threshold and rms > threshold:
            spoke, quiet = True, 0.0
        else:
            quiet += 0.1
        elapsed = len(chunks) / 10
        if os.path.exists(stop):
            break
        if spoke and quiet >= SILENCE_STOP:
            break
        if not spoke and elapsed >= NO_SPEECH_STOP:
            break
        if elapsed >= MAX_SECONDS:
            break
    sys.stdin.close()
    print(f"{time.strftime('%T')} recorded {len(chunks) / 10:.1f}s threshold={threshold:.0f} "
          f"peak={max(levels, default=0):.0f} spoke={spoke}", flush=True)
    return np.concatenate(chunks) if chunks else np.zeros(0, np.int16)


def transcribe(audio):
    from faster_whisper import WhisperModel

    try:
        model = WhisperModel(MODEL, device="cpu", compute_type="int8", local_files_only=True)
    except Exception:
        model = WhisperModel(MODEL, device="cpu", compute_type="int8")
    segments, _ = model.transcribe(audio.astype(np.float32) / 32768.0, language="en", vad_filter=True)
    return " ".join(s.text.strip() for s in segments).strip()


def main():
    pane, state = sys.argv[1], sys.argv[2]
    try:
        audio = record(state)
        beep = os.path.join(os.path.dirname(os.path.abspath(__file__)), "beep")
        subprocess.Popen([beep, "stop"], stdin=subprocess.DEVNULL, stdout=subprocess.DEVNULL,
                         stderr=subprocess.DEVNULL, start_new_session=True)
    finally:
        for name in ("recording", "stop"):
            try:
                os.remove(os.path.join(state, name))
            except FileNotFoundError:
                pass
    if len(audio) < RATE // 2:
        say("nothing recorded")
        return
    say("transcribing")
    text = transcribe(audio)
    print(f"{time.strftime('%T')} text={text!r}", flush=True)
    if not text:
        say("heard nothing")
        return
    sent = subprocess.run(["tmux", "send-keys", "-t", pane, "-l", text], check=False)
    if sent.returncode != 0:
        say(f"pane {pane} is gone; transcript is in {state}/log")


if __name__ == "__main__":
    main()
