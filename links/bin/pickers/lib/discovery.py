"""Discover candidates with concise labels and separate action fields.

Picker records are tab/newline delimited. Paths containing these characters
are rejected explicitly rather than misparsed into actions on another path.
"""
import glob
import os
from pathlib import Path
import re
import shlex
import subprocess
import sys


def record(*fields):
    if any(any(char in field for char in "\t\r\n") for field in fields):
        raise ValueError(f"unsupported tab/newline in picker record: {fields!r}")
    return "\t".join(fields)


def repos(config):
    candidates = []
    for line in Path(config).read_text().splitlines():
        line = line.strip()
        if line and not line.startswith("#"):
            candidates.append(line)
    candidates.extend(filter(None, os.environ.get("RP_SRC_ROOTS", "").split(":")))
    roots = {Path(os.path.expanduser(p.replace("$HOME", str(Path.home())))).resolve()
             for p in candidates}
    roots = sorted(p for p in roots if p.is_dir())
    if not roots:
        raise ValueError(f"no existing source roots (checked {config} and RP_SRC_ROOTS)")
    found = set()
    for root in roots:
        for directory, children, files in os.walk(root, onerror=lambda error: print(error, file=sys.stderr)):
            path = Path(directory)
            # Worktrees are available through wt. .git files also represent
            # submodules and separate-git-dir checkouts, so do not ignore them.
            children[:] = sorted(c for c in children
                                 if c != ".git" and c != ".worktrees" and not c.endswith(".worktrees"))
            if (path / ".git").exists():
                found.add(path.resolve())
            # Preserve a bounded scan without walking inside Git object stores.
            if len(path.relative_to(root).parts) >= 4:
                children.clear()
    rows = []
    for path in sorted(found, key=lambda p: (p.name, str(p))):
        peers = [other for other in found if other.name == path.name and other != path]
        label = path.name
        if peers:
            # Use the shortest unique parent suffix, rather than repeating an
            # absolute path on every row. Preserve enough context to distinguish
            # same-name repositories even when their immediate parents match.
            parts = path.parent.parts
            depth = 1
            while any(other.parent.parts[-depth:] == parts[-depth:] for other in peers):
                depth += 1
            label += "  — " + str(Path(*parts[-depth:]))
        rows.append(record(path.name, str(path), label))
    return rows


def ssh_hosts(configs=None):
    hosts, visited = set(), set()

    def visit(path, base):
        path = Path(path).resolve()
        if path in visited or not path.is_file():
            return
        visited.add(path)
        for number, line in enumerate(path.read_text().splitlines(), 1):
            match = re.match(r"^\s*(\w+)(?:\s*=\s*|\s+)(.*)$", line)
            if not match:
                continue
            keyword, value = match.groups()
            if keyword.lower() not in ("host", "include"):
                continue
            try:
                arguments = shlex.split(value, comments=True)
            except ValueError as error:
                raise ValueError(f"{path}:{number}: {error}") from error
            if keyword.lower() == "host":
                hosts.update(host for host in arguments
                             if not host.startswith(("!", "-")) and not any(c in host for c in "*?[]"))
            else:
                for pattern in arguments:
                    pattern = os.path.expanduser(pattern)
                    if not os.path.isabs(pattern):
                        pattern = str(base / pattern)
                    for included in sorted(glob.glob(pattern)):
                        visit(included, base)

    if configs is None:
        configs = [(Path.home() / ".ssh/config", Path.home() / ".ssh"),
                   (Path("/etc/ssh/ssh_config"), Path("/etc/ssh"))]
    for config, base in configs:
        visit(config, base)
    return [record(host) for host in sorted(hosts)]


def worktrees(root):
    data = subprocess.check_output(["git", "worktree", "list", "--porcelain", "-z"])
    rows, entry = [], {}
    for item in os.fsdecode(data).split("\0"):
        if not item:
            if entry and entry.get("worktree") != root and "bare" not in entry:
                branch = entry.get("branch", "").removeprefix("refs/heads/")
                label = branch or f"detached  — {entry['worktree']}"
                if entry["worktree"] == os.getcwd():
                    label = "● " + label
                else:
                    label = "  " + label
                rows.append(record(entry["worktree"], branch,
                                   "(detached)" if "detached" in entry else "", label))
            entry = {}
        else:
            key, _, value = item.partition(" ")
            entry[key] = value
    return rows


if __name__ == "__main__":
    try:
        if sys.argv[1] == "repos":
            rows = repos(sys.argv[2])
        elif sys.argv[1] == "hosts":
            rows = ssh_hosts()
        elif sys.argv[1] == "worktrees":
            rows = worktrees(sys.argv[2])
        else:
            raise ValueError("unknown discovery command")
        if rows:
            print("\n".join(rows))
    except (OSError, ValueError, subprocess.CalledProcessError) as error:
        sys.exit(f"picker discovery: {error}")
