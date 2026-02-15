# treemux

Small tmux session helper for root/child session trees.

## Commands

### switch-root

Create or switch to a root session rooted at a directory.

```
treemux switch-root <root-name> <root-dir>
```

Behavior
- normalizes the root dir to an absolute path
- creates the root session if missing
- stores @tree_root_dir and @tree_root_name on the root session
- switches to the session (or attaches if not already in tmux)

### switch-child

Create or switch to a child session under the current root.

```
treemux switch-child <child-name> <command>
```

Behavior
- requires running inside tmux
- reads @tree_root_dir and @tree_root_name from the current session
- creates the child session if missing
- stores @tree_root_dir and @tree_root_name on the child session
- switches to the child session

## Environment

- TMUX_TREE_SEPARATOR: child separator for session names (default: " 🌿 ")
