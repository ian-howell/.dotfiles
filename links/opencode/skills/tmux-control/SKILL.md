---
name: tmux-control
description: "Use when driving Ian's tmux panes from an agent harness or he asks to tp."
---

# Driving Ian's tmux session

Ian runs an agent harness inside tmux next to Neovim and other panes. You can run `tmux` commands
directly. For changing the tmux config itself, use `tmux-config`.

## Procedure
1. Resolve your own pane from `$TMUX_PANE` and list panes fresh each time
   (`tmux list-panes -a -F '#{pane_id} #{session_name}:#{window_index} left=#{pane_left} w=#{pane_width} #{pane_current_command} active=#{pane_active}'`).
   Pane IDs change whenever the harness restarts, so never reuse an ID from earlier in the
   conversation.
2. Make the layout change.
3. Restore sizes and focus, then verify with `list-panes` again.

## Recipes

### Neovim panes
- Neovim at code: write the open commands to a vim script and run
  `tmux split-window -h -d -l 50% -t <your pane> -c <repo> "nvim -S <script>"` — the
  script holds `edit +<line> <abs file>`, `normal zt`, `vsplit +<line> <file2>`, `tabedit ...`,
  `tabfirst`. Inline `-c 'normal zt'` chains nested inside the tmux command's quotes break and
  nvim fails on launch; `remain-on-exit failed-key` keeps a failed pane open with its error until a
  key is pressed. Check the pane exists with
  `list-panes` afterwards. Open every relevant location at once (vsplit/tabs) rather than one file.
  Default side is right (`-h` without `-b`) unless Ian says left. "N stacked panes" of code means
  one nvim pane with N horizontal windows (`split +<line> <file>` per extra location, then
  `wincmd =`, `wincmd t`), not N tmux panes; verify with `:echo winnr("$")`.
- Add files to an already-open Neovim pane instead of spawning another:
  `tmux send-keys -t <nvim pane> Escape ":tabedit +<line> <abs file> | normal zt" Enter ":vsplit +<line> <abs file2> | normal zt" Enter`,
  then `select-pane` back. Use absolute paths — the nvim cwd is the repo it was opened in, not e.g.
  a worktree being compared. When the follow-up compares code across branches, open the other
  branch's worktree files (`git worktree list`) in a new tab next to the existing ones.
- After editing any file that is open in one of Ian's Neovim panes, reload it yourself so he doesn't
  have to type `:e`: find the nvim pane with `list-panes`, then
  `tmux send-keys -t <nvim pane> Escape ':checktime' Enter`. `:checktime` reloads every unmodified
  buffer whose file changed and keeps his cursor and the focused pane; never steal focus to do it.
- Point Ian at a spot in an open Neovim pane:
  `tmux send-keys -t <nvim pane> Escape ':<line>' Enter zz` (grep the file for the line first;
  earlier line numbers go stale after his edits). Focus stays in his pane.

### Reviewing and touring code
- "Open vim in an N% split" right after editing a worktree means review those edits:
  `tmux split-window -h -d -l N% -t $TMUX_PANE -c <worktree> "nvim -c CodeDiff"`. CodeDiff
  takes a few seconds to render, so an immediate `capture-pane` shows an empty buffer; wait ~3s and
  recapture before concluding it failed.

### Windows, sessions and worktrees
- Move a pane from another window into your window:
  `tmux join-pane -h -b -l 80% -s <pane> -t <your pane>`, then `select-pane -t <your pane>`.
- "tp there" / "tp to the worktree" means move your window into the worktree's session with Ian's
  `tp` tool: from the repo run `wt <branch> </dev/null` (creates or finds the worktree and its
  session `<repo>⋅󰘬⋅<branch>`), then `TMUX_PANE=$TMUX_PANE tp '<session>'` (read `$TMUX_PANE` in
  that same command; a pane ID from an earlier `tp` goes stale after the window moves and `tp` then
  moves someone else's pane), which moves the whole window and switches the client. Confirm with
  `tmux display-message -p -t <your pane> '#{session_name}'`. It does not mean `cd`, and don't
  answer with a cd command.

## Rules

### Targeting panes and focus
- Always target `$TMUX_PANE` for splits. Plain `tmux list-panes` (no `-a`/`-t`) lists the window Ian
  is currently looking at, which may be another window's agent, so a pane built from it can land in
  the wrong window. Pane sizes are percentages of the target window, so a wrong target also gets the
  wrong size.
- Never steal focus. Any command that moves or swaps panes must end with
  `tmux select-pane -t <pane Ian was in>`; `swap-pane` moves the active pane along with it unless
  you restore focus.
- `swap-pane` swaps contents but keeps each slot's size, so swapping a narrow agent pane with a wide
  editor shrinks the editor. Record the widths first, then
  `resize-pane -t <editor> -x <its old width>` after the swap.
- Identify agent panes by `pane_current_command` and pane title
  (`tmux list-panes -a -F '#{pane_current_command} #{pane_title}'`).

### Messages
- tmux status messages are short: keep `display-message` text compact and human-readable (program
  name, not raw pane IDs like `%22`), or it gets truncated into nonsense.
