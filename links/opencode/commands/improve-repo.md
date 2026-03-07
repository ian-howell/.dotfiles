---
description: Find and implement a 1% improvement in this repo, committed on a new branch
---

# 1% Improvement

You are a thoughtful engineer who believes in compounding small improvements. Your job is to find
and implement one tiny, concrete improvement to this repository — inspired by James Clear's concept
of 1% gains.

## Step 1 — Locate the repo root

Run:
```bash
git rev-parse --show-toplevel
```
Store the result as `REPO_ROOT`. All subsequent paths are relative to this.

## Step 2 — Bootstrap `.ideas`

Run the following to ensure `.ideas` exists and is locally excluded from git:

```bash
# Create if missing
touch "$REPO_ROOT/.ideas"

# Add to local git exclude if not already present
exclude="$REPO_ROOT/.git/info/exclude"
grep -qxF '.ideas' "$exclude" || echo '.ideas' >> "$exclude"
```

Read `$REPO_ROOT/.ideas` carefully. Your idea must be meaningfully distinct from every entry
already in the list.

## Step 3 — Survey the repo

Read the repository to understand its structure, tech stack, and patterns:
- The top-level directory listing
- `AGENTS.md` (if present)
- `linkdotfiles.yaml` (if present)
- A representative sample of files across subdirectories (configs, scripts, Neovim Lua, shell
  files, etc.)

Your goal is to find **one small, concrete, creative improvement**. Think broadly:
- Adding missing inline comments or documentation
- Fixing an inconsistency in naming or structure
- Adding a helpful alias or utility script
- Improving an error message or user-facing string
- Adding a missing edge-case guard in a shell script
- Improving Neovim plugin configuration clarity
- Normalizing formatting or conventions across similar files

The improvement must be:
- **Small** — implementable in a single focused commit (aim for <100 lines changed)
- **Concrete** — tied to something you actually read in the repo
- **Distinct** — not already in `.ideas` (even conceptually similar ones should be avoided)
- **Creative** — don't default to the obvious; look for the delightful tiny thing

## Step 4 — Append your idea to `.ideas`

Append your idea to `$REPO_ROOT/.ideas` in this format:
```
- <short-slug>: <one sentence describing the improvement>
```

Example:
```
- zsh-alias-comments: Add inline comments to each alias in zshrc explaining its purpose
```

Do this **before** creating the worktree. `.ideas` is gitignored and must never be committed.

## Step 5 — Derive a branch slug and create a worktree

From the short slug you chose above, construct:
- `BRANCH=ianhowell/<short-slug>`
- `WORKTREE_PATH=${WORKTREES_BASE:-$REPO_ROOT/.worktrees}/ianhowell/<short-slug>`

Then create the worktree:
```bash
mkdir -p "$(dirname "$WORKTREE_PATH")"
git -C "$REPO_ROOT" worktree add -b "$BRANCH" "$WORKTREE_PATH"
```

If the branch already exists, choose a more specific slug to avoid collision.

## Step 6 — Implement the improvement

Work inside `$WORKTREE_PATH`. Make your changes there. The worktree is a full checkout of the
repo — edit files as you normally would.

Keep the change small and purposeful. Do not refactor unrelated things. Do not add TODOs. Finish
what you start.

## Step 7 — Commit the improvement

Stage and commit only the improvement — do **not** stage `.ideas`:

```bash
git -C "$WORKTREE_PATH" add -A
git -C "$WORKTREE_PATH" commit -m "<short-slug>: <concise description of what was done and why>"
```

Do **not** push. Stop after the commit succeeds and report:
- The branch name
- The worktree path
- A brief summary of what was changed and why
