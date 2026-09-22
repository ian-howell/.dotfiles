"""Kitty reloads its configuration on SIGUSR1."""
import os
import shutil
import subprocess


def refresh(mode, state):
    if not shutil.which("kitty"):
        return
    result = subprocess.run(["pkill", "-USR1", "-u", str(os.getuid()), "-x", "kitty"], capture_output=True, timeout=5)
    if result.returncode not in (0, 1):
        raise RuntimeError(result.stderr.decode().strip())
