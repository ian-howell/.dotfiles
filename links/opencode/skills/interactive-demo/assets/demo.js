// DEMO TITLE — model → scenes → render. Read reference/style-guide.md before filling this in.
'use strict';
(() => {
  const { $, tween, pulse, morph, later, flash, whisper, particles, breatheIn, breatheOut, sky } = Demo;

  // ── Model: pure. state.last = { kind, code, text } feeds the playground subtitle and code card.
  const initial = () => ({ last: { kind: 'start', code: null, text: 'Nothing has happened yet.' } });
  function step(prev, ev) {
    const s = structuredClone(prev);
    switch (ev) {
      default: return s;
    }
  }

  // ── Code excerpts: verbatim tokens; note 'reflowed' | 'proposed' | 'illustrative' when not.
  const snips = {
    // key: { start: 1, lines: ['…'], lang: 'go', focus: ['token'], tag: 'What this line means' },
  };

  // ── Scenes: plain, descriptive titles. ev = events replayed from initial() to reach the scene.
  const scenes = [
    { key: 'title', kicker: 'Context', title: 'Subject', sub: 'What the viewer will understand by the end.', ev: [], cam: 'title' },
    { key: 'finale', kicker: 'Summary', title: 'Summary', sub: 'One sentence.', ev: [], cam: 'finale' },
  ];

  const cams = {
    title: { t: 'translate(0px, 48px) scale(0.92)' },
    wide: { t: 'translate(0px, 14px) scale(1)' },
    code: { t: 'translate(-300px, 24px) scale(0.76)' },
    finale: { t: 'translate(0px, 210px) scale(0.5)', o: '0.1' },
  };
  const spots = {};

  // ── Render: set every object to match ctx.s; choreograph only when ctx.animated.
  function render(ctx) {
    const { prev, s, intro, animated } = ctx;
    // Intro: draw furniture in. Then: keyed objects breathe in/out, values tween, state cards morph.
    return { codeDelay: 0 };
  }

  Demo.story({
    scenes, initial, step, render, cams, spots, snips, file: 'source.go', finaleKey: 'finale',
    play: {
      cam: 'code',
      intro: 'Change the world, then step the system.',
      events: [
        // { ev: 'step', key: 'r', label: '⟳ Step', icon: '⟳', primary: true, enabled: s => true },
      ],
      presets: {},
    },
  });
})();
