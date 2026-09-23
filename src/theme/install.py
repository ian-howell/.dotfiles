"""One-time theme integration, called after dotfiles are linked."""
import argparse
import fcntl
import json
import os
from pathlib import Path
import shutil
import sys

HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE.parents[1] / "links/bin/theme.d"))
sys.path.insert(0, str(HERE / "windows-terminal"))
import theme
from jsonc import Document


def apps():
    theme.select(theme.get())
    config = Path(os.environ.get("XDG_CONFIG_HOME", Path.home() / ".config"))
    skin = config / "k9s/skins/dotfiles.yaml"
    target = theme.STATE / "k9s/skins/dotfiles.yaml"
    skin.parent.mkdir(parents=True, exist_ok=True)
    if skin.is_symlink() and skin.resolve() == target:
        pass
    elif skin.exists() or skin.is_symlink():
        raise ValueError(f"Refusing to replace existing {skin}")
    else:
        skin.symlink_to(target)

    # OpenCode's plugin and palettes are managed directly by links/opencode.
    if shutil.which("bat"):
        theme.run(["bat", "cache", "--build"])


def windows():
    saved = theme.STATE / "windows-terminal-path"
    explicit = os.environ.get("DOTFILES_WT_SETTINGS")
    if explicit:
        path = Path(explicit)
    elif saved.exists():
        path = Path(saved.read_text().strip())
    else:
        candidates = list(Path("/mnt/c/Users").glob("*/AppData/Local/Packages/Microsoft.WindowsTerminal*/LocalState/settings.json"))
        if len(candidates) != 1:
            raise ValueError("Set DOTFILES_WT_SETTINGS to the intended Windows Terminal settings.json")
        path = candidates[0]
    original = path.read_text(encoding="utf-8-sig")
    doc = Document(original)
    backup = theme.STATE / "windows-terminal.before.json"
    if not backup.exists():
        theme.write(backup, original)
    scheme = json.loads((HERE / "windows-terminal/light.json").read_text())
    if "schemes" not in doc.value:
        doc.set(("schemes",), [])
    schemes = doc.value["schemes"]
    index = next((i for i, s in enumerate(schemes) if s.get("name") == scheme["name"]), len(schemes))
    doc.set(("schemes", index), scheme)
    profiles = doc.value["profiles"]
    default = profiles.get("defaults", {}).get("colorScheme", "Campbell")
    count = 0
    for i, profile in enumerate(profiles["list"]):
        if profile.get("source") not in ("Windows.Terminal.Wsl", "Microsoft.WSL"):
            continue
        current = profile.get("colorScheme", default)
        dark = current.get("dark", "Campbell") if isinstance(current, dict) else current
        doc.set(("profiles", "list", i, "colorScheme"), {"dark": dark, "light": scheme["name"]})
        count += 1
    if not count:
        raise ValueError("No WSL profiles found")
    doc.set(("theme",), theme.get())
    if path.read_text(encoding="utf-8-sig") != original:
        raise RuntimeError("Windows Terminal settings changed during setup; retry")
    theme.write(path, doc.text)
    theme.write(saved, str(path) + "\n")
    print(f"Windows Terminal: {count} WSL profiles; backup: {backup}")


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--windows", action="store_true", help="also configure Windows Terminal")
    args = parser.parse_args()
    theme.STATE.mkdir(parents=True, exist_ok=True)
    with (theme.STATE / "lock").open("w") as lock:
        fcntl.flock(lock, fcntl.LOCK_EX)
        apps()
        if args.windows:
            windows()
    print("Theme integration installed. Restart OpenCode to load its plugin.")


if __name__ == "__main__":
    main()
