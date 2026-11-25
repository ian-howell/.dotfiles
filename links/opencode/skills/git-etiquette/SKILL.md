---
name: git-etiquette
description: Use for Git workflows involving branches, worktrees, staging, commits, rebases, pushes, or pull requests on any hosting platform. Enforces the user's authorization boundaries, branch naming, commit style, draft-first review process, and protection of unrelated changes.
---

# Git Etiquette

Follow these rules whenever a task involves local git state or a hosted pull
request. Explicit instructions from the user override defaults in this skill,
but authorization for one outcome only implies the prerequisites needed to
produce that outcome.

## Inspect before acting

Before changing git state:

- Read the repository's agent instructions.
- Inspect `git status`, the current branch, remotes, and worktrees. If HEAD is
  detached, report it and run `git reflog` before committing; switch back to the
  branch (`git switch <branch>`) only when the user asks, since another tool may
  have checked out the commit.
- Identify the intended base branch. Do not assume it is `main` when the task
  names another base or is part of a stack.
- Inspect the relevant diff and recent commit history.
- Derive commit and PR conventions from comparable repository history. Prefer
  recent commits authored by Ian Howell when available.

Before committing, pushing, or creating a PR, inspect the complete diff against
the intended base and confirm that it contains only the intended change.

## Authorization

Git authorization is outcome-based; the user does not need to use the literal
word `commit` when requesting an outcome that requires one.


| User request | Authorized operations |
| --- | --- |
| Implement, fix, or change code | Edit and verify only. Do not commit or push. |
| Commit the change | Surgically stage the task's changes and commit them. Do not push. |
| Push the change | Commit if necessary, update from the intended base, and push. |
| Create or open a PR | Create a branch/worktree if necessary, commit, update from the intended base, push, and create a draft PR. |
| Publish a PR | Activate the PR and perform explicitly requested handoff metadata transitions. |
| Merge or complete the PR | Merge the requested PR. Do not infer permission for broader issue or branch cleanup; apply explicitly documented work-overlay follow-ups when applicable. |


Use the smallest operation chain needed for the requested outcome. For example,
`create a PR` authorizes its prerequisite commit and push, but does not authorize
activating, merging, abandoning, or completing the PR.

Finishing edits never implies a commit: after "lgtm", "good" or "yes, make the changes", ask
one short question ("Commit and push?") rather than explaining that you only commit on request.

Rewriting or discarding history requires explicit authorization. This includes:

- Dropping commits or resetting a branch
- Amending an existing commit
- Rebasing when the user has explicitly prohibited git mutations
- Force-pushing
- Deleting branches or worktrees

Never use destructive commands such as `git reset --hard` or `git clean` unless
the user explicitly requests that exact destructive outcome and the affected
state has been inspected first.

## Branches and worktrees

Every branch created for the user **must** begin with `ianhowell/`. Treat this
prefix as mandatory, not a suggestion. If a proposed new branch omits it, add
the prefix before creating the branch. An existing branch named by the user may
be used as-is; do not rename other people's branches.

For a new PR-sized task, use a separate worktree unless the user explicitly asks
to use the current checkout or the session is already in the appropriate feature
worktree.

Place durable worktrees in a sibling directory named `<repo>.worktrees`, never
inside the repository and never under `/tmp/opencode`. Preserve all branch path
components beneath that directory:

```text
Repository: /path/to/project
Branch:     ianhowell/improve-startup
Worktree:   /path/to/project.worktrees/ianhowell/improve-startup
```

Before creating one, use `git worktree list --porcelain` to avoid duplicate
worktrees or branches already checked out elsewhere. Create the sibling parent
directory if needed, but do not alter ignore files because the worktree lives
outside the repository.

Base a new branch on the intended, freshly fetched base branch. Do not disturb a
dirty main checkout to create the worktree.

Once a task has a worktree, every file for it goes there, including docs Ian asks for "at the
repo root" (that means the worktree's root). When a planning doc may turn into code work, create
the worktree before writing the first file; Ian expects the main checkout to stay clean. If
something already landed in the main checkout, `mv` it into the worktree and confirm both
`git status` outputs.

### Removing worktrees

Uncommitted and untracked work in a worktree has no git copy; removal destroys it.

1. For each candidate, report `git status -sb` and commits not on any remote
   (`git log --oneline <upstream>..<branch>`). Diff its untracked/modified paths
   against the worktree being kept (`diff -rq`, excluding `bin/`).
2. Before deleting work the user calls disposable, grep the kept worktree for
   anything that depends on it (e.g. a tool that runs a test package, Makefile
   targets, env vars it reads). Kept files often reference the dropped files by
   path or name. Report each dependency and get a decision before you remove anything.
3. When pulling selected files over, port them as one change and finish the port
   (including renames) before removal.
4. Remove with `git worktree remove --force <path>`. Then `git branch -D` (only branches whose
   commits are on a remote) and `git worktree prune`, and confirm with `git worktree list`.

### Clearing gitignored files

Preview with `git clean -ndX`, then for each path report size and whether it can be rebuilt
(Makefile target). Flag binaries whose source is not in the repo (`git log --all -- cmd/<name>`) as
possibly unrecoverable, and offer `git clean -fdX` or a version that keeps them. Junk that is
tracked (stray `*.log`) is separate: removing it needs a commit, so list it apart.

## Public repos

Personal dotfiles (`ian-howell/.dotfiles`) are public. Never put work project/org names,
lab names, or work-derived content in a file that lands in a public repo, including skills,
examples, comments and commit messages. Personal skills live in `links/opencode/skills`;
work-only material, including skills, stays in the private `~/.config/work`.

- Before committing to any GitHub repo, check `gh repo view --json visibility`.
- New repos Ian owns are created private (`gh repo create --private`) unless he says otherwise.
- Dotfiles' `core.hooksPath` points at `~/.config/work/git-hooks/public-repo`, whose pre-commit
  blocks any term in its `denylist`. Add new sensitive terms there, never in a public file.

## Protect concurrent work

Assume dirty files may belong to the user or another agent.

- Never revert, overwrite, stash, clean, or include unrelated changes. To commit a subset,
  `git add <paths>` and commit; never `git stash --keep-index` to isolate it, which hides the
  remaining edits from the user and from the next commit. Never append a stash "just in case"
  to a commit command either. When asked for two commits from one dirty tree, stage and
  commit the first set, then stage and commit the second; the working tree needs no hiding in
  between. If a stash was made by mistake,
  `git stash show --stat`, then `git stash pop` that exact entry before doing anything else.
- Stage explicit files or hunks belonging to this task. Do not use `git add .`,
  `git add -A`, or an equivalent indiscriminate command when unrelated changes
  may exist.
- If a task intentionally modifies only part of an already-dirty file, stage
  only the task's hunks.
- Inspect both `git diff` and `git diff --staged` immediately before committing.
- After committing, verify the commit and report any dirty files left untouched.
- If concurrent changes directly conflict with the task, stop and ask rather
  than choosing which work to discard.

## Commits

Match the repository's established commit style. Unless the user explicitly
requests otherwise, every commit must have:

- A concise, imperative subject
- A meaningful body explaining what changed and why the change is correct,
  useful, or safe

Focus the body on the resulting difference from the intended base. Do not
recount the branch's development history, failed attempts, or review process.
Keep logically separate changes in separate commits when that materially helps
review, and preserve an explicitly requested commit sequence for stacked work.

Do not amend an existing commit unless explicitly requested. When Ian asks to fold follow-up edits
into the previous commit, stage only those paths, `git commit --amend -F -`, and rewrite the message
so it describes the combined result, not the original subset. When commit hooks fail, fix the
problem and create the requested commit normally rather than skipping hooks.

## Updating and pushing

Before the final push, fetch and rebase onto the intended base unless the user
requests another integration strategy. For a stacked branch, the intended base
is the preceding branch, not necessarily `main`.

- Inspect incoming changes before rebasing.
- Resolve conflicts without discarding intentional branch changes or unrelated
  user work.
- Re-run relevant verification after resolving conflicts.
- Re-check the diff against the intended base after rebasing.
- A rejected push in a repo with unrelated dirty files: `git fetch`, compare
  `git diff --name-only HEAD origin/<base>` with the dirty paths, then
  `git pull --rebase --autostash`. If they overlap, the autostash pop conflicts
  and leaves the stash plus `UU` files: `git reset` (unstage only, keeps edits), tell Ian
  which file conflicted, and merge it only when asked. When merging his local
  edits with upstream, keep both sides' rules, drop local notes that upstream
  now contradicts, and list what was kept/dropped; drop the stash only after
  confirming no conflict markers remain.
- Never force-push without explicit authorization. If a required rebase would
  make an already-published branch need a force-push, stop and ask first unless
  the user already authorized that history rewrite and push.

## Pull requests

Create PRs as drafts by default. A newly created draft is for Ian's personal
review; implementation being complete is not approval to hand it to the team.
When Ian says a PR should be published from the start, create it with `--draft false`.

Before creating a PR:

- Verify the source branch starts with `ianhowell/`.
- Verify the source and target branches are correct.
- Review all commits and the full diff included in the PR.
- Run the relevant tests or clearly report what could not be run.

Every PR description must contain a paragraph beginning exactly with `This PR`.
It may be a one-sentence paragraph and does not need to be first, but it must be
present. For example:

```text
This PR preserves full session titles in the window picker.
```

Leave the PR's own CI or pipeline results out of the description ("the PR build passed"); the
PR page already shows them. Describe validation the reviewer can't see there, such as local
runs or a test environment.

Do not leave the description empty. If PR tooling derives a description from
the commit message, inspect the result and update it unless it contains the
required `This PR...` paragraph. The rest of the description should explain the
actual branch diff, rationale, and verification without overstating results.

Do not activate, complete, abandon, or merge a PR without authorization. Do not
add reviewers unless requested or established repository instructions require
specific reviewers.

Before stating a PR's state (draft, auto-complete, votes, policies), re-read it with
`az repos pr show`: Ian publishes and sets auto-complete himself, so a state remembered
from creation is often stale. To publish with auto-complete, match the completion options
the repo's merged PRs use (`completionOptions`: squash, delete source branch, PR
description as `mergeCommitMessage`, set via REST PATCH). Once auto-complete is set,
stop polling; the PR merges itself after reviews and the pipeline.

## Final verification

After an authorized git or PR workflow, report the relevant final state:

- Worktree path and branch
- Commit hash and subject
- Push result
- PR URL, target branch, and draft status
- Linked issue and its state, when applicable
- Tests or checks run
- Any remaining dirty or unrelated files intentionally left untouched

Do not claim a state transition, link, push, or verification succeeded without
checking its result.
