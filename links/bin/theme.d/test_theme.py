"""Regression tests for external settings preservation and mode round-trips."""
import json
import os
from pathlib import Path
import tempfile
import subprocess
import sys
import unittest
from unittest.mock import patch

import theme
sys.path.insert(0, str(theme.LINKS.parent / "src/theme"))
import install
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

    def test_terminal_setup_and_toggle_preserve_unrelated_settings(self):
        terminal = Path(self.temp.name) / "settings.json"
        original = '{/* unchanged comment */"profiles":{"defaults":{"font":{"size":12}},"list":[{"source":"Microsoft.WSL","colorScheme":"Storm","font":{"size":11}},{"name":"PowerShell","colorScheme":"Campbell"}]},"schemes":[],"actions":[{"keys":"alt+t","command":"paste"}]}'
        terminal.write_text(original)
        with patch.dict(os.environ, {"DOTFILES_WT_SETTINGS": str(terminal)}):
            install.windows()
            install.windows()
            installed = Document(terminal.read_text()).value
            self.assertEqual(len(installed["schemes"]), 1)
            self.assertEqual(installed["profiles"]["list"][1]["colorScheme"], "Campbell")
            self.assertEqual(installed["profiles"]["list"][0]["font"], {"size": 11})
            self.assertEqual((self.state / "windows-terminal.before.json").read_text(), original)
            theme.refresh(theme.ADAPTERS["Windows Terminal"], "light")
            theme.refresh(theme.ADAPTERS["Windows Terminal"], "dark")
            self.assertEqual(Document(terminal.read_text()).value, installed)
            self.assertIn("/* unchanged comment */", terminal.read_text())

    def test_app_palettes_dark_light_dark_roundtrip(self):
        theme.select("dark")
        before = {p.relative_to(self.state): p.read_bytes() for p in self.state.rglob("*") if p.is_file()}
        theme.select("light")
        self.assertIn('active_bg="#e1e2e7"', (self.state / "tmux.conf").read_text())
        self.assertIn("tokyonight_day", (self.state / "delta.gitconfig").read_text())
        self.assertIn("= false", (self.state / "delta.gitconfig").read_text())
        self.assertEqual((self.state / "kitty.conf").read_text(), (theme.LINKS / "kitty/themes/light.conf").read_text())
        theme.select("dark")
        after = {p.relative_to(self.state): p.read_bytes() for p in self.state.rglob("*") if p.is_file()}
        self.assertEqual(before, after)

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


if __name__ == "__main__":
    unittest.main()
