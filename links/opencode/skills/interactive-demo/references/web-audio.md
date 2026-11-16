# Music and sound effects (Web Audio, no files)

Generate everything with Web Audio in the page; no audio assets, works from `file://`.

## Wiring

- One shared `AudioContext`, created lazily. Browsers block audio until a user gesture: start
  on the first `pointerdown`/`keydown` (capture listener), fade master gain in over a few s.
- Dock toggle (`Music`, key `N`), persisted in `localStorage`. SFX share the context and obey
  the same toggle. Expose `MUSIC_VOLUME`, `SFX_VOLUME`, `BPM`, `PROGRESSION`, `ARP_PATTERN`,
  `ECHO_LEVEL` as named constants so the user can tune by name.
- Schedule music with a look-ahead loop (`setTimeout` 250 ms, schedule notes ~1 s ahead on
  `ctx.currentTime`), one bar at a time; never `setInterval` per note.
- Reverb: `ConvolverNode` with a generated decaying-noise impulse.

## The user's taste (iterate one layer at a time; they steer by ear)

- Background music: slow, dark, menacing and looming, but with a Portal-style synth melody.
  What landed: ~46 BPM; a low C-minor progression returning to a C pedal and landing on a
  tritone chord (unresolved); a sub drone of detuned saws (C0/C1) through a low resonant
  lowpass that swells over ~20 s; dark detuned-saw pads with a slowly breathing lowpass; round
  sine bass; rare low chimes. They first asked for hopeful/futuristic, then preferred darker:
  start dark and ask before brightening.
- Pace: slow. 92 BPM was "way too fast"; halve before going faster.
- Melody timbre ("exactly right"): two detuned saws an octave down through a resonant lowpass
  closing fast (~1500 → 350 Hz over 0.3 s), ~20 ms attack, ~0.75 s decay. Never square waves
  or bright sweeps (too sharp); triangle/sine alone is too dull.
- Intro: let the drone/pads play alone for ~4 s before the melody enters.
- Melody echo: exactly ONE repeat, placed halfway between a note and the next melody note
  (step/2, recomputed when the arp switches between 8ths and 16ths), at ~80% of the note's
  volume, panned opposite and slightly darker. Implement it as a second scheduled pluck, not a
  feedback `DelayNode`: delay lines give many repeats, and echoes landing on the next note's
  beat (or quiet ones) are inaudible.
- When the user changes one layer ("the melody"), touch only that layer; they often like the rest.
- Dramatic explode SFX (well received): bandpassed-noise riser (~0.35 s) → hit = sine boom
  sweeping 110 → 28 Hz + highpassed noise crack + inharmonic triangle partials (metal clang) +
  lowpassed noise rumble tail (~3 s). Pair with a reverse suck-in whoosh + low thud on close.
  Trigger the hit to land when the parts start moving.
- Music changes can't be verified headlessly beyond "no page errors"; say it is unheard and keep
  replies short so the user can steer the next tweak. When they ask to split work ("do this in
  2 steps"), ship the music change alone and wait.

## Impact SFX — what landed

- Render each effect once into an `OfflineAudioContext` buffer and cache it plus a reversed
  copy (`Float32Array.from(data).reverse()`); one `playSfx(name, render, len, pan, reverse)`
  helper serves all effects. Reverse playback on undo (un-flatten) was a hit.
- The keeper thud ("perfect"): sine 62 → 26 Hz over 0.5 s (8 ms attack, ~0.95 s decay),
  lowpassed (240 Hz) noise burst 0.25 s, two quiet triangle pings (190/270 Hz) at 30/60 ms. An
  earlier 95 → 38 Hz version was asked to be deeper.
- The accepted build-up: a looming rumble through the whole fall (cinematic, "Prometheus
  ship rolling toward you"): sine drones 32→52 and 48→78 Hz plus brown noise through a lowpass
  opening 90→420 Hz with slow AM churn; gain swells exponentially (quiet first half, steep at
  the end) and cuts hard at touchdown, where the thud takes over. Length = fall duration,
  derived from the animation constant, started when the falling object starts moving.
- Rejected: cartoon SFX (sproing, bouncing-screw tinks, clanks), a separate bending-metal
  groan/creak, and any aftermath after the landing (rolling part, late clunk). Drama builds
  INTO the impact; nothing plays after it.
- Accents layered over the thud stay far below it (~0.2 gain); "too loud" is the usual first note.
- Proposing 2–3 named sound options before building lets the user pick by ear quickly.

## Promo/ad soundtrack (catchy, not menacing)

- The dark ~46 BPM taste above is for explainer backgrounds. An ad wants upbeat: ~118 BPM,
  I–V–vi–IV in a major key, pumping 8th-note triangle bass, filtered square arp, kick + hat +
  bandpassed-noise snare from bar 3, a 2-bar resonant-saw hook once the product appears,
  highpassed-noise crashes on section starts. The user called this "a bop": keep it.
- Music plays the WHOLE film: drums from bar 2 to the end, hook from the first product scene,
  and a final stinger chord + crash instead of a fade or a silent outro. A "quiet" scene only
  lowers the bus (~0.6x) and softens bass/arp; never drop layers out (gaps read as broken).
- Drive scenes and music from one constant, `BAR = 240/BPM`, with scenes listed as
  `[id, startBar]` so cuts land on downbeats. Schedule bars with the look-ahead loop from
  Wiring (not all up front, which drifts and stacks thousands of nodes); scene switches use
  `setTimeout` at the same offsets, all cleared on replay.
- Act out the product in the mix: a short rising sine chime when the assistant "hears" a
  command, a noise whoosh on each cut, and duck the music bus (`setTargetAtTime`, ~0.45x)
  while each spoken line plays (`u.onend`/`onerror` restore it).
- Spoken lines: `speechSynthesis` with `u.lang='en-US'` AND a voice filtered to
  `/^en[-_]US/` by `lang` first, then preferring `Natural` (Aria/Jenny/Ava), then
  Zira/Samantha. Matching on name alone picked Edge's Italian "…Natural" voice. Call
  `getVoices()` at load (the list fills asynchronously). Cancel on replay and mute.

## Matching a reference track

- `uvx yt-dlp -f bestaudio --download-sections '*20-80' -o 'yt.%(ext)s' <url>`, then
  `ffmpeg -ac 1 -ar 22050` to wav and analyse with numpy/scipy (`uv run --with numpy --with scipy`):
  spectral centroid/rolloff, band energy, top FFT peaks per frame, median onset attack time.
- A full mix can't prove the waveform; say so, and translate what it does show (brightness,
  attack) into filter and envelope settings.
- Write analysis scripts to a file; inline heredoc commands containing `&` get rejected by the
  terminal tool as backgrounding.
