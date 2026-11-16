# Scenes (backdrops)

A scene is the ambient backdrop drawn in front of the star field: a skyline, a desert, a
coastline. Each lives in `assets/scenes/<name>.js` + `<name>.css`; `new-demo.sh --scene <name>`
copies them into the demo as `scene.js`/`scene.css` (default `city`).

## Catalog

| Scene | Look | Tuned for |
|-------|------|-----------|
| `city` | night-city skyline along the bottom fifth, scattered lit windows (default) | Tokyo Night |
| `desert` | alien desert at dusk: two setting suns, two moons, layered dunes, a lit settlement with a beacon | Tokyo Night |

Use the scene the user names; otherwise `city`. If the user describes a look none of these
match, write a new scene (below) rather than restyling an existing one inside a demo.

## Contract

`scene.js` loads before `engine.js` and sets:

```js
window.DemoScene = {
  name: 'desert',
  mount(canvas) { /* draw on #horizon, redraw on resize */ return { flicker(ms) {} }; },
  stars(x, y, w, h) { return 1; }, // optional: star visibility 0..1 at a viewport point
};
```

- `mount` gets the full-viewport `#horizon` canvas. Size it to `innerWidth/innerHeight` times
  `devicePixelRatio` (capped at 2) and redraw on resize, debounced to one animation frame.
- `flicker(ms)` makes the scene show passing time (lights toggling) over `ms`; the engine calls
  it from `Demo.sky.timelapse`. Repaint at most once per frame.
- `stars` lets the scene hide stars behind or near its features (horizon, a sun).
- `scene.css` sets the `body` background (the sky gradient) and styles any extra elements the
  scene adds (the desert's `.beacon`). Use colour literals or the palette tokens.
- Lay out in viewport fractions or a fixed strip scaled to cover; keep the busy part in the
  bottom ~20% so it sits below the stage.
- Seed all randomness (the files share a small `seeded()` helper) so a scene is identical on
  every load and in screenshots.
- No network, no images unless stored next to the demo; the demo must stay self-contained.
- Subtle: it is ambience, not content. Nothing animates on its own except slow, small details
  (a blinking beacon); motion belongs to `timelapse`.

Without `scene.js` or `#horizon` the engine shows only stars.

## Add a scene

1. Write `assets/scenes/<name>.{js,css}` to the contract. Ask before changing the skill (it lives
   in the user's dotfiles); never commit without being asked.
2. Scaffold the example with it: `new-demo.sh <scratch>/<name> --example circuit-breaker --scene <name>`,
   serve it, run `verify.py`, and look at the screenshots at 1600×900 and a tall/narrow size:
   nothing in the scene may sit behind the stage's text or be clipped awkwardly.
3. Add a catalog row above (name, one-line look, palette it was tuned for).

A scene first built inside one demo is adopted the same way: lift its drawing code into a scene
file, replacing hardcoded `#horizon`/engine hooks with `mount`/`flicker`/`stars`.
