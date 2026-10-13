---
name: go-testing
description: Use when writing, reviewing, or refactoring Go tests. Ian's table, fixture, and fake rules.
---

# Go testing

These are Ian's standing preferences. They override repository styleguides that show
`[]struct{name ...}` tables or prefer mockery inside tables. If a reviewer may flag the
divergence, mention it once; don't argue it.

## Procedure

1. **Decide what is worth testing before writing anything.** Read the file and its callers (and
   run coverage when useful: `go test . -coverprofile=$TMPDIR/c.out && go tool cover
   -func=$TMPDIR/c.out`). Name the behaviour a refactor could silently break: a safety gate, a
   switch-case ordering, an error that must not become absence, a thing that must NOT happen, a
   persisted format, bounded metric labels. Skip wiring, struct literals, log lines, framework
   registration, and error paths only a fake could trigger. When asked "is this worth testing?",
   answer with two short lists (worth it / coverage only), propose a size, and ask before writing.
2. **Reuse what exists.** Look for sibling `_test.go` setup and helpers to copy (and mockery mocks
   under `mocks/<pkg>` for non-table tests).
3. **Put the test next to the code**: a test for `foo` in `x.go` goes in `x_test.go`; move fakes
   with the tests that use them.
4. **Write it** following the shape rules below.
5. **Run** `gofmt -l`, `go vet`, and `go test -run <Name> -v` for the package before reporting.
6. **Prove safety tests discriminate.** Back up the source to scratch, temporarily introduce the
   bug (swap switch cases, move a `DeepCopy` below the mutation, drop a check), confirm the
   intended case fails, restore, and confirm `git status` shows the source unchanged. If nothing
   fails, the input doesn't exercise the behaviour; change the input.

## Table shape

- Tables are `map[string]struct{...}` keyed by case name, ranged as
  `for name, tt := range tests { t.Run(name, ...) }`. Map order is random, which also surfaces
  cases that accidentally depend on each other.
- Case structs hold only data: inputs and expected outputs. Never functions (mock-expectation
  setup, builders, assertion funcs); that turns the table back into a program.
- No branching in the loop body (`if tt.wantErr {...} else {...}`). A table is right only when
  every row runs exactly the same code and assertions: branches are untested test logic and force
  rows to carry meaningless fields. When assertions differ, split into a success table and an
  error table (`TestX` / `TestXReadErrors`), or plain `t.Run` subtests. Two cases with different
  assertions are two subtests, not a two-row table.
- Error tables say only which dependency fails and assert only `ErrorIs`. Don't carry a `want`
  nobody checks. A single failure case is its own `t.Run` after the success table. Cover every
  dependency's failure.
- Cells hold the real values the code consumes (`[]clusterv1.Machine`, VMIs), built inline with
  small helpers (`vmiOwnedBy("m")`). Never encode inputs as strings the loop decodes (`""`
  meaning "unlabeled"); the decoding is hidden logic.
- Write meaningful zero inputs explicitly (`state: nil`). When rows share a non-obvious invariant
  (e.g. this function never counts; another does), state it in a comment above the table.
- When a feature has a reference walkthrough (a demo, process doc, or state diagram), order cases
  to follow it so the table reads as the story; each case's starting state is the real state at
  that phase (often the previous case's output). Put alternative branches next to the step they
  diverge from. After reordering or adding a case, check its inputs against neighbours: a copied
  case often keeps another step's starting state and silently tests the wrong transition.

## Naming

- Name tests after the type under test, not a field (`TestReporterEvents`, not
  `TestRecorderEvents`). One top-level `Test<Type><Concern>` per behaviour (Events vs Metrics);
  move shared helpers to file level when splitting.
- Case names state input and result as a parallel set ("a Machine without a recorded failure is
  not patched"). Avoid double negatives and narrative words that need outside context.
- Name time values for what they mean in the domain (`graceStart`, `withinGrace`,
  `graceExpired`), never the arithmetic (`pastGrace`, `oneMinutePastGrace`). Check a proposed
  name against the arithmetic (`observationTime.Add(grace)` is the end of the grace period, not
  after it); if it's wrong, say so and offer one alternative.
- Name fixtures for their state in the story (`bootingReplacement`, `bootedReplacement`), not an
  assumed quality. Follow Go initialisms; don't name a closure parameter `t` inside a test.
- Give repeated inline expressions (`deadline.Add(-time.Second)`) a named var and replace every
  occurrence.

## Fixtures and helpers

- Use `t.Context()`, never `context.Background()`.
- DAMP over DRY: a little repetition beats indirection. Shared setup is a plain helper, never a
  func field: a closure in the test that uses it (`newMachine`, `reconcilerAt(now)`), promoted to
  file level when several tests need it. Name helpers so the call site reads as a sentence.
- Every fixture field must be read by the code under test or required by the API. Prove a
  doubtful field by removing it and rerunning.
- Fixture variants are functional options named for the state they produce:
  `createVMI(t, graceExpired, withFinalizer)`, `createNode(t, setReady)`. Not a bare variadic of
  raw values, a bool parameter, or a parallel `createXWithY`. Put the computation and its why in
  the option's doc comment.
- Assertion helpers are plain functions named `assert…`/`require…` taking the fixture
  (`assertVMIKept(t, g, vmi)`), not fixture methods. Lift a repeated multi-line assertion into
  one, with its timing rationale in the doc comment.
- In an expected sequence (state history, event list), put a one-line comment above each element
  saying which step produced it.
- Time: freeze the clock at a shared `observationTime` ("when the controller looks") and place
  resource timestamps relative to it, going backwards. Vary resource timestamps rather than the
  clock, so one reconciler serves every case. Don't freeze `now` at a derived `deadline`.
- Pull long literals into named locals (`state :=`, `want :=`). When expected values are noisy
  (escaped JSON in JSON), the table holds the meaningful number (`wantRestarts: math.MaxInt32`)
  and a builder renders it (`patchWithRestarts(n)` via a written-out `fmt.Sprintf`, so it still
  pins the persisted format).
- No Arrange/Act/Assert comments; blank lines separate the phases.
- Doc comments on helpers and fakes say what they return, what is faked, and why, in two or three
  lines of Go doc prose.

## Fakes

- Prefer tiny hand-written fakes that return data over mockery expectations inside tables:
  `return &T{ObjectMeta: metav1.ObjectMeta{Namespace: ns, Name: name}}, f.err`. Asserting on
  the returned object already proves the right names were used and that a skipped read was
  skipped. Add a call log only when no output can reveal the behaviour.
- Embed the interface in a fake that needs only one method, so unimplemented methods panic.
- Strict mockery mocks (`NewX(t)`) are fine for single-scenario tests outside tables, where a
  missing `EXPECT()` asserts a call is skipped.
- For writes, record what would hit the API, not before/after snapshots: a `Patch` fake stores
  `ctrlclient.MergeFrom(original).Data(obj)` and the test uses `assert.JSONEq`. That catches a
  `DeepCopy` taken after the mutation (an empty `{}` patch), which snapshots miss. Add an
  unrelated annotation so a removal reads `{"key":null}`, not `annotations:null`.
- A nil dependency that would panic if touched (e.g. a nil manager passed to `SetupWithManager`)
  is a valid "returns before using it" assertion; say so in a comment.
- Assert only what matters: not read order, call order, or partial results returned alongside an
  error unless the caller uses them.
- Kubernetes Events and OTel metrics: see `references/events-and-metrics.md`.

## Rewriting someone else's tests

- Keep the production change; replace the tests rather than patching them. Fold each guard's
  cases into the existing per-function test in the file's style.
- Drop end-to-end re-proofs bolted onto a unit test (fake clients built inside a branch,
  Reconcile looped over states); unit tables plus integration tests already prove it.
- Then break each new guard one at a time and report a bug → failing-case table, restoring the
  file after each.

## Editing discipline

- Do only the edit asked for. Never merge, delete, or rename helpers that look duplicated; point
  them out. The user may have a different version in progress.
- The user edits concurrently. Re-read the file (or `git diff`) right before every edit and adapt
  to their version. In scripted multi-replaces, assert each anchor matches exactly once before
  writing, so a stale anchor aborts with no partial edit.
- When restoring something you changed wrongly, restore it exactly as it was.
- When proposing a multi-test change the user may not follow, show a mock diff first.
