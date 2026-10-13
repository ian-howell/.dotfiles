---
name: go-code-style
description: Use when changing Go production code: refactors, renames, config defaults, readability.
---

# Go code style

Ian's preferences for Go production code. Tests live in the `go-testing` skill; git workflow in
`git-etiquette`.

## Structure

- Keep I/O visible at the call site. Pure helpers only encode or mutate the object
  (`writeRecoveryAnnotation(m, state)`); the caller does `DeepCopy` → mutate → `Patch` → report →
  requeue itself, like a neighbouring `Delete`. Don't hide writes in `save`/`patch` wrappers or
  `defer r.patch(m)()`: deferred writes run after the body, lose errors, and fire on every exit.
- Don't split one function by a nil-vs-value parameter branch; give each case its own function.
- For a hard boolean, prefer a named local (`overflowsOnCount := ...`) over a single-use method
  or a De Morgan flip.
- Guard an invariant where it can break (saturate `n++` at `math.MaxInt32` in the incrementing
  function) rather than rejecting the state at read time far away.
- `time.Duration` comparisons need units: `d <= 10` is 10ns. Check edited thresholds carry
  `* time.Minute` (or similar).
- A doc comment stands alone: it says what the function does (for a reconciler, the steps one
  call can take in priority order and what it leaves alone). Never point at a design doc.

## Config options

- For an optional feature's config, clamp in `SetDefaults` (`x = max(x, minX)` with named
  `min<Field>` consts and a why-comment) rather than validating and failing startup: one
  feature's bad value must not stop every controller.
- Check a floor against manual and synthetic test configs; a production-sized floor makes every
  test cycle slow. Put a low safety floor in code and the operational value in chart values with
  a comment stating the minimum.
- After changing a default or minimum, grep the repo for the old value (`45m`, `45-minute`,
  `GRACE = 45`) across chart values, docs, demos, and test docs. Fix live config and docs; ask
  before touching demos or historical notes.
- A feature that defaults on gets a negative switch, `Disabled bool`
  (`json:"disabled,omitempty"`), so the zero value means on. Never `Enabled *bool` with
  nil-means-true defaulting. Flag the upgrade impact (deployments that never set it start acting).
- Trace every caller of `SetDefaults`/`Validate*` before testing a validator. If defaulting
  always runs first, the validator is dead code: propose deleting it and pin the rule with rows in
  the defaults test.
- A "kept for compatibility" claim about a persisted key is only real if the format has shipped.
  Check with `git log -S'<key>'`; on an unmerged branch there are no users, so rename freely
  (prefer renaming the code identifier to match the persisted key).

## Renames and scripted edits

- Grep the package for both the old and new name first to avoid collisions. Then `sed` with `\b`
  word boundaries, `gofmt -w` (it realigns `var` blocks), and run the package tests.
- When a Python script edits Go raw strings full of escaped JSON (`\"`), write the replacement
  with the file's own escaping and grep the line afterwards; Python doubles backslashes easily.
- The terminal cwd persists between calls; prefix multi-step commands with an absolute `cd`.

## Explaining and planning

- When asked to explain confusing code: what it does, how it reads at the call site, the
  timeline or values involved, and why it's confusing. Offer a concrete readability fix; don't
  apply it unasked.
- When asked what testing a branch still needs, ground it in coverage (`go test -coverprofile`,
  `go tool cover -func | awk '$3+0<80'`, count-0 blocks) and the feature's docs. Group gaps into
  unit (with `file:line`), integration, and e2e; mark pure plumbing "skip"; raise behaviour
  questions the gaps expose; recommend an order and ask before anything that costs money.
