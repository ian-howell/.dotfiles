---
agent: plan
---

# Diversify sub-command responses

You are an orchestrator agent. Your job is to run a given opencode sub-command repeatedly
until you have collected N semantically unique responses, then summarize them. Do not prompt
the user for confirmation before starting. Begin executing the plan immediately upon invocation.

## Arguments

- `$1` — the sub-command to run (e.g. `ado:review-agent`). If not provided, ask the user.
- `$2` — N, the number of unique responses to collect. Default: 5. If not a positive integer, use 5.

## Setup

- Set `MAX_ATTEMPTS = N * 3`.
- Initialize `collected = []` (list of unique responses with a 1-sentence semantic summary of each).
- Initialize `attempts = 0`.

## Loop

Repeat until `len(collected) == N` or `attempts == MAX_ATTEMPTS`:

1. Construct a steering prompt:
   - If `collected` is empty: use an empty string (no steering).
   - Otherwise: use the following text, filling in the summaries:
     > "The following angles have already been covered: [1-sentence summary of each collected
     > response]. Please take a meaningfully different approach, focusing on a distinct angle,
     > conclusion, or recommendation not yet explored."

2. Invoke the sub-command:
   ```bash
   opencode run --command $1 "<steering prompt>"
   ```
   Capture stdout as `candidate`. Increment `attempts`.

3. If `candidate` is empty or looks like an error: do not add to `collected`, continue the loop.

4. Semantically compare `candidate` against every entry in `collected`:
   - If it expresses the same core idea, conclusion, or recommendation as any existing entry
     (even if worded differently): it is a **duplicate** — continue the loop.
   - If it is genuinely different: it is **unique** — append it to `collected` along with a
     1-sentence summary, then continue the loop.

## Termination

- If the loop ends because `len(collected) == N`: proceed to the summary step normally.
- If the loop ends because `attempts == MAX_ATTEMPTS`: proceed to the summary step, but note
  in the output that diversity was exhausted before N unique responses were collected.

## Summary

Produce the following output:

```
## Diversified Responses for `<sub-command>`
Collected M of N unique responses across K attempts.

### Response 1
<full text of the response>

### Response 2
<full text of the response>

... (one section per collected response)

---

## Synthesis
**Common themes:** ...
**Key divergences:** ...
**Notable outliers:** ...
```

## Notes

- This command works best with self-contained sub-commands that discover their own context or
  require no arguments. If the sub-command needs specific inputs, ask the user for them before
  starting the loop and include them in the initial steering prompt.
- Trust your semantic judgment when comparing responses. Identical wording is obviously a
  duplicate, but so is the same conclusion reached via different reasoning.
