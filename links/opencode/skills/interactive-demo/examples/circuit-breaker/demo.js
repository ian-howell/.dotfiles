// Circuit breaker — an invented example for the interactive-demo skill.
'use strict';
(() => {
  const { $, $$, tween, pulse, morph, later, flash, whisper, particles, breatheIn, breatheOut, countTo, badge, fly, localPoint, sky } = Demo;
  const THRESHOLD = 3, COOLDOWN = 30;
  const INSTANCES = [
    { id: 'orders-7f3', color: '#7dcfff' },
    { id: 'orders-c19', color: '#73daca' },
    { id: 'orders-a42', color: '#bb9af7' },
  ];
  const inst = gen => INSTANCES[gen % INSTANCES.length];

  // ── Model ───────────────────────────────────────────────────────────────────
  const initial = () => ({
    breaker: 'closed', failures: 0, since: 0, healthy: true, gen: 0, sent: 0, outcomes: [],
    last: { kind: 'start', code: null, text: 'The breaker is closed. Calls go straight through.' },
  });

  function step(prev, ev) {
    const s = structuredClone(prev);
    const say = (kind, code, text) => { s.last = { kind, code: code ?? s.last.code, text }; return s; };
    switch (ev) {
      case 'fail':
        if (!s.healthy) return s;
        s.healthy = false;
        return say('fail', null, 'The service starts returning errors.');
      case 'heal':
        if (s.healthy) return s;
        s.healthy = true; s.gen += 1;
        return say('heal', null, 'A healthy instance replaces the failing one.');
      case 'health':
        return step(prev, s.healthy ? 'fail' : 'heal');
      case 'tick':
        if (s.breaker === 'open') s.since = Math.min(s.since + 10, 90);
        return say('tick', null, s.breaker === 'open' ? `Ten seconds pass. ${Math.min(s.since, COOLDOWN)} of ${COOLDOWN} cooldown seconds elapsed.` : 'Ten seconds pass.');
      case 'request': {
        s.sent += 1;
        let out;
        if (s.breaker === 'open' && s.since < COOLDOWN) out = 'rejected';
        else if (s.breaker === 'open') {
          out = s.healthy ? 'probe-ok' : 'probe-fail';
          if (s.healthy) { s.breaker = 'closed'; s.failures = 0; } else { s.since = 0; s.failures += 1; }
        } else if (s.healthy) { out = 'ok'; s.failures = 0; } else {
          s.failures += 1;
          if (s.failures >= THRESHOLD) { s.breaker = 'open'; s.since = 0; out = 'trip'; } else out = 'fail';
        }
        s.outcomes = [...s.outcomes, out].slice(-6);
        const text = {
          ok: 'The call succeeds. The failure count stays at zero.',
          fail: `The call fails. ${s.failures} of ${THRESHOLD} consecutive failures.`,
          trip: 'The third consecutive failure opens the breaker.',
          rejected: 'The breaker is open. The call fails immediately; the service never sees it.',
          'probe-ok': 'The cooldown has elapsed. One trial call succeeds, so the breaker closes.',
          'probe-fail': 'The trial call fails. The breaker reopens and the cooldown restarts.',
        }[out];
        const code = { ok: 'close', fail: 'count', trip: 'trip', rejected: 'reject', 'probe-ok': 'probe', 'probe-fail': 'reopen' }[out];
        return say('request', code, text);
      }
      default:
        return s;
    }
  }

  // ── Code (an illustrative breaker.go written for this demo) ────────────────────
  const SRC = [
    'func (b *Breaker) Call(fn func() error) error {',
    '\tif b.state == Open {',
    '\t\tif time.Since(b.openedAt) < b.cooldown {',
    '\t\t\treturn ErrOpen',
    '\t\t}',
    '\t\tb.state = HalfOpen',
    '\t}',
    '\tif err := fn(); err != nil {',
    '\t\tb.failures++',
    '\t\tif b.state == HalfOpen || b.failures >= b.threshold {',
    '\t\t\tb.state, b.openedAt = Open, time.Now()',
    '\t\t}',
    '\t\treturn err',
    '\t}',
    '\tb.state, b.failures = Closed, 0',
    '\treturn nil',
    '}',
  ];
  const lines = (a, b) => ({ start: a, lines: SRC.slice(a - 1, b).map(l => l.replace(/^\t/, '')), lang: 'go', pkgs: ['time'], note: 'illustrative' });
  const snips = {
    count: { ...lines(8, 14), focus: ['failures', '++'], tag: 'Each failure is counted' },
    trip: { ...lines(8, 14), focus: ['>=', 'Open', 'openedAt'], tag: 'At the threshold, open and remember when' },
    reject: { ...lines(2, 5), focus: ['ErrOpen', 'cooldown'], tag: 'While open, fail fast without calling' },
    probe: { ...lines(2, 7), focus: ['HalfOpen'], tag: 'After the cooldown, let one call through' },
    close: { ...lines(15, 16), focus: ['Closed', '0'], tag: 'A success closes the breaker and resets the count' },
    reopen: { ...lines(8, 12), focus: ['HalfOpen', 'Open'], tag: 'A failed probe reopens immediately' },
  };

  // ── Scenes ──────────────────────────────────────────────────────────────────
  const scenes = [
    { key: 'title', kicker: 'Resilience patterns', title: 'Circuit breaker', sub: 'How a client stops calling a failing service, and when it tries again.', ev: [], cam: 'title' },
    { key: 'closed', kicker: '01 · Closed', title: 'Calls pass through while the breaker is closed', sub: 'A success keeps the failure count at zero.', ev: ['request'], cam: 'wide' },
    { key: 'count', kicker: '02 · Count', title: 'Failures are counted', sub: 'The service starts failing. Two calls fail; the breaker stays closed.', ev: ['fail', 'request', 'request'], cam: 'code', spot: 'record', code: 'count' },
    { key: 'trip', kicker: '03 · Trip', title: 'The breaker opens at the threshold', sub: 'The third consecutive failure opens it and records the time.', ev: ['request'], cam: 'code', spot: 'breaker', code: 'trip' },
    { key: 'reject', kicker: '04 · Fail fast', title: 'Calls fail fast while the breaker is open', sub: 'The service receives no traffic while it recovers.', ev: ['request'], cam: 'code', spot: 'breaker', code: 'reject',
      interact: { selector: '#client', ev: 'request', key: 's', hint: 'Click the client to send another call — or anywhere to continue' } },
    { key: 'recover', kicker: '05 · Cooldown', title: 'The service recovers during the cooldown', sub: 'A healthy instance replaces the failing one. The breaker cannot know yet.', ev: ['heal', 'tick', 'tick', 'tick'], cam: 'wide', spot: 'service' },
    { key: 'probe', kicker: '06 · Probe', title: 'After the cooldown, one trial call goes through', sub: 'Half-open: a single call decides whether to close or reopen.', ev: ['request'], cam: 'code', spot: 'breaker', code: 'probe' },
    { key: 'resume', kicker: '07 · Closed', title: 'Normal traffic resumes', sub: 'The probe succeeded, so the breaker closed and the count reset.', ev: ['request'], cam: 'code', code: 'close' },
    { key: 'finale', kicker: 'Summary', title: 'Circuit breaker', sub: 'Count failures, stop calling, then probe.', ev: [], cam: 'finale' },
  ];
  const cams = {
    title: { t: 'translate(0px, 48px) scale(0.92)' },
    wide: { t: 'translate(0px, 14px) scale(1)' },
    code: { t: 'translate(-330px, 24px) scale(0.68)' },
    finale: { t: 'translate(0px, 210px) scale(0.5)', o: '0.1' },
  };
  const spots = { record: [800, 286, 1.05], breaker: [800, 520, .95], service: [1270, 520, .95] };

  // ── Rendering ───────────────────────────────────────────────────────────────
  const STATE_COLOR = { closed: '#9ece6a', open: '#f7768e', half: '#e0af68' };
  const LEVER = { closed: 'rotate(0deg)', half: 'rotate(-17deg)', open: 'rotate(-38deg)' };

  function recordTokens(s, view = s.breaker) {
    return [[
      { t: '{', c: 'br' }, { t: '"state"', c: 'key' }, { t: ':', c: 'p' }, { t: ' ', ws: true },
      { t: `"${view}"`, c: 's', color: STATE_COLOR[view] }, { t: ',', c: 'p' }, { t: ' ', ws: true },
      { t: '"failures"', c: 'key' }, { t: ':', c: 'p' }, { t: ' ', ws: true }, { t: String(s.failures), c: 'n roll', k: `f${s.failures}` },
      { t: '}', c: 'br' },
    ]];
  }

  function setBreaker(view, s, animate) {
    const el = $('#breaker');
    el.classList.toggle('open', view === 'open');
    el.classList.toggle('half', view === 'half');
    $('#bkState').textContent = view === 'half' ? 'half-open' : view;
    tween($('#lever'), { transform: LEVER[view] }, { duration: animate ? 700 : 1, easing: 'cubic-bezier(.3,1.5,.5,1)' });
    morph($('#recordBody'), recordTokens(s, view), { matchAll: true, animate, duration: 800 });
  }

  function makeService(gen) {
    const u = inst(gen);
    const el = document.createElement('div');
    el.className = 'svc';
    el.dataset.gen = gen;
    el.innerHTML = `<div class="presence"><div class="inner"></div>
      <div class="top">SERVICE<span class="chip" style="color:${u.color}">${u.id}</span></div>
      <div class="health"><i></i><span>healthy</span></div><div class="stat">200 OK · 40 ms</div></div>`;
    return el;
  }

  // One call's journey. Returns how long it takes to settle.
  function call(outcome, at) {
    const blue = '#7aa2f7', green = '#9ece6a', red = '#f7768e';
    pulse('beamA', { color: blue, dur: 600, delay: at });
    if (outcome === 'rejected') {
      later(at + 560, () => { flash(800, 520, red); whisper('fast fail', 800, 410, { color: red }); });
      pulse('beamA', { color: red, dur: 600, delay: at + 640, reverse: true });
      return at + 1250;
    }
    const ok = outcome === 'ok' || outcome === 'probe-ok';
    pulse('beamB', { color: blue, dur: 600, delay: at + 560 });
    later(at + 1130, () => { flash(1270, 520, ok ? green : red); whisper(ok ? '200 OK' : '503', 1270, 410, { color: ok ? green : red }); });
    pulse('beamB', { color: ok ? green : red, dur: 600, delay: at + 1200, reverse: true });
    pulse('beamA', { color: ok ? green : red, dur: 600, delay: at + 1760, reverse: true });
    return at + 2350;
  }

  function render(ctx) {
    const { prev, s, sc, play, intro, animated } = ctx;

    if (intro) {
      ['#client', '#breaker', '#svcLabel'].forEach((sel, i) => tween($(sel), { opacity: '1', transform: 'translateY(0px)' }, { duration: 1100, delay: 300 + i * 220, via: { transform: 'translateY(24px)', opacity: '.4', offset: .3 } }));
      Demo.$$('.beam').forEach((b, i) => tween(b, { opacity: '1' }, { duration: 1200, delay: 900 + i * 180 }));
      tween($('#record'), { opacity: '1' }, { duration: 1000, delay: 1200 });
      particles({ x: 330, y: 520 }, { inward: true, n: 30, spread: 220, dur: 1000, colors: ['#7aa2f7', '#7dcfff', '#bb9af7'] });
    }

    // Client affordance
    const hot = !play && !!sc.interact;
    $('#client').classList.toggle('hot', hot);

    // Service instances: the failing one breathes out, its replacement breathes in.
    const host = $('#services');
    let fresh = false;
    for (const el of $$('.svc', host)) {
      if (+el.dataset.gen === s.gen) { if (el.dataset.leaving) breatheIn($('.presence', el)); }
      else if (!el.dataset.leaving) breatheOut(el, $('.presence', el), 0, () => particles({ x: 1270, y: 520 }, { n: 22, color: '#f7768e', spread: 150, rise: 30, dur: 1200, rect: { x: 1270, y: 520, w: 200, h: 130 } }));
    }
    let svc = host.querySelector(`.svc[data-gen="${s.gen}"]`);
    if (!svc) { svc = makeService(s.gen); host.append(svc); fresh = true; breatheIn($('.presence', svc), intro ? 700 : animated && prev && prev.gen !== s.gen ? 1500 : 300); }
    svc.classList.toggle('failing', !s.healthy);
    $('.health span', svc).textContent = s.healthy ? 'healthy' : 'failing';
    $('.stat', svc).textContent = s.healthy ? '200 OK · 40 ms' : '503 · upstream timeout';
    if (animated && prev?.healthy && !s.healthy) { flash(1270, 520, '#f7768e'); particles({ x: 1270, y: 520 }, { n: 18, color: '#f7768e', spread: 120, dur: 1000 }); }
    if (animated && fresh && prev) later(1800, () => whisper('new instance', 1270, 410, { color: inst(s.gen).color }));

    // Calls: replay the requests that just happened, staggered, then settle the breaker.
    const n = animated && prev ? Math.max(0, s.sent - prev.sent) : 0;
    let settle = 0;
    if (n) {
      const outs = s.outcomes.slice(-n);
      outs.forEach((o, i) => { settle = call(o, i * 1300); });
      const probe = outs.find(o => o.startsWith('probe'));
      if (probe) later(560, () => { setBreaker('half', { ...s, failures: prev.failures }, true); flash(800, 520, '#e0af68'); whisper('half-open', 800, 410, { color: '#e0af68' }); });
      // Count each failure as its response returns.
      outs.forEach((o, i) => {
        if (o === 'fail' || o === 'trip') later(i * 1300 + 2300, () => {
          const f = prev.failures + outs.slice(0, i + 1).filter(x => x === 'fail' || x === 'trip').length;
          morph($('#recordBody'), recordTokens({ ...s, failures: f }, o === 'trip' ? 'open' : 'closed'), { matchAll: true, duration: 700 });
          flash(800, 290, o === 'trip' ? '#f7768e' : '#e0af68');
        });
      });
    }
    if (settle) later(settle, () => setBreaker(s.breaker, s, true)); else setBreaker(s.breaker, s, !intro);

    // Cooldown ring: time passes in a time-lapse.
    const open = s.breaker === 'open';
    const pct = open ? Math.min(s.since / COOLDOWN, 1) : 0;
    const lapse = animated && prev && s.since > prev.since && prev.breaker === 'open';
    if (lapse) sky.timelapse((s.since - prev.since) / COOLDOWN);
    tween($('#breaker .ring .prog'), { strokeDashoffset: String(100 - pct * 100) }, { duration: lapse ? 2400 : 700, delay: lapse ? 1400 : 0, easing: lapse ? 'cubic-bezier(.45,.05,.35,1)' : undefined });
    tween($('#breaker .ring'), { opacity: open ? '1' : '0' }, { duration: 700, delay: open && settle ? settle : 0, channel: 'ring' });
    tween($('#cool'), { opacity: open ? '1' : '0' }, { duration: 700, delay: open && settle ? settle : 0 });
    if (lapse) later(1400, () => countTo($('#cool'), Math.min(s.since, COOLDOWN), 2400, v => `cooldown ${v} / ${COOLDOWN} s`));
    else countTo($('#cool'), Math.min(s.since, COOLDOWN), 1, v => `cooldown ${v} / ${COOLDOWN} s`);

    return { codeDelay: 0 };
  }

  Demo.story({
    scenes, initial, step, render, cams, spots, snips, file: 'breaker.go', finaleKey: 'finale',
    play: {
      cam: 'code',
      intro: 'Send calls, break or heal the service, and let time pass.',
      events: [
        { ev: 'request', key: 's', label: '→ Send call', icon: '→', primary: true },
        { sep: true },
        { ev: 'health', key: 'h', label: s => (s.healthy ? '✕ Service fails' : '✚ Service recovers'), icon: '⇅' },
        { ev: 'tick', key: 't', label: '⏱ +10 s', icon: '⏱', enabled: s => s.breaker === 'open' },
      ],
      tape: (ev, s) => (ev === 'request' ? `→ ${s.outcomes[s.outcomes.length - 1]}` : ev === 'health' ? (s.healthy ? '✚ healed' : '✕ failing') : '⏱ +10 s'),
      presets: {
        failing: { label: 'Service failing', make: () => step(initial(), 'fail') },
        open: { label: 'Breaker open', make: () => ['fail', 'request', 'request', 'request'].reduce(step, initial()) },
        cooled: { label: 'Cooldown elapsed, still failing', make: () => ['fail', 'request', 'request', 'request', 'tick', 'tick', 'tick'].reduce(step, initial()) },
      },
    },
  });
})();
