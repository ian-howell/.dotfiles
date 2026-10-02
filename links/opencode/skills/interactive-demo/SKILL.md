---
name: interactive-demo
description: Build polished, click-driven, animated browser demos that explain how a system, algorithm, or design works — Tokyo Night look, continuous morphing motion, code excerpts that fly in and magic-move, and a playground for edge cases. Use when the user asks for an interactive demo, animated explainer, visual walkthrough, or presentation of how something behaves; also for choosing a visual style for such a demo.
---

# Interactive demo

Produces a self-contained web page (HTML + CSS + JS, no build, no network) that tells a story in
scenes and lets people poke at edge cases in a playground. A reusable engine does the motion; each
demo supplies a model, scenes, world markup, and choreography.

Read `reference/style-guide.md` before writing anything — it is the locked-in look, voice, and
motion vocabulary. Study `examples/circuit-breaker/` for a complete, working demo.

## Layout of this skill

- `assets/engine.js`, `assets/engine.css` — the engine (motion primitives, morphing, effects,
  night sky, code card, story/playground runner). API is documented at the top of `engine.js`.
- `assets/template.html`, `assets/demo.js` — a blank demo: page contract + model/scenes/render stub.
- `examples/circuit-breaker/` — reference demo built only on the engine.
- `scripts/new-demo.sh` — scaffold a demo directory (copies the engine into it).
- `scripts/serve.sh` — serve a directory on localhost in the background.
- `scripts/verify.py` — browser smoke test with per-scene screenshots.

## Workflow

1. **Understand the subject.** Read the real source/design. Write down the decision order
   (the model) and the 6–10 story beats, one idea each. Resolve contradictions in the source
   material before encoding them; surface open design questions instead of guessing.
2. **Scaffold** into a stable location (default `/tmp/opencode/demos/<name>/`, or where the user
   says): `scripts/new-demo.sh <dir>` (or `--example circuit-breaker` to start from the example).
   Each demo owns its copy of the engine.
3. **Serve once, keep the URL stable:** `scripts/serve.sh /tmp/opencode/demos` (default port
   8765) and give the user `http://localhost:8765/<name>/` — a real URL, never a filesystem path.
   Always overwrite the same files so the user can just refresh; the hash keeps their scene.
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
   - **Snippets, cameras, spotlights, finale cards, playground events and presets.**
   - **Playground footer:** keep the template's two rows: actions/presets above, Undo/Redo and
     a horizontally scrollable event timeline below. The engine fits the stage to the footer's
     measured height; keep this when customizing the layout.
6. **Verify:** run `scripts/verify.py <url> --out <dir>` with a Python that has Playwright
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
- Do not autoplay. Do not add timers that advance scenes.
- Do not let text and code compete: if the code card crowds the world, use the `code` camera
  preset (or shrink the world further) rather than shrinking the code.
- Long code lines wrap or overflow; choose a shorter excerpt or reflow (and badge it).
- Changing only the URL hash in Playwright does not reload the page; call `reload()`.
- Keep work-specific demos out of the dotfiles; only generic engine/skill changes belong here.
