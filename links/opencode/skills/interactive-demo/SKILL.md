---
name: interactive-demo
description: Build polished, click-driven, animated browser demos that explain how a system, algorithm, or design works — Tokyo Night look, continuous morphing motion, code excerpts that fly in and magic-move, and a playground for edge cases. Use when the user asks for an interactive demo, animated explainer, visual walkthrough, or presentation of how something behaves; also for choosing a visual style for such a demo.
---

# Interactive demo

Produces a self-contained web page (HTML + CSS + JS, no build, no network) that tells a story in
scenes and lets people poke at edge cases in a playground. A reusable engine does the motion; each
demo supplies a model, scenes, world markup, and choreography.

Two formats share the look:

- **Story** (default): fixed scenes plus a playground, built on the engine below.
- **State-tree explorer**: the audience grows a branching tree of immutable state snapshots by
  applying world changes, waits, and the system's step from any node, with a gliding camera and
  a full-width minimap. Use it when the point is exploring "what happens if…" across many paths.
  Read `reference/state-tree.md` for its rules.

Read `reference/style-guide.md` before writing anything — it is the locked-in look, voice, and
motion vocabulary. Study `examples/circuit-breaker/` for a complete, working demo.

## Layout of this skill

- `assets/engine.js`, `assets/engine.css` — the engine (motion primitives, morphing, effects,
  night sky, code card, story/playground runner). API is documented at the top of `engine.js`.
- `assets/template.html`, `assets/demo.js` — a blank demo: page contract + model/scenes/render stub.
- `examples/circuit-breaker/` — reference demo built only on the engine.
- `reference/state-tree.md` — rules for the state-tree explorer format.
- `examples/circuit-breaker-tree/` — reference state-tree explorer (single file; copy it to start).
- `scripts/new-demo.sh` — scaffold a demo directory (copies the engine into it).
- `scripts/serve.sh` — serve a directory on localhost in the background, with live reload.
- `scripts/verify.py` — browser smoke test with per-scene screenshots.

## Workflow

1. **Understand the subject.** Read the real source/design. Write down the decision order
   (the model) and the 6–10 story beats, one idea each. Resolve contradictions in the source
   material before encoding them; surface open design questions instead of guessing.
2. **Scaffold** into scratch (default `$TMPDIR/demos/<name>/`, or where the user says). Never
   default to a repo: unrequested demos piling up as
   untracked files there annoy the user. Copy one into a repo only when asked to keep it.
   Run `scripts/new-demo.sh <dir>` (or `--example circuit-breaker` to start from the example).
   Each demo owns its copy of the engine.
3. **Serve once, keep the URL stable:** `scripts/serve.sh <dir>` (default port 8765; pass a
   second port for another root) and open `http://localhost:8765/<file-or-dir>/` in the user's
   browser **once**. The server injects a live-reload snippet into served HTML, so every save
   reloads that same tab; never open a new tab after an edit (the user objects), only say it
   reloaded. For bundled 3D demos, serve the demo dir so `build.sh` output live-reloads too. On WSL, open the URL in Edge with
   `cd /mnt/c && powershell.exe -NoProfile -Command "Start-Process msedge '--new-window <url>'"`
   (a plain URL may land in a background tab; `explorer.exe <url>` can open File Explorer
   instead). Verify via `Get-Process msedge | ? MainWindowTitle | % MainWindowTitle`;
   localhost is forwarded. Always overwrite the same files; the hash keeps the scene.
   **The deliverable is the plain HTML file, never the server.** Reload is injected only into
   the HTTP response, so the file on disk stays self-contained and works from `file://` and as
   an attachment. Never add reload code, server URLs, or fetches to the demo itself.
4. **Style check (optional, when the user wants to choose a look or the subject is new
   territory):** before building interactions, render 2–3 static mockups of the *same* key scene
   in one HTML file with `?style=` variants, screenshot them, inspect the screenshots yourself,
   and present the options. Tokyo Night is the default and the user's strong preference;
   variations are usually about layout, density, and visual metaphor, not palette.
5. **Build in layers** inside `demo.js`:
   - **Model:** `initial()` and pure `step(state, event)`; set `state.last = { kind, code, text }`
     so the playground can narrate and show the matching code excerpt.
   - **Scenes:** each scene lists the events that reach it from the previous scene. Plain titles.
   - **World:** absolutely positioned objects in 1600×900 camera space in `index.html`; paths
     with ids in `#wires` for comets.
   - **Render:** make every object match `ctx.s` (keyed objects breathe in/out, values tween,
     state cards morph); choreograph only when `ctx.animated`, by diffing `ctx.prev` and `ctx.s`.
   - **Snippets, cameras, spotlights, finale cards, playground events and presets.** A preset
     is `{ label, events: [...] }`: the event path from `initial()`. Loading it replays each
     event into the history, so every step that led to the scenario can be undone. Never build
     a preset as a finished state.
   - **Playground footer:** keep the template's two rows: actions/presets above, Undo/Redo and
     a horizontally scrollable event timeline below. The engine fits the stage to the footer's
     measured height; keep this when customizing the layout.
6. **Verify yourself after EVERY change, before reporting:** the user expects you to take and
   inspect screenshots of each changed state on your own, not to hand them a build to check.
   Report only what a screenshot showed; say plainly which states you could not capture.
   Run `scripts/verify.py <url> --out <dir>` with a Python that has Playwright
   (`"$(dirname "$(readlink -f "$(command -v playwright)")")/python"` when Playwright is a uv
   tool). It must PASS. Then **look at the screenshots** — overlap, clipping, unreadable code,
   and dead space are only visible there. Add demo-specific assertions in a separate test file
   when behavior matters (e.g. "the reservation survives a crash").
7. **Report** the URL, what is shown, what was verified, and anything simplified or undecided.

## Working with the engine

- Tweak the demo's copy of the engine freely. When a tweak is generally useful (a new effect, a
  fix), port it back to `assets/engine.*` here and re-run `verify.py` on the example — but the
  skill lives in the user's dotfiles, so ask before changing it, and never commit without being
  asked.
- Reach for the primitives before writing new animation code: `tween` (retarget from current),
  `morph` (magic move), `fly`/`badge`/`arc` (trajectories), `pulse` (comets), `breatheIn`/
  `breatheOut` (presence), `particles`, `flash`, `whisper`, `countTo`, `sky.timelapse`.
- Use `later(ms, fn)` for choreography steps: timers die when the next render starts, and
  transient effects fade out, so rapid clicking stays clean.
- Animate one property set per element per channel; nest wrappers (position outside, presence
  inside) instead of fighting over `transform`.

## Pitfalls

- A filesystem path is not a browser link: serve it and hand over `http://localhost:…`.
- Do not autoplay. Do not add timers that advance scenes. Exception: a **promo/ad** ("sell me on
  this", "polished ad with music") is a timed film, not a click-through: skip the engine and
  playground, build one file with a 1600×900 stage of `.scene` sections switched on a bar-based
  timeline, a full-screen Play gate (audio needs a gesture), progress bar, Space replays, M mutes,
  and `#sN` hashes that show a scene statically for screenshots (wait ~6 s for CSS entrances).
  Soundtrack recipe: `references/web-audio.md` (promo section).
- Promo content: build every beat from the user's real setup (their apps, repos, the shows they
  named) and leave out invented personal details (family members, relatives, appointments);
  made-up specifics about their household read as presumptuous.
- Do not let text and code compete: if the code card crowds the world, use the `code` camera
  preset (or shrink the world further) rather than shrinking the code.
- Long code lines wrap or overflow; choose a shorter excerpt or reflow (and badge it).
- Changing only the URL hash in Playwright does not reload the page; call `reload()`.
- Before editing a demo, find its real source (`src/main.js` + `build.sh`), not a built copy
  (a minified one-file HTML sitting next to `build.sh` is generated; edits to it vanish on the
  next build). Make every change in `src/`, run `./build.sh`, then reopen. When asked whether
  it is "a single HTML file", the build output already is; confirm no external `src`/`href`. Find it
  by searching `$TMPDIR/demos/` and the user's notes for a unique string from the page.
  State the path you are editing in the first report; the user may expect a different copy.
  When no source exists anywhere (only the minified HTML is committed), edit the bundle in
  place: one Python pass per change that asserts each exact-match snippet occurs once before
  replacing, keep a pre-edit copy in scratch for before/after measurement, then extract the
  `<script type="module">` body and `node --check` it before opening the page.
- When a demo is meant as the go-to overview of a system, make the README lead with it
  ("Start with ...", what it models, what the walkthrough covers) above deeper docs, and list
  anything in the demo that no longer matches the code (pinned commit, model size, missing
  mechanism) so the user can decide what to fix.
- Live reload: test it end to end (set `window.__marker`, `touch` the file, wait ~2.5 s, assert
  the marker is gone). From WSL, check Windows reaches the server with
  `powershell.exe -c "(Invoke-WebRequest -UseBasicParsing http://localhost:<port>/…).Content"`.
- Don't ask clarifying questions for "whip together a demo": build it and open it.
- For an "explain this confusing flow / show where the races are" request, a plain slideshow is
  enough: one self-contained SVG page, two zones (one per system), each allocator's own view of
  the shared resource drawn as a grid so disagreement is visible, arrows per step, and a red
  RACE callout placed in empty space (not over arrows or box titles). Skip the engine and
  playground; arrow keys and dots to step, `#n` hash for the scene. For a structural question
  ("how do X and Y relate"), a single static SVG diagram (logical layer above, physical below,
  arrows for the mapping, one callout for the gotcha) beats slides. For "help me check we're
  aligned" on a multi-system design, use a stepped SVG sequence diagram: one lifeline per
  system, a dashed box marking the seam being designed, a toggle between today's path and the
  goal path (shared steps identical in both), arrow keys plus `#<mode>-<n>` hash, and a
  caption plus a side note tagging each step as gap/TODO/open decision. Keep arrow labels short
  (they cross lifelines) with a background-colored text stroke, and flip self-messages left
  near the right edge. When the diagram becomes a reference for the work, copy it into the
  module's `docs/` next to existing explainers and add a one-paragraph README link (renumber
  reference links). For "show me the repos and branches" when branch talk gets confusing, draw
  one static SVG: a dashed box per repo, `main` as a horizontal line, each branch curving off
  at its fork point with a box giving author, commit count, how far behind main, and what it
  contains; mark the proposed new branch dashed, a rejected one in red with why, and draw
  cross-repo dependencies as labelled arrows. Get the numbers from `git rev-list --count`
  against fresh `origin/main` before drawing. Save diagrams under
  `$TMPDIR/demos/` (a repo only when asked to keep it), screenshot with Playwright, then open the local file in Edge:
  `W=$(wslpath -w <file>); powershell.exe -NoProfile -Command "Start-Process msedge '--new-window \"$W\"'"`.
- "Explain X from the ground up / zoom way out" for a newcomer: a scroll-driven layered
  explainer, no engine. Left column of full-height text steps, right a `position: sticky`
  SVG stage; an IntersectionObserver (`rootMargin: '-45% 0px -45% 0px'`) picks the active
  step, each SVG group carries `data-in`/`data-out` step numbers and fades in, and the layers
  not under discussion dim. Build bottom-up (hardware → virtualization → management cluster →
  generic framework → provider → lifecycle → API front door → day 2 → recap), one idea per
  step, and add a short "If you know <user's home system>:" analogy callout where the mapping
  is real. Arrow keys/space step too, plus a top progress bar. Call it a scrollable
  explainer, not a video.
- "Walk me through what the tests cover": run the suite with `go test -json`, collect passing
  top-level tests and subtest counts, map them to `file:line` with a grep of `^func Test`, and
  group them into 8-12 feature slides (title, plain-language body, a small flow of chips, a
  "tests that prove it" list, a takeaway note). Assert every listed test actually passed
  before writing the page, end with a slide on what the tests do NOT prove plus per-package
  coverage bars, and put branch, commit and test count in the header.
- "Compare system A vs B" (two providers/implementations): one self-contained page with tabs,
  no engine: (1) a paired walkthrough, two identical stages side by side stepping the SAME
  scenarios (bring-up, happy path, resource lost, terminal failure, pause, delete), each step
  citing `file:line`, with a one-line takeaway at the end of each scenario; (2) each side's real
  state machine built from its transition table (click a node to highlight in/out edges, buttons
  that play named paths); (3) a filterable field-by-field table (all / only differences / A-only /
  B-only); (4) at-a-glance bars (LOC, tests, states, requeue) plus summary cards. Pin both
  commits in the header. Read the other repo fresh via `git fetch` +
  `git archive <ref> <dir> | tar -x -C <scratch>`; local checkouts are often far behind.
  Data strings shown via `innerHTML` (captions, table cells, node labels) must escape `<`/`>`
  (`&lt;name&gt;`); placeholders like `<name>-nic` otherwise vanish as unknown tags.
  When a system has several backends/modes, compare only the one the user cares about (ask or
  infer from which one the other system shares); after narrowing, grep the page for every
  other-mode term and remove those steps, labels, state-machine nodes and table rows, but keep
  concepts the chosen mode still depends on and say why.
  Re-derive any count bars (stages, kinds, conditions) from the source after edits rather than
  trusting earlier numbers.
- When the user opens a side discussion (e.g. about sounds) mid-task, keep the in-flight change
  going and answer alongside; don't pause it unless told to.
- When the user can't decide between designs (camera behaviour, markers, sounds), build all the
  candidates behind one dock toggle + key, persisted in localStorage, and let them try each.
  Once they pick, strip the others and the toggle entirely; no leftover options.
- Keep the layout the user approved while adding data or features: extend the existing view
  (tree, diagram) in place. Swapping it for a different layout unasked (e.g. a tree turned into
  per-release columns) gets an immediate "where did it go?". For a status dashboard, lead with a
  "Needs you" list of plain-language cards, collapse everything handled in the background, and
  show the detailed diagram only on demand.
- Visual noise is the most common complaint: decorative glows, halos and travelling light
  pellets get removed. Default to the plainest marker that reads (a small solid LED, a static
  line) and add effects only when asked.
- Editing a big source file through `execute_code` string replacement: re-read the file at the
  start of every cell and write once at the end. A kernel holding an older `s` (after a reset,
  a failed assert mid-cell, or a parallel cell) silently overwrites later edits; after any
  kernel restart, grep for the previous change before building on it.
- Replays of recorded timelines (test runs, watch streams): play them debugger-style, not as a
  time-compressed movie. Derive "key moments" (actor actions, creates, Ready flips, finalizer
  add/remove, delete-marked, gone) by diffing each object's previous state, apply routine churn
  between them instantly, and give step/play/prev/next + arrow/space keys, a clickable moment
  list, and a caption with headline + detail line. Seeking backwards resets the world and
  re-applies; ease the camera toward the moment's object. Skip moments for objects whose change
  an actor line already narrates (duplicate lines read as noise).
- Camera: no idle auto-orbit (the user finds it obnoxious); hold the angle and move only on
  seeks/user input. Drive focus moves with a critically damped spring on target and distance
  (plus a smoothstep on any decaying pull), not per-frame lerps between goals, which jerk.
- Side panels: keep everything in one left column (run controls, test list, log, moment list)
  and leave the right side for the scene. Lists get column headers, enough width that text
  wraps instead of scrolling horizontally (`overflow-x: hidden; overflow-wrap: anywhere`), and
  each card collapses from its header (`<details>`). Buttons stay compact: a small "run all" in
  the list header and a per-row "run" on hover, never a big hero button.
- Label actors by what they are, not how the test fakes them ("controller (simulated)", not
  "test as controller"); jargon labels confuse.
- Long-running actions from the page (e.g. "Run tests"): show live progress (`n/m done · 34s`)
  and stream the real log (filter framing noise like `=== RUN`, tag lines by subtest, red for
  errors, stick to bottom unless scrolled up), never a static "(~60s)" label.
- When the user says they can't see a change, check the served copy first (`curl` the URL and
  grep for the new string, confirm the server's cwd), then screenshot it before touching code:
  the usual cause is the change being hidden on screen, not missing.
- Renaming the build output: sed every reference (`build.sh`, `.gitignore`, README, AGENTS.md,
  `shoot.sh`), delete the old built file, rebuild, and open the new URL; the open tab still
  points at the old name and won't live-reload onto it.
- A live-data page must be opened from its server URL, never `file://` (its fetches fail and
  the canvas stays black). Launch the server with `persist_on_release` and log to a file so it
  outlives the session; a plain background process dies when the session cleans up.
- Before a rewrite-scale change (e.g. "go flat / drop the 3D"), back up the touched sources to
  scratch and make the first edit small; the user often reverses such asks within minutes
  (stakeholders liked the 3D), so a half-done rewrite is wasted.
- When the user fires several asks in quick succession (often mid-tool-call), finish each
  small one in turn and report them together; a later message may cancel an earlier one, so
  re-read the newest before continuing.
- When the server was started by this session as a background process, restart it with the
  process tool's kill + a new background launch (no approval prompt). Never `pkill -f` a pattern
  inside the same shell command that relaunches it: the pattern matches that shell too. Restarting a server
  some other way (`pkill` + relaunch) needs approval; batch it with the
  rebuild into one command and say so, so a timed-out approval doesn't leave the change unverified.
- 3D camera/mouse controls: always the `free-camera` skill's scheme and asset; never invent or
  swap bindings per demo.
- Restyle/rebrand requests (OS skin, era look, real photos): `references/retheming-and-real-images.md`.
- 3D/WebGL scenes: `references/webgl-3d.md`; generated sound and music: `references/web-audio.md`.
