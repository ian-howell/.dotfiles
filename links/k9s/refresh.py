"""Select a checked-in skin and notify K9s's skins-directory watcher."""
import os
from pathlib import Path


def refresh(mode, state):
    config = Path(os.environ.get("XDG_CONFIG_HOME", Path.home() / ".config"))
    skin = config / "k9s/skins/dotfiles.yaml"
    skins = Path(__file__).resolve().parent / "skins"
    target = skins / ("tokyonight-day.yaml" if mode == "light" else "tokyonight-moon.yaml")
    if skin.exists() and not skin.is_symlink():
        raise ValueError(f"Refusing to replace existing {skin}")
    managed = (state / "k9s/skins/dotfiles.yaml", skins / "tokyonight-day.yaml", skins / "tokyonight-moon.yaml")
    if skin.is_symlink() and skin.readlink() not in managed:
        raise ValueError(f"Refusing to replace unrelated symlink {skin}")
    skin.parent.mkdir(parents=True, exist_ok=True)
    temporary = skin.with_name(f".dotfiles-{os.getpid()}.yaml")
    try:
        temporary.symlink_to(target)
        os.replace(temporary, skin)
    finally:
        temporary.unlink(missing_ok=True)
