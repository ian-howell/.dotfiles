AGENTS.md is a living document that is heavily under construction. This is the most important
guidance here: aggressively seek improvements to this document and make suggestions as you work
through tasks. This includes suggesting structural changes to the document itself.

The files in the "links" directory are symlinked to files according to the content of the
"linkdotfiles.yaml" file in the root of this repository.

Work-related OpenCode configs (including custom commands/agents) should live under
"~/.config/work/opencode" and be referenced via the OPENCODE_CONFIG_DIR environment variable.
Do not manage those paths via linkdotfiles.yaml.

The primary Neovim configuration lives in the "links/nvim" directory (lazyvim-based). An
experimental configuration lives in "links/experimental-neovim" and is not symlinked. The user is
migrating back to the lazyvim-based setup, incorporating learnings from the experimental config.
Use the `evim` alias to launch the experimental config.

Neovim module loading: use `require("module")` directly for both plugins and local modules. Do not
silence or wrap errors from `require` calls; missing modules should fail loudly.

When adding scripts to `links/bin`, ensure they are executable (e.g., `chmod +x`).

## 1% improvement workflow

Two tools exist for making small, compounding improvements to this repo:

**`/improve-repo`** — OpenCode command at `links/opencode/commands/improve-repo.md`.
Surveys the repo, picks one small creative improvement distinct from prior ideas, implements it
on a new branch (`ianhowell/<slug>`), and commits it. Ideas are logged to `.ideas` in the repo
root — this file is gitignored via `.git/info/exclude` and is never committed.

**`src/improve-repo/`** — Go program that drives the command sequentially N times:
```bash
go run ./src/improve-repo -n 5 -dir /path/to/repo
```
Flags: `-n` (default 5), `-dir` (default `.`), `-command` (default `improve-repo`).
Streams each agent's output live and prints a pass/fail summary at the end. Runs are sequential
to avoid `.ideas` write conflicts. For long runs (>5), launch inside a tmux window:
```bash
tmux new-window "cd ~/.dotfiles && go run ./src/improve-repo -n 15 -dir ."
```
