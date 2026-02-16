AGENTS.md is a living document that is heavily under construction. This is the most important
guidance here: aggressively seek improvements to this document and make suggestions as you work
through tasks. This includes suggesting structural changes to the document itself.

The files in the "links" directory are symlinked to files according to the content of the
"linkdotfiles.yaml" file in the root of this repository.

The primary Neovim configuration lives in the "links/nvim" directory. A legacy Neovim configuration
lives in the "links/lazyvim" directory. The user is fond of the legacy configuration, and it should
be used as inspiration for the newer setup.

OpenCode workflow: use `treemux` for root/child tmux session trees. Worktrees default to
`${WORKTREES_BASE:-<repo>/.worktrees}` when using `treemux attach-root -w <branch>`.

Tmux integration: use `treemux-worktree-picker` (bound to `<prefix> f g`) to pick a branch and
attach a treemux worktree root.

When adding scripts to `links/bin`, ensure they are executable (e.g., `chmod +x`).
