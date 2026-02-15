# treemux

Small tmux session helper for root/child session trees.

## Commands

### create-root

Create a root session rooted at a directory.

```
treemux create-root <root-name> <root-dir>
```

Behavior
- normalizes the root dir to an absolute path
- creates the root session if missing
- stores @tree_root_dir and @tree_root_name on the root session
- prints a result message

### create-child

Create a child session under the current root.

```
treemux create-child <child-name> <command>
```

Behavior
- requires running inside tmux
- reads @tree_root_dir and @tree_root_name from the current session
- creates the child session if missing
- stores @tree_root_dir and @tree_root_name on the child session
- prints a result message

## Environment

- TMUX_TREE_SEPARATOR: child separator for session names (default: " 🌿 ")
