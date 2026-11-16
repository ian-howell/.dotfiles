// interactive-demo scene: a night-city skyline along the bottom fifth of the page. Tuned for the
// Tokyo Night palette. Seeded, so the skyline is the same on every load. See references/scenes.md.
'use strict';
(() => {
  // The skyline is laid out in a 1600×200 strip, scaled to cover the page width and the bottom 20%.
  const SW = 1600, SH = 200, BAND = .2;
  const seeded = seed => () => {
    seed = (seed + 0x6d2b79f5) | 0;
    let t = Math.imul(seed ^ (seed >>> 15), 1 | seed);
    t = (t + Math.imul(t ^ (t >>> 7), 61 | t)) ^ t;
    return ((t ^ (t >>> 14)) >>> 0) / 4294967296;
  };
  const rnd = seeded(7), blocks = [], lights = [];
  for (let x = -40; x < SW + 40;) {
    const bw = 34 + rnd() * 78, bh = 30 + rnd() ** 1.6 * 140;
    blocks.push({ x, y: SH - bh, w: bw, h: bh, c: rnd() < .5 ? '#14151e' : '#181926' });
    if (bh > 120 && rnd() < .5) blocks.push({ x: x + bw / 2 - 1, y: SH - bh - 18, w: 2, h: 18, c: '#181926' });
    for (let wy = SH - bh + 9; wy < SH - 6; wy += 11) {
      for (let wx = x + 6; wx < x + bw - 6; wx += 9) lights.push({ x: wx, y: wy, c: rnd() < .12 ? '#7dcfff' : '#e0af68', on: rnd() < .16 });
    }
    x += bw + rnd() * 6;
  }

  function mount(cv) {
    const g = cv.getContext('2d');
    let queued = 0, resizing = 0;
    function paint() {
      queued = 0;
      const dpr = Math.min(devicePixelRatio || 1, 2), w = innerWidth, h = innerHeight;
      if (cv.width !== Math.round(w * dpr) || cv.height !== Math.round(h * dpr)) { cv.width = Math.round(w * dpr); cv.height = Math.round(h * dpr); }
      g.setTransform(1, 0, 0, 1, 0, 0);
      g.clearRect(0, 0, cv.width, cv.height);
      const k = Math.max(w / SW, h * BAND / SH);
      g.setTransform(dpr * k, 0, 0, dpr * k, dpr * (w - SW * k) / 2, dpr * (h - SH * k));
      g.globalAlpha = .95;
      for (const b of blocks) { g.fillStyle = b.c; g.fillRect(b.x, b.y, b.w, b.h); }
      g.globalAlpha = .55;
      for (const l of lights) if (l.on) { g.fillStyle = l.c; g.fillRect(l.x, l.y, 3, 4); }
      const fog = g.createLinearGradient(0, 0, 0, SH);
      fog.addColorStop(0, 'rgba(26,27,38,0)');
      fog.addColorStop(1, 'rgba(22,22,30,.9)');
      g.fillStyle = fog;
      g.fillRect(-SW, 0, 3 * SW, SH);
      g.globalAlpha = 1;
    }
    addEventListener('resize', () => { cancelAnimationFrame(resizing); resizing = requestAnimationFrame(paint); });
    paint();
    return {
      flicker(d) {
        for (let i = 0; i < 70; i += 1) {
          const l = lights[(Math.random() * lights.length) | 0];
          setTimeout(() => { l.on = !l.on; queued ||= requestAnimationFrame(paint); }, Math.random() * d);
        }
      },
    };
  }

  // Stars behind the skyline are dimmed.
  const stars = (x, y, w, h) => (y > h * .78 ? .5 : 1);

  window.DemoScene = { name: 'city', mount, stars };
})();
