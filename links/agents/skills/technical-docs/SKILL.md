---
name: technical-docs
description: Use when writing or restructuring feature/design docs. Ian's doc structure and voice.
---

# Technical docs

Ian's conventions for feature documentation in code repositories.

## Structure

- One feature, one `docs/<feature>/README.md`. Merge process/design/validation files into it
  rather than cross-linking siblings. Order: overview, configuration, detection/rules, the
  decision flowchart with its notes, persisted state, scope, verification, demo. Drop duplicated
  paragraphs when merging.
- A demo sits next to the README as `demo.html`: one self-contained file, no `demo/` directory,
  no version suffix. Rename with `git mv` to keep history.
- After moving or merging docs, grep the whole repo (agent instructions, code comments, other
  docs) for the old filenames and fix every reference.

## Voice

- Describe what the code does, stated positively. Cut disclaimers ("X is not evidence", "does
  not read Leases", "not an atomic lock"); they read as noise.
- Write gating rules as one list of conditions that must all hold ("The controller judges a guest
  only when all of these hold:"), then one sentence on what happens while any fails.
- Stay at the behaviour level: no code identifiers, "named X in code" asides, or compatibility
  notes. If a doc tweak would make a diagram slightly imprecise, adjust the prose; don't reorder
  production logic to fit the diagram.
- No ceremony for trivial decisions: an on/off switch is one sentence, not a diagram. Diagrams
  are for the real decision loop.

## Sections

- Notes under a diagram are short plain paragraphs defining its decision nodes. No bold-labelled
  mini-sections, no "the chart leaves out N details" lists, no rare edge cases; if it isn't worth
  a reviewer's attention, delete it.
- A persisted-state section: where the state lives with one JSON example, one sentence per field,
  the numbered steps that write it, one paragraph on why the ordering is safe, one on how the
  state ends. Cut code-level notes and read-ordering detail.
- A demo section is one paragraph: the story it walks through, that a playground exists, and
  that it is one self-contained file to open or share. No scene walkthroughs, control lists, or
  shortcuts; the demo shows those itself.
- Links are reference-style with the definition at the bottom of the section that uses them
  (`the [demo] shows…`, then `[demo]: demo.html`). Repeat a definition in each section that
  uses it rather than sharing one at the top.
- Don't keep ad-hoc tests nothing runs (e.g. a browser script CI never invokes); recommend
  deleting them.
