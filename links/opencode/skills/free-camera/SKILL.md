---
name: free-camera
description: Use when Ian says "free camera" or mentions camera controls in any 3D/three.js scene. Drop in his locked control scheme verbatim.
---

# Free camera

Ian's camera controls are locked (settled October 2026). Whenever he says "free camera", or
mentions camera/mouse controls for any 3D space, use exactly this scheme. Don't redesign, swap
buttons, add modifiers or "improve" it, and don't use OrbitControls or other library controls.

| Input | Does |
|-------|------|
| left-drag | look, Minecraft-style: the pointer locks to the centre while held and the mouse turns the head (WASD keeps moving) |
| right-drag or middle-drag | pan (camera and look-at point slide in the screen plane) |
| wheel | dolly forward/back along the view (gently) |
| arrows | look |
| + / − | zoom the lens (FOV) |
| W / S | fly forward/back exactly where the camera faces (looking down, W descends) |
| A / D | strafe left/right, level with the floor |
| Space / Shift | up / down |
| Ctrl | nothing (no speed or down modifier) |
| left-click | select (a press that moves ≤5px) |
| right-click | secondary action, e.g. enter (≤5px; a right-drag pans instead) |

There is no separate look mode or mode toggle: holding left is the Minecraft mode. The browser
context menu is suppressed on the canvas, and so is middle-click autoscroll.

## Use

1. Copy `assets/free-camera.js` into the project unchanged (e.g. `src/free-camera.js`).
2. Wire it:
   ```js
   import { createFreeCamera } from './free-camera.js';
   const cam = createFreeCamera(THREE, camera, renderer.domElement, {
     target: new THREE.Vector3(0, 0, 0),
     onClick: (ev) => select(pick(ev)),
     onRightClick: (ev) => enter(pick(ev)),
     onDragStart: () => { flight = null; },   // a drag cancels a scripted flight
     busy: () => !!flight,                    // wheel/keys pause during flights
     keysEnabled: () => !palette.open,
   });
   // render loop: cam.update(dt)
   ```
   Flights animate `camera.position` and `cam.target` together, then `camera.lookAt(cam.target)`.
   Selection zoom-reset sets `cam.fovWant`.
3. Put the controls in the page's hint line: `hold left to look · right-drag to slide · arrows look · WASD move ·
   Space Shift up/down · wheel forward/back · + − zoom`.

Hover tooltips: skip hover work while `cam.dragging` or `ev.buttons` is set.

Retrofitting a page that ships as one bundled/minified HTML file with no source tree: see
`references/retrofit-bundled-page.md`.

## Pitfalls

- Give the hint line a `max-width` so it wraps: one long line runs under a bottom dock and the
  newest controls are the part that gets hidden.
- Right-click must act on pointerup with the 5px threshold, not in `contextmenu` (which fires on
  press and would enter/select at the start of every pan); `contextmenu` only calls
  `preventDefault()`.
- With a bundler, pass `{ Vector3, Spherical, MathUtils }` instead of the `THREE` namespace;
  passing the namespace as a value pulls all of three.js into the bundle.
- Lock the pointer only once a left press has moved more than 5px, so a plain click still
  selects; read `movementX/Y` (clientX freezes while locked) and exit the lock on pointerup.
  Skip the first event after `pointerlockchange` (the warp to the centre) and drop single events
  over 250px (Chromium's sporadic spikes). Fix the drag mode (look or pan) when the drag starts
  instead of re-reading `ev.buttons` per event. Don't request `{ unadjustedMovement: true }`:
  in Edge on Windows the lock engages but no movement arrives.
- Shift is down, not "faster"; Ctrl does nothing (Ctrl+W/S/D would also close or hijack the tab).
- Speeds are constant: WASD `moveSpeed` units/s, wheel `wheelStep` per pixel (deltaY clamped to
  ±120), right/middle-drag `panStep` per pixel. Never scale them by distance to the look-at point, the
  content or anything else: movement then speeds up and crawls unpredictably. Set the three
  options once for the scene's scale.
- Keep this skill and the asset free of work project names (repo hygiene rules: git-etiquette).
- Verify headlessly before handing over: drive Playwright mouse/keyboard (left-drag, middle-drag,
  right-drag, wheel, W, +, arrows, click on a projected object, right-click) and read the camera's
  position, direction and fov after each step; wait for the intro flight to finish first or
  `busy()` swallows the input. Then re-open the page for Ian and ask him to try the drags, since
  only he can judge the feel. A screenshot checks the hint line and dock.
- Remove every old control path when switching (separate look modes, mode buttons and their keys,
  stale hint text): leftovers fight the free camera for the same events.

## Source of truth

Originally extracted from a three.js lab explorer.
If Ian changes the controls, update `assets/free-camera.js` and this table first, then
the projects.
