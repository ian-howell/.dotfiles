---
name: ado-user-story-authoring
description: Use when drafting or filing ADO user stories.
---

# ADO user story authoring (Ian / REDACTED style)

## Procedure
1. **Ground the gaps in code first.** Trace each suspected blocker to where the value is actually produced (follow the call chain into sibling repos when the producer lives elsewhere, e.g. a controller that writes a status ref). Only raise a question to the user if tracing cannot settle it — "could existing data hit this?" is usually answerable by finding the single writer of the field.
2. **Ask only behavior-changing decisions** in one clarify batch (scope split, migration, defaults/fallbacks, verification level). Recommended option first.
3. **Draft the story as outcomes, not implementation.** Narrative (human actor), context, in/out of scope, Given/When/Then acceptance criteria, independent verification, dependencies, resolved decisions. No file paths, function names, or "build X with option Y" — the story says *what* must be true; the implementer decides *how*. Code pointers belong in the chat analysis, not the story.
4. **Search ADO for existing work before proposing creation.** WIQL Features/Epics by keywords, then list the candidate Feature's children (`az boards work-item show --id <F> --expand relations`, then show each child). An existing child may already be assigned to the user and cover part of the scope — prefer updating it over creating a duplicate.
5. **State the exact ADO actions and wait for go-ahead** before any write: new vs update, parent link, assignee (`az account show --query user.name -o tsv` for "myself"), area path, board column, and what is explicitly not done (no repo changes, PRs, extra links). Offer update-vs-create as options when an existing item overlaps.
6. Write, then reply with work item ID + URL.

## Pitfalls
- Leave dependencies on unrelated in-flight PRs out of the story unless asked; the story should stand alone.
- An "error instead of fallback" criterion can conflict with "existing behavior unchanged" — resolve it by proving the fallback is unreachable (trace the writer) rather than asking the user to guess.
- When told to "investigate before making changes", do read-only queries only (WIQL, work-item show, repo grep) and end with the proposal.
