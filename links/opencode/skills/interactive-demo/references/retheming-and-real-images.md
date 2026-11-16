# Re-theming a demo and using real images

Use when the user asks for a full re-skin (e.g. an OS/era skin such as Windows 7) or asks for
real photos instead of custom SVG. For a different backdrop only, pick or write a scene
(`references/scenes.md`); for different colours only, redefine the palette tokens.

## Re-theme without touching the engine

1. Scaffold a NEW directory from the existing demo (`new-demo.sh <dir> --example <name>`);
   never edit the original. A theme is a copy, not a mode.
2. Override only in the demo's `index.html` `<style>`: redefine `--sans/--mono/--fg/...`,
   then restyle the engine's page contract (`#code`, `.code-head`, `#codeBody`, `.fcard`,
   `.whisper`, `.flash`, `footer`, `#dots`, `.nav`, `#playDock`, `#tape`, `dialog`). Keep
   every contract id; the runner looks them up.
3. Drop `#sky`/`#horizon` and `scene.js` when a photo background replaces them (the engine no-ops without
   them); remove `sky.timelapse` calls and show passing time some other way (e.g. a clock).
4. Theme the OS chrome as page furniture:
   - **footer -> taskbar**: keep `#storyBar`/`#playBar` inside it; put `#modeStory/#modePlay`
     as taskbar buttons, `#notesBtn/#fsBtn` in a tray. Add a narrow-viewport media query
     that wraps the bar to its own row; verify.py's 390 px check clicks `#tape` and fails
     with "element is outside of the viewport" if the taskbar overflows.
   - **popups**: build message boxes / tray balloons as transient elements with `keep()` +
     `el.animate(...).finished.then(() => drop(el))`, appended to `#fxCam` (camera space) or
     fixed (screen space), so `nextEpoch()` cleans them on rapid clicking.
   - Extra UI (Start menu etc.) goes after `Demo.story(...)` using the returned api
     (`api.go(i)`, `api.setMode('play')`, `api.idx`, `api.mode`). Close-on-outside-click
     listeners must run in capture phase and `stopPropagation`, or the stage click also
     advances the scene.
5. When the model needs new display state (e.g. a simulated clock), add it to `initial()`/
   `step()` rather than tracking it in render, so undo/redo and presets stay exact.

## Fetching real images (Wikimedia Commons)

- Search with the API, not guessed filenames:
  `https://commons.wikimedia.org/w/api.php?action=query&generator=search&gsrsearch=<terms>&gsrnamespace=6&prop=imageinfo&iiprop=url|size&iiurlwidth=1920&format=json`
  (send a descriptive User-Agent). Adding `filetype:bitmap` to the search drops SVG/PDF.
- Download via `https://commons.wikimedia.org/wiki/Special:FilePath/<File_name>?width=<w>`;
  it resizes reliably. Direct `upload.wikimedia.org/.../thumb/...px-` URLs often return an
  HTML error page for non-standard widths. Always `file` each download — a 40 KB "jpg" is
  usually an HTML error page.
- Look at every candidate image with vision before using it; search titles lie ("Bliss
  location" photos were autumn vineyards; a generic "hill covered with green grass" was the
  Bliss look).
- Store images in `<demo>/img/` with relative paths so the folder stays self-contained, and
  credit the Commons file titles in the Notes dialog.
- Prefer photos with a plain background for objects that sit in small windows; use
  `object-fit: cover` + `object-position` to frame them, and CSS `filter` (sepia/hue-rotate/
  grayscale) to show state changes on the same photo.
