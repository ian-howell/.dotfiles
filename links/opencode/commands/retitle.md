---
description: Queue a background agent to summarize this session in its title
subtask: false
---

Call `session_title` once to queue background retitling of this session. Pass the
optional guidance below as `guidance` (or an empty string when none is supplied).
The plugin captures the conversation and delegates title generation to the
`session-titler` agent, then updates this session when the result is ready.

Optional user guidance for the title: $ARGUMENTS

After the tool confirms it is queued, reply only: "Retitling in background."
Do not generate a title yourself, invoke the Task tool, poll, or wait for completion.
If queueing fails or the tool is unavailable, report the failure instead.
