# Retrofitting the free camera into a bundled single-file page

For a self-contained HTML page whose three.js app is an esbuild-minified module and no source
tree exists (search for one first; rebuild from source when it does).

1. Copy the page to scratch as a backup. Locate the camera code by grepping byte offsets for
   `pointerdown`, `wheel`, `KeyW`, `requestPointerLock`, `keydown`, then print a few KB around
   them. Identify the camera variable, the flight variable/function (`ln(pos,target,dur)`-style),
   the pick/select function, the yaw/pitch sync helper and the per-frame camera update.
2. Cut the old input region as one contiguous slice (from the first input helper to the app's
   own key handler). Before cutting, check every minified name in it with a whole-word regex
   over the rest of the script, and fix the remaining references (render loop, keymap, the
   exported debug API such as `window.demo`).
3. Paste `assets/free-camera.js` in its place with `export` removed. Minified three.js lacks
   the `THREE` namespace: pass a shim `{Vector3: <minified Vector3>, Spherical: <small class with
   radius/phi/theta and setFromVector3 using atan2(x,z), acos(y/r)>, MathUtils: {clamp}}`.
   Seed `target` from the camera's current view direction.
4. Rewire: render loop calls `cam.update(dt)` when no flight runs; flights end by resetting
   `cam.target` along the new view; `busy: () => !!flight`; `onDragStart` cancels the flight;
   left-click calls the existing pick/select; right-click calls the existing back-out.
   Guided walkthroughs that own the arrow keys keep them (`keysEnabled` returns false for arrows
   while the walkthrough runs) and mark the user as driving the camera on any WASD/wheel input.
5. Replace the hint text and drop mode buttons; add `max-width` to the hint.
6. Check syntax by extracting the module to a `.mjs` and running `node --check`, then run the
   Playwright verification from SKILL.md against the page (use the installed chromium via
   `executable_path` with `--use-angle=swiftshader` for WebGL), screenshot, and re-open it.
