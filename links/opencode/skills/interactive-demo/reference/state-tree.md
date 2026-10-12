# State-tree explorer

A second demo format, beside the scene-based story. Instead of a fixed sequence, the audience
grows a **tree of states**: each node is a snapshot of the system, each edge is one thing that
happened, and any node can be branched from. Use it when the interesting part is "what would the
controller do if…" across many paths, not one narrative.

`examples/circuit-breaker-tree/index.html` is the reference implementation: start a new
explorer by copying it and replacing the model, the card renderer, the decision chart, and the
minimap state line. The tree, camera, minimap, and input sections are generic.

It is one self-contained HTML file (inline CSS and JS, DOM plus SVG plus a few 2D canvases; no
WebGL, no engine copy). The look follows `style-guide.md`: Tokyo Night, night sky, things move
and transform rather than pop.

## Model

- `initial()` returns the stable starting state. Everything is plain data; `structuredClone` it.
- **Two kinds of transition, both pure:**
  - **World changes** (`OPS`): each has `label(state)`, `can(state)`, `apply(state)`. They model
    what the outside world does — power, deletion, maintenance, config edits, *waiting*.
  - **The system's step** (`reconcile(state)`): returns `{ state, kind, reason, text, path }`.
    `kind` picks the colour, `reason` is the short result name, `text` one plain sentence of why,
    `path` the list of decision-chart nodes visited.
- **Toggles are latches.** A toggle offers only the move valid from the current state ("Power off"
  when on, "Power on" when off). Disable, don't hide, ops that cannot apply.
- Model the real decision order; if the tree can reach a state the real system cannot, fix the
  model.

## Tree

- **Nodes are immutable snapshots.** Never edit a node in place, and never stage or chain several
  changes on one node.
- **Every action creates exactly one child**: one world change, one wait, or one reconcile. Acting
  on an earlier node grows a sibling branch; that is the point of the format.
- **Waiting is a first-class action**, not a world-change button. It sits next to the system's
  step ("Wait 5 min" beside "Reconcile") with its own key (T beside R).
- Edges are labelled `change · <op label>`, `wait`, or `reconcile · <reason>`, coloured by the
  child's kind. The path from the root to the selection is lit; everything else dims.
- Layout: depth → x, leaves stacked → y, parents centred on their children. Nodes ease toward
  their layout target every frame, so the tree reflows smoothly when a branch is added.

## Preloaded story

- **Open on a prebuilt tree, not a lone root.** Seed the main story as a chain of actions from
  `initial()` (`STORY`), plus a few side branches (`BRANCHES`, from a node id) that show the
  interesting alternatives. → walks the story's first-child path, so a presenter can click
  through it and the audience can branch from any step.
- Build seeds with the same `act(from, action)` the buttons use, so the preload can never show a
  state the model cannot reach.

## Node card

The node *is* the object being explained, drawn as in a story demo, at full size:

- Left: the object (e.g. a Machine card holding its persisted annotation, the instance with its
  identity chip and health trace, the durable parts that survive). Its appearance changes with
  state — glow when healthy, dashed and breathing while terminating, empty dashed slot when absent,
  a ring that fills with elapsed grace.
- Small environment chips (flags that gate decisions), config steppers, and the world-change
  buttons sit **on the card itself**.
- Right: kicker (`start` / `world change` / `reconcile result`), the reason in the kind's colour,
  one sentence of why, a mini decision chart with this step's path lit, then the action row
  (Wait / Reconcile).

## Story and playground modes

- Open in **story mode**: controls (ops, steppers, Wait/Reconcile, branch note, New tree, action
  shortcuts) are hidden, so the page is a clean walkthrough of the preloaded tree with → / ←.
- A header toggle **Show controls (P)** switches to **playground mode** and fades the controls
  in (`body.play`, opacity + visibility transitions). Action keys only work in playground mode;
  navigation works in both. The help line crossfades between the two key sets.

## Step transition (morph, not slide)

Moving to a child — a new action, or → onto an existing child — plays the step on one card:

- The child card takes the parent's place on screen (the camera jumps by the layout offset, so
  nothing visibly moves) and starts painted with the **parent's** state and explanation.
- A ghost clone of the parent fades and slides back to the parent's place in the tree (behind
  every card), drawing the eye along the new edge.
- Every other card and edge label fades in at the same time. After the camera jump they sit in
  new screen positions, and showing them solid at once is jarring.
- The components **act out the step**: a call packet travels client → breaker → service and back
  in the result's colour, hit components flash. Only after that does the card repaint with the
  child's state, so the lever swings, rings fill, values flash, and the explanation swaps.
- To make that possible, cards are built once (`buildCard`) and painted in place (`paint(card,
  state, explanationNode, animate)`); CSS transitions (registered `@property` colours, transforms,
  dash offsets) carry the change. Never rebuild a card's DOM to show a new state.
- **Every visual state change must be smooth — nothing may blink.** Never swap content that
  changes with state (text, SVG path `d`, an animation's name/duration) in place: those cannot
  transition. Render every variant up front, stack them (`display: grid; grid-area: 1/1` for text,
  sibling `<g>`s for traces), keep their looping animations running, and let state classes only
  crossfade opacity. Pulses/alarms live on their own always-animating overlay layer whose opacity
  fades in and out — toggling `animation` itself snaps. Components that arrive or leave (a
  replacement instance) fade/scale/blur out while the new one fades in, and the leaving element is
  removed only after its transition ends. Check the selectors actually match the classes you emit.
- A new action/step finishes any running morph first; jumps elsewhere (clicks, minimap, ←, siblings)
  fly without a morph.

## Camera

- **Default zoom fills the screen with one node.** No dead space around the focus.
- **Glide, don't hop.** Moving to another node follows the same S-curve the edges use (leave
  horizontally, arrive horizontally) at a constant zoom; no zoom-out-then-in. Ease in-out,
  duration grows gently with distance.
- When a new node is created, the edge **draws with a glowing comet head** while the morph plays.
- Drag to pan and wheel to zoom (around the cursor) on the main view; both cancel a flight and
  finish any growing edge.
- **Drags must not stick.** Listen on the dragged element, not `window`; start only on the primary
  button, `preventDefault()` the press and `dragstart` (native text/image drags otherwise steal the
  gesture and the release never arrives), and `setPointerCapture`. End the drag on `pointerup`,
  `pointercancel`, `lostpointercapture`, window `blur`, and any `pointermove` with `buttons === 0`.
  The same applies to the minimap. Fit-all zooms out to the whole tree on purpose; Focus returns.
- Keys: ←/→ parent/child, ↑/↓ siblings, H root, F fit, Space focus, plus the action keys.

## Minimap

- A **full-width strip along the bottom**, not a corner thumbnail. The main view's focus is
  shifted up by its height.
- Tiles are readable, laid out like the tree: `#id · kind`, the reason in colour, and one compact
  state line (clock, instance identity and status, counters, a pending marker).
- It follows the selection and centres the whole tree vertically when it fits.
- **Drag to pan** (a press that moves more than a few pixels), wheel to scroll, a still click on
  a tile flies there. Manual panning holds until the next selection change.

## Verification

Drive it with the browser: run a short chain (change → wait → reconcile), branch from the root,
fit all, click a minimap tile, drag the minimap. Check the console for errors and look at the
screenshots for clipping and overlap.
