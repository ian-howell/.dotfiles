# Stable mode reminders

`plugins/stable-mode-reminders.ts` is automatically loaded through the shared
OpenCode config symlink. Restart OpenCode to activate it. Official binary
auto-updates continue normally.

OpenCode 1.18.34 injects a temporary plan/build reminder into the latest user
message. The plugin persists that exact synthetic part using OpenCode's API
before the model request, and removes core's duplicate injection on subsequent
steps. It retains one reminder per applicable user message, preserving the
existing instruction frequency. Old turns are not backfilled. Already-persisted
reminders are left alone, including when core starts persisting them itself.

This fixes the moving-reminder cache invalidation described in upstream issues
[23595](https://github.com/anomalyco/opencode/issues/23595) and
[26749](https://github.com/anomalyco/opencode/issues/26749). It does not fix Astra
reasoning-effort serialization or guarantee cache hits after unrelated context
changes, mode-dependent tool changes, or provider cache expiration.

## Upgrade checks

From the dotfiles root:

```sh
node --experimental-strip-types --test links/opencode/tests/stable-mode-reminders.test.ts
REMINDER_TEST_OUTPUT=/tmp/opencode/evidence/reminder-upgrade-check \
  python3 links/opencode/tests/stable-mode-reminders.integration.py
```

The integration test starts temporary loopback OpenCode servers and a local mock
model. It uses isolated configuration, creates labeled test sessions in the
normal session database, and makes no paid model calls. It checks actual wire
history, plan/build transitions, tool continuations, server restart, fork, and
compaction. The control should reproduce the bug; if upstream fixes it, update
that expectation and check whether this workaround can be removed.

Compatibility dependencies: `experimental.chat.messages.transform` runs after
core reminder injection; the legacy plugin client's `_client` transport is used
because that client exposes no public `part.update` method. Reusing this transport
preserves embedded CLI operation, authentication, and directory routing. API
failures propagate rather than silently submitting unstable history. These two
integration points warrant retesting after upgrades.

Disable by moving `plugins/stable-mode-reminders.ts` out of the plugins directory,
then restarting. Persisted reminders remain in history; disabling cannot undo
the original core bug. No changes to the work overlay are required.

## Validation on 1.18.34

Live GitHub Copilot/Astra test: four short turns, plan → plan → build → build,
with approximately 4,800 input tokens initially. Control follow-ups had 0% cache
reuse. Patched follow-ups had 93.8%, 98.6%, and 98.7%; combined follow-up charges
fell from $0.1775525 to $0.0216865 (87.8%). Both arms used identical plan/build
system prompts and disabled tools to isolate reminder behavior. Production mode
switches can additionally change tool definitions. This is one controlled run,
not a universal savings estimate.
