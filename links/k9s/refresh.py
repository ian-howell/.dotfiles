"""Notify K9s's skins-directory watcher after publishing its selected skin."""
import os
from pathlib import Path


def refresh(mode, state):
    config = Path(os.environ.get("XDG_CONFIG_HOME", Path.home() / ".config"))
    skin = config / "k9s/skins/dotfiles.yaml"
    target = state / "k9s/skins/dotfiles.yaml"
    if not skin.is_symlink() or skin.resolve() != target:
        return
    temporary = skin.with_name(f".dotfiles-{os.getpid()}.yaml")
    try:
        temporary.symlink_to(target)
        os.replace(temporary, skin)
    finally:
        temporary.unlink(missing_ok=True)
