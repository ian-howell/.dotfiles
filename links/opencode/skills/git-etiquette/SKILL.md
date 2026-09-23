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
- Inspect `git status`, the current branch, remotes, and worktrees.
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
| Make the PR ready or hand it off for team review | Activate the PR and perform explicitly requested handoff metadata transitions. |
| Merge or complete the PR | Merge the requested PR. Do not infer permission for broader issue or branch cleanup; apply explicitly documented work-overlay follow-ups when applicable. |

Use the smallest operation chain needed for the requested outcome. For example,
`create a PR` authorizes its prerequisite commit and push, but does not authorize
activating, merging, abandoning, or completing the PR.

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

## Protect concurrent work

Assume dirty files may belong to the user or another agent.

- Never revert, overwrite, stash, clean, or include unrelated changes.
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

Do not amend an existing commit unless explicitly requested. When commit hooks
fail, fix the problem and create the requested commit normally rather than
skipping hooks.

## Updating and pushing

Before the final push, fetch and rebase onto the intended base unless the user
requests another integration strategy. For a stacked branch, the intended base
is the preceding branch, not necessarily `main`.

- Inspect incoming changes before rebasing.
- Resolve conflicts without discarding intentional branch changes or unrelated
  user work.
- Re-run relevant verification after resolving conflicts.
- Re-check the diff against the intended base after rebasing.
- Never force-push without explicit authorization. If a required rebase would
  make an already-published branch need a force-push, stop and ask first unless
  the user already authorized that history rewrite and push.

## Pull requests

Create PRs as drafts by default. A newly created draft is for Ian's personal
review; implementation being complete is not approval to hand it to the team.

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

Do not leave the description empty. If PR tooling derives a description from
the commit message, inspect the result and update it unless it contains the
required `This PR...` paragraph. The rest of the description should explain the
actual branch diff, rationale, and verification without overstating results.

Do not activate, complete, abandon, or merge a PR without authorization. Do not
add reviewers unless requested or established repository instructions require
specific reviewers.

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
