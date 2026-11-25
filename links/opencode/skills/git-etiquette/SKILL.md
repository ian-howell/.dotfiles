---
name: git-etiquette
description: Use for Git workflows involving branches, worktrees, staging, commits, rebases, pushes, or pull requests on any hosting platform. Enforces the user's authorization boundaries, branch naming, commit style, draft-first review process, and protection of unrelated changes.
---

# Git Etiquette

Follow these rules whenever a task touches local git state or a hosted pull request. Ian's
explicit instructions override them.

## Before you start

- Read the repository's agent instructions.
- Inspect `git status`, the current branch, remotes, and worktrees. If HEAD is detached, report
  it and run `git reflog` before committing; switch back to the branch only when Ian asks, since
  another tool may have checked out the commit.
- Identify the base: the branch the task names, the preceding branch for stacked work, and
  otherwise the default branch. Do not assume `main`. "The base" below means this branch.
- Read recent history and copy the commit and PR conventions of comparable commits, preferring
  Ian Howell's recent ones.
- For a GitHub repository, check `gh repo view --json visibility`. A public repository gets no
  work project, org or lab names and no work-derived content, including in skills, examples,
  comments and commit messages.

## Authorization

Git authorization is outcome-based: Ian need not say "commit" to ask for an outcome that requires
one, and a request authorizes only that outcome and the smallest chain of prerequisites it needs.

| Ian asks to | Authorized operations |
| --- | --- |
| Implement, fix, or change code | Edit and verify. No commit or push. |
| Commit | Stage the task's changes and commit them. No push. |
| Push | Commit if needed, rebase onto the base, and push. |
| Create or open a PR | Create a branch and worktree if needed, commit, rebase onto the base, push, and create a draft PR. |
| Publish a PR | Mark the PR ready for review. |
| Merge or complete a PR | Merge that PR. Branch, worktree and issue cleanup need their own request. |

Finishing edits never implies a commit: after "lgtm", "good" or "yes, make the changes", ask one
short question ("Commit and push?") rather than explaining that you only commit on request.

These always need an explicit request from Ian:

- Dropping commits or resetting a branch
- Amending a commit
- Force-pushing. When rebasing a published branch would require one, ask before rebasing.
- Deleting branches or worktrees
- Activating, abandoning, completing or merging a PR
- Destructive commands such as `git reset --hard` or `git clean`, only for the exact outcome Ian
  requested and after inspecting the state they affect

## Branches and worktrees

Every branch you create starts with `ianhowell/`; add the prefix when a proposed name lacks it.
Use an existing branch Ian names as-is, and never rename other people's branches.

Do each new PR-sized task in its own worktree, unless Ian asks for the current checkout or the
session is already in the task's worktree. Worktrees live in a sibling `<repo>.worktrees`
directory, never inside the repository or under `/tmp/opencode`, with the full branch path
beneath it:

```text
Repository: /path/to/project
Branch:     ianhowell/improve-startup
Worktree:   /path/to/project.worktrees/ianhowell/improve-startup
```

Before creating one, check `git worktree list --porcelain` for an existing worktree or a branch
checked out elsewhere. Create the parent directory if needed, but do not alter ignore files. Branch
from the freshly fetched base without disturbing a dirty main checkout.

Once a task has a worktree, every file for it goes there, including docs Ian asks for "at the repo
root" (the worktree's root). When a planning doc may turn into code work, create the worktree
before writing the first file; the main checkout stays clean. If something already landed in the
main checkout, `mv` it into the worktree and confirm both `git status` outputs.

## Staging and committing

Dirty files may belong to Ian or another agent. Never revert, overwrite, stash, clean, or commit
changes that are not this task's; if they conflict directly with the task, stop and ask.

- Stage explicit files or hunks belonging to this task. Never use `git add .`, `git add -A`, or a
  similar command when unrelated changes may exist.
- Never stash to isolate a commit (`git stash --keep-index`) or append a stash "just in case" to a
  commit command: a stash hides the remaining edits from Ian and from the next commit. For two
  commits from one dirty tree, stage and commit the first set, then the second. If a stash was
  made by mistake, run `git stash show --stat`, then `git stash pop` that exact entry before
  anything else. The one sanctioned stash is the `--autostash` in
  [Push rejected with unrelated dirty files](#push-rejected-with-unrelated-dirty-files).
- Inspect `git diff --staged` and `git diff` immediately before committing. Before each commit,
  push and PR, confirm that the full diff against the base contains only the intended change.

Every commit needs a concise, imperative subject and a body explaining what changed and why the
change is correct, useful, or safe. Describe the resulting difference from the base, not the
branch's development history, failed attempts, or review.

Split logically separate changes into separate commits when that materially helps review, and
keep any commit sequence Ian requests for stacked work.

When Ian asks to fold follow-up edits into the previous commit, stage only those paths, run
`git commit --amend -F -`, and rewrite the message to describe the combined result, not the
original subset. When commit hooks fail, fix the problem and commit normally; never skip hooks.

## Rebasing and pushing

Before the final push, fetch, inspect the incoming changes, and rebase onto the base. Resolve
conflicts without discarding intentional branch changes or unrelated work, then re-run the
relevant verification. If the push is rejected while unrelated files are dirty, follow
[Push rejected with unrelated dirty files](#push-rejected-with-unrelated-dirty-files).

## Pull requests

Create PRs as drafts unless Ian says to publish from the start. A draft is for Ian's personal
review; finished implementation is not approval to hand it to the team.

Before creating a PR, confirm the source and target branches, review every commit it includes,
and run the relevant tests or report what could not be run.

The description must include a paragraph that begins exactly with `This PR`. It may be one
sentence and need not come first:

```text
This PR preserves full session titles in the window picker.
```

The rest explains the branch's diff, rationale, and verification without overstating results.
Describe validation the reviewer can't see, such as local runs or a test environment, but leave
out the PR's own CI results ("the PR build passed"), which the PR page already shows. Never leave
the description empty; when tooling derives it from the commit message, update it unless it
already has the `This PR` paragraph.

Add reviewers only when Ian asks or the repository's instructions require specific ones.

Before stating a PR's state (draft, votes, checks), re-read it from the host: Ian publishes and
changes PRs himself, so state remembered from creation is often stale.

## Report

After an authorized git or PR workflow, report what applies:

- Worktree path and branch
- Commit hash and subject
- Push result
- PR URL, target branch, and draft status
- Linked issue and its state
- Tests or checks run
- Dirty or unrelated files left untouched

Check the result of each commit, push, link, state transition, and verification before reporting
it as done.

## Procedures

### Removing a worktree

Uncommitted and untracked work in a worktree has no git copy; removal destroys it.

1. For each candidate, report `git status -sb` and commits not on any remote
   (`git log --oneline <upstream>..<branch>`). Diff its untracked and modified paths against the
   worktree being kept (`diff -rq`, excluding `bin/`).
2. Before deleting work Ian calls disposable, grep the kept worktree for anything that depends on
   it, such as a tool that runs a test package, Makefile targets, or env vars it reads. Kept files
   often reference dropped files by path or name. Report each dependency and get a decision before
   removing anything.
3. When pulling selected files over, port them as one change and finish the port, including
   renames, before removal.
4. Run `wt -d --force <branch>` from the repository, then confirm with `git worktree list`. It
   also deletes the local branch, so the branch's commits must be on a remote first. It also
   closes the worktree's tmux session, so stop and ask when that is the session your pane is in
   (`tmux display -p -t "$TMUX_PANE" '#S'`).

### Clearing gitignored files

Preview with `git clean -ndX`, then report each path's size and whether it can be rebuilt (for
example by a Makefile target). Flag binaries whose source is not in the repository
(`git log --all -- cmd/<name>`) as possibly unrecoverable, and offer `git clean -fdX` or a version
that keeps them. Tracked junk, such as a stray `*.log`, needs a commit to remove, so list it
separately.

### Push rejected with unrelated dirty files

1. Run `git fetch`, then compare `git diff --name-only HEAD origin/<base>` with the dirty paths.
2. Run `git pull --rebase --autostash`.
3. If the paths overlap, the autostash pop conflicts and leaves the stash plus `UU` files. Run
   `git reset` (it only unstages, keeping the edits), tell Ian which file conflicted, and merge it
   only when he asks.
4. When merging his local edits with upstream, keep both sides' rules, drop local notes that
   upstream now contradicts, and list what was kept and dropped. Drop the stash only after
   confirming no conflict markers remain.
