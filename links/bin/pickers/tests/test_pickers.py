#!/usr/bin/env python3
"""Behavioral regression coverage using isolated Git, tmux and command fixtures."""
import importlib.util
import json
import os
from pathlib import Path
import pty
import shutil
import subprocess
import time
import tempfile
import unittest

BUNDLE = Path(__file__).resolve().parents[1]
BIN = BUNDLE.parent
REAL_TMUX = shutil.which("tmux")
spec = importlib.util.spec_from_file_location("discovery", BUNDLE / "lib/discovery.py")
discovery = importlib.util.module_from_spec(spec)
spec.loader.exec_module(discovery)


class PickerTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory(prefix="pickers-test-", dir="/tmp/opencode")
        self.root = Path(self.temp.name)
        self.home = self.root / "home"
        self.home.mkdir()
        self.commands = self.root / "bin"
        self.commands.mkdir()
        self.socket = self.root / "tmux.sock"
        self.log = self.root / "commands.jsonl"
        self.env = dict(os.environ, HOME=str(self.home), PATH=f"{self.commands}:{BIN}:{os.environ['PATH']}",
                        TEST_SOCKET=str(self.socket), TEST_LOG=str(self.log), REAL_TMUX=REAL_TMUX,
                        PICKER_POPUP="1", PICKER_SOURCE_PANE="", PICKER_SOURCE_SESSION="",
                        FZF_DEFAULT_OPTS="", FZF_DEFAULT_OPTS_FILE="/dev/null")
        self.env.pop("TMUX", None)
        self.env.pop("TMUX_PANE", None)
        self.script("tmux", '''#!/usr/bin/env python3
import json, os, subprocess, sys
with open(os.environ['TEST_LOG'], 'a') as f: f.write(json.dumps(sys.argv[1:]) + '\\n')
if sys.argv[1] in ('attach-session', 'switch-client'): sys.exit(0)
sys.exit(subprocess.call([os.environ['REAL_TMUX'], '-S', os.environ['TEST_SOCKET'], '-f', '/dev/null', *sys.argv[1:]]))
''')
        self.script("fzf", '''#!/usr/bin/env python3
import json, os, sys
rows = sys.stdin.read().splitlines()
with open(os.environ['TEST_LOG'], 'a') as f: f.write(json.dumps(['fzf', *sys.argv[1:]]) + '\\n')
status = int(os.environ.get('TEST_FZF_STATUS', '0'))
if status: sys.exit(status)
if rows: print(next((row for row in rows if os.environ.get('TEST_SELECT', '') in row), rows[0]))
''')
        self.tmux("new-session", "-d", "-s", "keeper", "-c", str(self.home), "sleep", "120")

    def tearDown(self):
        subprocess.run([REAL_TMUX, "-S", str(self.socket), "kill-server"], capture_output=True)
        self.temp.cleanup()

    def script(self, name, contents):
        path = self.commands / name
        path.write_text(contents)
        path.chmod(0o755)

    def run_cmd(self, args, cwd=None, check=True, env=None):
        result = subprocess.run([str(arg) for arg in args], cwd=cwd or self.root,
                                env=env or self.env, capture_output=True, text=True)
        if check:
            self.assertEqual(result.returncode, 0, result.stderr + result.stdout)
        return result

    def tmux(self, *args):
        return self.run_cmd([REAL_TMUX, "-S", self.socket, "-f", "/dev/null", *args]).stdout.strip()

    def calls(self):
        return [json.loads(line) for line in self.log.read_text().splitlines()]

    def git_repo(self):
        repo = self.root / "project with spaces"
        self.run_cmd(["git", "init", "-b", "main", repo])
        self.run_cmd(["git", "-C", repo, "config", "user.name", "Picker Tests"])
        self.run_cmd(["git", "-C", repo, "config", "user.email", "picker-tests@example.invalid"])
        (repo / "tracked").write_text("base\n")
        self.run_cmd(["git", "-C", repo, "add", "tracked"])
        self.run_cmd(["git", "-C", repo, "commit", "-m", "fixture"])
        return repo

    def test_entrypoints_resolve(self):
        for name in ("rp", "ts", "wt", "tp", "ssh-session", "tmux-switch",
                     "k8s-context-switcher", "k8s-namespace-switcher"):
            self.assertTrue((BIN / name).is_symlink())
            self.assertEqual((BIN / name).resolve(), BUNDLE / name)
            self.assertTrue(os.access(BIN / name, os.X_OK))

    def test_colliding_names_and_paths_have_distinct_identities(self):
        for name, leaf in (("foo.bar", "a"), ("foo_bar", "b"), ("foo.bar", "c")):
            path = self.root / leaf
            path.mkdir()
            self.run_cmd([BIN / "tmux-switch", name, "--dir", path, "--identity", f"repo:{path}"])
        before = self.tmux("list-sessions", "-F", "#{session_id}\t#{@picker_identity}")
        self.assertEqual(len(before.splitlines()), 4)
        self.assertIn(f"repo:{self.root / 'b'}", before)
        self.run_cmd([BUNDLE / "tmux-switch", "foo.bar", "--dir", self.root / "a",
                      "--identity", f"repo:{self.root / 'a'}"])
        self.assertEqual(self.tmux("list-sessions", "-F", "#{session_id}\t#{@picker_identity}"), before)

    def test_legacy_directory_session_is_adopted(self):
        self.tmux("new-session", "-d", "-s", "legacy_name", "-c", str(self.home), "sleep", "120")
        self.run_cmd([BIN / "tmux-switch", "legacy.name", "--dir", self.home,
                      "--identity", f"repo:{self.home}"])
        self.assertEqual(self.tmux("display-message", "-p", "-t", "=legacy_name:", "#{@picker_identity}"),
                         f"repo:{self.home}")

    def test_missing_directory_fails_without_creating_session(self):
        result = self.run_cmd([BIN / "tmux-switch", "missing", "--dir", self.root / "missing"], check=False)
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("directory does not exist", result.stderr)
        result = self.run_cmd([BIN / "tmux-switch", "missing", "--dir"], check=False)
        self.assertIn("requires a value", result.stderr)

    def test_ts_uses_ids_for_names_with_spaces_and_has_no_preview(self):
        self.tmux("new-session", "-d", "-s", "my project", "sleep", "120")
        self.env["TEST_SELECT"] = "my project"
        self.run_cmd([BIN / "ts"])
        calls = self.calls()
        selection = self.tmux("display-message", "-p", "-t", "=my project:", "#{session_id}")
        self.assertIn(["attach-session", "-t", selection], calls)
        options = next(call for call in calls if call[0] == "fzf")
        self.assertIn("--no-preview", options)
        self.assertIn("--no-info", options)
        self.assertIn("--no-separator", options)
        self.assertFalse(any(call[0] == "capture-pane" for call in calls))
        self.assertIn("--delimiter=\t", options)

    def test_cancel_and_error_have_different_exit_status(self):
        for status in (1, 130, 2):
            self.env["TEST_FZF_STATUS"] = str(status)
            result = self.run_cmd([BIN / "ts"], check=False)
            self.assertEqual(result.returncode, 0 if status in (1, 130) else 2)
        self.assertFalse(any(call[0] in ("attach-session", "switch-client") for call in self.calls()))

    def test_ssh_recursive_includes_relative_paths_and_patterns(self):
        ssh = self.home / ".ssh"
        ssh.mkdir()
        (ssh / "config").write_text('Include a.conf "with spaces.conf"\n  hOsT=base !excluded *.invalid\n')
        (ssh / "a.conf").write_text('Include nested/*.conf\nHost\talpha\n')
        (ssh / "with spaces.conf").write_text('Host second\n')
        (ssh / "nested").mkdir()
        (ssh / "nested/b.conf").write_text('Include config\nHost nested alias\n')
        self.assertEqual(discovery.ssh_hosts([(ssh / "config", ssh)]), ["alias", "alpha", "base", "nested", "second"])

    def test_repository_discovery_prunes_metadata_and_supports_git_files(self):
        root = self.root / "source"
        root.mkdir()
        for leaf in ("same/a", "other/a", "file-repo", "hidden.worktrees/nope", ".worktrees/nope"):
            path = root / leaf
            path.mkdir(parents=True)
            (path / ".git").write_text("gitdir: elsewhere")
        (root / ".git").mkdir()
        (root / ".git/objects").mkdir()
        config = self.root / "roots.conf"
        config.write_text(f"{root}\n{root}\n")
        old = os.environ.pop("RP_SRC_ROOTS", None)
        try:
            rows = discovery.repos(config)
        finally:
            if old is not None:
                os.environ["RP_SRC_ROOTS"] = old
        self.assertEqual(len(rows), 4)
        self.assertIn(f"source\t{root}\tsource", rows)
        self.assertIn(f"a\t{root}/same/a\ta  — same", rows)
        self.assertIn(f"a\t{root}/other/a\ta  — other", rows)

    def test_worktree_dirty_and_unmerged_deletion_preserves_files(self):
        repo = self.git_repo()
        worktree = self.root / "feature worktree"
        self.run_cmd(["git", "-C", repo, "worktree", "add", "-b", "feature", worktree])
        (worktree / "tracked").write_text("dirty\n")
        result = self.run_cmd([BIN / "wt", "-d", "feature"], cwd=repo, check=False)
        self.assertNotEqual(result.returncode, 0)
        self.assertTrue(worktree.exists())
        self.run_cmd(["git", "-C", worktree, "commit", "-am", "unmerged"])
        result = self.run_cmd([BIN / "wt", "-d", "feature"], cwd=worktree, check=False)
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("not merged", result.stderr)
        self.assertTrue(worktree.exists())

    def test_clean_merged_worktree_deletion_and_detached_selection(self):
        repo = self.git_repo()
        worktree = self.root / "feature worktree"
        self.run_cmd(["git", "-C", repo, "worktree", "add", "-b", "feature", worktree])
        self.run_cmd([BIN / "wt", "-d", "feature"], cwd=repo)
        self.assertFalse(worktree.exists())
        self.run_cmd(["git", "-C", repo, "worktree", "add", "--detach", worktree])
        self.run_cmd([BIN / "wt"], cwd=repo)
        self.assertIn(f"worktree:{worktree}", self.tmux("list-sessions", "-F", "#{@picker_identity}"))

    def test_worktree_cancel_is_success(self):
        repo = self.git_repo()
        self.run_cmd(["git", "-C", repo, "worktree", "add", "-b", "feature", self.root / "feature"])
        self.env["TEST_FZF_STATUS"] = "130"
        self.run_cmd([BIN / "wt"], cwd=repo)

    def test_tp_moves_original_window_with_explicit_source(self):
        self.tmux("new-session", "-d", "-s", "destination", "sleep", "120")
        pane = self.tmux("display-message", "-p", "-t", "=keeper:", "#{pane_id}")
        window = self.tmux("display-message", "-p", "-t", pane, "#{window_id}")
        self.env["PICKER_SOURCE_PANE"] = pane
        self.run_cmd([BIN / "tp", "destination"])
        self.assertIn(window, self.tmux("list-windows", "-t", "=destination", "-F", "#{window_id}"))

    def test_namespace_reload_keeps_context_and_record_format(self):
        self.script("kubectl", '''#!/usr/bin/env python3
import json, os, sys
args = sys.argv[1:]
with open(os.environ['TEST_LOG'], 'a') as f: f.write(json.dumps(['kubectl', *args]) + '\\n')
if args == ['config', 'current-context']: print('original')
elif 'view' in args: print('default')
elif 'namespaces' in args: print('default\\nproduction')
''')
        self.env["TEST_SELECT"] = "production"
        self.run_cmd([BIN / "k8s-namespace-switcher"])
        self.assertIn(["kubectl", "config", "set-context", "original", "--namespace=production"], self.calls())
        options = next(call for call in self.calls() if call[0] == "fzf")
        reload = next(arg for arg in options if arg.startswith("--bind=ctrl-r:"))
        self.assertIn("--context=original", reload)
        self.assertFalse(any(arg.startswith("--preview=") for arg in options))

    def test_insert_window_reorders_and_preserves_option(self):
        self.tmux("set-option", "-t", "keeper:", "base-index", "1")
        self.tmux("move-window", "-r", "-t", "keeper:")
        first = self.tmux("display-message", "-p", "-t", "keeper:", "#{window_id}")
        second = self.tmux("new-window", "-P", "-F", "#{window_id}", "-t", "keeper:", "sleep", "120")
        third = self.tmux("new-window", "-P", "-F", "#{window_id}", "-t", "keeper:", "sleep", "120")
        for setting in ("off", "on"):
            self.tmux("set-option", "-t", "keeper:", "renumber-windows", setting)
            self.tmux("select-window", "-t", third)
            self.run_cmd([BIN / "tmux-insert-window", "1"])
            self.assertEqual(self.tmux("list-windows", "-t", "keeper", "-F", "#{window_id}").splitlines(),
                             [third, first, second])
            self.run_cmd([BIN / "tmux-insert-window", "3"])
            self.assertEqual(self.tmux("list-windows", "-t", "keeper", "-F", "#{window_id}").splitlines(),
                             [first, second, third])
            self.assertEqual(self.tmux("show-options", "-v", "-t", "keeper:", "renumber-windows"), setting)
        before = self.tmux("list-windows", "-t", "keeper", "-F", "#{window_id}")
        result = self.run_cmd([BIN / "tmux-insert-window", "99"], check=False)
        self.assertNotEqual(result.returncode, 0)
        self.assertEqual(self.tmux("list-windows", "-t", "keeper", "-F", "#{window_id}"), before)

    def test_real_fzf_full_width_list_on_wide_and_narrow_terminals(self):
        real_fzf = shutil.which("fzf")
        self.script("fzf", f'#!/bin/sh\nexec "{real_fzf}" "$@"\n')
        for width in (90, 50):
            name = f"repo⋅ianhowell/long-branch-name-{width}"
            command = ["env", f"PATH={self.env['PATH']}", f"TEST_LOG={self.log}",
                       f"TEST_SOCKET={self.socket}", f"REAL_TMUX={REAL_TMUX}",
                       "PICKER_POPUP=1", "PICKER_SOURCE_PANE=", "PICKER_SOURCE_SESSION=",
                       "FZF_DEFAULT_OPTS=--preview='echo UNWANTED_PREVIEW'", "FZF_DEFAULT_OPTS_FILE=/dev/null", str(BIN / "ts")]
            pane = self.tmux("new-session", "-d", "-P", "-F", "#{pane_id}", "-s", name,
                             "-x", str(width), "-y", "9", *command)
            deadline = time.monotonic() + 5
            screen = ""
            while time.monotonic() < deadline:
                screen = self.tmux("capture-pane", "-p", "-t", pane)
                if "Ctrl-X: delete session" in screen and name in screen:
                    break
                time.sleep(0.05)
            self.assertIn(name, screen)
            self.assertIn("Ctrl-X: delete session", screen)
            self.assertIn("keeper", screen)
            self.assertNotIn("session>", screen)
            self.assertIn("j/k: move", screen)
            self.assertNotRegex(screen, r"\b\d+/\d+\b", screen)
            self.assertNotIn("UNWANTED_PREVIEW", screen)
            self.assertNotIn("│", screen)
            self.assertNotIn("──", screen)
            self.assertNotIn(str(self.root), screen)
            self.tmux("kill-session", "-t", f"={name}")

    def test_real_fzf_selector_filter_keys_and_escape(self):
        real_fzf = shutil.which("fzf")
        self.script("fzf", f'#!/bin/sh\nexec "{real_fzf}" "$@"\n')
        fixture = self.root / "selector"
        fixture.write_text(f'''#!/bin/bash
source "{BUNDLE}/lib/picker.sh"
picker_choose --prompt='filter> ' --no-sort --query="$1" <<<'alpha
beta
jk/target' >"{self.root}/selected"
printf 'DONE\\n'
sleep 30
''')
        fixture.chmod(0o755)

        def start(query=""):
            return self.tmux("new-window", "-P", "-F", "#{pane_id}", "-t", "keeper:",
                             "env", f"PATH={self.env['PATH']}", "PICKER_POPUP=1",
                             "FZF_DEFAULT_OPTS=", "FZF_DEFAULT_OPTS_FILE=/dev/null", str(fixture), query)

        def wait(pane, text, absent=None):
            deadline = time.monotonic() + 3
            while time.monotonic() < deadline:
                screen = self.tmux("capture-pane", "-p", "-t", pane)
                if text in screen and (absent is None or absent not in screen):
                    return screen
                time.sleep(0.03)
            self.fail(f"Expected {text!r}, absent {absent!r}:\n{screen}")

        pane = start()
        wait(pane, "j/k: move", "filter>")
        self.tmux("send-keys", "-t", pane, "j", "j", "k", "Enter")
        wait(pane, "DONE")
        self.assertEqual((self.root / "selected").read_text(), "beta\n")

        pane = start()
        wait(pane, "j/k: move")
        self.tmux("send-keys", "-t", pane, "/")
        wait(pane, "filter>")
        self.tmux("send-keys", "-t", pane, "-l", "jk/")
        wait(pane, "filter> jk/", "alpha")
        self.tmux("send-keys", "-t", pane, "Enter")
        wait(pane, "DONE")
        self.assertEqual((self.root / "selected").read_text(), "jk/target\n")

        pane = start("jk/")
        wait(pane, "filter> jk/", "alpha")
        self.tmux("send-keys", "-t", pane, "Escape")
        wait(pane, "alpha", "filter>")
        self.tmux("send-keys", "-t", pane, "/")
        wait(pane, "filter>")
        self.tmux("send-keys", "-t", pane, "Escape")
        wait(pane, "j/k: move", "filter>")
        self.tmux("send-keys", "-t", pane, "Escape")
        wait(pane, "DONE")
        self.assertEqual((self.root / "selected").read_text(), "")

    def test_tmux_bindings_parse(self):
        self.tmux("source-file", "-n", str(BIN.parent / "tmux/config/keybindings.conf"))

    def test_worktree_binding_runs_in_source_pane_directory(self):
        repo = self.git_repo()
        worktree = self.root / "feature"
        self.run_cmd(["git", "-C", repo, "worktree", "add", "-b", "feature", worktree])
        pane = self.tmux("new-window", "-P", "-F", "#{pane_id}", "-c", str(repo), "sleep", "120")
        output = self.root / "binding-result"
        probe = self.root / "binding-probe"
        probe.write_text(f'#!/bin/bash\n"{BIN}/wt" -l >"{output}" 2>&1\n')
        probe.chmod(0o755)
        self.tmux("run-shell", "-t", pane, "cd -- #{q:pane_current_path} && " + str(probe))
        self.assertIn(str(worktree), output.read_text())

    def test_popup_preserves_source_context_and_fits_small_terminal(self):
        probe = self.root / "popup-probe"
        output = self.root / "popup.json"
        probe.write_text('#!/usr/bin/env python3\nimport json, os\n'
                         'result = dict(os.environ, size=list(os.get_terminal_size()))\n'
                         f'open({str(output)!r}, "w").write(json.dumps(result))\n')
        probe.chmod(0o755)
        master, slave = pty.openpty()
        client = subprocess.Popen([REAL_TMUX, "-S", str(self.socket), "attach-session", "-t", "keeper"],
                                  stdin=slave, stdout=slave, stderr=slave, env=dict(self.env, TERM="xterm-256color"))
        try:
            deadline = time.monotonic() + 3
            while time.monotonic() < deadline:
                if self.tmux("list-clients", "-F", "#{client_tty}"):
                    break
                time.sleep(0.05)
            source_pane = self.tmux("display-message", "-p", "-t", "keeper:", "#{pane_id}")
            source_session = self.tmux("display-message", "-p", "-t", "keeper:", "#{session_id}")
            env = dict(self.env, TMUX=f"{self.socket},0,0", PICKER_POPUP="",
                       PICKER_SOURCE_PANE=source_pane, PICKER_SOURCE_SESSION=source_session)
            self.run_cmd(["bash", "-c", f'source "{BUNDLE}/lib/picker.sh"; picker_popup "$1"', probe,
                          "one\ntwo"], env=env)
            environment = json.loads(output.read_text())
            self.assertEqual(environment["PICKER_SOURCE_PANE"], source_pane)
            self.assertEqual(environment["PICKER_SOURCE_SESSION"], source_session)
            self.assertTrue(environment.get("TMUX"))
            self.assertEqual(environment["size"][1], 7)  # nine rows minus popup border
            self.run_cmd(["bash", "-c", f'source "{BUNDLE}/lib/picker.sh"; picker_popup "$1"', probe,
                          "\n".join(str(n) for n in range(100))], env=env)
            environment = json.loads(output.read_text())
            self.assertEqual(environment["size"][1], 18)  # capped at twenty rows
        finally:
            client.terminate()
            client.wait(timeout=3)
            os.close(master)
            os.close(slave)

    def test_repository_picker_disambiguates_duplicate_basenames(self):
        source = self.home / "src"
        for relative in ("team-a/api", "team-b/api"):
            self.run_cmd(["git", "init", "-b", "main", source / relative])
        self.env["TEST_SELECT"] = "team-a"
        self.run_cmd([BIN / "rp"])
        self.env["TEST_SELECT"] = "team-b"
        self.run_cmd([BUNDLE / "rp"])
        identities = self.tmux("list-sessions", "-F", "#{@picker_identity}")
        self.assertIn(f"repo:{source}/team-a/api", identities)
        self.assertIn(f"repo:{source}/team-b/api", identities)

    def test_ssh_alias_is_an_argument_not_a_shell_command(self):
        ssh = self.home / ".ssh"
        ssh.mkdir()
        (ssh / "config").write_text("Host host;literal\n")
        self.script("ssh", '''#!/usr/bin/env python3
import json, os, sys, time
with open(os.environ['TEST_LOG'], 'a') as f: f.write(json.dumps(['ssh', *sys.argv[1:]]) + '\\n')
time.sleep(30)
''')
        self.env["TEST_SELECT"] = "host;literal"
        self.run_cmd([BIN / "ssh-session"])
        deadline = time.monotonic() + 2
        while time.monotonic() < deadline:
            if ["ssh", "--", "host;literal"] in self.calls():
                break
            time.sleep(0.02)
        self.assertIn(["ssh", "--", "host;literal"], self.calls())


if __name__ == "__main__":
    unittest.main()
