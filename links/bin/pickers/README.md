# Pickers

Public commands in `../` are relative symlinks into this directory. Only that
parent directory belongs on PATH. Entry points resolve their real location so
direct invocation and invocation through `~/.bin` work identically.

## Interface

- One full-width list, with no previews, counters, or separator lines.
- tmux popups size to the initial number of entries, up to 90 columns × 20 rows,
  and shrink to fit smaller terminals. Reloaded lists scroll within that size.
- Outside tmux, fzf uses at most 20 rows, shrinking for short lists.
- Rows show names and current/active markers. Repository names gain a short,
  unique parent suffix only when needed to distinguish duplicates.
- Pickers start in selector mode: `j`/`k` move down/up and `/` opens the filter.
  In filter mode, `j`, `k`, and `/` type normally. Escape clears the filter and
  returns to selector mode; another Escape closes the picker.
- Nonempty query arguments (for example, `rp something`) start in filter mode.
- Arrow keys move and Enter selects in either mode. Real errors remain errors.
- A small footer shows mode controls and any picker-specific actions.
- `ts`: `Ctrl-X` kills the selected session, targeting its stable tmux ID.
- `wt`: `Ctrl-X` removes a clean, merged worktree and its branch. Explicit
  `wt -d --force <branch>` permits discarding local changes and unmerged commits.
- Namespace selection pins the original Kubernetes context throughout the operation.

## Internals

`lib/picker.sh` owns presentation and popup context. `lib/sessions.sh` owns
session lookup. Discovery keeps action IDs and paths separate from display labels.

`tmux-switch` stores `@picker_identity` session metadata. Repository and worktree
identities use canonical paths; SSH identities use aliases. Friendly names stay
short unless a collision requires a stable hash suffix. Legacy directory sessions
are reused only when both name and canonical directory agree. Legacy SSH sessions
without identity metadata cannot be safely disambiguated after tmux's lossy name
normalization; the first selection creates a separately identified session.

`rp` reads `config/repo-roots.conf` and colon-separated `RP_SRC_ROOTS`. Config
comments occupy whole lines; `#` is otherwise a literal path character. Discovery
checks the root itself and up to four directory levels beneath it, skips Git
metadata and `.worktrees`/`*.worktrees` trees, and recognizes `.git` files too.

SSH discovery enumerates concrete aliases through recursive includes, with glob
expansion, cycle protection, case-insensitive keywords, and SSH-relative paths.
Includes in conditional blocks are enumerated as candidate aliases. SSH configuration
is never evaluated as shell source; browsing the list does not run SSH.

Picker records use tabs/newlines as separators; discovery rejects paths containing
those characters rather than selecting a different path. Spaces and shell
metacharacters are passed as arguments, not interpolated as commands.

Dependencies: Bash, Python 3, fzf (tested with 0.66), tmux (tested with 3.5a),
and the selected tool's backend (Git, SSH, or kubectl).

## Verification

```sh
python3 links/bin/pickers/tests/test_pickers.py -v
shellcheck links/bin/pickers/{rp,ts,ssh-session,wt,tp,tmux-switch,k8s-context-switcher,k8s-namespace-switcher} links/bin/pickers/lib/*.sh links/bin/tmux-insert-window
```

Tests use temporary fixtures and a separate tmux socket; they never operate on
the user's sessions, repositories, SSH configuration, or Kubernetes contexts.
