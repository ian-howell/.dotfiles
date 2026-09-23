"""Apply the static Day scheme and select Terminal's theme across WSL."""
import json
import os
from pathlib import Path
import runpy
import tempfile

Document = runpy.run_path(str(Path(__file__).with_name("jsonc.py")))["Document"]


def discover():
    explicit = os.environ.get("DOTFILES_WT_SETTINGS")
    if explicit:
        return Path(explicit)
    if not (os.environ.get("WSL_DISTRO_NAME") or os.environ.get("WSL_INTEROP")
            or "microsoft" in os.uname().release.lower()):
        return None
    users = Path("/mnt/c/Users")
    candidates = list(users.glob("*/AppData/Local/Packages/Microsoft.WindowsTerminal*/LocalState/settings.json"))
    candidates += list(users.glob("*/AppData/Local/Microsoft/Windows Terminal/settings.json"))
    if len(candidates) != 1:
        raise ValueError("Set DOTFILES_WT_SETTINGS to the intended Windows Terminal settings.json path in WSL")
    return candidates[0]


def refresh(mode, state):
    path = discover()
    if path is None:
        return
    original = path.read_text(encoding="utf-8-sig")
    doc = Document(original)
    scheme = json.loads(Path(__file__).with_name("light.json").read_text())
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
        raise ValueError(f"No WSL profiles found in {path}")
    doc.set(("theme",), mode)
    if doc.text == original:
        return
    backup = state / "windows-terminal.before.json"
    backup.parent.mkdir(parents=True, exist_ok=True)
    if not backup.exists():
        backup.write_text(original)
    fd, temporary = tempfile.mkstemp(prefix=".theme-", dir=path.parent)
    try:
        with os.fdopen(fd, "w") as stream:
            stream.write(doc.text)
        if path.read_text(encoding="utf-8-sig") != original:
            raise RuntimeError("settings changed concurrently; retry")
        os.replace(temporary, path)
    finally:
        if os.path.exists(temporary):
            os.unlink(temporary)
