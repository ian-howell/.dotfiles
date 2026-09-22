"""Select app-owned palettes and refresh running applications."""
import argparse
import fcntl
import os
from pathlib import Path
import runpy
import subprocess
import sys
import tempfile

LINKS = Path(__file__).resolve().parents[2]
STATE = Path(os.environ.get("DOTFILES_THEME_STATE", Path.home() / ".local/state/dotfiles/theme"))
ADAPTERS = {
    "Windows Terminal": LINKS.parent / "src/theme/windows-terminal/refresh.py",
    "tmux": LINKS / "tmux/themes/refresh.py",
    "Kitty": LINKS / "kitty/themes/refresh.py",
    "K9s": LINKS / "k9s/refresh.py",
}


def write(path, text):
    """Publish a complete file; leave unchanged files alone."""
    path.parent.mkdir(parents=True, exist_ok=True)
    if path.exists() and path.read_text() == text:
        return
    fd, tmp = tempfile.mkstemp(prefix=".theme-", dir=path.parent)
    try:
        with os.fdopen(fd, "w") as stream:
            stream.write(text)
        os.replace(tmp, path)
    finally:
        if os.path.exists(tmp):
            os.unlink(tmp)


def get():
    value = (STATE / "mode").read_text().strip() if (STATE / "mode").exists() else "dark"
    if value not in ("light", "dark"):
        raise ValueError(f"Invalid mode in {STATE / 'mode'}: {value!r}")
    return value


def select(mode):
    variant = "day" if mode == "light" else "moon"
    files = {
        "tmux.conf": f"tmux/themes/{mode}.conf",
        "kitty.conf": f"kitty/themes/{mode}.conf",
        "delta.gitconfig": f"delta/tokyonight_{variant}.gitconfig",
        "bat.conf": f"bat/{mode}.conf",
        "fzf.conf": f"zsh/fzf-themes/{mode}.conf",
        "lazygit.yml": f"lazygit/themes/{mode}.yml",
        "k9s/skins/dotfiles.yaml": f"k9s/skins/tokyonight-{variant}.yaml",
    }
    # Read all assets before publishing anything. No parsing or recoloring.
    contents = {name: (LINKS / source).read_text() for name, source in files.items()}
    for name, text in contents.items():
        write(STATE / name, text)
    write(STATE / "mode", mode + "\n")


def run(args):
    result = subprocess.run(args, text=True, capture_output=True, timeout=15)
    if result.returncode:
        raise RuntimeError(result.stderr.strip() or f"{args[0]} exited {result.returncode}")


def refresh(adapter, mode):
    runpy.run_path(str(adapter))["refresh"](mode, STATE)


def set_mode(mode):
    select(mode)
    failed = False
    for name, adapter in ADAPTERS.items():
        try:
            refresh(adapter, mode)
        except (OSError, ValueError, RuntimeError, subprocess.SubprocessError) as error:
            print(f"theme: {name}: {error}", file=sys.stderr)
            failed = True
    message = f"Theme: {mode}" + (" (some apps failed to refresh)" if failed else "")
    print(message)
    if os.environ.get("TMUX"):
        subprocess.run(["tmux", "display-message", message], capture_output=True, timeout=5)
    return int(failed)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("command", choices=("dark", "light", "get"))
    args = parser.parse_args()
    if args.command == "get":
        print(get())
        return 0
    STATE.mkdir(parents=True, exist_ok=True)
    with (STATE / "lock").open("w") as lock:
        fcntl.flock(lock, fcntl.LOCK_EX)
        return set_mode(args.command)


if __name__ == "__main__":
    try:
        sys.exit(main())
    except (OSError, ValueError, RuntimeError, subprocess.SubprocessError) as error:
        print(f"theme: {error}", file=sys.stderr)
        sys.exit(1)
