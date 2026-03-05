---
description: Switch to a git worktree tmux session
---

Switch the current tmux client to a session for the git worktree branch "$ARGUMENTS".

If $ARGUMENTS is empty, follow these steps and stop — do not do anything else:
1. Run `git worktree list` — count the output lines. If the count is <= 1, report "No additional worktrees found." and stop.
2. Otherwise run: `tmux display-popup -E "git worktree list | awk 'NR>1 {print \$3}' | tr -d '[]' | fzf --prompt='worktree> ' | read branch && tmux new-session -d -s \"\$branch\" -c \"\$(git worktree list --porcelain | awk -v b=\"refs/heads/\$branch\" '/^worktree/{wt=\$2} /^branch/{if(\$2==b)print wt}')\" 2>/dev/null; tmux switch-client -t \"\$branch\""`

Otherwise, run: `wt "$ARGUMENTS"`
