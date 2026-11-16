// interactive-demo engine — Tokyo Night motion toolkit for click-driven, state-driven explainers.
//
// Each demo gets its OWN COPY of this file. Tweak it freely for the demo at hand; if a change is
// generally useful, port it back to the skill's assets/engine.js.
//
// Page contract (see template.html): #sky, #skyline, #stage > #world > (#camera > #wires(#comets),
// #spot, #fxCam) + #hud(#kicker, #headline, #subline, #code, .fcard*, #finaleCtas, #hint);
// footer #storyBar(#back, #dots, #count, #next) and #playBar with two rows:
// .play-actions(#playDock, #preset), .history-row(#tape; runner adds Undo/Redo);
// header #modeStory, #modePlay, #notesBtn, #fsBtn; dialog #notes(#closeNotes).
//
// Layers: a pure model (initial, step) → scenes (event lists replayed from initial) → the demo's
// render(ctx), which diffs ctx.prev against ctx.s and choreographs only what just happened.
'use strict';
(() => {
  const $ = (s, r = document) => r.querySelector(s);
  const $$ = (s, r = document) => [...r.querySelectorAll(s)];
  const RM = matchMedia('(prefers-reduced-motion: reduce)');
  const calm = () => RM.matches;
  const EASE = 'cubic-bezier(.65,0,.35,1)';
  const SVGNS = 'http://www.w3.org/2000/svg';
  const W = 1600, H = 900;

  // ───────────── Epochs & transients ─────────────
  // Every render starts a new epoch. Timers scheduled with later() die with their epoch, and
  // transient effects (comets, sparks, flying badges) fade out, so rapid clicking never piles up.
  let epoch = 0;
  const transients = new Set();
  const later = (ms, fn) => { const e = epoch; setTimeout(() => { if (e === epoch) fn(); }, calm() ? 0 : ms); };
  const keep = el => { transients.add(el); return el; };
  const drop = el => { transients.delete(el); el.remove(); };
  function nextEpoch() {
    epoch += 1;
    for (const el of transients) {
      const from = getComputedStyle(el).opacity;
      el.getAnimations().forEach(a => a.pause());
      el.animate([{ opacity: from }, { opacity: 0 }], { duration: 240, fill: 'forwards' }).finished.then(() => el.remove(), () => el.remove());
    }
    transients.clear();
  }

  // ───────────── Core motion ─────────────
  // Animate from the element's CURRENT rendered values to `to`, so retargeting mid-flight never
  // jumps. One animation per (element, channel); use channels for disjoint property sets.
  // `via` adds intermediate keyframes (an object at offset .5, or an array with offsets).
  function tween(el, to, o = {}) {
    if (!el) return null;
    const ch = o.channel || 'main';
    el._tw = el._tw || {};
    const cs = getComputedStyle(el);
    const from = {};
    for (const k of Object.keys(to)) from[k] = cs[k];
    if (el._tw[ch]) el._tw[ch].cancel();
    Object.assign(el.style, from);
    const frames = [from];
    if (o.via && !calm()) frames.push(...(Array.isArray(o.via) ? o.via : [{ ...o.via, offset: o.via.offset ?? .5 }]));
    frames.push(to);
    const a = el.animate(frames, { duration: calm() ? 1 : (o.duration ?? 900), delay: calm() ? 0 : (o.delay || 0), easing: o.easing || EASE, fill: 'both' });
    el._tw[ch] = a;
    a.finished.then(() => {
      if (el._tw[ch] !== a) return;
      Object.assign(el.style, to);
      a.cancel();
      delete el._tw[ch];
    }, () => {});
    return a;
  }

  // Center/size of `el` in `layer`'s local (unscaled) coordinates, whatever transforms are in flight.
  function localPoint(el, layer = $('#camera')) {
    const r = el.getBoundingClientRect(), L = layer.getBoundingClientRect();
    const k = L.width / layer.offsetWidth || 1;
    return { x: (r.left + r.width / 2 - L.left) / k, y: (r.top + r.height / 2 - L.top) / k, w: r.width / k, h: r.height / k };
  }

  // Quadratic-bezier keyframes from p0 to p1, lifted by `lift`. `extra(t)` appends transforms.
  function arc(p0, p1, lift, n = 28, extra = () => '') {
    const cx = (p0.x + p1.x) / 2, cy = Math.min(p0.y, p1.y) - lift;
    const out = [];
    for (let i = 0; i <= n; i += 1) {
      const t = i / n, u = 1 - t;
      const x = u * u * p0.x + 2 * u * t * cx + t * t * p1.x, y = u * u * p0.y + 2 * u * t * cy + t * t * p1.y;
      out.push({ transform: `translate(${x}px, ${y}px) ${extra(t)}`, offset: t });
    }
    return out;
  }

  function lcs(a, b) {
    const n = a.length, m = b.length, dp = Array.from({ length: n + 1 }, () => new Uint16Array(m + 1));
    for (let i = n - 1; i >= 0; i -= 1) for (let j = m - 1; j >= 0; j -= 1) dp[i][j] = a[i] === b[j] ? dp[i + 1][j + 1] + 1 : Math.max(dp[i + 1][j], dp[i][j + 1]);
    const out = []; let i = 0, j = 0;
    while (i < n && j < m) { if (a[i] === b[j]) { out.push([i, j]); i += 1; j += 1; } else if (dp[i + 1][j] >= dp[i][j + 1]) i += 1; else j += 1; }
    return out;
  }

  // "Magic move". lines = [[token…]…], token = { t, c?, k?, color?, ws?, nm? }.
  //   t: text · c: classes · k: match key (default t) · ws: plain whitespace · nm: never match.
  // Shared tokens (LCS, order-preserving) glide to new positions; the rest dissolve out/condense in.
  // Tokens with class `roll` exit upward and enter from below (numbers). o.hold(tk) → token starts
  // invisible and is returned in `held` so a choreography can deliver it (e.g. a flying badge).
  function morph(box, lines, o = {}) {
    const sig = JSON.stringify(lines.map(l => l.map(t => [t.t, t.c, t.color])));
    if (box._sig === sig && !box._held && !o.force) return { held: [], same: true };
    box._sig = sig;
    const animate = o.animate !== false && !calm() && box.getClientRects().length > 0;
    const dur = o.duration || 820;
    const host = box.querySelector(':scope > .mm-lines');
    let ghosts = box.querySelector(':scope > .mm-ghosts');
    if (!ghosts) { ghosts = document.createElement('div'); ghosts.className = 'mm-ghosts'; box.append(ghosts); }
    const k = animate ? (box.getBoundingClientRect().width / box.offsetWidth) || 1 : 1;
    const old = animate && host ? $$('.tok', host).map(el => {
      const cs = getComputedStyle(el);
      return { el, key: el.dataset.k, nm: !!el.dataset.nm, r: el.getBoundingClientRect(), color: cs.color, op: +cs.opacity, cls: el.className, text: el.textContent, style: el.getAttribute('style') };
    }) : [];
    const wrap = document.createElement('div');
    wrap.className = 'mm-lines';
    const fresh = [];
    for (const line of lines) {
      const row = document.createElement('div');
      row.className = 'mm-line';
      if (!line.length) row.append('\u200b');
      for (const tk of line) {
        if (tk.ws) { row.append(tk.t); continue; }
        const sp = document.createElement('span');
        sp.className = `tok ${tk.c || ''}`;
        sp.textContent = tk.t;
        sp.dataset.k = tk.k ?? tk.t;
        if (tk.nm) sp.dataset.nm = '1';
        if (tk.color) sp.style.color = tk.color;
        row.append(sp);
        fresh.push({ el: sp, key: sp.dataset.k, nm: !!tk.nm, tk });
      }
      wrap.append(row);
    }
    if (host) host.replaceWith(wrap); else box.insertBefore(wrap, ghosts);
    const held = fresh.filter(f => o.hold && o.hold(f.tk)).map(f => f.el);
    held.forEach(el => { el.style.opacity = '0'; });
    box._held = held.length > 0;
    if (!animate) return { held };

    const B = box.getBoundingClientRect();
    const ok = key => o.matchAll || /[\w"']/.test(key) || key.length > 1;
    const A = old.filter(t => !t.nm && ok(t.key));
    const N = fresh.filter(t => !t.nm && ok(t.key) && !held.includes(t.el));
    const rects = N.map(t => t.el.getBoundingClientRect());
    const used = new Set(), placed = new Set();
    lcs(A.map(t => t.key), N.map(t => t.key)).forEach(([i, j], n) => {
      const a = A[i], b = N[j], r = rects[j];
      used.add(a); placed.add(b);
      const dx = (a.r.left - r.left) / k, dy = (a.r.top - r.top) / k;
      const color = getComputedStyle(b.el).color;
      if (Math.abs(dx) < .5 && Math.abs(dy) < .5 && a.color === color && a.op > .99) return;
      b.el.animate([
        { transform: `translate(${dx}px, ${dy}px)`, color: a.color, opacity: Math.max(a.op, .25) },
        { transform: 'translate(0px, 0px)', color, opacity: 1 },
      ], { duration: dur, delay: Math.min(n * 7, 160), easing: EASE, fill: 'backwards' });
    });
    let q = 0;
    for (const f of fresh) {
      if (placed.has(f) || held.includes(f.el)) continue;
      const roll = f.el.classList.contains('roll');
      f.el.animate([
        { opacity: 0, transform: `translateY(${roll ? 20 : 10}px)`, filter: 'blur(6px)' },
        { opacity: 1, transform: 'translateY(0px)', filter: 'blur(0px)' },
      ], { duration: dur * .8, delay: dur * .3 + (o.stagger ?? 14) * q, easing: 'cubic-bezier(.2,.7,.2,1)', fill: 'backwards' });
      q += 1;
    }
    const gx = B.left + box.clientLeft * k, gy = B.top + box.clientTop * k;
    for (const a of old) {
      if (used.has(a) || a.op < .02) continue;
      const g = document.createElement('span');
      g.className = `${a.cls} ghost`;
      g.textContent = a.text;
      if (a.style) g.setAttribute('style', a.style);
      Object.assign(g.style, { left: `${(a.r.left - gx) / k}px`, top: `${(a.r.top - gy) / k}px`, color: a.color, opacity: '', transform: '' });
      ghosts.append(g);
      const roll = a.cls.includes('roll');
      g.animate([
        { opacity: a.op, transform: 'translateY(0px)', filter: 'blur(0px)' },
        { opacity: 0, transform: `translateY(${roll ? -20 : -10}px)`, filter: 'blur(6px)' },
      ], { duration: dur * .55, easing: 'cubic-bezier(.4,0,.6,1)', fill: 'forwards' }).finished.then(() => g.remove(), () => g.remove());
    }
    return { held };
  }

  const words = text => [String(text).split(/(\s+)/).filter(Boolean).map(t => (/^\s+$/.test(t) ? { t, ws: true } : { t }))];

  // ───────────── Code tokens ─────────────
  const KW = {
    go: new Set(['if', 'else', 'return', 'func', 'for', 'range', 'var', 'const', 'type', 'struct', 'defer', 'go', 'switch', 'case', 'default', 'break', 'continue', 'select', 'chan', 'map', 'package', 'import']),
    js: new Set(['if', 'else', 'return', 'function', 'for', 'of', 'in', 'const', 'let', 'var', 'class', 'new', 'await', 'async', 'switch', 'case', 'default', 'break', 'continue', 'throw', 'try', 'catch', 'import', 'export', 'from']),
  };
  const CONSTS = new Set(['nil', 'null', 'undefined', 'true', 'false', 'None', 'True', 'False']);
  function codeTokens(line, lang = 'go', pkgs = new Set()) {
    const kw = KW[lang] || KW.go;
    const out = [];
    const re = /(\s+)|("(?:[^"\\]|\\.)*"|'(?:[^'\\]|\\.)*'|`[^`]*`)|(\/\/.*$|#.*$)|(\d+(?:\.\d+)?)|([A-Za-z_]\w*)|(:=|==|!=|===|!==|\|\||&&|\+\+|--|<=|>=|=>|->)|([^\s\w])/g;
    let m;
    while ((m = re.exec(line))) {
      const t = m[0];
      if (m[1]) out.push({ t, ws: true });
      else if (m[2]) out.push({ t, c: 's' });
      else if (m[3]) out.push({ t, c: 'cm' });
      else if (m[4]) out.push({ t, c: 'n' });
      else if (m[5]) {
        const before = line.slice(0, m.index), after = line.slice(re.lastIndex);
        let c = 'id';
        if (kw.has(t)) c = 'kw';
        else if (CONSTS.has(t)) c = 'k';
        else if (pkgs.has(t) && after.startsWith('.')) c = 'pkg';
        else if (after.startsWith('(')) c = 'fn';
        else if (before.endsWith('.')) c = 'prop';
        else if (/^[A-Z]/.test(t)) c = 'ty';
        out.push({ t, c });
      } else if (m[6]) out.push({ t, c: 'op' });
      else out.push({ t, c: /[{}()[\]]/.test(t) ? 'br' : 'p' });
    }
    return out;
  }
  // snip = { start, lines: [...] (tabs ok), lang?, pkgs?: [...], file?, note?: 'reflowed'|'proposed'|'illustrative', focus?: [...], tag? }
  const codeLines = snip => snip.lines.map((raw, i) => [
    { t: String(snip.start + i), c: 'ln', nm: true, k: `ln${Math.random()}` },
    ...codeTokens(raw.replace(/\t/g, '  '), snip.lang, new Set(snip.pkgs || [])),
  ]);

  // ───────────── Effects (in #fxCam / #comets, camera coordinates) ─────────────
  // A comet travelling along an SVG path. o: { color, dur, delay, reverse, carry: element riding the head }.
  function pulse(pathOrId, o = {}) {
    const path = typeof pathOrId === 'string' ? document.getElementById(pathOrId) : pathOrId;
    const L = path.getTotalLength();
    const color = o.color || '#7aa2f7', dur = o.dur || 900, delay = o.delay || 0;
    const tail = keep(path.cloneNode());
    tail.removeAttribute('id');
    tail.setAttribute('class', 'comet');
    tail.setAttribute('pathLength', '100');
    tail.style.stroke = color; tail.style.color = color;
    const head = keep(document.createElementNS(SVGNS, 'circle'));
    head.setAttribute('r', String(o.r || 5.5));
    head.setAttribute('class', 'comet-head');
    head.style.fill = color; head.style.color = color;
    $('#comets').append(tail, head);
    const pts = [];
    for (let i = 0; i <= 36; i += 1) {
      const p = path.getPointAtLength(L * (o.reverse ? 1 - i / 36 : i / 36));
      pts.push({ transform: `translate(${p.x}px, ${p.y}px)`, offset: i / 36 });
    }
    const timing = { duration: calm() ? 1 : dur, delay: calm() ? 0 : delay, easing: o.easing || 'cubic-bezier(.45,0,.3,1)', fill: 'both' };
    tail.animate(o.reverse ? [{ strokeDashoffset: -100 }, { strokeDashoffset: 0 }] : [{ strokeDashoffset: 18 }, { strokeDashoffset: -82 }], timing);
    head.animate(pts, timing);
    if (o.carry) {
      const c = keep(o.carry);
      $('#fxCam').append(c);
      const w = c.offsetWidth, h = c.offsetHeight;
      c.animate(pts.map(f => ({ ...f, transform: `${f.transform} translate(${-w / 2}px, ${-h / 2 - 26}px)` })), timing);
      setTimeout(() => c.isConnected && c.animate([{ opacity: 1 }, { opacity: 0 }], { duration: 300, fill: 'forwards' }), calm() ? 0 : delay + dur);
    }
    const end = calm() ? 0 : delay + dur;
    setTimeout(() => [tail, head].forEach(el => el.isConnected && el.animate([{ opacity: 1 }, { opacity: 0 }], { duration: 380, fill: 'forwards' })), end);
    setTimeout(() => [tail, head, o.carry].forEach(el => el && drop(el)), end + 450);
  }

  // A pill badge (ID, token, message) suitable for flying between places.
  function badge(text, color = '#bb9af7', size = 19) {
    const c = document.createElement('span');
    c.className = 'chip fly';
    c.style.color = color;
    c.style.fontSize = `${size}px`;
    c.textContent = text;
    return c;
  }

  // Fly an element along an arc between two camera points. o: { dur, delay, lift, s0, s1, spin, fadeOut, land() }.
  function fly(el, from, to, o = {}) {
    const c = keep(el);
    $('#fxCam').append(c);
    const w = c.offsetWidth, h = c.offsetHeight;
    const s0 = o.s0 ?? 1, s1 = o.s1 ?? 1;
    const frames = arc({ x: from.x - w / 2, y: from.y - h / 2 }, { x: to.x - w / 2, y: to.y - h / 2 }, o.lift ?? 120, 30, t => `scale(${s0 + (s1 - s0) * t}) rotate(${Math.sin(t * Math.PI) * (o.spin ?? -6)}deg)`);
    frames[0].opacity = 0; frames[3].opacity = 1;
    frames[frames.length - 1].opacity = o.fadeOut ? 0 : 1;
    c.animate(frames, { duration: calm() ? 1 : (o.dur || 1100), delay: calm() ? 0 : (o.delay || 0), easing: 'cubic-bezier(.45,0,.25,1)', fill: 'both' });
    later((o.delay || 0) + (o.dur || 1100), () => { o.land?.(); drop(c); });
    return c;
  }

  // Sparks bursting out of a point/rect, or converging into a point (o.inward).
  function particles(center, o = {}) {
    if (calm()) return;
    const n = o.n || 36, spread = o.spread || 180, dur = o.dur || 1400;
    for (let i = 0; i < n; i += 1) {
      const color = o.colors ? o.colors[i % o.colors.length] : (o.color || '#bb9af7');
      const p = keep(document.createElement('i'));
      p.className = 'spark';
      const sz = 2 + Math.random() * (o.size || 4);
      Object.assign(p.style, { width: `${sz}px`, height: `${sz}px`, marginLeft: `${-sz / 2}px`, marginTop: `${-sz / 2}px`, background: color, boxShadow: `0 0 ${sz * 3}px ${color}` });
      $('#fxCam').append(p);
      const sx = o.rect ? o.rect.x + (Math.random() - .5) * o.rect.w : center.x;
      const sy = o.rect ? o.rect.y + (Math.random() - .5) * o.rect.h : center.y;
      const ang = Math.random() * Math.PI * 2, dist = spread * (.3 + Math.random() * .7);
      const ex = sx + Math.cos(ang) * dist, ey = sy + Math.sin(ang) * dist * .75 - (o.rise || 0) * (.4 + Math.random());
      const [a, b] = o.inward ? [[ex, ey], [center.x, center.y]] : [[sx, sy], [ex, ey]];
      p.animate([
        { transform: `translate(${a[0]}px, ${a[1]}px) scale(1)`, opacity: o.inward ? 0 : 1 },
        { opacity: 1, offset: .3 },
        { transform: `translate(${b[0]}px, ${b[1]}px) scale(${o.inward ? 1 : .2})`, opacity: o.inward ? .9 : 0 },
      ], { duration: dur * (.7 + Math.random() * .5), delay: Math.random() * dur * .15 + (o.delay || 0), easing: o.inward ? 'cubic-bezier(.6,0,.35,1)' : 'cubic-bezier(.1,.6,.3,1)', fill: 'both' })
        .finished.then(() => drop(p), () => {});
    }
  }

  // A short floating label that rises and fades.
  function whisper(text, x, y, o = {}) {
    const w = keep(document.createElement('div'));
    w.className = 'whisper';
    w.textContent = text;
    w.style.color = o.color || '#a9b1d6';
    $('#fxCam').append(w);
    const half = w.offsetWidth / 2;
    w.animate([
      { transform: `translate(${x - half}px, ${y + 12}px)`, opacity: 0, filter: 'blur(4px)' },
      { transform: `translate(${x - half}px, ${y}px)`, opacity: 1, filter: 'blur(0px)', offset: .18 },
      { transform: `translate(${x - half}px, ${y - 4}px)`, opacity: 1, offset: .75 },
      { transform: `translate(${x - half}px, ${y - 18}px)`, opacity: 0, filter: 'blur(3px)' },
    ], { duration: calm() ? 1 : (o.dur || 1700), delay: calm() ? 0 : (o.delay || 0), easing: 'ease-out', fill: 'both' })
      .finished.then(() => drop(w), () => {});
  }

  function flash(x, y, color = '#bb9af7', delay = 0) {
    if (calm()) return;
    const f = keep(document.createElement('div'));
    f.className = 'flash';
    f.style.color = color;
    $('#fxCam').append(f);
    f.animate([{ transform: `translate(${x}px, ${y}px) scale(.3)`, opacity: .9 }, { transform: `translate(${x}px, ${y}px) scale(2.6)`, opacity: 0 }], { duration: 900, delay, easing: 'cubic-bezier(.2,.7,.3,1)', fill: 'both' })
      .finished.then(() => drop(f), () => {});
  }

  // ───────────── Presence: breathe in / breathe out ─────────────
  // Give the element an inner `body` that starts at { opacity: 0; transform: scale(.94); filter: blur(8px) }.
  function breatheIn(body, delay = 0) {
    const el = body.parentElement;
    if (el) { el._leave = (el._leave || 0) + 1; delete el.dataset.leaving; }
    return tween(body, { opacity: '1', transform: 'scale(1)', filter: 'blur(0px)' }, {
      duration: 1900, delay, easing: 'linear',
      via: [{ opacity: '.55', transform: 'scale(.97)', filter: 'blur(3px)', offset: .18 }, { opacity: '.12', offset: .36 }, { opacity: '.8', offset: .55 }, { opacity: '.38', offset: .7 }, { opacity: '.95', offset: .86 }],
    });
  }
  // Breathe for about a second, then dissolve. Removes `el` afterwards unless it is revived first.
  function breatheOut(el, body, delay = 0, onDissolve) {
    el.dataset.leaving = '1';
    const token = el._leave = (el._leave || 0) + 1;
    const run = () => {
      if (el._leave !== token) return;
      tween(body, { opacity: '0', transform: 'scale(1.06)', filter: 'blur(12px)' }, {
        duration: 1750, easing: 'linear',
        via: [{ opacity: '.3', offset: .16 }, { opacity: '1', offset: .32 }, { opacity: '.3', offset: .48 }, { opacity: '.9', transform: 'scale(1)', filter: 'blur(0px)', offset: .62 }],
      });
      if (onDissolve && !calm()) setTimeout(() => { if (el._leave === token) onDissolve(); }, 1150);
      setTimeout(() => { if (el._leave === token) el.remove(); }, calm() ? 0 : 1800);
    };
    if (delay && !calm()) setTimeout(run, delay); else run();
  }

  // Tween a number inside an element. fmt(n) renders it.
  function countTo(el, to, ms, fmt = n => String(n)) {
    const from = +(el.dataset.v || 0), t0 = performance.now(), tok = el._count = (el._count || 0) + 1;
    const tick = now => {
      if (el._count !== tok) return;
      const t = calm() ? 1 : Math.min(1, (now - t0) / ms), e = t < .5 ? 2 * t * t : 1 - (-2 * t + 2) ** 2 / 2;
      const n = Math.round(from + (to - from) * e);
      el.textContent = fmt(n);
      el.dataset.v = n;
      if (t < 1) requestAnimationFrame(tick);
    };
    requestAnimationFrame(tick);
  }

  // ───────────── Ambient: night sky & city ─────────────
  const City = (() => {
    const svg = $('#skyline'), lit = [];
    if (!svg) return { flicker() {} };
    let x = -40;
    const add = (tag, attrs) => { const e = document.createElementNS(SVGNS, tag); for (const k in attrs) e.setAttribute(k, attrs[k]); svg.append(e); return e; };
    const fog = add('linearGradient', { id: 'fog', x1: 0, y1: 0, x2: 0, y2: 1 });
    fog.innerHTML = '<stop offset="0" stop-color="#1a1b26" stop-opacity="0"/><stop offset="1" stop-color="#16161e" stop-opacity=".9"/>';
    while (x < 1640) {
      const bw = 34 + Math.random() * 78, bh = 30 + Math.random() ** 1.6 * 140;
      add('rect', { x, y: 200 - bh, width: bw, height: bh, fill: Math.random() < .5 ? '#14151e' : '#181926' });
      if (bh > 120 && Math.random() < .5) add('rect', { x: x + bw / 2 - 1, y: 200 - bh - 18, width: 2, height: 18, fill: '#181926' });
      for (let wy = 200 - bh + 9; wy < 194; wy += 11) {
        for (let wx = x + 6; wx < x + bw - 6; wx += 9) {
          lit.push(add('rect', { x: wx, y: wy, width: 3, height: 4, fill: Math.random() < .12 ? '#7dcfff' : '#e0af68', opacity: Math.random() < .16 ? .55 : 0 }));
        }
      }
      x += bw + Math.random() * 6;
    }
    add('rect', { x: 0, y: 0, width: 1600, height: 200, fill: 'url(#fog)', opacity: .55 });
    return {
      flicker(d) {
        for (let i = 0; i < 70; i += 1) {
          const r = lit[(Math.random() * lit.length) | 0];
          setTimeout(() => r.setAttribute('opacity', r.getAttribute('opacity') === '0' ? '.55' : '0'), Math.random() * d);
        }
      },
    };
  })();

  // Stars wheel around a pole above the screen. timelapse(amount) sweeps them into trails;
  // amount 1 ≈ a 0.55 rad sweep. Use it whenever time passes in the story.
  const Sky = (() => {
    const cv = $('#sky');
    if (!cv) return { timelapse() {} };
    const g = cv.getContext('2d');
    const COLS = ['#c0caf5', '#c0caf5', '#c0caf5', '#a9b1d6', '#7dcfff', '#bb9af7', '#e0af68'];
    let w = 0, h = 0, stars = [], pole = { x: 0, y: 0 }, theta = 0, lapse = null, last = performance.now(), meteor = null, nextMeteor = performance.now() + 12000;
    function resize() {
      const d = Math.min(devicePixelRatio || 1, 2);
      w = innerWidth; h = innerHeight;
      cv.width = w * d; cv.height = h * d;
      g.setTransform(d, 0, 0, d, 0, 0);
      pole = { x: w * .64, y: -h * .3 };
      const rmin = Math.max(0, -pole.y), rmax = Math.hypot(Math.max(pole.x, w - pole.x), h - pole.y) + 20;
      const n = Math.min(2600, Math.round(Math.PI * (rmax * rmax - rmin * rmin) / 3400));
      stars = Array.from({ length: n }, () => ({
        r: Math.sqrt(rmin * rmin + Math.random() * (rmax * rmax - rmin * rmin)), a: Math.random() * Math.PI * 2,
        z: Math.random() ** 2.6 * 1.5 + .35, b: .3 + Math.random() * .7, f: .4 + Math.random() * 1.8, p: Math.random() * 6.3, c: COLS[(Math.random() * COLS.length) | 0],
      }));
      draw(performance.now(), true);
    }
    function draw(now, full) {
      const dt = Math.min(64, now - last); last = now;
      let speed = .000004, fade = 1;
      if (lapse) {
        const t = (now - lapse.t0) / lapse.d;
        if (t >= 1) lapse = null;
        else { const env = Math.sin(Math.PI * t); speed += lapse.peak * env; fade = 1 - .92 * Math.sqrt(env); }
      }
      theta += speed * dt;
      g.globalCompositeOperation = 'destination-out';
      g.fillStyle = `rgba(0,0,0,${full ? 1 : fade})`;
      g.fillRect(0, 0, w, h);
      g.globalCompositeOperation = 'source-over';
      for (const s of stars) {
        const a = s.a + theta, x = pole.x + s.r * Math.cos(a), y = pole.y + s.r * Math.sin(a);
        if (x < -3 || x > w + 3 || y < -3 || y > h + 3) continue;
        g.globalAlpha = s.b * (.72 + .28 * Math.sin(now * .001 * s.f + s.p)) * (y > h * .78 ? .5 : 1);
        g.fillStyle = s.c;
        g.beginPath(); g.arc(x, y, s.z, 0, 6.2832); g.fill();
      }
      if (!calm() && now > nextMeteor && !meteor) meteor = { t0: now, x: w * (.3 + Math.random() * .6), y: h * (.05 + Math.random() * .25), d: 900 };
      if (meteor) {
        const t = (now - meteor.t0) / meteor.d;
        if (t >= 1) { meteor = null; nextMeteor = now + 16000 + Math.random() * 22000; } else {
          const x = meteor.x - 260 * t, y = meteor.y + 120 * t;
          const grad = g.createLinearGradient(x, y, x + 90, y - 42);
          grad.addColorStop(0, '#c0caf5'); grad.addColorStop(1, 'rgba(192,202,245,0)');
          g.globalAlpha = Math.sin(Math.PI * t) * .8; g.strokeStyle = grad; g.lineWidth = 1.4;
          g.beginPath(); g.moveTo(x, y); g.lineTo(x + 90, y - 42); g.stroke();
        }
      }
      g.globalAlpha = 1;
    }
    const loop = now => { draw(now, false); requestAnimationFrame(loop); };
    addEventListener('resize', resize);
    resize();
    requestAnimationFrame(loop);
    return {
      timelapse(amount = 1) {
        if (calm()) return;
        const d = 2600, total = .55 * Math.min(Math.max(amount, 0), 1.4);
        lapse = { t0: performance.now(), d, peak: total * Math.PI / (2 * d) };
        City.flicker(d);
      },
    };
  })();

  // ───────────── Stage pieces driven by the story runner ─────────────
  function fit(top = 62, bottom = ($('footer')?.offsetHeight ?? 86) + 6) {
    const aw = innerWidth - 24, ah = innerHeight - top - bottom;
    const k = Math.min(aw / W, ah / H);
    $('#world').style.transform = `translate(${(innerWidth - W * k) / 2}px, ${top + (ah - H * k) / 2}px) scale(${k})`;
  }

  const camera = (c, instant) => tween($('#camera'), { transform: c.t, opacity: c.o ?? '1' }, { duration: instant ? 1 : 1600, channel: 'cam' });

  // Spotlight vignette centred on [x, y, scale] in camera coordinates; null hides it.
  function spot(target, instant) {
    const el = $('#spot');
    if (!el) return;
    if (!target) { tween(el, { opacity: '0' }, { duration: 900 }); return; }
    const [x, y, r = 1] = target;
    tween(el, { transform: `translate(${x - 4000}px, ${y - 4000}px) scale(${r})`, opacity: '1' }, { duration: instant ? 1 : 1500, delay: instant ? 1200 : 0 });
  }

  function text(t, intro) {
    morph($('#kicker'), words(t.k || ''), { matchAll: true, duration: 600, stagger: 8 });
    morph($('#headline'), words(t.h || ''), { matchAll: true, duration: intro ? 1100 : 950, stagger: 34 });
    morph($('#subline'), words(t.s || ''), { matchAll: true, duration: 760, stagger: 9 });
  }

  // Code card states: off (beyond the right edge) → card (flies in on an arc) ⇄ dock (corner tab).
  const CARD_AT = { card: 'translate(908px, 300px) rotate(0deg) scale(1)', dock: 'translate(1372px, 832px) rotate(0deg) scale(1)', off: 'translate(2050px, 470px) rotate(10deg) scale(0.92)' };
  const code = {
    current: () => $('#code')?.dataset.key || null,
    show(key, o = {}) {
      const card = $('#code');
      if (!card) return;
      const inner = $('#codeInner'), chip = $('#codeChip');
      const was = card.dataset.state || 'off';
      const target = key ? 'card' : (o.dock ? 'dock' : 'off');
      const delay = o.delay || 0;
      const at = o.at || CARD_AT.card;
      if (key) {
        const snip = o.snips[key];
        const visible = was === 'card' && !o.intro;
        if (card.dataset.key !== key) {
          card.dataset.key = key;
          const file = snip.file || o.file || 'source';
          morph($('#codeFile'), words(`${file} · ${snip.start}–${snip.start + snip.lines.length - 1}`), { matchAll: true, animate: visible, duration: 600 });
          $('#codeBadge').innerHTML = snip.note ? `<span class="badge ${snip.note}">${snip.note}</span>` : '';
          morph($('#codeBody'), codeLines(snip), { animate: visible, duration: 1000, stagger: 9 });
          $('#codeFoot').textContent = snip.tag || '';
          $('#codeChip').innerHTML = `<b>‹/›</b> ${file}`;
          // Excerpts may share lines (same tokens, different focus): always reset highlights.
          const focus = new Set(snip.focus || []);
          $$('#codeBody .tok').forEach(t => {
            t.classList.remove('focus');
            if (focus.has(t.textContent)) later(visible ? 950 : 1500 + delay, () => t.classList.add('focus'));
          });
        }
        const size = { w: inner.offsetWidth, h: inner.offsetHeight };
        if (was === 'off') {
          Object.assign(card.style, { width: `${size.w}px`, height: `${size.h}px` });
          tween(inner, { opacity: '1' }, { duration: 1, channel: 'inner' });
          tween(chip, { opacity: '0' }, { duration: 1, channel: 'chip' });
          tween(card, { transform: at, opacity: '1' }, { duration: 1500, delay: (o.intro ? 900 : 380) + delay, easing: 'cubic-bezier(.2,.85,.25,1)', via: { transform: 'translate(1280px, 120px) rotate(-5deg) scale(1.03)', opacity: '1', offset: .6 } });
        } else {
          tween(card, { transform: at, opacity: '1', width: `${size.w}px`, height: `${size.h}px` }, { duration: 1150, delay });
          tween(inner, { opacity: '1' }, { duration: 520, delay: (was === 'dock' ? 700 : 0) + delay, channel: 'inner' });
          tween(chip, { opacity: '0' }, { duration: 220, channel: 'chip' });
        }
      } else if (target === 'dock') {
        tween(inner, { opacity: '0' }, { duration: 280, channel: 'inner' });
        tween(card, { transform: CARD_AT.dock, opacity: '1', width: '196px', height: '44px' }, { duration: 1250, delay: was === 'card' ? 140 : 0, via: { transform: 'translate(1240px, 640px) rotate(2deg) scale(1)', offset: .5 } });
        tween(chip, { opacity: '1' }, { duration: 420, delay: 850, channel: 'chip' });
      } else if (was !== 'off') {
        tween(card, { transform: CARD_AT.off, opacity: '0' }, { duration: 1100, easing: 'cubic-bezier(.6,0,.8,.45)', via: { transform: 'translate(1250px, 190px) rotate(-3deg) scale(1)', opacity: '1', offset: .38 } });
      }
      card.dataset.state = target;
    },
  };

  // Summary cards fly out of the world objects named by each card's data-from selector.
  function finale(on, intro) {
    const hud = $('#hud');
    $$('.fcard').forEach((c, i, all) => {
      const src = $(c.dataset.from || '#camera') || $('#camera');
      const o = localPoint(src, hud);
      const gap = 440, x0 = 800 - ((all.length - 1) * gap) / 2 - 190;
      const home = `translate(${x0 + i * gap}px, 300px) scale(1)`;
      const origin = `translate(${o.x - 190}px, ${o.y - 100}px) scale(0.18)`;
      if (on) {
        if (c.dataset.on !== '1') c.style.transform = origin;
        tween(c, { transform: home, opacity: '1' }, { duration: 1500, delay: (intro ? 600 : 450) + i * 230, easing: 'cubic-bezier(.2,.85,.25,1)', via: { transform: `translate(${(o.x - 190 + x0 + i * gap) / 2}px, ${Math.min(o.y - 100, 300) - 140}px) scale(0.7)`, opacity: '1', offset: .55 } });
      } else if (c.dataset.on === '1') {
        tween(c, { transform: origin, opacity: '0' }, { duration: 900 });
      }
      c.dataset.on = on ? '1' : '';
    });
    const ctas = $('#finaleCtas');
    if (ctas) {
      tween(ctas, { opacity: on ? '1' : '0', transform: on ? 'translateY(0px)' : 'translateY(16px)' }, { duration: 800, delay: on ? 1500 : 0 });
      ctas.style.pointerEvents = on ? 'auto' : 'none';
    }
  }

  // ───────────── Story + playground runner ─────────────
  // cfg = {
  //   scenes: [{ key, kicker, title, sub, ev: [events], cam, spot, code, interact?: { selector, ev } }],
  //   initial(), step(state, ev)           pure model; state.last = { kind, code, text } drives the playground
  //   render(ctx)                          draws the world; returns optional { codeDelay }
  //   cams: { name: { t, o } }, spots: { name: [x, y, scale] }, snips: { key: snip }, file: 'name.go',
  //   finaleKey: 'finale', text?(ctx), spotFor?(ctx), hint?(ctx),
  //   resolve?(state) → event               an event Next must apply before advancing (e.g. restart a crashed process)
  //   play: { cam, intro, events: [{ ev, key, label | label(s), enabled(s) }], presets: { id: { label, events: [ev…] | events() } }, tape?(ev, state) }
  // }
  // A preset is the event path from initial() to the scenario, not a finished state. Loading it
  // replaces the history with the stable start plus one chip per event, so every step leading to
  // the scenario can be inspected and undone. Entering the playground from a scene does the same
  // with the scene path, including any in-scene interactions.
  // The playground keeps a timeline of states: Undo/Redo (Z / Shift+Z, Ctrl+Z / Ctrl+Y, ← / →) and
  // clickable history chips travel through it; a new event after travelling back discards the
  // undone branch. Travel renders with ctx.animated = false, so objects glide without replaying
  // effects. Keys z, y and the arrows are reserved in the playground.
  // ctx = { prev, s, sc, idx, play, intro, animated, api } — animate choreography only when ctx.animated.
  function story(cfg) {
    let mode = 'story', idx = 0, state = cfg.initial(), shown = null, cine = false, interactions = [];
    let line = [], pos = 0, fresh = false; // playground timeline: [{ label, s }], current index
    const scenes = cfg.scenes;
    const snapshot = i => { let s = cfg.initial(); for (let n = 0; n <= i; n += 1) for (const e of scenes[n].ev || []) s = cfg.step(s, e); return s; };
    const codeAround = i => scenes.slice(0, i).some(s => s.code) && scenes.slice(i + 1).some(s => s.code);
    const api = {
      get state() { return structuredClone(state); }, get idx() { return idx; }, get mode() { return mode; },
      initial: cfg.initial, scenes, snapshot, go, next, back, act, interact, setMode, render, undo, redo, travel,
      get timeline() { return { pos, labels: line.map(e => e.label) }; },
    };

    // Timeline: record() after a change; replay() starts a fresh history from initial().
    const tapeLabel = (ev, before, after) => {
      if (cfg.play.tape) return cfg.play.tape(ev, after);
      const def = (cfg.play.events || []).find(e => e.ev === ev);
      return `${def?.icon || '•'} ${typeof def?.label === 'function' ? def.label(before) : def?.label || ev}`;
    };
    function replay(label, events) {
      let s = cfg.initial();
      line = [{ label: `◇ ${label}`, s: structuredClone(s) }];
      for (const ev of events) {
        const before = s;
        s = cfg.step(s, ev);
        line.push({ label: tapeLabel(ev, before, s), s: structuredClone(s) });
      }
      pos = line.length - 1;
      state = structuredClone(s);
      fresh = true;
      cine = false;
    }
    // Narrate the playground's opening entry; the stored snapshot keeps undo/redo exact.
    function introduce() {
      if (!cfg.play.intro) return;
      state.last = { ...(state.last || {}), text: cfg.play.intro };
      line[pos].s = structuredClone(state);
    }
    function record(label) { line = line.slice(0, pos + 1); line.push({ label, s: structuredClone(state) }); pos = line.length - 1; fresh = true; }
    function travel(i) {
      if (mode !== 'play' || i < 0 || i >= line.length || i === pos) return;
      pos = i; state = structuredClone(line[i].s); cine = false; fresh = false;
      render();
    }
    function undo() { travel(pos - 1); }
    function redo() { travel(pos + 1); }

    function render() {
      nextEpoch();
      const prev = shown && shown.s, sc = scenes[idx], play = mode === 'play';
      const intro = !shown, animated = !intro && cine;
      cine = false;
      const ctx = { prev, s: state, sc, idx, play, intro, animated, api };
      const camKey = play ? (cfg.play?.cam || 'wide') : (sc.cam || 'wide');
      camera(cfg.cams[camKey], intro);
      spot(play ? null : (cfg.spotFor ? cfg.spotFor(ctx) : (sc.spot ? cfg.spots[sc.spot] : null)), intro);
      text(cfg.text?.(ctx) || (play ? { k: 'Playground', h: 'Playground', s: state.last?.text || '' } : { k: sc.kicker, h: sc.title, s: sc.sub }), intro);
      const out = cfg.render(ctx) || {};
      const codeKey = play ? (state.last?.code && cfg.snips[state.last.code] ? state.last.code : code.current()) : (sc.code || null);
      code.show(codeKey, { snips: cfg.snips, file: cfg.file, dock: !play && codeAround(idx), intro, delay: out.codeDelay || 0 });
      finale(!play && sc.key === cfg.finaleKey, intro);
      const hint = cfg.hint?.(ctx) ?? (play ? 'Change the world, then step the system. Undo (Z) to go back and try another path.'
        : sc.interact ? sc.interact.hint || 'Click the highlighted object — or anywhere to continue'
          : sc.key === cfg.finaleKey ? '' : idx === 0 ? 'Click anywhere to begin' : 'Click anywhere to continue');
      $('#hint').textContent = hint;
      $('#hint').style.opacity = !play && idx > 2 && !sc.interact ? '.45' : '.8';
      $('#stage').classList.toggle('clickable', !play && sc.key !== cfg.finaleKey);
      chrome();
      shown = { s: structuredClone(state) };
    }

    // A pointer click should not leave a focused button behind: the next arrow key
    // would otherwise paint a focus ring on it. Keyboard activation (detail 0)
    // keeps focus so keyboard users still see where they are.
    addEventListener('click', e => {
      const button = e.target.closest?.('button');
      if (button && e.detail > 0) button.blur();
    }, true);

    // Footer, header, dock
    const dots = $('#dots');
    scenes.forEach((sc, i) => {
      const b = document.createElement('button');
      b.title = `${i}. ${sc.title}`;
      b.setAttribute('aria-label', `Scene ${i}: ${sc.title}`);
      b.addEventListener('click', e => { e.stopPropagation(); go(i); });
      dots.append(b);
    });
    const dock = $('#playDock');
    for (const e of cfg.play?.events || []) {
      if (e.sep) { dock.append(Object.assign(document.createElement('span'), { className: 'sep' })); continue; }
      const b = document.createElement('button');
      b.dataset.ev = e.ev;
      if (e.primary) b.className = 'primary';
      b.innerHTML = `<span></span><kbd>${e.key.toUpperCase()}</kbd>`;
      b.addEventListener('click', () => act(e.ev));
      dock.append(b);
    }
    const hist = document.createElement('div');
    hist.className = 'hist';
    hist.setAttribute('role', 'group');
    hist.setAttribute('aria-label', 'History controls');
    hist.innerHTML = '<button id="undo" title="Undo (Z)">↶ Undo<kbd>Z</kbd></button><button id="redo" title="Redo (Shift+Z)">↷ Redo<kbd>⇧Z</kbd></button>';
    $('#playBar .history-row').prepend(hist);
    $('#undo').addEventListener('click', undo);
    $('#redo').addEventListener('click', redo);
    const presetSel = $('#preset');
    if (presetSel) {
      for (const [id, p] of Object.entries(cfg.play?.presets || {})) presetSel.append(new Option(p.label, id));
      presetSel.hidden = !cfg.play?.presets;
      presetSel.addEventListener('change', e => {
        const p = cfg.play.presets[e.target.value];
        if (!p) return;
        replay(p.label.toLowerCase(), typeof p.events === 'function' ? p.events() : p.events);
        e.target.value = '';
        render();
      });
    }

    function chrome() {
      const play = mode === 'play';
      $('#storyBar').hidden = play;
      $('#playBar').hidden = !play;
      $('#modeStory').classList.toggle('on', !play); $('#modeStory').setAttribute('aria-pressed', String(!play));
      $('#modePlay').classList.toggle('on', play); $('#modePlay').setAttribute('aria-pressed', String(play));
      $('#modePlay').hidden = !cfg.play;
      $$('#dots button').forEach((b, i) => { b.className = i === idx ? 'on' : i < idx ? 'seen' : ''; });
      $('#count').textContent = `${String(idx).padStart(2, '0')} / ${scenes.length - 1}`;
      $('#back').disabled = idx === 0;
      $('#next').disabled = idx === scenes.length - 1;
      const pending = cfg.resolve?.(state);
      $('#next').textContent = pending ? (cfg.resolveLabel || 'Resume →') : idx === scenes.length - 1 ? 'End' : 'Next →';
      for (const e of cfg.play?.events || []) {
        if (e.sep) continue;
        const b = dock.querySelector(`[data-ev="${e.ev}"]`);
        b.disabled = e.enabled ? !e.enabled(state) : false;
        b.firstChild.textContent = typeof e.label === 'function' ? e.label(state) : e.label;
      }
      $('#undo').disabled = pos <= 0;
      $('#redo').disabled = pos >= line.length - 1;
      $('#tape').replaceChildren(...line.map((e, i) => {
        const b = document.createElement('button');
        b.textContent = e.label;
        b.className = i === pos ? `now${fresh ? ' fresh' : ''}` : i > pos ? 'future' : '';
        b.setAttribute('aria-current', i === pos ? 'step' : 'false');
        b.title = i === pos ? 'Current state' : i > pos ? 'Undone — click to redo up to here' : 'Click to go back to this point';
        b.addEventListener('click', () => travel(i));
        return b;
      }));
      if (play) $('#tape .now')?.scrollIntoView({ block: 'nearest', inline: 'nearest' });
      fresh = false;
      history.replaceState(null, '', play ? '#play' : `#${idx}`);
      fit();
    }

    function go(i) {
      i = Math.max(0, Math.min(scenes.length - 1, i));
      mode = 'story';
      const forward = i === idx + 1;
      if (i === idx && !cfg.resolve?.(state) && !interactions.length) return;
      idx = i; state = snapshot(i); cine = forward; interactions = [];
      render();
    }
    function next() {
      if (mode !== 'story') return;
      const pending = cfg.resolve?.(state);
      if (pending) { interact(pending); return; }
      if (idx < scenes.length - 1) go(idx + 1);
    }
    function back() { if (mode === 'story' && idx > 0) go(idx - 1); }
    // An in-scene interaction (story mode): apply an event without leaving the scene.
    function interact(ev) { state = cfg.step(state, ev); interactions.push(ev); cine = true; render(); }
    function act(ev) {
      if (mode !== 'play') return;
      const def = (cfg.play.events || []).find(e => e.ev === ev);
      if (def?.enabled && !def.enabled(state)) return;
      const before = state;
      state = cfg.step(state, ev);
      if (state === before) return;
      record(tapeLabel(ev, before, state));
      cine = true;
      render();
    }
    function setMode(m) {
      if (m === mode || (m === 'play' && !cfg.play)) return;
      mode = m;
      if (m === 'play') {
        replay(`scene ${idx}`, [...scenes.slice(0, idx + 1).flatMap(sc => sc.ev || []), ...interactions]);
        introduce();
      } else { state = snapshot(idx); interactions = []; }
      render();
    }

    $('#stage').addEventListener('click', e => {
      if (mode !== 'story' || e.target.closest('.live')) return;
      const sc = scenes[idx];
      if (sc.interact && e.target.closest(sc.interact.selector)) { interact(sc.interact.ev); return; }
      if (sc.key !== cfg.finaleKey) next();
    });
    $('#next').addEventListener('click', next);
    $('#back').addEventListener('click', back);
    $('#modeStory').addEventListener('click', () => setMode('story'));
    $('#modePlay').addEventListener('click', () => setMode('play'));
    $('#notesBtn')?.addEventListener('click', () => $('#notes').showModal());
    $('#closeNotes')?.addEventListener('click', () => $('#notes').close());
    $('#fsBtn')?.addEventListener('click', () => (document.fullscreenElement ? document.exitFullscreen() : document.documentElement.requestFullscreen()).catch(() => {}));

    addEventListener('keydown', e => {
      if ($('#notes')?.open || e.altKey || /^(SELECT|INPUT|TEXTAREA)$/.test(e.target.tagName)) return;
      const k = e.key.toLowerCase();
      if (mode === 'play') {
        const back = k === 'z' && !e.shiftKey || k === 'arrowleft', fwd = k === 'z' && e.shiftKey || k === 'y' || k === 'arrowright';
        if ((back || fwd) && (!(e.metaKey || e.ctrlKey) || k === 'z' || k === 'y')) { e.preventDefault(); if (back) undo(); else redo(); return; }
      }
      if (e.metaKey || e.ctrlKey) return;
      if (k === 'f') { $('#fsBtn')?.click(); return; }
      if (k === '?') { $('#notes')?.showModal(); return; }
      if (mode === 'story') {
        if (['arrowright', 'pagedown', ' ', 'enter'].includes(k)) {
          if (e.target.tagName === 'BUTTON' && (k === ' ' || k === 'enter')) return;
          e.preventDefault(); next();
        } else if (['arrowleft', 'pageup', 'backspace'].includes(k)) { e.preventDefault(); back(); }
        else if (k === 'home') go(0);
        else if (k === 'end') go(scenes.length - 1);
        else if (k === 'p') setMode('play');
        else if (scenes[idx].interact?.key === k) interact(scenes[idx].interact.ev);
      } else {
        const ev = (cfg.play?.events || []).find(x => x.key === k);
        if (ev) { e.preventDefault(); act(ev.ev); } else if (k === 'escape') setMode('story');
      }
    });

    addEventListener('resize', () => fit());
    fit();
    const hash = location.hash.slice(1);
    if (hash === 'play' && cfg.play) { mode = 'play'; replay('start', []); introduce(); }
    else if (/^\d+$/.test(hash)) { idx = Math.min(scenes.length - 1, +hash); state = snapshot(idx); }
    render();
    $('#ctaReplay')?.addEventListener('click', e => { e.stopPropagation(); go(0); });
    $('#ctaPlay')?.addEventListener('click', e => { e.stopPropagation(); setMode('play'); });
    window.demo = api;
    return api;
  }

  window.Demo = {
    $, $$, calm, EASE, SVGNS, W, H,
    later, keep, drop, tween, localPoint, arc, lcs, morph, words, codeTokens, codeLines,
    pulse, badge, fly, particles, whisper, flash, breatheIn, breatheOut, countTo,
    sky: Sky, city: City, fit, camera, spot, text, code, finale, story,
  };
})();
