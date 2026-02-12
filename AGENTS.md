AGENTS.md is a living document that is heavily under construction. This is the most important
guidance here: aggressively seek improvements to this document and make suggestions as you work
through tasks. This includes suggesting structural changes to the document itself.

The files in the "links" directory are symlinked to files according to the content of the
"linkdotfiles.yaml" file in the root of this repository.

The primary Neovim configuration lives in the "links/nvim" directory. A legacy Neovim configuration
lives in the "links/lazyvim" directory. The user is fond of the legacy configuration, and it should
be used as inspiration for the newer setup.

OpenCode workflow: use `opencode-worktree <branch> [repo-path]` to create or reuse a git worktree
and print the worktree path. Worktrees default to `${WORKTREES_BASE:-<repo>/.worktrees}`.

Tmux integration: use `opencode-worktree-sessionizer` (bound to `<prefix> W`) to prompt for a task
name and open a new tmux session that `cd`s into the repo worktree.
