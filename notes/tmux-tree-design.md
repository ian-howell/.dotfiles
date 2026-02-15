# tmux session tree design

ASCII sketch (root + children, no grandchildren):
```
dotfiles (root)
|- opencode (child)
|- nvim     (child)
`- k9s      (child)
```

## goals
- fast navigation across roots and children
- clear parent-child relationship via naming convention
- each child session represents a responsibility and runs a single program across all windows
- root sessions remain a plain shell (zsh)

## non-goals
- nested trees beyond a single child layer
- running multiple programs within a single child session

## terminology
- listPicker: a tmux popup list; scroll with j/k, select with Enter
- root: top-level session
- root directory: the filesystem directory associated with a root session
- child: leaf session under a root; all windows run the same program
- implementation language: bash scripts in `links/bin`

## naming convention

root session name
- `<root-name>`
- example: `dotfiles`

child session name
- `<root-name> 🌿 <child-name>`
- example: `dotfiles 🌿 opencode`

This encodes the parent-child relationship and makes it easy to derive the root from a child name
(split on ` 🌿 `).

## behavior rules
1. root session
   - runs only the default shell (zsh)
   - is the anchor of a tree
   - is associated with a root directory
2. child session
   - represents a single responsibility (e.g., opencode, nvim, k9s)
   - all windows in that session run the same program
   - child names are fixed to program names (no aliases)
3. tree height
   - only root and direct children, no nested children
4. last-used child
   - each root tracks the last selected child session
   - when user switches to a root, land in its last-used child (if any), otherwise the root itself
   - any command that switches sessions updates last-used child to the previous child for that root

## keybinds (given)
All keybinds are invoked as `<prefix> <key>`.

- `s` listPicker of all roots. selecting a root switches to its last-used child (or root if none)
- `o` create/switch to child `opencode` under current root
- `v` create/switch to child `nvim` under current root
- `k` create/switch to child `k9s` under current root
- `z` switch to the root session for the current tree
- `l` switch to last-used child for current root
- `c` create a new window in current child running its designated program (zsh for root)
- `S` create a new root (directory-first)

## listPicker contents

Root list
- display: `dotfiles`, `work`, `infra` (optionally show directory path)
- action: switch to last-used child of selected root

Child list
- display: `opencode`, `nvim`, `k9s`
- action: switch to selected child under current root

## state tracking

Minimal metadata needed per root:
- `root:<name>` -> `last_used_child = <child>` (string or empty)
- `root:<name>` -> `root_directory = <path>`

Storage options (implementation detail, not required yet):
- tmux options (`@tree_last_child_<root>`)
- tmux options (`@tree_root_dir_<root>`)
- file in `~/.cache` (later)

## root creation flow
1. prompt for directory using `tmux-root-create-fzf` (lists under `$HOME`)
2. create or switch to `root` session (root shell)

## git worktree sessions
- use `<prefix> W` to prompt for a branch, create a repo-local `.worktrees/<branch>` worktree, and
  open a new tmux session that starts in that worktree
- implemented by `git-worktree-create`, `git-worktree-session-name`, and
  `git-worktree-sessionizer`; use these scripts as a reference for future session tooling
- `git-worktree-create-fzf` selects local and remote branches with preview and opens a session
