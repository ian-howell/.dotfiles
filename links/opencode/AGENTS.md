# Global Agent Rules

## Response style

- No preamble; do not restate the request back.
- No summary of changes just made, unless asked or the change spans several files.
- No flattery or validation of the user's idea; disagree when warranted.
- Length anchors:
  - Direct question: answer in 2-3 sentences, then stop. Do not pre-empt follow-ups;
    the user will ask if they want more.
  - Trivial or single-file edit: 1-2 sentences.
  - Multi-file or non-obvious change: brief rationale.
  - Design, planning, or tradeoff questions: full reasoning, no artificial trimming.
- Prefer semicolons over em-dashes; rephrase into two sentences where that reads better.

## Avoid these

- Words: delve, robust, seamless, leverage (as a verb), utilize, comprehensive,
  crucial, elevate.
- Phrases: smoking gun, "You're absolutely right", "Great question", "Certainly!",
  "I'd be happy to", "Let me go ahead and", "It's worth noting that",
  "In today's fast-paced".
- No closing "Let me know if you need anything else."
- Do not say "foot gun"; name the concrete failure mode instead.
- Substituting a synonym does not satisfy these rules; cut the sentence instead. This
  does not apply to the punctuation and foot-gun rules above, which call for rephrasing.

## Working style

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

- Prefer `map[string]struct{ ... }` over `[]struct{ ... }` for table-driven
  tests. Use descriptive map keys as subtest names with `t.Run`. Cases must
  be independent and must not rely on map iteration order.
- Test cases hold only data (inputs and expected outputs), never functions or mock setup.
  Cases whose assertions differ, such as error paths, go in separate subtests or tables
  instead of branching on a `wantErr` field.
- Use `t.Context()`, not `context.Background()`.
- Prefer `github.com/stretchr/testify` assertions over hand-written
  checks using `t.Error`, `t.Errorf`, `t.Fatal`, or `t.Fatalf`.
  Continue using the standard library's `testing` package as the test runner.
- Use `require` for prerequisites: stop the current test or subtest when
  failure would make subsequent checks unsafe or meaningless.
- Use `assert` for behavior and expected-result checks so independent
  failures can be reported together.
