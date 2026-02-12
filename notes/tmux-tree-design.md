# tmux session tree design

ASCII sketch (root + children, no grandchildren):
```
dotfiles (root)
|- opencode (child)
|- vim      (child)
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
- implementation language: Go

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
   - represents a single responsibility (e.g., opencode, neovim, k9s)
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
- `v` create/switch to child `neovim` under current root
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
- display: `opencode`, `neovim`, `k9s`
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
1. prompt for directory using listPicker sourced from `fd` or `find` piped to `fzf` (or `gum`)
   - search roots start at `$HOME` and `/tmp`
2. derive root name from directory basename, with option to edit
3. create `root` session and store `root_directory`
4. switch to new root (root shell)
