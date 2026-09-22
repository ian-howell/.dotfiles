"""Switch Terminal's application theme without rewriting unrelated settings."""
import os
from pathlib import Path
import runpy
import tempfile

Document = runpy.run_path(str(Path(__file__).with_name("jsonc.py")))["Document"]


def refresh(mode, state):
    setting = state / "windows-terminal-path"
    if not setting.exists():
        return
    path = Path(setting.read_text().strip())
    original = path.read_text(encoding="utf-8-sig")
    doc = Document(original)
    doc.set(("theme",), mode)
    if doc.text == original:
        return
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
