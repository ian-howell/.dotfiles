"""Reload the invoking tmux server's selected palette and common styles."""
from pathlib import Path
import shutil
import subprocess


def refresh(mode, state):
    if not shutil.which("tmux"):
        return
    if subprocess.run(["tmux", "list-sessions"], capture_output=True, timeout=5).returncode:
        return
    config = Path(__file__).resolve().parents[1] / "config/theme.conf"
    subprocess.run(["tmux", "source-file", str(config)], check=True, capture_output=True, text=True, timeout=15)
