# 3D / WebGL format (three.js)

Use when the user wants a navigable 3D space (fly around, click to explode, title cards) rather
than scenes. The 2D engine does not apply; the look (Tokyo Night palette, fluid motion, honest
notes dialog) still does.

## Build: bundle, then inline into one HTML file

```
<demo>/src/main.js        # scene code (imports 'three', 'three/addons/...')
<demo>/src/index.html     # page chrome + <script type="module">/*__BUNDLE__*/</script>
<demo>/build.sh           # esbuild --bundle --minify --format=esm \
                          #   --alias:three/addons=three/examples/jsm -> out/bundle.js,
                          # then python replaces /*__BUNDLE__*/ (escape '</script' as '<\/script')
```

- Install locally: `npm i three@<ver> esbuild@<ver> --no-save --registry=https://registry.npmjs.org/ --userconfig=/dev/null`
  (the user's npmrc points at an authenticated feed that 401s for public packages). Name the
  packages explicitly and call `node_modules/.bin/esbuild`, not `npx`: a bare `npm i` from a
  package.json and `npx` both fall back to the user's npmrc and 401. In a standalone repo,
  commit a repo-local `.npmrc` with `registry=https://registry.npmjs.org/` and install with
  `npm install --userconfig ./.npmrc` so a plain clone builds.
- Result is ~600 KB and works from `file://`. Serve the parent dir with `scripts/serve.sh` so
  rebuilds live-reload the open tab.
- Expose tunables as named constants (`SENS`, `REPLAY_SLOW`, `REPLAY_PAUSE`) and mention them in
  the report; the user tunes feel by asking for "half that speed".

## Camera

Pick a scheme by scene type; for free-flying scenes use the `free-camera` skill.

**Map controls:** OrbitControls with `mouseButtons = { LEFT: PAN, MIDDLE: ROTATE, RIGHT: null }`,
`screenSpacePanning = false`, `enableZoom = false` plus an own wheel handler: wheel zooms toward
the point under the cursor, horizontal wheel / Shift+wheel slides sideways, WASD slides on the
ground plane relative to view, Q/E turn. Double-click flies to the object under the cursor.
- **Right-click never moves the view.** Reserve it for an action (e.g. "enter" an object).
- Iterate controls one change at a time and ask how it feels; the user tried orbit-drag and
  stationary look-drag before settling on map controls, and can't be verified headless.
- A `/` (or Ctrl+K) jump palette that fuzzy-finds every object by name and flies to it is a good
  navigation complement in dense scenes.

## Architecture that worked

- Renderer: ACES tone mapping, soft shadows, RoomEnvironment PMREM, FogExp2; EffectComposer with
  RenderPass -> OutlinePass (hover) -> UnrealBloomPass (emissive glow) -> OutputPass;
  CSS2DRenderer for 3D-anchored HTML tags. Shader grid floor with radial fade.
- Explodable items: `{ root, parts[{obj, home, out, card}], e, target }`; spring `e` toward
  `target` each frame and lerp parts home->out with easing. Part tags show only while their item
  is exploded; raycast returns the item unless it is already exploded, then the part.
- Esc backs out one level (part -> item -> overview), R resets.
- With a side info card open, shift the render via `camera.setViewOffset(...)` so the focused
  object is not hidden behind it; frame at ~1.7x item size, not tighter.
- Exploded pieces must move into free space: slide covers out sideways/backwards like a drawer
  rather than lifting them through objects stacked on top.
- Floating in-scene "document" cards (e.g. a config file's contents): canvas-texture Sprites with
  `toneMapped = false`, color ~0.8 and `depthTest = false`, else bloom blows them out to white.
  Set `material.needsUpdate` when swapping `map`.
- Expose `window.demo = { select, selectPart, replay, startWalk, walkGo, ... }` for automation.
- Info-card tables: one value per column with a header row (`Role · Machine · vCPU · Memory`),
  never "10/56Gi" packed into one cell; numeric columns right-aligned. When card children get
  side margins, size tables and buttons `width: calc(100% - 2*margin); box-sizing: border-box`
  (`width: 100%` plus margins overflows and clips the right edge), `table-layout: fixed` with
  ellipsis cells.

## Animations for presentation

- Creation beat shape (the user's spec): pan from the previous shot to the creator (~0.6 s),
  the object appears there while the camera holds (~0.5 s; 2.2 s + 0.9 s read as "slow to spawn
  in"), then it flies to its resting spot. During the flight, frame the whole path, not the
  object: goal look = path midpoint, goal offset = the step's usual offset direction stretched to
  `max(|off|, pathLength*1.45 + 3)`. A spring-smoothed camera chasing the object lags behind a
  fast flight and the object leaves the screen; the path framing kept it on screen every frame.
- Once an object lands, it stays landed: when a beat finishes, clear its steering override
  (e.g. `volAt = null`) and drop any per-step "starting state" that re-places it at the hand-off
  point, or it reappears mid-air and the camera snaps back to it.
- Tracked camera per step (the user's chosen style over static wide shots): glide from wherever
  the camera currently is straight onto the step's subject, keep it in frame while it moves
  (fixed offset for slow subjects, path framing for flights, see above), and hold on the last
  subject. Never pull out to a wide shot between or
  within steps: the wide-shot flyout read as jarring. Script each step as beats
  `{dur, subj(), run(k)}` driven by step time, set each step's starting state explicitly so
  Back/Next work, and stop directing the camera the moment the user drags/scrolls/flies.
  Flights for a single small object need ~3 s+; 1.6 s read as too fast.
- One camera director for the whole walkthrough. Every step, fixed shot or tracked beat, only
  writes a goal `{pos, look}`; a single per-frame controller moves the camera toward it with two
  cascaded critically damped springs per vector (goal → smoothed goal → camera, same stiffness
  `k`, look slightly stiffer), so velocity and acceleration stay continuous when the goal jumps.
  Mixing scripted flights (`flyTo`) with per-frame lerp tracking, switching the lerp gain
  mid-step, or retargeting to a new subject with a plain lerp all produced visible jerks
  (900+ °/s turns at step boundaries). Inside the walkthrough cancel scripted flights; keep
  `Ls`/reduced-motion as an instant snap; sync the free camera's target from the director.
- Timed replays: pace for an audience, not reality. Default slow (~30 s for a 15-node rollout)
  and insert a held beat with a status caption at causal milestones (first control plane Ready
  -> pause -> fan-out) even when the real system runs in parallel.
- Every toggle/visual mode must explain itself. A bare effect toggle ("show all beams") is
  confusing; prefer a **guided walkthrough**: one subject followed step by step, each step moves
  the camera, outlines the actor, animates the artifact moving between actors, and shows a card
  with Back/Next, progress dots, arrow keys/Enter, Esc to exit. Clicks in the scene are ignored
  while it runs; starting it cancels any replay.

## Verifying headless

- Launch Chromium with `--use-gl=angle --use-angle=swiftshader --enable-unsafe-swiftshader`.
- SwiftShader is slow and frame dt is clamped, so animations take far longer in wall time: wait
  ~12 s after load and ~7-11 s after each selection/step, or shots show mid-flight states.
- Blank scene from Edge shots: get the console error with `msedge.exe --headless=new
  --enable-logging=stderr --v=0 --dump-dom <url> 2>&1 | grep CONSOLE`. A classic cause:
  `Object.assign(mesh, { position })` throws (Object3D.position is read-only); use
  `mesh.position.copy(v)`.
- If `window.demo` is undefined, collect `pageerror` first: a `let`/`const` referenced by the
  frame loop before its declaration (TDZ) kills the module silently. Declare state the first
  `frame()` touches near the top.
- On WSL when Playwright Chromium has no WebGL, screenshot with Windows headless Edge (real
  GPU): `cd /mnt/c && "/mnt/c/Program Files (x86)/Microsoft/Edge/Application/msedge.exe"
  --headless=new --window-size=1600,900 --virtual-time-budget=9000
  --screenshot="$(wslpath -w out.png)" "http://localhost:<port>/page.html#<deeplink>"`. Wrap it
  in a `shoot.sh <outdir> view...` script in the demo dir. Add `?$RANDOM` to the URL (Edge
  caches, so shots silently repeat), and make deep links snap the camera to the flight's end
  pose (`camera.position.copy(flight.p1)`, `flight = null`): `--virtual-time-budget` does not
  advance rAF flights, so shots show the start of the flight and hide a too-close/too-far end.
- When the user reports blur/"lost resolution" or "too zoomed out", ask whether the browser
  is zoomed (Ctrl+0) before touching pixel ratio or framing; browser zoom caused both here.
- Prove occlusion/visibility claims with a metric, not a screenshot (faint lines don't show):
  a temporary hash handler raycasts camera→sample points along each line against opaque meshes
  (excluding the line's own endpoint mesh) and reports hidden counts via `#snap`; run it in
  every mode (upright, flat), before and after, then delete it.
- For framing/placement bugs, behind a `?dbg` query flag write positions, scales and
  quaternions as JSON into an on-page element and read it with Edge `--dump-dom | grep -o
  '<div id="snap">[^<]*'` (faster than reading a screenshot); then remove the debug code.
  Long animations need a bigger `--virtual-time-budget` (~20000) or shots catch mid-motion.
- If no available browser can create a WebGL context (`getContext('webgl')` is null), say
  plainly that the scene is unverified, open it for the user and ask for a screenshot or
  console errors; never report a 3D page as working from API checks alone.
- Animated walkthrough steps: SwiftShader runs several times slower than real time, so a fixed
  `wait_for_timeout` lands at random points in the choreography. Mark `window.__t0 =
  performance.now()` after `walkGo(n)`, wait with `wait_for_function('performance.now()-__t0>X')`,
  and log actual elapsed per shot; use a 960×540 viewport to speed renders. Capture the start,
  mid-flight and end of every changed step, not just one frame.
- Camera smoothness ("transitions are rocky") is measured, not eyeballed: frames and video
  can't show jerk. With Playwright, `await page.clock.install()` before `goto`, then advance a
  virtual 60 fps clock with integer ticks (`run_for(16)` / `run_for(17)`; float ticks are
  rejected), log `[now, step, camera.position, getWorldDirection()]` from a rAF hook, and press
  the walk keys between runs. Per step compute max acceleration (second difference / dt²), max
  turn rate (deg/s between direction vectors) and max speed; skip frames whose dt is off 16 ms
  (harness hiccups make fake spikes). Print a before→after table per step and report it; a
  480×280 viewport keeps a 9-step × 6 s run around a minute. Then ask the user how it feels.
  For "it flies off screen", log the moving object's `getWorldPosition().project(camera)` each
  frame on the same clock and count frames with `max(|x|,|y|) > 1` per step, before and after.
  Run only the steps under test (advance the others with one big `run_for`); a full 9-step
  visibility run exceeds a 7-minute foreground timeout, so launch long traces in the background.
- Drive states through `window.demo`, screenshot each, and inspect for label collisions, framing
  (both ends of a beam in frame), and parts clipping through neighbors.
