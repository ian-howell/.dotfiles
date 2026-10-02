# Interactive demo style guide

These rules came out of iterating on a demo the user loved. Follow them by default; break one only
when the user asks or the subject clearly demands it, and say so.

## Look

- **Tokyo Night, always.** Palette and syntax colors live in `engine.css` custom properties. Use
  the tokens (`--blue`, `--magenta`, `--green`…) instead of new colors. Semantics: blue = flow and
  structure, magenta = persisted intent / the system's own state, cyan = instances and data,
  green = success and health, yellow/amber = waiting and warnings, red = failure, orange = numbers
  and constants.
- A fixed **1600×900 world** scaled to fit the window (letterboxed). Lay everything out in those
  coordinates; never fight responsive layout inside the stage.
- **Ambient night sky** (stars, rare meteor, city skyline) stays subtle. It earns its place by
  showing time: call `Demo.sky.timelapse(amount)` whenever time passes in the story.
- Generous space. One focal object per scene, highlighted with the spotlight; everything else is
  context.

## Words

- **Plain, descriptive headings.** Say what happens: "Delete the reserved VMI", "The breaker opens
  at the threshold". No slogans, no cleverness, no rhetorical questions, no "There you are."
- Kicker = `NN · Short step name`. Subline = one sentence of the essential detail.
- One idea per scene. If a scene needs two sentences of subline, it is two scenes.
- Labels in the world are lowercase and terse.

## Interaction

- **Click-driven. Never autoplay.** Click anywhere / → / Space / PageDown advances; ← / PageUp
  goes back (presentation clickers work). Home/End jump. F = fullscreen, ? = notes.
- In-scene interactions (`scene.interact`) let the presenter click a world object to trigger an
  event ("crash the operator", "send another call") without leaving the scene.
- **Story** is a fixed sequence; **Playground** exposes the model's events as buttons with
  keyboard shortcuts, plus presets, plus an event history. The playground is a branching
  timeline: Undo/Redo (Z / Shift+Z, ← / →) and clickable history chips let people try
  something, go back, and try something else. Travelling back glides objects to the earlier
  state without replaying effects. Don't bind z, y, or the arrows to demo events. The playground must run the same model as
  the story, so edge cases the audience asks about can be shown live.
- The URL hash keeps the scene (`#4`, `#play`) so a refresh after an edit lands in the same place.

## Motion

The whole point: things **move and transform**; they do not snap or pop.

- **Retarget from where things are.** Every animation starts from the element's current rendered
  value (`Demo.tween`). Clicking mid-animation redirects motion smoothly; it never jumps back.
- **Curved trajectories.** Objects that travel follow arcs (`Demo.arc`, `Demo.fly`), with a slight
  rotation that settles. Messages are comets along drawn paths (`Demo.pulse`).
- **Breathe out, breathe in.** An object that goes away breathes (dims and brightens) for about a
  second, then dissolves into light (`breatheOut`). A replacement breathes into existence
  (`breatheIn`). Give replacements a distinct ID badge so identity changes are visible.
- **Morph state, don't replace it.** Persisted state (annotations, records, counters) lives in a
  `.statecard` whose contents morph token by token (`Demo.morph`): shared tokens glide, numbers
  roll, removed tokens dissolve. Values that move between places fly as badges and land in the
  exact token that then appears (`hold` + `fly`).
- **Code cards fly in, then magic-move.** The first code scene flies the card in from off-screen
  on an arc. Later excerpts morph token by token. Between code scenes the card shrinks into a
  corner tab and expands again; it leaves on an arc when no later scene needs it.
- **Choreograph only what just happened.** `render` diffs `ctx.prev` against `ctx.s`; effects run
  when `ctx.animated` (adjacent forward step or a playground event). Jumps and backward steps
  just glide everything to the target state.
- **Camera.** Named camera presets (`title`, `wide`, `code`, `finale`) glide between scenes; the
  `code` preset shifts and shrinks the world to make room for the code card.
- Respect `prefers-reduced-motion`: the engine collapses durations and skips particles.

## Code excerpts

- Real source when explaining real code: copy **verbatim tokens**, dedent, tabs → two spaces.
- Badge anything that is not a verbatim excerpt: `reflowed` (only line breaks changed),
  `proposed` (code that does not exist yet), `illustrative` (written for the demo).
- 1–7 lines, ≤ ~60 characters per line at the default size. If an excerpt needs more, it is the
  wrong excerpt — show the line that matters. Use `focus` to highlight the 1–3 tokens the scene
  is about, and `tag` for one plain sentence under the card.
- Record the source path and revision in the notes dialog; excerpts go stale when code changes.

## Honesty

- The notes dialog states what is modeled, what is simplified, where code comes from, and what
  is still under discussion. Label in-flight design decisions as such.
- Model the real decision order. If the playground can reach a state the real system cannot, fix
  the model.
