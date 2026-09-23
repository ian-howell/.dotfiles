"""Regression tests for external settings preservation and mode round-trips."""
import json
import os
from pathlib import Path
import runpy
import shutil
import tempfile
import subprocess
import sys
import unittest
from unittest.mock import patch

import theme
sys.path.insert(0, str(theme.LINKS.parent / "src/theme/windows-terminal"))
from jsonc import Document


class JsoncTests(unittest.TestCase):
    def test_comments_trailing_commas_and_escaped_strings(self):
        original = '{\n// keep me\n"url": "https://example.test/a//b", "quoted": "a\\\"b",\n"profiles": {"list": [{"colorScheme":"Storm",},],},\n}'
        doc = Document(original)
        doc.set(("profiles", "list", 0, "colorScheme"), {"dark": "Storm", "light": "Day"})
        doc.set(("theme",), "light")
        self.assertIn('// keep me', doc.text)
        self.assertIn('"url": "https://example.test/a//b"', doc.text)
        self.assertEqual(doc.value["quoted"], 'a"b')
        self.assertEqual(Document(doc.text).value["theme"], "light")

    def test_insert_after_comment_without_trailing_comma(self):
        doc = Document('{"a": [1 /* stay */, // also stay\n], "b": 2 // final comment\n}')
        doc.set(("a", 1), 3)
        doc.set(("c",), 4)
        self.assertEqual(doc.value, {"a": [1, 3], "b": 2, "c": 4})
        self.assertIn('// final comment', doc.text)

    def test_duplicate_keys_rejected(self):
        with self.assertRaises(ValueError):
            Document('{"theme":"dark","theme":"light"}')


class ThemeTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.state = Path(self.temp.name) / "state"
        self.patcher = patch.object(theme, "STATE", self.state)
        self.patcher.start()
        self.addCleanup(self.patcher.stop)

    def test_terminal_first_switch_and_toggle_preserve_unrelated_settings(self):
        terminal = Path(self.temp.name) / "settings.json"
        original = '{/* unchanged comment */"profiles":{"defaults":{"font":{"size":12}},"list":[{"source":"Microsoft.WSL","colorScheme":"Storm","font":{"size":11}},{"name":"PowerShell","colorScheme":"Campbell"}]},"schemes":[],"actions":[{"keys":"alt+t","command":"paste"}]}'
        terminal.write_text(original)
        with patch.dict(os.environ, {"DOTFILES_WT_SETTINGS": str(terminal)}):
            theme.refresh(theme.ADAPTERS["Windows Terminal"], "dark")
            theme.refresh(theme.ADAPTERS["Windows Terminal"], "dark")
            installed = Document(terminal.read_text()).value
            self.assertEqual(len(installed["schemes"]), 1)
            self.assertEqual(installed["profiles"]["list"][1]["colorScheme"], "Campbell")
            self.assertEqual(installed["profiles"]["list"][0]["font"], {"size": 11})
            self.assertEqual((self.state / "windows-terminal.before.json").read_text(), original)
            theme.refresh(theme.ADAPTERS["Windows Terminal"], "light")
            theme.refresh(theme.ADAPTERS["Windows Terminal"], "dark")
            self.assertEqual(Document(terminal.read_text()).value, installed)
            self.assertIn("/* unchanged comment */", terminal.read_text())

    def test_terminal_discovery_requires_unambiguous_path_on_wsl(self):
        discover = runpy.run_path(str(theme.ADAPTERS["Windows Terminal"]))["discover"]
        with patch.dict(os.environ, {"WSL_DISTRO_NAME": "Ubuntu", "DOTFILES_WT_SETTINGS": ""}):
            for candidates in ([], [Path("one.json"), Path("two.json")]):
                with self.subTest(candidates=candidates), patch.object(Path, "glob", side_effect=[candidates, []]):
                    with self.assertRaisesRegex(ValueError, "DOTFILES_WT_SETTINGS"):
                        discover()
            with patch.object(Path, "glob", side_effect=[[Path("settings.json")], []]):
                self.assertEqual(discover(), Path("settings.json"))

    def test_app_palettes_dark_light_dark_roundtrip(self):
        theme.select("dark")
        for p in self.state.rglob("*"):
            if p.is_file() and p.name != "mode":
                self.assertTrue(p.is_symlink(), p)
                self.assertTrue(p.resolve().is_relative_to(theme.LINKS))
        before = {p.relative_to(self.state): p.read_bytes() for p in self.state.rglob("*") if p.is_file()}
        theme.select("light")
        self.assertIn("tokyonight_day", (self.state / "delta.gitconfig").read_text())
        self.assertIn("= false", (self.state / "delta.gitconfig").read_text())
        self.assertEqual((self.state / "kitty.conf").read_text(), (theme.LINKS / "kitty/themes/light.conf").read_text())
        theme.select("dark")
        after = {p.relative_to(self.state): p.read_bytes() for p in self.state.rglob("*") if p.is_file()}
        self.assertEqual(before, after)

    def test_k9s_first_switch_links_static_skin(self):
        config = Path(self.temp.name) / "config"
        overlay = Path(self.temp.name) / "work/opencode"
        overlay.mkdir(parents=True)
        tui = overlay / "tui.json"
        original = '{"plugin":["./work-only.mjs"]}\n'
        tui.write_text(original)
        with patch.dict(os.environ, {"XDG_CONFIG_HOME": str(config), "OPENCODE_CONFIG_DIR": str(overlay)}):
            for mode, variant in (("light", "day"), ("dark", "moon")):
                theme.select(mode)
                theme.refresh(theme.ADAPTERS["K9s"], mode)
                self.assertEqual((config / "k9s/skins/dotfiles.yaml").resolve(), theme.LINKS / f"k9s/skins/tokyonight-{variant}.yaml")
        self.assertEqual(tui.read_text(), original)
        self.assertEqual(list(overlay.iterdir()), [tui])
        self.assertTrue((config / "k9s/skins/dotfiles.yaml").is_symlink())

    def test_switch_migrates_generated_copies_without_editing_palettes(self):
        self.state.mkdir()
        (self.state / "kitty.conf").write_text("old generated palette\n")
        palette = theme.LINKS / "kitty/themes/light.conf"
        original = palette.read_bytes()
        theme.select("light")
        self.assertTrue((self.state / "kitty.conf").is_symlink())
        self.assertEqual((self.state / "kitty.conf").resolve(), palette)
        theme.select("dark")
        self.assertEqual(palette.read_bytes(), original)

    def test_integration_failure_does_not_block_others(self):
        with patch.object(theme, "refresh", side_effect=[OSError("unavailable"), None, None, None]) as refresh, patch.dict(os.environ, {"TMUX": ""}):
            self.assertEqual(theme.set_mode("light"), 1)
            self.assertEqual(refresh.call_count, len(theme.ADAPTERS))
            self.assertEqual(theme.get(), "light")

    def test_cli_get_and_rejected_commands_are_read_only(self):
        env = os.environ | {"DOTFILES_THEME_STATE": str(self.state)}
        command = [sys.executable, str(theme.LINKS / "bin/theme.d/theme.py")]
        result = subprocess.run(command + ["get"], env=env, text=True, capture_output=True)
        self.assertEqual(result.returncode, 0)
        self.assertEqual(result.stdout, "dark\n")
        self.assertFalse(self.state.exists())
        for old in ("toggle", "mode", "status", "apply", "env", "tmux", "setup-apps", "setup-windows"):
            with self.subTest(command=old):
                result = subprocess.run(command + [old], env=env, capture_output=True)
                self.assertEqual(result.returncode, 2)
                self.assertFalse(self.state.exists())


class FreshHomeTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory(prefix="theme-home-")
        self.addCleanup(self.temp.cleanup)
        self.home = Path(self.temp.name)
        (self.home / ".dotfiles").symlink_to(theme.LINKS.parent)
        config = self.home / ".config"
        config.mkdir()
        (config / "tmux").symlink_to(theme.LINKS / "tmux")
        self.state = self.home / ".local/state/dotfiles/theme"
        self.env = os.environ | {
            "HOME": str(self.home), "XDG_CONFIG_HOME": str(config),
            "FZF_DEFAULT_OPTS_FILE": "/missing/old-machine/fzf.conf", "FZF_DEFAULT_OPTS": "",
            "BAT_CONFIG_PATH": "/missing/old-machine/bat.conf", "TMUX": "",
        }

    def run_command(self, args, **kwargs):
        result = subprocess.run(args, env=self.env, text=True, capture_output=True, timeout=15, **kwargs)
        self.assertEqual(result.returncode, 0, result.stderr)
        return result.stdout.strip()

    @unittest.skipUnless(shutil.which("zsh") and shutil.which("fzf"), "requires zsh and fzf")
    def test_shell_uses_static_palettes_with_no_or_partial_state(self):
        script = '''source "$HOME/.dotfiles/links/zsh/theme.zsh"
print -r -- "$FZF_DEFAULT_OPTS_FILE"
[[ -r $BAT_CONFIG_PATH ]] || exit 1
[[ -r ${LG_CONFIG_FILE##*,} ]] || exit 1
print -r -- needle | fzf --filter needle
'''
        for mode in (None, "light", "dark", "invalid"):
            with self.subTest(mode=mode):
                if mode is not None:
                    self.state.mkdir(parents=True, exist_ok=True)
                    (self.state / "mode").write_text(mode + "\n")
                selected = "light" if mode == "light" else "dark"
                output = self.run_command(["zsh", "-f", "-c", script])
                self.assertEqual(output, f"{self.home}/.dotfiles/links/zsh/fzf-themes/{selected}.conf\nneedle")
                if mode is None:
                    self.assertFalse(self.state.exists())

    @unittest.skipUnless(shutil.which("zsh"), "requires zsh")
    def test_existing_shell_follows_mode_changes(self):
        script = '''source "$HOME/.dotfiles/links/zsh/theme.zsh"
mkdir -p "$HOME/.local/state/dotfiles/theme"
for mode in light dark; do
    print -r -- "$mode" > "$HOME/.local/state/dotfiles/theme/mode"
    _dotfiles_theme_refresh
    print -r -- "$FZF_DEFAULT_OPTS_FILE"
done
'''
        output = self.run_command(["zsh", "-f", "-c", script])
        self.assertEqual(output.splitlines(), [
            f"{self.home}/.dotfiles/links/zsh/fzf-themes/{mode}.conf" for mode in ("light", "dark")
        ])

    @unittest.skipUnless(shutil.which("tmux") and shutil.which("fzf"), "requires tmux and fzf")
    def test_tmux_pickers_before_and_after_switching(self):
        tmux = ["tmux", "-S", str(self.home / "tmux.sock")]
        self.run_command(tmux + ["-f", "/dev/null", "new-session", "-d", "-s", "test", "sleep 120"])
        self.addCleanup(subprocess.run, tmux + ["kill-server"], env=self.env, capture_output=True)
        for mode in (None, "light", "dark"):
            with self.subTest(mode=mode):
                if mode:
                    with patch.object(theme, "STATE", self.state):
                        theme.select(mode)
                self.run_command(tmux + ["source-file", str(theme.LINKS / "tmux/config/theme.conf")])
                if mode == "light":
                    self.assertIn("bg=#e1e2e7", self.run_command(tmux + ["show-options", "-gv", "window-active-style"]))
                value = self.run_command(tmux + ["show-environment", "-g", "FZF_DEFAULT_OPTS_FILE"]).split("=", 1)[1]
                self.assertEqual(Path(value).resolve(), theme.LINKS / f"zsh/fzf-themes/{mode or 'dark'}.conf")
                self.env["FZF_DEFAULT_OPTS_FILE"] = value
                self.assertEqual(self.run_command(["fzf", "--filter", "needle"], input="needle\n"), "needle")
                if mode is None:
                    self.assertFalse(self.state.exists())


if __name__ == "__main__":
    unittest.main()
