# Advanced git recipes

## Splitting tangled changes into commits

When the working tree mixes changes that touch the same files (a rename, a config flip, a doc
merge), build each commit's index from HEAD content instead of `git add -p`:

1. Compute the file's intermediate content: HEAD plus only that change (e.g. apply the rename
   with `re.sub` to `git show HEAD:<path>`).
2. `git hash-object -w --stdin < content`, then
   `git update-index --cacheinfo 100644,<sha>,<path>`.
3. Earlier commits may need small edits to files a later commit deletes, so each commit is
   self-consistent on its own.
4. Verify each commit alone before committing it: `git checkout-index -a --prefix=<scratch>/`,
   then build and test there.
5. Order commits so the last one leaves the working tree clean.

To verify a commit that excludes other dirty files: `git stash push --keep-index -- <others>`,
run the checks, then `git stash pop`.

## Rebasing a published branch (when authorized)

1. `git status --short` must be clean. `git fetch origin`, then confirm the remote has nothing
   local lacks: `git merge-base --is-ancestor origin/<branch> HEAD`. Note the remote SHA.
2. Make a backup branch (`git branch backup/<branch>-pre-rebase HEAD`) and tell the user to
   delete it later.
3. `git rebase origin/main`. A file touched by many branch commits often conflicts once per
   commit with the same main-side insertion. Resolve with a scripted loop that checks the only
   unmerged path is the expected one and the conflict has exactly the expected shape, writes the
   resolution, `git add`s, and `GIT_EDITOR=true git rebase --continue`; stop on anything else and
   resolve by hand.
4. Verify: no conflict markers; `git range-diff <old-base>..backup <main>..HEAD` shows every
   branch commit unchanged and only already-on-main commits dropped; then build and run the full
   test suite.
5. Push with a lease pinned to the checked SHA:
   `git push --force-with-lease=<branch>:<remote-sha> origin HEAD:<branch>`, then fetch and
   confirm local and remote SHAs match.

Report conflicts and their resolutions, the range-diff result, checks run, and leftovers (the
backup branch, unrelated local state).

## Recovering from an interrupted commit

Check `git log -1` and `git status` before anything else, and report the real state.
