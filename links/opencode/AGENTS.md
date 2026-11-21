# Global Agent Rules

## Working style

- "tp there" / "tp us to the worktree" means move this tmux window into the worktree's session:
  from the repo: `TMUX_PANE=$TMUX_PANE tp '<session>'`.
- When you suspect a bug or flake, prove it yourself (reproduce it, test it, compare recent
  runs) before calling it one. Don't ask Ian to check.
- Do the obvious next step (run the test, read the log, look it up) instead of asking
  or putting it off.
- Give zsh syntax for commands Ian runs, e.g. `read -rs "T?Token: "`, not bash `read -p`.
- Never run `pkill -f` or `pgrep -f` with a pattern that also matches the calling shell's
  own command line; the call kills itself. Use a PID or the bracket trick
  (`pkill -f '[n]ame'`).
- Docs and code comments describe what the code does now: no "does not" disclaimers,
  edge-case asides, references from code back to docs, or change history.
- New GitHub repos Ian owns are private unless he says otherwise.

## Go Tests

- For tests of a single function, prefer one `TestFuncName` with a `t.Run` subtest per
  scenario over top-level functions with suffixed names such as `TestFuncNameWithoutID`.
  Name subtests as short sentences that state the behavior, e.g. "a node without a
  machine fails".
- Prefer `map[string]struct{ ... }` over `[]struct{ ... }` for table-driven
  tests. Use descriptive map keys as subtest names with `t.Run`. Cases must
  be independent and must not rely on map iteration order.
- Test cases hold only data (inputs and expected outputs), never functions or mock setup.
  Cases whose assertions differ, such as error paths, go in separate subtests or tables
  instead of branching on a `wantErr` field.
- Use `t.Context()`, not `context.Background()`.
- Prefer `github.com/stretchr/testify` assertions over hand-written
  checks using `t.Error`, `t.Errorf`, `t.Fatal`, or `t.Fatalf`.
- Use `require` for prerequisites: stop the current test or subtest when
  failure would make subsequent checks unsafe or meaningless.
- Use `assert` for behavior and expected-result checks so independent
  failures can be reported together.
