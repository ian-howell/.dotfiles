// Free camera: Ian's standard mouse/keyboard controls for three.js scenes.
// Copy this file into a project; don't rewrite it.
//
//   left-drag     look, Minecraft-style: the pointer locks to the centre while held and the mouse turns the head
//   right-drag    pan (camera and look-at slide in the screen plane); middle-drag does the same
//                 (right-click without a drag is onRightClick)
//   wheel         dolly forward/back along the view
//   arrows        look        + / -         zoom the lens (FOV)
//   W / S         fly where the camera faces   A / D   level strafe   Space / Shift   up / down
//   left-click    onClick      right-click (no drag)       onRightClick     (5px drag threshold)
//
// The camera never moves on its own: scripted flights set camera.position and cam.target together.
// Pass `busy: () => !!flight` so wheel/keys pause during them, and cancel the flight in onDragStart.
//
// const cam = createFreeCamera(THREE, camera, renderer.domElement, { target, onClick, onRightClick, busy, keysEnabled });
// in the render loop: cam.update(dt)   (applies held keys and eases FOV)

export function createFreeCamera(THREE, camera, dom, opts = {}) {
  const {
    target = new THREE.Vector3(),
    baseFov = camera.fov,
    minFov = 8, maxFov = 70,
    floorY = 1, // camera never goes below this
    onClick = () => {}, onRightClick = () => {},
    onDragStart = () => {}, // e.g. cancel a flight
    busy = () => false, // true while a scripted flight runs: wheel/keys pause
    keysEnabled = () => true, // false while a text input / palette has focus
    // fixed speeds, in world units: never scaled by distance or anything else
    moveSpeed = 20, // WASD / Space / Shift, per second
    wheelStep = 0.03, // per wheel pixel (a 120px notch moves 3.6)
    panStep = 0.04, // per mouse pixel
  } = opts;
  const cam = { target, fovWant: baseFov, dragging: false };
  let down = null;
  const held = new Set();
  const NAV = ['ArrowLeft', 'ArrowRight', 'ArrowUp', 'ArrowDown', 'Equal', 'Minus', 'KeyW', 'KeyA', 'KeyS', 'KeyD', 'Space', 'ShiftLeft', 'ShiftRight'];
  const sph = new THREE.Spherical();

  const floor = () => { if (camera.position.y < floorY) { const l = floorY - camera.position.y; camera.position.y += l; target.y += l; } };
  const move = (step) => { camera.position.add(step); target.add(step); floor(); camera.lookAt(target); };
  cam.look = (dYaw, dPitch) => {
    const d = target.clone().sub(camera.position);
    sph.setFromVector3(d);
    sph.theta -= dYaw;
    sph.phi = THREE.MathUtils.clamp(sph.phi + dPitch, 0.02, Math.PI - 0.02);
    target.copy(camera.position).add(d.setFromSpherical(sph));
    camera.lookAt(target);
  };
  cam.zoomBy = (f) => { cam.fovWant = THREE.MathUtils.clamp(cam.fovWant * f, minFov, maxFov); };

  dom.addEventListener('contextmenu', (ev) => ev.preventDefault());
  // Pointer lock: skip the first event after the lock engages, which carries the warp of the
  // cursor to the centre, and drop single huge events (Chromium reports sporadic spikes).
  document.addEventListener('pointerlockchange', () => { if (document.pointerLockElement === dom && down) down.skip = 1; });
  dom.addEventListener('pointerdown', (ev) => { if (ev.button === 1) ev.preventDefault(); /* no autoscroll */ down = { x: ev.clientX, y: ev.clientY, drag: false }; });
  dom.addEventListener('pointerup', (ev) => {
    const wasClick = down && !down.drag && Math.hypot(ev.clientX - down.x, ev.clientY - down.y) <= 5;
    if (down?.drag) dom.style.cursor = '';
    if (document.pointerLockElement === dom) document.exitPointerLock();
    down = null; cam.dragging = false;
    if (!wasClick) return;
    if (ev.button === 0) onClick(ev);
    else if (ev.button === 2) onRightClick(ev);
  });
  dom.addEventListener('pointermove', (ev) => {
    if (!down) return;
    if (!down.drag) {
      if (!(ev.buttons & 7)) return; // left, right or middle
      if (Math.hypot(ev.clientX - down.x, ev.clientY - down.y) <= 5) return;
      // the mode is fixed for the whole drag; buttons can read differently once the pointer is locked
      down.drag = ev.buttons & 1 ? 'look' : 'pan';
      cam.dragging = true;
      onDragStart();
      dom.setPointerCapture?.(ev.pointerId);
      if (down.drag === 'look') dom.requestPointerLock?.()?.catch?.(() => {}); // lock to the centre while looking
      dom.style.cursor = down.drag === 'look' ? 'grabbing' : 'move';
    }
    if (down.drag === 'look') {
      if (down.skip) { down.skip--; return; }
      if (Math.abs(ev.movementX) > 250 || Math.abs(ev.movementY) > 250) return; // a spike, not a hand movement
      const rad = (camera.fov * Math.PI / 180) / innerHeight; // radians per pixel at this zoom
      cam.look(ev.movementX * rad, ev.movementY * rad); // mouse turns the head, as in Minecraft
    } else {
      const right = new THREE.Vector3().setFromMatrixColumn(camera.matrixWorld, 0);
      const up = new THREE.Vector3().setFromMatrixColumn(camera.matrixWorld, 1);
      move(right.multiplyScalar(-ev.movementX * panStep).addScaledVector(up, ev.movementY * panStep));
    }
  });
  dom.addEventListener('wheel', (ev) => {
    ev.preventDefault();
    if (busy()) return;
    const px = ev.deltaY * (ev.deltaMode === 1 ? 33 : ev.deltaMode === 2 ? 800 : 1);
    move(camera.getWorldDirection(new THREE.Vector3()).multiplyScalar(-THREE.MathUtils.clamp(px, -120, 120) * wheelStep));
  }, { passive: false });
  addEventListener('keydown', (ev) => {
    if (keysEnabled() && !ev.target.closest?.('input, textarea, [contenteditable]') && !ev.ctrlKey && !ev.metaKey && !ev.altKey && NAV.includes(ev.code)) { held.add(ev.code); ev.preventDefault(); }
  });
  addEventListener('keyup', (ev) => held.delete(ev.code));
  addEventListener('blur', () => held.clear());

  cam.update = (dt) => {
    camera.fov += (cam.fovWant - camera.fov) * (1 - Math.exp(-8 * dt));
    camera.updateProjectionMatrix();
    if (busy()) return;
    const h = (k) => (held.has(k) ? 1 : 0);
    const yaw = h('ArrowLeft') - h('ArrowRight'), pitch = h('ArrowDown') - h('ArrowUp');
    if (yaw || pitch) cam.look(-yaw * dt * 0.9 * camera.fov / baseFov, pitch * dt * 0.7 * camera.fov / baseFov);
    const z = h('Minus') - h('Equal');
    if (z) cam.zoomBy(Math.exp(z * dt * 1.2));
    const fwd = h('KeyW') - h('KeyS'), side = h('KeyD') - h('KeyA');
    const up = h('Space') - Math.max(h('ShiftLeft'), h('ShiftRight'));
    if (!fwd && !side && !up) return;
    const dir = camera.getWorldDirection(new THREE.Vector3()); // W/S: straight where the camera faces
    const right = new THREE.Vector3().setFromMatrixColumn(camera.matrixWorld, 0).setY(0).normalize(); // A/D: level strafe
    const step = dir.multiplyScalar(fwd).addScaledVector(right, side);
    step.y += up; // Space/Shift: straight up/down
    move(step.multiplyScalar(moveSpeed * dt));
  };
  camera.lookAt(target);
  return cam;
}
