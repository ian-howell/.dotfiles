---
name: bash-scripts
description: "Use when modifying bash scripts."
---

# Bash scripts for Ian

Applies to long-lived scripts, not throwaway one-liners.

## Layout

1. Header: shebang, copyright line if the repo uses one, then a short comment saying what the
   script does and which env vars it reads (`IMG`, `CONTEXT`, `KEEP=1`).
2. `set -euo pipefail`, then required inputs (`: "${IMG:?IMG must name ...}"`) and the few
   globals (`root`, `context`, `work=$(mktemp -d)`).
3. `main()` near the top, reading as the plan: one line per step, calling named functions
   (`deploy_manager`, `register_webhooks`). Ian finds a top-level `main` plus small functions
   far easier to read than a flat script of commands.
4. Helpers and step functions below `main`, each with a one-line comment when its name does not
   say why (e.g. why flannel goes in before the second wait).
5. Last line: `main "$@"`.

## Fixing broken scripts

Ian treats a script bug as a cleaning exercise: find what the workaround is compensating for,
fix that, and delete the workaround code. Don't propose extra cleanup/guard code that papers
over a hack (e.g. teardown that removes a hand-written iptables rule) when the hack itself can
go; grep for sibling workarounds of the same cause and remove them in the same change.
When Ian says to set something up ("just create the devbox"), do it without stopping to
offer option menus for tooling friction you can route around without touching his files.
Before claiming a deleted workaround was unnecessary, run the old code path on `main` as a
baseline whenever the new path fails, so a pre-existing failure isn't blamed on the change.

## Style

- Before creating or modifying a script, check the available skills for one that covers the
  place it will be pushed (for example a work overlay's `ado-bash-scripting` for Azure DevOps)
  and follow it as well.
- Wrap repeated command prefixes in a function, never an array:
  `k() { kubectl --context "$context" -n nc-system "$@"; }` so calls read `k apply -f -`.
  Ian rejects `"${k[@]}"` as ugly.
- Prefer the tool's own wait over hand-rolled polling: `kubectl wait --for=condition=...`,
  `kubectl rollout status`, `wait deployment --all`, one `wait` naming several objects. Keep a
  small `retry SECONDS cmd...` helper only for checks no condition expresses.
- Prefer `yq`/`jq` one-liners over inline Python. Pass shell values in with `strenv(var)`
  (`image=$image yq '... = strenv(image)'`) or `--arg`, never by splicing into a
  double-quoted expression with escaped quotes.
- Keep manifests in YAML files beside the script with `${VAR}` placeholders, rendered by
  `clusterctl generate yaml --from <file>` (or the repo's existing renderer) and piped to
  `k apply -f -`. Ian finds a heredoc manifest ugly; never jq-rewrite a live object either.
  Check `--list-variables` shows exactly the variables you meant.
- Failure diagnostics and temp cleanup go in one `trap on_exit EXIT` that checks `$?`; let
  `set -e` fail the script rather than custom `fail`/`dump` helpers.
- Pass explicit context flags (`--context`) instead of checking or switching the current
  kubectl context. For Azure CLI, append the global flag after the args:
  `az() { command az "$@" --subscription "$SUBSCRIPTION"; }`; a leading `--subscription`
  breaks command parsing (az reads the ID as a command name).
- When Ian asks for scripts to "exercise it myself", write them under the requested dir with a
  README of the run order and what to look for, `bash -n` them, and do not run anything that
  creates cloud resources. Probe cheap read-only calls (`az group exists`) to verify wrappers.
- Drop steps that re-verify what an earlier wait already proved; say so in the summary.
- jsonpath that indexes `.items[0]` errors while the list is still empty; use
  `{range .items[*]}...{end}` in anything a `retry` loop polls.

## Verify

`bash -n` every script, test any yq/jq expression against real input locally, then run the script
end to end before calling it done.
