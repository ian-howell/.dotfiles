// interactive-demo scene: an alien desert at dusk. Tuned for the Tokyo Night palette.
// Two suns set behind layered dunes, two moons, a settlement with lit windows and a slow beacon.
// Seeded, so the scene is the same on every load. See references/scenes.md for the contract.
'use strict';
(() => {
  // Two suns set behind the far dunes and the stars come out above them. Positions are fractions
  // of the viewport. The canvas holds everything in front of the stars and is drawn on resize.
  const SCENE = {
    horizon: .815,
    sun: { x: .535, r: .04, sink: .25 }, // sink: how far below the far ridge its centre sits, in radii
    twin: { x: .579, y: .787, r: .0095 },
    moons: [
      { x: .05, y: .13, r: .019, phase: .55, dim: '#7f88b8', lit: '#e3e7ff' },
      { x: .955, y: .112, r: .009, phase: .9, dim: '#4f8a85', lit: '#c8f6ee' },
    ],
  };
  // Far to near. waves: cycles across the viewport; lift raises a dune toward the viewport's edges.
  const DUNES = [
    { seed: 11, base: .822, amp: .016, lift: 0, waves: [1.3, 2.9, 6.1], crest: '#3a2340', foot: '#2f1f39', rim: .55, mist: .28 },
    { seed: 23, base: .866, amp: .036, lift: .02, waves: [1.1, 2.4, 5.2], crest: '#2b1b33', foot: '#23172b', rim: .32, mist: .2 },
    { seed: 37, base: .912, amp: .045, lift: .045, waves: [.9, 2.1, 4.4], crest: '#211627', foot: '#1b1221', rim: .2, mist: .14 },
    { seed: 53, base: .97, amp: .05, lift: .085, waves: [.8, 1.7, 3.6], crest: '#1a111d', foot: '#140d17', rim: .12, mist: 0 },
  ];
  // A settlement on the far ridge, left of the suns: domes [x, radius] and towers [x, height, pod],
  // pod being the rounded top's half-width and half-height. Sizes are fractions of the height.
  const TOWN = {
    domes: [[.389, .0055], [.398, .0085], [.4095, .0125], [.4215, .0075], [.4305, .0105], [.4415, .0065], [.4505, .009]],
    towers: [[.4035, .034, [.0024, .0024]], [.4255, .03, [.0042, .008]], [.4372, .024, [.002, .002]], [.4465, .016, [.0036, .005]]],
  };
  // Lone outposts with one lit window: [dune, x, height of a mast with a warning light, or 0].
  const OUTPOSTS = [[1, .03, .02], [2, .612, 0], [1, .94, 0], [2, .962, .026]];

  const seeded = seed => () => {
    seed = (seed + 0x6d2b79f5) | 0;
    let t = Math.imul(seed ^ (seed >>> 15), 1 | seed);
    t = (t + Math.imul(t ^ (t >>> 7), 61 | t)) ^ t;
    return ((t ^ (t >>> 14)) >>> 0) / 4294967296;
  };
  const rgba = (hex, a) => `rgba(${[1, 3, 5].map(i => parseInt(hex.slice(i, i + 2), 16))},${a})`;
  // A radial glow squashed vertically by `squash`; stops: [[offset, colour]…].
  function glow(c, x, y, r, squash, stops) {
    const gr = c.createRadialGradient(0, 0, 0, 0, 0, r);
    for (const [o, col] of stops) gr.addColorStop(o, col);
    c.save();
    c.translate(x, y);
    c.scale(1, squash);
    c.fillStyle = gr;
    c.fillRect(-r, -r, 2 * r, 2 * r);
    c.restore();
  }
  // Each dune's ridge y(x) sums skewed sine waves: rounded crests, a gentle side and a steeper one.
  const RIDGES = DUNES.map(d => {
    const rnd = seeded(d.seed);
    const ws = d.waves.map((f, i) => ({ f, p: rnd() * 6.2832, a: (1 + i) ** -1.4, k: .25 + rnd() * .4 }));
    const sum = ws.reduce((s, v) => s + v.a, 0);
    return (x, w, h) => {
      const u = x / w;
      let s = 0;
      for (const v of ws) { const t = u * v.f * 6.2832 + v.p; s += v.a * Math.sin(t + v.k * Math.sin(t)); }
      return h * (d.base - d.amp * (.5 + .5 * s / sum) - d.lift * Math.abs(2 * u - 1) ** 1.7);
    };
  });

  function mount(cv) {
    const g = cv.getContext('2d');
    const base = document.createElement('canvas'), b = base.getContext('2d');
    const beacon = document.createElement('i');
    beacon.className = 'beacon';
    beacon.setAttribute('aria-hidden', 'true');
    cv.after(beacon);
    let w = 0, h = 0, dpr = 1, lights = [], queued = 0, resizing = 0;
    const ridge = (i, x) => RIDGES[i](x, w, h);

    // A light on dune `dune`, left out when a nearer dune hides it. o: { size, color, on: chance it is lit }.
    function light(x, y, rnd, dune, o = {}) {
      const c = o.color || (rnd() < .18 ? '#7dcfff' : rnd() < .3 ? '#ff9e64' : '#e0af68'), a = .55 + rnd() * .4, on = rnd() < (o.on ?? .8);
      const r = (.0009 + rnd() * .0005) * h * (o.size || 1);
      for (let j = dune + 1; j < DUNES.length; j += 1) if (ridge(j, x) < y + r) return;
      lights.push({ x, y, r, c, a, on });
    }
    function dome(x, y, r, color) {
      b.fillStyle = color;
      b.beginPath();
      b.ellipse(x, y, r, r * .72, 0, Math.PI, 2 * Math.PI);
      b.fill();
    }
    function moon(m) {
      const x = m.x * w, y = m.y * h, r = m.r * h;
      const dx = SCENE.sun.x * w - x, dy = SCENE.horizon * h - y, d = Math.hypot(dx, dy), lx = dx / d, ly = dy / d;
      glow(b, x, y, r * 2.6, 1, [[.35, rgba(m.lit, .035)], [1, rgba(m.lit, 0)]]);
      b.save();
      b.beginPath();
      b.arc(x, y, r, 0, 6.2832);
      b.fillStyle = '#181926';
      b.fill();
      b.clip();
      const shade = b.createLinearGradient(x - lx * r, y - ly * r, x + lx * r, y + ly * r);
      shade.addColorStop(0, rgba(m.dim, .55));
      shade.addColorStop(1, rgba(m.lit, .72));
      b.fillStyle = shade;
      b.fillRect(x - r, y - r, 2 * r, 2 * r);
      // The night side, a disc shifted away from the suns, leaves a crescent facing them.
      b.filter = `blur(${r * .14}px)`;
      b.beginPath();
      b.arc(x - lx * r * m.phase, y - ly * r * m.phase, r * 1.03, 0, 6.2832);
      b.fillStyle = '#181926';
      b.fill();
      b.restore();
    }
    function town(rnd) {
      const ink = '#291930';
      for (const [fx, fr] of TOWN.domes) {
        const x = fx * w, r = fr * h, y = ridge(0, x) + r * .3;
        dome(x, y, r, ink);
        const n = Math.max(1, Math.round(fr / .0042));
        for (let k = 0; k < n; k += 1) light(x + (k - (n - 1) / 2) * r * .5, y - r * (.28 + rnd() * .12), rnd, 0);
      }
      let tip = null;
      for (const [fx, fh, [rx, ry]] of TOWN.towers) {
        const x = fx * w, foot = ridge(0, x) + 3, top = foot - 3 - fh * h, mid = (foot + top) / 2;
        const bw = .0026 * h, tw = .001 * h, py = top - ry * h * .6;
        b.fillStyle = ink;
        b.beginPath();
        b.moveTo(x - bw, foot);
        b.quadraticCurveTo(x - tw, mid, x - tw, top);
        b.lineTo(x + tw, top);
        b.quadraticCurveTo(x + tw, mid, x + bw, foot);
        b.closePath();
        b.fill();
        b.beginPath();
        b.ellipse(x, py, rx * h, ry * h, 0, 0, 6.2832);
        b.fill();
        if (ry > .004) for (let k = 0; k < 2; k += 1) light(x, py + (k - .5) * ry * h * .8, rnd, 0);
        light(x, top + (foot - top) * .45, rnd, 0);
        if (!tip || py - ry * h < tip.y) tip = { x, y: py - ry * h };
      }
      beacon.style.transform = `translate(${tip.x}px, ${tip.y}px)`;
    }
    function outpost(x, mast, i, rnd) {
      const s = 1 + i * .25, r = .005 * h * s, y = ridge(i, x) + r * .3, ink = DUNES[i].foot;
      dome(x, y, r, ink);
      light(x + (rnd() - .5) * r * .5, y - r * .35, rnd, i, { size: s, color: '#e0af68', on: 1 });
      if (!mast) return;
      const mx = x + r * .9, top = y - mast * h;
      b.strokeStyle = ink;
      b.lineWidth = .0016 * h * s;
      b.lineCap = 'round';
      b.beginPath();
      b.moveTo(mx, y);
      b.lineTo(mx, top);
      b.stroke();
      light(mx, top, rnd, i, { size: s * .8, color: '#f7768e', on: 1 });
    }
    function drawBase() {
      b.setTransform(1, 0, 0, 1, 0, 0);
      b.clearRect(0, 0, base.width, base.height);
      b.setTransform(dpr, 0, 0, dpr, 0, 0);
      lights = [];
      const rnd = seeded(5);
      const sr = SCENE.sun.r * h, sx = SCENE.sun.x * w, sy = ridge(0, sx) + SCENE.sun.sink * sr;
      const tx = SCENE.twin.x * w, ty = SCENE.twin.y * h, tr = SCENE.twin.r * h;
      SCENE.moons.forEach(moon);
      // The sunset: a warm glow spread along the horizon, and the companion's cooler light.
      glow(b, sx, sy, w * .6, .42, [[0, 'rgba(255,158,100,.32)'], [.15, 'rgba(247,118,142,.16)'], [.45, 'rgba(187,154,247,.05)'], [1, 'rgba(187,154,247,0)']]);
      glow(b, sx, sy, w * .95, .08, [[0, 'rgba(255,158,100,.14)'], [1, 'rgba(255,158,100,0)']]);
      glow(b, tx, ty, h * .18, 1, [[0, 'rgba(125,207,255,.11)'], [1, 'rgba(125,207,255,0)']]);
      glow(b, sx, sy, sr * 1.25, 1, [[0, 'rgba(255,226,190,.95)'], [.5, 'rgba(255,190,138,.9)'], [.78, 'rgba(255,148,104,.8)'], [.9, 'rgba(255,130,100,.3)'], [1, 'rgba(255,120,100,0)']]);
      glow(b, tx, ty, tr * 3.4, 1, [[0, 'rgba(236,250,255,.9)'], [.22, 'rgba(196,240,255,.72)'], [.32, 'rgba(125,207,255,.2)'], [1, 'rgba(125,207,255,0)']]);
      DUNES.forEach((d, i) => {
        const crest = new Path2D(), body = new Path2D();
        let top = h;
        body.moveTo(-8, h + 8);
        for (let x = -8; x <= w + 12; x += 4) {
          const y = ridge(i, x);
          top = Math.min(top, y);
          crest.lineTo(x, y);
          body.lineTo(x, y);
        }
        body.lineTo(w + 12, h + 8);
        body.closePath();
        const fill = b.createLinearGradient(0, top, 0, Math.max(top + 1, (d.base + .02) * h));
        fill.addColorStop(0, d.crest);
        fill.addColorStop(1, d.foot);
        b.fillStyle = fill;
        b.fill(body);
        // The crest catches the light where it stands in front of the suns.
        const rim = b.createRadialGradient(sx, sy, 0, sx, sy, w * .42);
        rim.addColorStop(0, `rgba(255,180,130,${d.rim})`);
        rim.addColorStop(.35, `rgba(247,118,142,${d.rim * .32})`);
        rim.addColorStop(1, 'rgba(247,118,142,0)');
        b.save();
        b.clip(body);
        b.filter = 'blur(1.6px)';
        b.lineWidth = 3.2;
        b.strokeStyle = rim;
        b.stroke(crest);
        b.restore();
        if (i === 0) {
          glow(b, sx, sy, w * .14, .5, [[0, 'rgba(255,176,128,.3)'], [1, 'rgba(255,176,128,0)']]);
          town(rnd);
        }
        for (const [k, fx, mast] of OUTPOSTS) if (k === i) outpost(fx * w, mast, i, rnd);
        const next = DUNES[i + 1];
        if (next) {
          // Haze in the valley in front of this dune.
          const y0 = (next.base - next.amp - next.lift - .02) * h;
          const mist = b.createLinearGradient(0, y0, 0, next.base * h);
          mist.addColorStop(0, 'rgba(96,50,82,0)');
          mist.addColorStop(1, `rgba(96,50,82,${d.mist})`);
          b.fillStyle = mist;
          b.fillRect(0, y0, w, h - y0);
        }
      });
    }
    function paint() {
      queued = 0;
      g.setTransform(1, 0, 0, 1, 0, 0);
      g.clearRect(0, 0, cv.width, cv.height);
      g.drawImage(base, 0, 0);
      g.setTransform(dpr, 0, 0, dpr, 0, 0);
      for (const l of lights) {
        if (!l.on) continue;
        glow(g, l.x, l.y, l.r * 5, 1, [[0, rgba(l.c, l.a * .3)], [1, rgba(l.c, 0)]]);
        g.globalAlpha = l.a;
        g.fillStyle = l.c;
        g.beginPath();
        g.arc(l.x, l.y, l.r, 0, 6.2832);
        g.fill();
        g.globalAlpha = 1;
      }
    }
    function resize() {
      dpr = Math.min(devicePixelRatio || 1, 2);
      w = innerWidth; h = innerHeight;
      cv.width = base.width = Math.round(w * dpr);
      cv.height = base.height = Math.round(h * dpr);
      drawBase();
      paint();
    }
    addEventListener('resize', () => { cancelAnimationFrame(resizing); resizing = requestAnimationFrame(resize); });
    resize();
    return {
      flicker(d) {
        for (const l of lights) {
          if (Math.random() < .4) setTimeout(() => { l.on = !l.on; queued ||= requestAnimationFrame(paint); }, Math.random() * d);
        }
      },
    };
  }

  // No stars at the horizon, and fewer toward the suns.
  function stars(x, y, w, h) {
    const hz = SCENE.horizon * h, up = (hz - y) / (hz * .62);
    if (up <= 0) return 0;
    return Math.min(1, up) ** 2 * Math.min(1, Math.hypot((x - SCENE.sun.x * w) * .5, y - hz) / (h * .8));
  }

  window.DemoScene = { name: 'desert', mount, stars };
})();
