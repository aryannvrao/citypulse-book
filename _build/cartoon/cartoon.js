'use strict';
/* Cartoon engine: draws one frame of a storyboard at time t on a 1280x720 canvas.
   Everything is drawn by code: two characters (Mira, Bolt), seven backgrounds, fifteen scene types.
   setup(story) then renderBatch(firstFrame, lastFrame) -> base64 JPEG frames. */
const W = 1280, H = 720, TAU = Math.PI * 2;
const cv = document.getElementById('c'), ctx = cv.getContext('2d');
const F = '"Segoe UI", Arial, sans-serif', MONO = '"Cascadia Mono", Consolas, monospace', EMO = '"Segoe UI Emoji"';
const INK = '#1f2544';
const PAL = ['#f97316', '#14b8a6', '#6366f1', '#ec4899', '#eab308', '#22c55e', '#0ea5e9'];
const SOFT = ['#ffedd5', '#ccfbf1', '#e0e7ff', '#fce7f3', '#fef9c3', '#dcfce7', '#e0f2fe'];
const BX = 150, BY = 60, BW = 980, BH = 444;
let S = null;

const clamp = (x, a = 0, b = 1) => Math.max(a, Math.min(b, x));
const lerp = (a, b, p) => a + (b - a) * p;
const ease = p => p < .5 ? 4 * p * p * p : 1 - Math.pow(-2 * p + 2, 3) / 2;
const outCubic = p => 1 - Math.pow(1 - p, 3);
const outBack = p => 1 + 2.9 * Math.pow(p - 1, 3) + 1.9 * Math.pow(p - 1, 2);
const outBounce = p => { const n = 7.5625, d = 2.75; return p < 1 / d ? n * p * p : p < 2 / d ? n * (p -= 1.5 / d) * p + .75 : p < 2.5 / d ? n * (p -= 2.25 / d) * p + .9375 : n * (p -= 2.625 / d) * p + .984375; };
const prog = (t, t0, d) => clamp((t - t0) / d);
const pop = (t, t0, d = .38) => t < t0 ? 0 : outBack(prog(t, t0, d));
const rnd = i => { const x = Math.sin(i * 127.1 + 311.7) * 43758.5453; return x - Math.floor(x); };

// ---------- drawing helpers ----------
function paint(fill, stroke, lw = 3) {
  if (fill) { ctx.fillStyle = fill; ctx.fill(); }
  if (stroke) { ctx.strokeStyle = stroke; ctx.lineWidth = lw; ctx.lineJoin = 'round'; ctx.stroke(); }
}
function rr(x, y, w, h, r, fill, stroke, lw) {
  if (w <= 0 || h <= 0) return;
  ctx.beginPath(); ctx.roundRect(x, y, w, h, Math.max(0, Math.min(r, w / 2, h / 2))); paint(fill, stroke, lw);
}
function circ(x, y, r, fill, stroke, lw) { if (r <= 0) return; ctx.beginPath(); ctx.arc(x, y, r, 0, TAU); paint(fill, stroke, lw); }
function ell(x, y, rx, ry, fill, stroke, lw) { if (rx <= 0 || ry <= 0) return; ctx.beginPath(); ctx.ellipse(x, y, rx, ry, 0, 0, TAU); paint(fill, stroke, lw); }
function line(x1, y1, x2, y2, color, lw = 3, dash) {
  ctx.beginPath(); ctx.moveTo(x1, y1); ctx.lineTo(x2, y2); ctx.strokeStyle = color; ctx.lineWidth = lw; ctx.lineCap = 'round';
  if (dash) ctx.setLineDash(dash); ctx.stroke(); if (dash) ctx.setLineDash([]);
}
function poly(pts, fill, stroke, lw) { ctx.beginPath(); pts.forEach((p, i) => i ? ctx.lineTo(p[0], p[1]) : ctx.moveTo(p[0], p[1])); ctx.closePath(); paint(fill, stroke, lw); }
function font(size, weight = 700, fam = F) { ctx.font = `${weight} ${size}px ${fam}`; }
function text(s, x, y, size, color, o = {}) {
  let sz = size; const wt = o.weight || 700, fam = o.fam || F;
  font(sz, wt, fam);
  if (o.w) while (ctx.measureText(s).width > o.w && sz > 9) { sz -= 1; font(sz, wt, fam); }
  ctx.textAlign = o.align || 'center'; ctx.textBaseline = 'middle';
  if (o.stroke) { ctx.lineWidth = o.lw || 8; ctx.strokeStyle = o.stroke; ctx.lineJoin = 'round'; ctx.strokeText(s, x, y); }
  ctx.fillStyle = color; ctx.fillText(s, x, y);
  return sz;
}
function emoji(e, x, y, size) { ctx.font = `${size}px ${EMO}`; ctx.textAlign = 'center'; ctx.textBaseline = 'middle'; ctx.fillStyle = '#000'; ctx.fillText(e, x, y + size * .05); }
function wrap(s, maxW) {
  const out = []; let cur = '';
  for (const w of String(s).split(/\s+/)) { const tr = cur ? cur + ' ' + w : w; if (cur && ctx.measureText(tr).width > maxW) { out.push(cur); cur = w; } else cur = tr; }
  if (cur) out.push(cur); return out;
}
function scaled(x, y, s, fn) { if (s <= 0.001) return; ctx.save(); ctx.translate(x, y); ctx.scale(s, s); fn(); ctx.restore(); }
function pill(s, x, y, size, bg, fg, maxW = 900, lw = 3) {
  const sz = text(s, -9999, -9999, size, fg, { w: maxW - 30 }); font(sz);
  const w = ctx.measureText(s).width + 30, h = sz * 1.75;
  rr(x - w / 2, y - h / 2, w, h, h / 2, bg, INK, lw); text(s, x, y + 1, sz, fg);
  return w;
}
function arrowHead(x, y, ux, uy, size, color) { poly([[x + ux * size, y + uy * size], [x - uy * size * .7, y + ux * size * .7], [x + uy * size * .7, y - ux * size * .7]], color); }
function arrow(x1, y1, x2, y2, color, lw, p = 1) {
  const d = Math.hypot(x2 - x1, y2 - y1) || 1, ux = (x2 - x1) / d, uy = (y2 - y1) / d, ex = lerp(x1, x2 - ux * lw * 2, p), ey = lerp(y1, y2 - uy * lw * 2, p);
  line(x1, y1, ex, ey, color, lw); if (p > .2) arrowHead(ex, ey, ux, uy, lw * 2.2, color);
}
function confetti(cx, cy, t0, t, n = 70) {
  const dt = t - t0; if (dt < 0 || dt > 2.2) return;
  for (let i = 0; i < n; i++) {
    const a = rnd(i) * TAU, sp = 220 + rnd(i + 9) * 420, x = cx + Math.cos(a) * sp * dt, y = cy + Math.sin(a) * sp * dt * .8 - 260 * dt + 620 * dt * dt;
    ctx.save(); ctx.translate(x, y); ctx.rotate(dt * (4 + rnd(i + 3) * 8)); ctx.globalAlpha = clamp(2.2 - dt);
    ctx.fillStyle = PAL[i % 7]; ctx.fillRect(-6, -4, 12, 8); ctx.restore();
  }
}
function note(a, t, y = 458) { if (!a) return; scaled(640, y, pop(t, a.t, .3), () => pill(a.text, 0, 0, 21, '#fef9c3', INK, 880)); }
function tick(x, y, r, p) {           // green disc with a tick that draws itself
  circ(x, y, r, '#22c55e', INK, 3);
  ctx.beginPath(); ctx.moveTo(x - r * .45, y); ctx.lineTo(x - r * .1, y + r * .35);
  if (p > .5) ctx.lineTo(lerp(x - r * .1, x + r * .5, (p - .5) * 2), lerp(y + r * .35, y - r * .4, (p - .5) * 2));
  ctx.strokeStyle = '#fff'; ctx.lineWidth = r * .28; ctx.lineCap = 'round'; ctx.lineJoin = 'round'; ctx.stroke();
}
function cross(x, y, r) {
  circ(x, y, r, '#ef4444', INK, 3);
  line(x - r * .4, y - r * .4, x + r * .4, y + r * .4, '#fff', r * .28); line(x + r * .4, y - r * .4, x - r * .4, y + r * .4, '#fff', r * .28);
}

// ---------- backgrounds ----------
function grad(c1, c2) { const g = ctx.createLinearGradient(0, 0, 0, H); g.addColorStop(0, c1); g.addColorStop(1, c2); ctx.fillStyle = g; ctx.fillRect(0, 0, W, H); }
function cloud(x, y, s, a = 1) {
  ctx.globalAlpha = a; ctx.fillStyle = '#fff';
  for (const [dx, dy, r] of [[0, 0, 30], [36, -14, 38], [76, 0, 30], [38, 10, 34]]) { ctx.beginPath(); ctx.arc(x + dx * s, y + dy * s, r * s, 0, TAU); ctx.fill(); }
  ctx.globalAlpha = 1;
}
function drift(t, speed, off) { return ((t * speed + off) % (W + 400)) - 200; }
function skyline(base, color, seed, hmin, hmax, win, t) {
  let x = -20, i = 0;
  while (x < W) {
    const w = 54 + rnd(seed + i) * 70, h = hmin + rnd(seed + i * 3 + 1) * (hmax - hmin);
    ctx.fillStyle = color; ctx.fillRect(x, base - h, w, h);
    if (win) for (let wy = base - h + 14; wy < base - 16; wy += 26) for (let wx = x + 10; wx < x + w - 16; wx += 21) {
      const k = rnd(seed + wx * 7.3 + wy * 13.1); if (k > .4) { ctx.fillStyle = win(k, t); ctx.fillRect(wx, wy, 10, 13); }
    }
    x += w + 5; i++;
  }
}
function floor(c1, c2) { ctx.fillStyle = c1; ctx.fillRect(0, 648, W, 72); ctx.fillStyle = c2; ctx.fillRect(0, 648, W, 9); }
const SETS = {
  city(t) {
    grad('#7dd3fc', '#fef3c7');
    ctx.save(); ctx.translate(1090, 118); ctx.rotate(t * .25);
    for (let i = 0; i < 12; i++) { ctx.rotate(TAU / 12); poly([[62, -7], [92, 0], [62, 7]], '#fde047'); }
    ctx.restore(); circ(1090, 118, 52, '#fde047', '#f59e0b', 4);
    cloud(drift(t, 14, 300), 110, 1.1, .95); cloud(drift(t, 9, 900), 190, .8, .85); cloud(drift(t, 19, 1300), 70, .65, .8);
    skyline(648, '#a5b4fc', 3, 130, 290);
    skyline(648, '#6366f1', 50, 70, 190, () => '#fef08a');
    floor('#86efac', '#4ade80');
  },
  night(t) {
    grad('#0b1026', '#3730a3');
    for (let i = 0; i < 80; i++) { ctx.globalAlpha = .35 + .65 * Math.abs(Math.sin(t * 1.3 + i * 2.1)); ctx.fillStyle = '#fff'; ctx.fillRect(rnd(i) * W, rnd(i + 40) * 420, 3, 3); }
    ctx.globalAlpha = 1; circ(1090, 112, 46, '#fef9c3', '#fde68a', 4); circ(1074, 100, 9, '#fde68a'); circ(1104, 128, 6, '#fde68a');
    skyline(648, '#312e81', 9, 120, 280);
    skyline(648, '#12163a', 70, 70, 180, (k, t) => Math.sin(t * .6 + k * 50) > -.55 ? '#fde68a' : '#334155');
    floor('#1e293b', '#334155');
  },
  room(t) {
    ctx.fillStyle = '#fde8d0'; ctx.fillRect(0, 0, W, H);
    for (let i = 0; i < 60; i++) circ(40 + (i % 12) * 110, 50 + Math.floor(i / 12) * 120 + (i % 2) * 40, 5, '#fbd5b0');
    rr(880, 90, 250, 200, 14, '#bae6fd', '#fff', 14);
    ctx.save(); ctx.beginPath(); ctx.rect(887, 97, 236, 186); ctx.clip(); cloud(880 + ((t * 10) % 320) - 60, 160, .6); ctx.restore();
    line(1005, 92, 1005, 288, '#fff', 8); line(882, 190, 1128, 190, '#fff', 8);
    rr(120, 212, 300, 14, 4, '#b45309', INK, 3);
    [['#f97316', 30], ['#6366f1', 26], ['#14b8a6', 34], ['#ec4899', 24], ['#eab308', 30], ['#0ea5e9', 28]].forEach(([c, w], i) => rr(140 + i * 40, 212 - 60 - (i % 3) * 8, w, 60 + (i % 3) * 8, 3, c, INK, 3));
    floor('#d6a36c', '#b07a45'); for (let i = 0; i < 9; i++) line(i * 160 + 40, 660, i * 160 - 10, 720, '#b07a45', 3);
  },
  sky(t) {
    grad('#38bdf8', '#e0f2fe');
    for (let i = 0; i < 7; i++) cloud(drift(t, 8 + i * 4, i * 260), 90 + rnd(i) * 380, .6 + rnd(i + 5) * .9, .9);
    for (let i = 0; i < 3; i++) { const x = drift(t, 40, i * 500), y = 130 + i * 60 + Math.sin(t * 3 + i) * 8; ctx.beginPath(); ctx.moveTo(x - 12, y - 6); ctx.quadraticCurveTo(x - 4, y - 10, x, y); ctx.quadraticCurveTo(x + 4, y - 10, x + 12, y - 6); ctx.strokeStyle = INK; ctx.lineWidth = 3; ctx.stroke(); }
    ctx.fillStyle = '#fff'; for (let x = -20; x < W + 60; x += 70) { ctx.beginPath(); ctx.arc(x, 690 + Math.sin(x) * 6, 62, 0, TAU); ctx.fill(); }
  },
  server(t) {
    ctx.fillStyle = '#0f2a3a'; ctx.fillRect(0, 0, W, H);
    for (let i = 0; i < 8; i++) {
      rr(30 + i * 156, 70, 126, 570, 10, '#16384a', '#0b1f2b', 5);
      for (let j = 0; j < 14; j++) { rr(42 + i * 156, 86 + j * 39, 102, 28, 5, '#0f2a3a'); const on = Math.sin(t * (2 + rnd(i * 20 + j) * 5) + i + j) > 0; circ(56 + i * 156, 100 + j * 39, 5, on ? (rnd(i + j * 9) > .3 ? '#4ade80' : '#fbbf24') : '#1e4a5f'); rr(70 + i * 156, 97 + j * 39, 62, 6, 3, '#1e4a5f'); }
    }
    floor('#0b1f2b', '#16384a');
  },
  class(t) {
    ctx.fillStyle = '#fef3c7'; ctx.fillRect(0, 0, W, H);
    rr(50, 24, 1180, 580, 18, '#166534', '#92400e', 16);
    ctx.globalAlpha = .18; ctx.strokeStyle = '#fff'; ctx.lineWidth = 4;
    for (let i = 0; i < 6; i++) { ctx.beginPath(); ctx.arc(160 + i * 190, 90 + (i % 2) * 440, 26 + i * 4, 0, TAU * .7); ctx.stroke(); }
    ctx.globalAlpha = 1; rr(60, 600, 1160, 12, 4, '#b45309', INK, 3); rr(600, 592, 44, 10, 3, '#fff', INK, 2);
    floor('#e2b07a', '#b07a45');
  },
  lab(t) {
    ctx.fillStyle = '#ecfeff'; ctx.fillRect(0, 0, W, H);
    for (let x = 0; x < W; x += 40) line(x, 0, x, 648, '#cffafe', 2); for (let y = 0; y < 648; y += 40) line(0, y, W, y, '#cffafe', 2);
    for (let i = 0; i < 9; i++) {
      const x = rnd(i) * W, y = 80 + rnd(i + 20) * 480 + Math.sin(t * .8 + i) * 14, s = 16 + rnd(i + 7) * 20;
      ctx.save(); ctx.translate(x, y); ctx.rotate(t * .3 + i); ctx.globalAlpha = .5;
      if (i % 3 === 0) circ(0, 0, s, SOFT[i % 7], PAL[i % 7], 3); else if (i % 3 === 1) rr(-s, -s, s * 2, s * 2, 6, SOFT[i % 7], PAL[i % 7], 3); else poly([[0, -s], [s, s], [-s, s]], SOFT[i % 7], PAL[i % 7], 3);
      ctx.restore();
    }
    floor('#a5f3fc', '#67e8f9');
  },
};

// ---------- characters ----------
function arm(x1, y1, x2, y2, color, lw, hand) {
  const mx = (x1 + x2) / 2 + (x1 < 0 ? -12 : 12), my = (y1 + y2) / 2 + 10;
  for (const [c, w] of [[INK, lw + 6], [color, lw]]) { ctx.beginPath(); ctx.moveTo(x1, y1); ctx.quadraticCurveTo(mx, my, x2, y2); ctx.strokeStyle = c; ctx.lineWidth = w; ctx.lineCap = 'round'; ctx.stroke(); }
  circ(x2, y2, lw * .74, hand, INK, 3);
}
function above(m, t, y) {            // little symbol over the head for strong moods
  if (m === 'confused') text('?', 34, y + Math.sin(t * 4) * 4, 44, '#f97316', { weight: 800, stroke: '#fff', lw: 7 });
  if (m === 'shock') text('!', 36, y + Math.sin(t * 14) * 3, 48, '#ef4444', { weight: 800, stroke: '#fff', lw: 7 });
  if (m === 'think') for (let i = 0; i < 3; i++) circ(30 + i * 15, y + 8 - i * 9 + Math.sin(t * 3 + i) * 2, 4 + i * 2, '#fff', INK, 2.5);
  if (m === 'cheer') for (let i = 0; i < 4; i++) { const a = t * 2 + i * TAU / 4; text('✦', Math.cos(a) * 62, y + 40 + Math.sin(a) * 26, 22, PAL[i], { weight: 800 }); }
}
function mira(x, y, s, o) {
  const t = o.t, m = o.mood, jump = m === 'cheer' ? -Math.abs(Math.sin(t * 6)) * 16 : 0;
  const bob = Math.sin(t * 2.2) * 2.5 + (o.speaking ? Math.sin(t * 9) * 1.5 : 0);
  ctx.save(); ctx.translate(x, y); ctx.scale(s, s);
  ell(0, 2, 52 + jump, 9, 'rgba(15,23,42,.22)');
  ctx.translate(0, bob + jump);
  rr(-25, -42, 19, 40, 7, '#334155', INK, 3); rr(6, -42, 19, 40, 7, '#334155', INK, 3);
  rr(-32, -11, 29, 14, 6, '#f43f5e', INK, 3); rr(3, -11, 29, 14, 6, '#f43f5e', INK, 3);
  let L = [-50, -58], R = [50, -58];
  if (o.speaking) R = [60, -100 + Math.sin(t * 7) * 9];
  if (m === 'think') R = [22, -116];
  if (m === 'confused') { L = [-64, -94]; R = [64, -94]; }
  if (m === 'shock') { L = [-48, -146]; R = [48, -146]; }
  if (m === 'cheer') { L = [-58, -198 + Math.sin(t * 9) * 8]; R = [58, -198 - Math.sin(t * 9) * 8]; }
  arm(-30, -102, L[0], L[1], '#14b8a6', 13, '#f6c9a0');
  ctx.beginPath(); ctx.moveTo(-31, -112); ctx.quadraticCurveTo(0, -124, 31, -112); ctx.lineTo(39, -42); ctx.quadraticCurveTo(0, -32, -39, -42); ctx.closePath(); paint('#14b8a6', INK, 3.5);
  rr(-18, -72, 36, 20, 8, '#0d9488'); circ(17, -97, 6.5, '#fde047', INK, 2);
  arm(30, -102, R[0], R[1], '#14b8a6', 13, '#f6c9a0');
  ctx.save(); ctx.translate(0, -152); ctx.rotate(m === 'confused' ? -.09 : m === 'sad' ? .06 : 0);
  circ(0, -4, 49, '#3b2459', INK, 3.5); rr(-50, -6, 22, 54, 10, '#3b2459', INK, 3.5); rr(28, -6, 22, 54, 10, '#3b2459', INK, 3.5);
  circ(31, -47, 17, '#3b2459', INK, 3.5);
  circ(0, 0, 42, '#f6c9a0', INK, 3.5);
  ctx.beginPath(); ctx.moveTo(-42, -4); ctx.quadraticCurveTo(-42, -47, 0, -45); ctx.quadraticCurveTo(42, -47, 42, -4); ctx.quadraticCurveTo(24, -30, 2, -25); ctx.quadraticCurveTo(-20, -19, -42, -4); paint('#3b2459', INK, 3);
  ell(-27, 13, 8, 5, 'rgba(244,114,182,.55)'); ell(27, 13, 8, 5, 'rgba(244,114,182,.55)');
  const blink = (t % 3.7) < .12, lx = o.look * 3.5, ly = m === 'think' ? -4 : m === 'sad' ? 3 : 0;
  for (const sx of [-15, 15]) {
    if (m === 'cheer') { ctx.beginPath(); ctx.arc(sx, 0, 8, Math.PI * 1.1, Math.PI * 1.9); ctx.strokeStyle = INK; ctx.lineWidth = 4; ctx.lineCap = 'round'; ctx.stroke(); continue; }
    if (blink) { line(sx - 7, -2, sx + 7, -2, INK, 3.5); continue; }
    ell(sx, -2, 9, m === 'shock' ? 13 : 10.5, '#fff', INK, 2.5); circ(sx + lx, -2 + ly, m === 'shock' ? 4 : 5.5, INK); circ(sx + lx + 2, -4 + ly, 1.8, '#fff');
  }
  const bl = m === 'shock' ? -22 : -17, br = m === 'shock' || m === 'confused' || m === 'think' ? -23 : -17;
  const sl = m === 'sad' ? 4 : m === 'confused' ? -2 : 0;
  line(-23, bl + sl, -8, bl - sl, INK, 3.5); line(8, br - sl, 23, br + sl, INK, 3.5);
  if (o.speaking) { ell(0, 20, 9, 2.5 + o.talk * 11, '#7f1d1d', INK, 2.5); if (o.talk > .35) ell(0, 24 + o.talk * 4, 5, 3, '#fb7185'); }
  else if (m === 'cheer') { ctx.beginPath(); ctx.arc(0, 14, 13, 0, Math.PI); ctx.closePath(); paint('#7f1d1d', INK, 2.5); }
  else if (m === 'shock') ell(0, 22, 6, 8, '#7f1d1d', INK, 2.5);
  else if (m === 'sad') { ctx.beginPath(); ctx.arc(0, 32, 12, Math.PI * 1.2, Math.PI * 1.8); ctx.strokeStyle = INK; ctx.lineWidth = 3.5; ctx.stroke(); }
  else if (m === 'think' || m === 'confused') line(-6, 22, 8, 20, INK, 3.5);
  else { ctx.beginPath(); ctx.arc(0, 12, 13, Math.PI * .15, Math.PI * .85); ctx.strokeStyle = INK; ctx.lineWidth = 3.5; ctx.lineCap = 'round'; ctx.stroke(); }
  ctx.restore();
  above(m, t, -236);
  ctx.restore();
}
function bolt(x, y, s, o) {
  const t = o.t, m = o.mood, jump = m === 'cheer' ? -Math.abs(Math.sin(t * 6 + 1)) * 14 : 0, bob = Math.sin(t * 2.6 + 1) * 5;
  const C = '#67e8f9';
  ctx.save(); ctx.translate(x, y); ctx.scale(s, s);
  ell(0, 16, 46 - bob, 8, 'rgba(15,23,42,.22)');
  ctx.translate(0, bob + jump);
  const fl = 18 + Math.sin(t * 31) * 5 + rnd(Math.floor(t * 24)) * 6;
  poly([[-13, -30], [0, -30 + fl + 10], [13, -30]], '#fb923c'); poly([[-7, -30], [0, -30 + fl], [7, -30]], '#fde047');
  rr(-21, -46, 42, 18, 7, '#64748b', INK, 3);
  let L = [-54, -62], R = [54, -62];
  if (o.speaking) L = [-62, -104 + Math.sin(t * 7) * 9];
  if (m === 'think') L = [-24, -124];
  if (m === 'confused') { L = [-66, -98]; R = [66, -98]; }
  if (m === 'shock') { L = [-52, -150]; R = [52, -150]; }
  if (m === 'cheer') { L = [-60, -200 + Math.sin(t * 9) * 8]; R = [60, -200 - Math.sin(t * 9) * 8]; }
  arm(-36, -104, L[0], L[1], '#94a3b8', 10, '#64748b'); arm(36, -104, R[0], R[1], '#94a3b8', 10, '#64748b');
  rr(-39, -120, 78, 80, 20, '#fbbf24', INK, 3.5);
  rr(-23, -104, 46, 28, 7, '#1e293b', INK, 2.5);
  for (let i = 0; i < 5; i++) { const h = 4 + (o.speaking ? o.talk : .12) * (7 + 11 * Math.abs(Math.sin(t * 11 + i * 1.7))); rr(-18 + i * 8, -90 - h / 2, 5, h, 2, '#5eead4'); }
  circ(-22, -60, 5, '#ef4444', INK, 2); circ(-7, -60, 5, '#22c55e', INK, 2); rr(6, -65, 22, 10, 4, '#b45309');
  rr(-9, -130, 18, 14, 4, '#94a3b8', INK, 3);
  ctx.save(); ctx.translate(0, -168); ctx.rotate(m === 'confused' ? .09 : m === 'sad' ? -.05 : Math.sin(t * 1.3) * .02);
  line(0, -40, 0, -60, INK, 5);
  if (o.speaking) circ(0, -67, 14 + Math.sin(t * 12) * 3, 'rgba(251,113,133,.4)');
  circ(0, -67, 8, o.speaking ? '#fb7185' : '#f87171', INK, 3);
  rr(-61, -14, 11, 28, 4, '#94a3b8', INK, 3); rr(50, -14, 11, 28, 4, '#94a3b8', INK, 3);
  rr(-52, -40, 104, 80, 24, '#fcd34d', INK, 3.5);
  rr(-42, -31, 84, 60, 16, '#0f172a', INK, 2.5);
  const blink = ((t + 1.3) % 4.1) < .12, lx = o.look * 4, ly = m === 'think' ? -5 : 0;
  ctx.strokeStyle = C; ctx.lineWidth = 5; ctx.lineCap = 'round';
  for (const sx of [-18, 18]) {
    const ex = sx + lx, ey = -8 + ly;
    if (blink) line(ex - 7, ey, ex + 7, ey, C, 4);
    else if (m === 'cheer') { ctx.beginPath(); ctx.arc(ex, ey + 4, 8, Math.PI * 1.1, Math.PI * 1.9); ctx.strokeStyle = C; ctx.lineWidth = 5; ctx.stroke(); }
    else if (m === 'shock') circ(ex, ey, 10, null, C, 4);
    else if (m === 'sad') line(ex - 8, ey + (sx < 0 ? -3 : 3), ex + 8, ey + (sx < 0 ? 3 : -3), C, 5);
    else if (m === 'confused') circ(ex, ey, sx < 0 ? 10 : 5, C);
    else rr(ex - 7, ey - 9, 14, 18, 6, C);
  }
  if (o.speaking) for (let i = 0; i < 5; i++) { const h = 3 + o.talk * (4 + 9 * Math.abs(Math.sin(t * 13 + i * 2.1))); rr(-13 + i * 6, 15 - h / 2, 3.5, h, 1.5, C); }
  else if (m === 'sad') { ctx.beginPath(); ctx.arc(0, 24, 10, Math.PI * 1.2, Math.PI * 1.8); ctx.strokeStyle = C; ctx.lineWidth = 4; ctx.stroke(); }
  else if (m === 'shock') circ(0, 16, 5, null, C, 3.5);
  else { ctx.beginPath(); ctx.arc(0, 8, 11, Math.PI * .2, Math.PI * .8); ctx.strokeStyle = C; ctx.lineWidth = 4; ctx.stroke(); }
  ctx.restore();
  above(m, t, -258);
  ctx.restore();
}
function moodOf(sc, who, bi, t) {
  let m = 'happy';
  for (let i = 0; i <= bi; i++) { const b = sc.beats[i]; if (b.who === who) m = b.mood || (who === 'M' && sc.type === 'trap' && i === 0 ? 'shock' : 'happy'); }
  const last = sc.beats[sc.beats.length - 1];
  if (sc.type === 'quiz' && t > last.t0 + .4) m = 'cheer';
  if (sc.type === 'recap' && t > last.t1 - .2) m = 'cheer';
  return m;
}
function characters(sc, t, bi, speaking, env, big) {
  const s = big ? 1.42 : .92, b = bi >= 0 ? sc.beats[bi] : null, who = b ? b.who : '';
  mira(big ? 205 : 108, 706, s, { t, mood: moodOf(sc, 'M', bi, t), talk: env, speaking: speaking && who === 'M', look: who === 'B' || !big ? 1 : .4 });
  bolt(big ? 1075 : 1172, 706 - 14 * s, s, { t, mood: moodOf(sc, 'B', bi, t), talk: env, speaking: speaking && who === 'B', look: who === 'M' || !big ? -1 : -.4 });
}
function bubble(b, t, big) {
  const x = big ? 340 : 236, w = big ? 600 : 808, y = 524, h = 180, p = pop(t, b.t0 - .06, .22);
  if (p <= 0) return;
  const isM = b.who === 'M', col = isM ? '#0d9488' : '#d97706', cx = x + w / 2, cy = y + h / 2;
  ctx.save(); ctx.translate(cx, cy); ctx.scale(lerp(.86, 1, p), lerp(.86, 1, p)); ctx.translate(-cx, -cy); ctx.globalAlpha = clamp(p * 1.6);
  rr(x + 5, y + 7, w, h, 28, 'rgba(15,23,42,.22)');
  const tx = isM ? x : x + w, d = isM ? -1 : 1;
  poly([[tx - d * 6, y + h - 78], [tx + d * 34, y + h - 44], [tx - d * 6, y + h - 40]], '#fff', INK, 4);
  rr(x, y, w, h, 28, '#fff', INK, 4);
  ctx.fillStyle = '#fff'; ctx.fillRect(tx - (isM ? -2 : 8), y + h - 74, 6, 31);
  const nx = isM ? x + 26 : x + w - 26 - 92; rr(nx, y - 17, 92, 34, 17, col, INK, 3); text(isM ? 'Mira' : 'Bolt', nx + 46, y + 1, 19, '#fff', { weight: 800 });
  let sz = 31, lines;
  for (; sz >= 19; sz--) { font(sz, 600); lines = wrap(b.text, w - 60); if (lines.length * sz * 1.3 <= h - 44) break; }
  const n = b.text.split(/\s+/).length, shown = t >= b.t1 ? n : Math.ceil(prog(t, b.t0, b.t1 - b.t0) * n);
  let k = 0, ly = cy + 8 - (lines.length - 1) * sz * .65;
  ctx.textAlign = 'left'; ctx.textBaseline = 'middle';
  for (const ln of lines) {
    let lx = cx - ctx.measureText(ln).width / 2;
    for (const wd of ln.split(' ')) { ctx.fillStyle = k < shown ? INK : '#cbd5e1'; ctx.fillText(wd, lx, ly); lx += ctx.measureText(wd + ' ').width; k++; }
    ly += sz * 1.3;
  }
  ctx.restore();
}

// ---------- board, HUD, transitions ----------
const TAGS = { same: ['THINK OF IT LIKE THIS', 3], journey: ['HOW IT TRAVELS', 6], code: ['STEP THROUGH THE CODE', 2], term: ['IN THE TERMINAL', 1], chain: ['STEP BY STEP', 0], versus: ['SIDE BY SIDE', 2], table: ['LOOK AT THE DATA', 1], bars: ['COMPARE THE NUMBERS', 0], array: ['WATCH IT MOVE', 3], graph: ['SEE THE SHAPE', 6], trap: ['WATCH OUT', 0], quiz: ['QUICK QUESTION', 2], recap: ['REMEMBER THIS', 5] };
function board(sc) {
  rr(BX + 8, BY + 11, BW, BH, 30, 'rgba(15,23,42,.28)');
  rr(BX, BY, BW, BH, 30, '#fffdf7', INK, 5);
  const [tag, c] = TAGS[sc.type]; font(17, 800); const tw = ctx.measureText(tag).width + 38;
  rr(BX + 30, BY - 17, tw, 36, 18, PAL[c], INK, 3.5); text(tag, BX + 30 + tw / 2, BY + 2, 17, '#fff', { weight: 800 });
}
function hud(sc, t) {
  ctx.fillStyle = 'rgba(15,23,42,.3)'; ctx.fillRect(0, 0, W, 7); ctx.fillStyle = '#f97316'; ctx.fillRect(0, 0, W * t / S.dur, 7);
  if (sc.type !== 'title') { font(16, 700); const s = S.title, w = Math.min(520, ctx.measureText(s).width + 34); rr(BX + BW - w, 14, w, 30, 15, 'rgba(15,23,42,.72)'); text(s, BX + BW - w / 2, 30, 16, '#fff', { w: w - 24 }); }
  const a = prog(t, S.dur - .45, .4); if (a > 0) { ctx.globalAlpha = a; ctx.fillStyle = '#0f172a'; ctx.fillRect(0, 0, W, H); ctx.globalAlpha = 1; }
}
function wipe(t) {
  S.scenes.forEach((sc, i) => {
    let p = (t - (sc.t0 - .32)) / .7;
    if (i === 0) p = t < .9 ? lerp(.457, 1, t / .9) : 2;
    if (p <= 0 || p >= 1) return;
    const BWID = W + 900, x0 = lerp(W + 200, -(BWID + 50), p), cols = ['#fde047', '#fb7185', '#2dd4bf', '#4f46e5'];
    cols.forEach((c, k) => { const a = x0 + k * 60, b = x0 + BWID - k * 60; poly([[a, 0], [b, 0], [b - 180, H], [a - 180, H]], c); });
    if (p > .3 && p < .62) { const sp = S.scenes[i]; emoji(['🚀', '💡', '⚡', '🧩', '🎯', '🔧'][i % 6], 640, 360, 150 * outBack(prog(p, .3, .12))); }
  });
}

// ---------- scenes ----------
const upTo = (sc, t) => sc.acts.filter(a => a.t <= t);
const SCENES = {
  title(sc, t, lt) {
    pill('CITYPULSE MASTERY', 640, 78, 20, '#fde047', INK, 400, 4);
    let sz = 70, lines; for (; sz > 34; sz -= 2) { font(sz, 800); lines = wrap(S.title, 1040); if (lines.length <= 2) break; }
    const p = outBounce(prog(lt, .45, .9));
    lines.forEach((ln, i) => text(ln, 640, lerp(-120, 170 + i * sz * 1.12 - (lines.length - 1) * sz * .4, p), sz, '#fff', { weight: 800, stroke: INK, lw: 14 }));
    scaled(640, 330, pop(lt, 1.3), () => { ctx.rotate(-.03); pill(S.hook, 0, 0, 30, '#fb7185', '#fff', 900, 5); });
    for (let i = 0; i < 6; i++) emoji(['✨', '💻', '⚙️', '📊', '☁️', '🔑'][i], 150 + i * 196, 440 + Math.sin(lt * 2 + i * 1.3) * 12, 40 * pop(lt, 1.6 + i * .12));
  },
  talk(sc, t) {
    let props = [], word = null;
    for (const a of upTo(sc, t)) { if (a.k === 'clear') { props = []; word = null; } else if (a.k === 'word') word = a; else props.push(a); }
    props = props.slice(-4);
    const n = props.length, cw = 168, gap = 22, x0 = 640 - (n * cw + (n - 1) * gap) / 2, py = word && n ? 268 : 232;
    props.forEach((a, i) => scaled(x0 + i * (cw + gap) + cw / 2, py + Math.sin(t * 2 + i) * 5, pop(t, a.t), () => {
      ctx.rotate(Math.sin(t * 1.5 + i * 2) * .03);
      rr(-cw / 2 + 5, -92, cw, 196, 22, 'rgba(15,23,42,.22)'); rr(-cw / 2, -98, cw, 196, 22, SOFT[(i + a.label.length) % 7], INK, 4);
      emoji(a.emoji, 0, -22, 84); text(a.label, 0, 66, 21, INK, { w: cw - 18, weight: 800 });
    }));
    if (word) scaled(640, n ? 112 : 230, pop(t, word.t), () => { ctx.rotate(-.02); pill(word.text, 0, 0, n ? 40 : 58, '#fde047', INK, 880, 5); });
  },
  same(sc, t) {
    const L = sc.data.left, R = sc.data.right, tl = sc.beats[0].t0 + .1, tr = sc.beats[1].t0 + .1;
    const card = (d, x, bg, tag, t0) => scaled(x, 286, pop(t, t0), () => {
      pill(tag, 0, -150, 17, INK, '#fff', 300, 3);
      circ(4, 5, 108, 'rgba(15,23,42,.2)'); circ(0, 0, 108, bg, INK, 5);
      emoji(d.emoji, 0, Math.sin(t * 2.4 + x) * 5, 118); pill(d.label, 0, 142, 24, '#fff', INK, 380, 4);
    });
    card(L, 400, '#fde68a', 'EVERYDAY LIFE', tl);
    if (t < tr) { ctx.setLineDash([12, 12]); circ(880, 286, 108, null, '#cbd5e1', 5); ctx.setLineDash([]); text('?', 880, 286, 110, '#e2e8f0', { weight: 800 }); }
    card(R, 880, '#a5f3fc', 'IN TECH', tr);
    const p = prog(t, tr + .5, .5);
    if (p > 0) { arrow(640, 286, 640 + 96 * p, 286, '#f97316', 9, 1); arrow(640, 286, 640 - 96 * p, 286, '#f97316', 9, 1); scaled(640, 232, pop(t, tr + .8), () => pill('works like', 0, 0, 21, '#f97316', '#fff', 300)); }
  },
  journey(sc, t, lt) {
    const ns = sc.data.nodes, n = ns.length, y = 330, X = i => lerp(BX + 130, BX + BW - 130, n > 1 ? i / (n - 1) : .5);
    const idx = id => ns.findIndex(q => q.id === id), acts = upTo(sc, t), hops = acts.filter(a => a.k === 'hop');
    let glow = []; acts.forEach(a => { if (a.k === 'hi') glow = a.ids; });
    for (let i = 0; i < n - 1; i++) line(X(i) + 66, y, X(i + 1) - 66, y, '#cbd5e1', 4, [10, 12]);
    const Q = (A, B, cy, q) => [(1 - q) * (1 - q) * A + 2 * (1 - q) * q * (A + B) / 2 + q * q * B, (1 - q) * (1 - q) * (y - 64) + 2 * (1 - q) * q * cy + q * q * (y - 64)];
    hops.forEach((a, k) => {
      const age = hops.length - 1 - k; if (age > 2) return;
      const ia = idx(a.a), ib = idx(a.b), A = X(ia), B = X(ib), cy = y - (150 + 36 * Math.abs(ia - ib) + 56 * (k % 2)), e = ease(prog(t, a.t, 1)), col = PAL[k % 7];
      ctx.globalAlpha = age ? .3 : 1;
      ctx.beginPath(); for (let q = 0; q <= e + 1e-6; q += .04) { const [px, py] = Q(A, B, cy, Math.min(q, e)); q ? ctx.lineTo(px, py) : ctx.moveTo(px, py); }
      const [ex, ey] = Q(A, B, cy, e); ctx.lineTo(ex, ey); ctx.strokeStyle = col; ctx.lineWidth = 6; ctx.lineCap = 'round'; ctx.stroke();
      if (e >= 1) { const [qx, qy] = Q(A, B, cy, .93), d = Math.hypot(ex - qx, ey - qy) || 1; arrowHead(ex, ey, (ex - qx) / d, (ey - qy) / d, 13, col); }
      const [lx, ly] = Q(A, B, cy, e >= 1 ? lerp(1, .5, ease(prog(t, a.t + 1, .4))) : e);
      pill(a.label, lx, ly, 19, '#fff', INK, 300, 3.5);
      ctx.globalAlpha = 1;
    });
    ns.forEach((q, i) => scaled(X(i), y, pop(lt, .4 + i * .12), () => {
      const arrive = hops.find(a => a.b === q.id && t > a.t + 1 && t < a.t + 1.6), on = glow.includes(q.id);
      if (on) circ(0, 0, 74 + Math.sin(t * 6) * 4, 'rgba(250,204,21,.45)');
      if (arrive) circ(0, 0, 62 + (t - arrive.t - 1) * 60, null, '#f97316', 5);
      circ(3, 5, 62, 'rgba(15,23,42,.2)'); circ(0, 0, 62, on ? '#fef08a' : '#fff', INK, 4.5);
      emoji(q.emoji, 0, 0, 62); pill(q.label, 0, 92, 19, SOFT[i % 7], INK, 190, 3);
    }));
  },
  code(sc, t, lt) {
    const code = sc.data.code, n = code.length, ex = 174, ey = 104, ew = 606, eh = 388, acts = upTo(sc, t);
    rr(ex, ey, ew, eh, 14, '#1e293b', INK, 4); rr(ex + 2, ey + 2, ew - 4, 32, 12, '#334155');
    ['#fb7185', '#fbbf24', '#4ade80'].forEach((c, i) => circ(ex + 22 + i * 20, ey + 18, 6, c));
    text('main.py', ex + ew / 2, ey + 18, 15, '#cbd5e1', { fam: MONO, weight: 500 });
    const lh = Math.min(31, (eh - 52) / n); let fs = Math.min(21, lh - 7);
    font(fs, 500, MONO); const mx = Math.max(10, ...code.map(c => c.length));
    while (ctx.measureText('M').width * mx > ew - 74 && fs > 10) { fs--; font(fs, 500, MONO); }
    const cw = ctx.measureText('M').width, y0 = ey + 44;
    let cur = null, prev = null; const vars = new Map(), outs = [];
    for (const a of acts) { if (a.k === 'line') { prev = cur; cur = a; } else if (a.k === 'var') vars.set(a.name, { v: a.value, t: a.t, born: vars.has(a.name) ? vars.get(a.name).born : a.t }); else outs.push(a); }
    if (cur) { const ly = y0 + (lerp(prev ? prev.n : cur.n, cur.n, ease(prog(t, cur.t, .3))) - 1) * lh; rr(ex + 6, ly, ew - 12, lh, 6, 'rgba(250,204,21,.22)', '#facc15', 2.5); poly([[ex + 10, ly + lh / 2 - 6], [ex + 19, ly + lh / 2], [ex + 10, ly + lh / 2 + 6]], '#facc15'); }
    code.forEach((c, i) => {
      const a = prog(lt, .45 + i * .07, .25); if (!a) return;
      ctx.globalAlpha = a; text(String(i + 1), ex + 46, y0 + i * lh + lh / 2, fs * .8, '#64748b', { align: 'right', fam: MONO, weight: 500 });
      font(fs, 500, MONO); ctx.textAlign = 'left'; ctx.textBaseline = 'middle'; let x = ex + 58;
      for (const [s, col] of tokens(c)) { ctx.fillStyle = col; ctx.fillText(s, x, y0 + i * lh + lh / 2); x += cw * s.length; }
      ctx.globalAlpha = 1;
    });
    const px = 796, pw = 310;
    rr(px, ey, pw, 232, 14, '#f1f5f9', INK, 4); text('VARIABLES', px + 16, ey + 20, 15, '#64748b', { align: 'left', weight: 800 });
    [...vars].slice(-6).forEach(([name, q], i) => scaled(px + pw / 2, ey + 52 + i * 31, pop(t, q.born, .3), () => {
      rr(-pw / 2 + 12, -13, pw - 24, 27, 8, t - q.t < .7 ? '#fde047' : '#fff', INK, 2.5);
      text(`${name} = ${q.v}`, -pw / 2 + 24, 1, 17, INK, { align: 'left', fam: MONO, weight: 600, w: pw - 48 });
    }));
    rr(px, ey + 242, pw, 146, 14, '#0f172a', INK, 4); text('OUTPUT', px + 16, ey + 262, 15, '#64748b', { align: 'left', weight: 800 });
    outs.slice(-4).forEach((a, i) => { ctx.globalAlpha = prog(t, a.t, .2); text(a.text, px + 16, ey + 290 + i * 25, 16, '#86efac', { align: 'left', fam: MONO, weight: 500, w: pw - 32 }); ctx.globalAlpha = 1; });
  },
  term(sc, t) {
    const x = 174, y = 104, w = 932, h = 388, lines = upTo(sc, t).slice(-11);
    rr(x, y, w, h, 14, '#0f172a', INK, 4); rr(x + 2, y + 2, w - 4, 32, 12, '#334155');
    ['#fb7185', '#fbbf24', '#4ade80'].forEach((c, i) => circ(x + 22 + i * 20, y + 18, 6, c));
    text('mira@citypulse: ~/project', x + w / 2, y + 18, 15, '#cbd5e1', { fam: MONO, weight: 500 });
    font(20, 500, MONO); const cw = ctx.measureText('M').width;
    lines.forEach((a, i) => {
      const ly = y + 60 + i * 30; ctx.textAlign = 'left'; ctx.textBaseline = 'middle'; font(20, 500, MONO);
      if (a.k === 'cmd') {
        const k = Math.ceil(prog(t, a.t, Math.min(.5, .1 + a.text.length * .02)) * a.text.length);
        ctx.fillStyle = '#4ade80'; ctx.fillText('$', x + 22, ly); ctx.fillStyle = '#f8fafc'; ctx.fillText(a.text.slice(0, k), x + 22 + cw * 2, ly);
        if (i === lines.length - 1 && (t * 2 % 1) < .6) ctx.fillRect(x + 22 + cw * (2 + k) + 2, ly - 11, cw * .8, 22);
      } else { ctx.globalAlpha = prog(t, a.t, .2); ctx.fillStyle = '#94a3b8'; ctx.fillText(a.text, x + 22, ly); ctx.globalAlpha = 1; }
    });
  },
  chain(sc, t) {
    const A = sc.acts, n = A.length;
    if (sc.opts.dir === 'pile') {
      const bh = Math.min(68, 376 / n - 8);
      A.forEach((a, i) => {
        const p = prog(t, a.t, .55), bw = 640 - i * 46, yb = 488 - (i + 1) * (bh + 8);
        if (!p) { ctx.setLineDash([8, 8]); rr(640 - bw / 2, yb, bw, bh, 14, null, '#cbd5e1', 3); ctx.setLineDash([]); return; }
        const yy = lerp(yb - 320, yb, outBounce(p)); ctx.globalAlpha = clamp(p * 4);
        rr(640 - bw / 2, yy, bw, bh, 14, SOFT[i % 7], INK, 4); emoji(a.emoji, 640 - bw / 2 + 46, yy + bh / 2, bh * .62);
        text(a.label, 640 + 20, yy + bh / 2, 25, INK, { w: bw - 150, weight: 800 }); ctx.globalAlpha = 1;
      });
      return;
    }
    const gap = 46, bw = Math.min(236, (BW - 80 - (n - 1) * gap) / n), bh = Math.min(230, bw + 40), x0 = 640 - (n * bw + (n - 1) * gap) / 2, y = 290 - bh / 2;
    A.forEach((a, i) => {
      const x = x0 + i * (bw + gap), p = pop(t, a.t);
      if (p <= 0) { ctx.setLineDash([8, 8]); rr(x, y, bw, bh, 18, null, '#cbd5e1', 3); ctx.setLineDash([]); text(String(i + 1), x + bw / 2, y + bh / 2, 44, '#e2e8f0', { weight: 800 }); return; }
      if (i) arrow(x - gap + 5, y + bh / 2, x - 4, y + bh / 2, '#f97316', 7, prog(t, a.t, .3));
      scaled(x + bw / 2, y + bh / 2, p, () => {
        rr(-bw / 2 + 5, -bh / 2 + 7, bw, bh, 18, 'rgba(15,23,42,.2)'); rr(-bw / 2, -bh / 2, bw, bh, 18, SOFT[i % 7], INK, 4);
        emoji(a.emoji, 0, -30 + Math.sin(t * 2.5 + i) * 3, Math.min(70, bw * .5));
        let sz = 20; font(sz, 800); let ls = wrap(a.label, bw - 16); while (ls.length > 2 && sz > 12) { sz--; font(sz, 800); ls = wrap(a.label, bw - 16); }
        ls.forEach((ln, k) => text(ln, 0, 46 + k * sz * 1.2 - (ls.length - 1) * sz * .3, sz, INK, { weight: 800, w: bw - 12 }));
        circ(-bw / 2 + 6, -bh / 2 + 6, 17, PAL[i % 7], INK, 3); text(String(i + 1), -bw / 2 + 6, -bh / 2 + 7, 18, '#fff', { weight: 800 });
      });
    });
  },
  versus(sc, t, lt) {
    const cw = 446, xs = { L: 174, R: 660 }, cols = { L: '#60a5fa', R: '#fb923c' }, cnt = { L: 0, R: 0 };
    for (const side of 'LR') {
      const d = sc.data[side === 'L' ? 'left' : 'right'], x = xs[side];
      scaled(x + cw / 2, 134, pop(lt, side === 'L' ? .4 : .6), () => { rr(-cw / 2, -31, cw, 62, 18, cols[side], INK, 4); if (d.emoji) emoji(d.emoji, -cw / 2 + 40, 0, 36); text(d.label, d.emoji ? 16 : 0, 1, 26, '#fff', { weight: 800, w: cw - 100 }); });
    }
    for (const a of upTo(sc, t)) {
      const i = cnt[a.side]++, x = xs[a.side], y = 184 + i * 76, p = outCubic(prog(t, a.t, .35));
      ctx.globalAlpha = p; const dx = (1 - p) * (a.side === 'L' ? -70 : 70);
      rr(x + dx, y, cw, 62, 14, '#fff', INK, 3.5); circ(x + dx + 30, y + 31, 9, cols[a.side], INK, 2.5);
      text(a.text, x + dx + 52, y + 32, 22, INK, { align: 'left', w: cw - 68, weight: 600 }); ctx.globalAlpha = 1;
    }
    scaled(640, 134, pop(lt, .8), () => { ctx.rotate(Math.sin(t * 3) * .12); circ(0, 0, 33, '#fde047', INK, 4); text('VS', 0, 1, 23, INK, { weight: 800 }); });
  },
  table(sc, t, lt) {
    const hd = sc.data.head, rows = sc.data.rows, nc = hd.length, nr = rows.length, x = 200, w = 880, y = 110, hh = 52, rh = Math.min(56, 322 / nr), cw = w / nc;
    let hr = null, hc = null, kp = null;
    for (const a of upTo(sc, t)) { if (a.k === 'rows') hr = a; else if (a.k === 'col') hc = a; else if (a.k === 'keep') kp = a; else hr = hc = kp = null; }
    rr(x, y, w, hh, 12, '#4f46e5', INK, 4); hd.forEach((c, j) => text(c, x + cw * (j + .5), y + hh / 2 + 1, 21, '#fff', { w: cw - 16, weight: 800 }));
    rows.forEach((r, i) => {
      const ry = y + hh + 7 + i * rh, kept = !kp || kp.rows.includes(i + 1), isH = hr && hr.rows.includes(i + 1);
      ctx.globalAlpha = prog(lt, .4 + i * .08, .3) * (kp && !kept ? lerp(1, .17, prog(t, kp.t, .4)) : 1);
      const g = isH ? 1 + .012 * Math.sin((t - hr.t) * 7) : 1;
      scaled(x + w / 2, ry + (rh - 7) / 2, g, () => {
        rr(-w / 2, -(rh - 7) / 2, w, rh - 7, 10, isH ? '#fde047' : i % 2 ? '#f1f5f9' : '#fff', isH ? INK : '#cbd5e1', isH ? 4 : 2);
        r.forEach((c, j) => text(c, -w / 2 + cw * (j + .5), 1, 21, INK, { w: cw - 16, weight: 600 }));
        if (kp && !kept) line(-w / 2 + 14, 0, w / 2 - 14, 0, '#ef4444', 3);
      });
      ctx.globalAlpha = 1;
    });
    if (hc) { ctx.globalAlpha = prog(t, hc.t, .3); rr(x + cw * (hc.n - 1) + 3, y - 5, cw - 6, hh + 10 + nr * rh, 12, 'rgba(45,212,191,.2)', '#0d9488', 4.5); ctx.globalAlpha = 1; }
  },
  bars(sc, t, lt) {
    const B = sc.data.bars, n = B.length, mx = Math.max(1e-9, ...B.map(b => b.value)), unit = sc.opts.unit ? ' ' + sc.opts.unit : '';
    const ax = 230, aw = 820, base = 432, top = 160, slot = aw / n, bw = Math.min(120, slot * .62);
    let hi = null; for (const a of upTo(sc, t)) hi = a;
    for (let k = 1; k <= 3; k++) line(ax - 20, base - (base - top) * k / 3, ax + aw + 20, base - (base - top) * k / 3, '#e2e8f0', 2, [6, 8]);
    line(ax - 24, base, ax + aw + 24, base, INK, 4);
    B.forEach((b, i) => {
      const g = outCubic(prog(lt, .5 + i * .12, .7)), h = (base - top) * b.value / mx * g, x = ax + slot * (i + .5) - bw / 2, on = !hi || hi.n === i + 1;
      const dec = Math.min(2, (String(b.value).split('.')[1] || '').length), big = hi && hi.n === i + 1 ? 1 + .03 * Math.sin((t - hi.t) * 7) : 1;
      ctx.globalAlpha = on ? 1 : .32;
      rr(x - (big - 1) * bw / 2, base - h * big, bw * big, h * big, 10, PAL[i % 7], INK, 4);
      if (g > 0) text((b.value * g).toFixed(dec) + unit, x + bw / 2, base - h * big - 20, 23, INK, { weight: 800 });
      ctx.globalAlpha = 1; text(b.label, x + bw / 2, base + 26, 20, INK, { w: slot - 10 });
      if (hi && hi.n === i + 1) emoji('👆', x + bw / 2, base + 58 + Math.sin(t * 6) * 3, 26);
    });
  },
  array(sc, t, lt) {
    const vals = sc.data.cells.slice(), n = vals.length, cw = Math.min(90, 880 / n), x0 = 640 - n * cw / 2, y = 176, ch = cw;
    let hi = [], hiT = 0, nt = null, sw = null, setA = null; const done = new Set(), ptr = {};
    for (const a of upTo(sc, t)) {
      if (a.k === 'ptr') for (const k in a.ptrs) ptr[k] = { i: a.ptrs[k], from: ptr[k] ? ptr[k].i : a.ptrs[k], t: a.t, born: ptr[k] ? ptr[k].born : a.t };
      else if (a.k === 'hi') { hi = a.idx; hiT = a.t; } else if (a.k === 'done') a.idx.forEach(i => done.add(i));
      else if (a.k === 'swap') { [vals[a.i], vals[a.j]] = [vals[a.j], vals[a.i]]; sw = a; } else if (a.k === 'set') { vals[a.i] = a.value; setA = a; } else nt = a;
    }
    vals.forEach((v, i) => {
      let dx = 0, dy = 0; const p = sw ? prog(t, sw.t, .55) : 1;
      if (sw && p < 1 && (i === sw.i || i === sw.j)) { const from = i === sw.i ? sw.j : sw.i; dx = (from - i) * cw * (1 - ease(p)); dy = (i === sw.i ? -1 : 1) * Math.sin(Math.PI * p) * 56; }
      const cx = x0 + i * cw + cw / 2 + dx, isH = hi.includes(i), g = pop(lt, .35 + i * .05) * (isH ? 1 + .04 * Math.sin((t - hiT) * 8) : 1) * (setA && setA.i === i ? lerp(1.3, 1, prog(t, setA.t, .3)) : 1);
      scaled(cx, y + ch / 2 + dy, g, () => { rr(-cw / 2 + 4, -ch / 2 + 4, cw - 8, ch - 8, 13, done.has(i) ? '#86efac' : isH ? '#fde047' : '#fff', INK, 4); text(v, 0, 2, Math.min(36, cw * .42), INK, { weight: 800, w: cw - 20 }); });
      text(String(i), x0 + i * cw + cw / 2, y + ch + 14, 16, '#94a3b8', { fam: MONO, weight: 600 });
    });
    const seen = {};
    Object.keys(ptr).forEach((name, k) => {
      const q = ptr[name], pos = lerp(q.from, q.i, ease(prog(t, q.t, .4))), px = x0 + pos * cw + cw / 2, lvl = seen[q.i] = (seen[q.i] || 0) + 1, py = y + ch + 34 + (lvl - 1) * 46;
      scaled(px, py, pop(t, q.born, .3), () => { poly([[0, -6], [-11, 12], [11, 12]], PAL[k % 7], INK, 3); pill(name, 0, 29, 18, PAL[k % 7], '#fff', 120, 3); });
    });
    note(nt, t);
  },
  graph(sc, t, lt) {
    const N = sc.data.nodes, E = sc.data.edges || [], cs = N.map(n => n.col), rs = N.map(n => n.row);
    const c0 = Math.min(...cs), c1 = Math.max(...cs), r0 = Math.min(...rs), r1 = Math.max(...rs), P = {}, R = 38;
    N.forEach(n => P[n.id] = [c1 > c0 ? lerp(250, 1030, (n.col - c0) / (c1 - c0)) : 640, r1 > r0 ? lerp(150, 392, (n.row - r0) / (r1 - r0)) : 270]);
    let hi = [], hiT = 0, nt = null; const done = new Set();
    for (const a of upTo(sc, t)) { if (a.k === 'hi') { hi = a.ids; hiT = a.t; } else if (a.k === 'done') a.ids.forEach(i => done.add(i)); else nt = a; }
    const lit = id => done.has(id) || hi.includes(id);
    E.forEach((e, k) => {
      const [ax, ay] = P[e.a], [bx, by] = P[e.b], d = Math.hypot(bx - ax, by - ay) || 1, ux = (bx - ax) / d, uy = (by - ay) / d, p = prog(lt, .7 + k * .06, .3);
      if (!p) return; const on = lit(e.a) && lit(e.b), col = on ? '#f97316' : '#94a3b8', lw = on ? 7 : 5;
      if (e.dir) arrow(ax + ux * R, ay + uy * R, bx - ux * (R + 3), by - uy * (R + 3), col, lw, p); else line(ax + ux * R, ay + uy * R, lerp(ax + ux * R, bx - ux * R, p), lerp(ay + uy * R, by - uy * R, p), col, lw);
    });
    N.forEach((n, i) => { const [x, y] = P[n.id], isH = hi.includes(n.id); scaled(x, y, pop(lt, .35 + i * .07) * (isH ? 1 + .07 * Math.sin((t - hiT) * 8) : 1), () => { circ(3, 5, R, 'rgba(15,23,42,.2)'); circ(0, 0, R, done.has(n.id) ? '#86efac' : isH ? '#fde047' : '#fff', INK, 4.5); text(n.label, 0, 1, 19, INK, { w: R * 2 - 12, weight: 800 }); }); });
    note(nt, t);
  },
  trap(sc, t) {
    const t0 = sc.beats[0].t0 + .1, t1 = sc.beats[1].t0 + .15;
    ctx.save(); ctx.beginPath(); const hy = BY + BH - 46; ctx.roundRect(BX + 4, hy, BW - 8, 42, [0, 0, 26, 26]); ctx.clip();
    ctx.fillStyle = '#fde047'; ctx.fillRect(BX, hy, BW, 46);
    for (let x = BX - 60 + (t * 30) % 64; x < BX + BW + 60; x += 64) poly([[x, hy + 46], [x + 32, hy + 46], [x + 62, hy], [x + 30, hy]], '#1f2544');
    ctx.restore();
    const card = (s, y, bg, edge, ok, t0) => { const p = outCubic(prog(t, t0, .4)); if (!p) return; ctx.globalAlpha = p; const yy = y + (1 - p) * 40;
      rr(184, yy, 912, 112, 18, bg, edge, 5); ok ? tick(244, yy + 56, 30, prog(t, t0 + .2, .4)) : cross(244, yy + 56, 30);
      text(ok ? 'DO THIS' : 'NOT THIS', 296, yy + 28, 16, edge, { align: 'left', weight: 800 });
      text(s, 296, yy + 66, 25, INK, { align: 'left', fam: MONO, weight: 600, w: 780 }); ctx.globalAlpha = 1; };
    card(sc.data.wrong, 100, '#fee2e2', '#dc2626', false, t0); card(sc.data.right, 228, '#dcfce7', '#16a34a', true, t1);
    const sp = prog(t, t0 + .2, .25);
    if (sp > 0) { ctx.save(); ctx.translate(940, 398); ctx.rotate(-.14); ctx.scale(lerp(3, 1, outCubic(sp)), lerp(3, 1, outCubic(sp))); ctx.globalAlpha = sp; rr(-112, -38, 224, 76, 12, null, '#dc2626', 7); text('TRAP!', 0, 2, 54, '#dc2626', { weight: 800 }); ctx.restore(); }
    if (t > t1) emoji('💡', 250, 398 + Math.sin(t * 4) * 5, 56 * pop(t, t1 + .3));
  },
  quiz(sc, t, lt) {
    const o = sc.data.options, tr = sc.beats[sc.beats.length - 1].t0 + .4, done = t >= tr;
    font(29, 800); const ls = wrap(sc.data.q, 880); ls.forEach((ln, i) => text(ln, 640, 138 + i * 38 - (ls.length - 1) * 19, 29, INK, { weight: 800, w: 890 }));
    const tp = 1 - prog(t, sc.t0 + 1, tr - sc.t0 - 1);
    rr(340, 196, 600, 14, 7, '#e2e8f0', INK, 2.5); if (!done) rr(340, 196, 600 * tp, 14, 7, tp > .3 ? '#22c55e' : '#ef4444', INK, 2.5);
    o.forEach((q, i) => {
      const x = i % 2 ? 870 : 410, y = 268 + Math.floor(i / 2) * 92, p = pop(lt, .8 + i * .15);
      ctx.globalAlpha = done && !q.ok ? lerp(1, .32, prog(t, tr, .3)) : 1;
      scaled(x, y, p * (done && q.ok ? 1 + .06 * Math.abs(Math.sin((t - tr) * 5)) : 1), () => {
        rr(-218, -34, 436, 68, 34, done && q.ok ? '#86efac' : '#fff', INK, 4);
        if (done && q.ok) tick(-184, 0, 22, prog(t, tr, .4)); else { circ(-184, 0, 22, PAL[i], INK, 3); text('ABCD'[i], -184, 1, 21, '#fff', { weight: 800 }); }
        text(q.text, -150, 1, 22, INK, { align: 'left', w: 350, weight: 700 });
      });
      ctx.globalAlpha = 1;
      if (q.ok) confetti(x, y, tr, t);
    });
  },
  recap(sc, t, lt) {
    const A = sc.acts, n = A.length, rh = Math.min(72, 372 / n), last = sc.beats[sc.beats.length - 1];
    A.forEach((a, i) => {
      const y = 116 + i * rh + rh / 2;
      if (t < a.t) { ctx.setLineDash([8, 8]); rr(260, y - rh / 2 + 6, 760, rh - 12, 16, null, '#e2e8f0', 3); ctx.setLineDash([]); return; }
      scaled(640, y, pop(t, a.t), () => { rr(-380, -rh / 2 + 6, 760, rh - 12, 16, SOFT[i % 7], INK, 4); tick(-340, 0, Math.min(21, rh * .3), prog(t, a.t + .15, .4)); text(a.text, -300, 1, 26, INK, { align: 'left', w: 660, weight: 800 }); });
    });
    confetti(640, 300, last.t1 - .1, t, 110);
  },
};

const KW = new Set('def return if elif else for while in not and or import from as class with try except finally raise None True False lambda pass break continue is yield assert SELECT FROM WHERE GROUP BY ORDER JOIN ON AS AND OR INSERT INTO VALUES CREATE TABLE LIMIT HAVING COUNT SUM AVG'.split(' '));
const BI = new Set('print len range sum int str float list dict set sorted min max enumerate zip open abs round isinstance tuple any all map filter self'.split(' '));
function tokens(s) {
  const out = [], re = /(#.*$|--.*$)|("(?:[^"\\]|\\.)*"|'(?:[^'\\]|\\.)*')|(\b\d+(?:\.\d+)?\b)|([A-Za-z_]\w*)|(\s+)|(.)/g; let m;
  while ((m = re.exec(s))) out.push([m[0], m[1] ? '#94a3b8' : m[2] ? '#fca5a5' : m[3] ? '#fdba74' : m[4] ? (KW.has(m[4]) ? '#c4b5fd' : BI.has(m[4]) ? '#7dd3fc' : '#e2e8f0') : m[6] ? '#f9a8d4' : '#e2e8f0']);
  return out;
}

// ---------- frame ----------
function draw(t, f) {
  let si = 0; S.scenes.forEach((s, i) => { if (t >= s.t0) si = i; });
  const sc = S.scenes[si], lt = t - sc.t0, big = sc.type === 'title' || sc.type === 'talk';
  let bi = -1; sc.beats.forEach((b, i) => { if (t >= b.t0 - .06) bi = i; });
  const beat = bi >= 0 ? sc.beats[bi] : null, speaking = !!beat && t >= beat.t0 && t < beat.t1, env = speaking ? (S.env[f] || 0) : 0;
  ctx.setTransform(1, 0, 0, 1, 0, 0); ctx.globalAlpha = 1; ctx.setLineDash([]);
  ctx.save();
  if (sc.type === 'trap') { const k = t - sc.beats[0].t0 - .3; if (k > 0 && k < .45) ctx.translate(Math.sin(k * 90) * 9 * (1 - k / .45), Math.cos(k * 70) * 6 * (1 - k / .45)); }
  SETS[sc.set] ? SETS[sc.set](t) : SETS.city(t);
  if (!big) board(sc);
  SCENES[sc.type](sc, t, lt);
  characters(sc, t, bi, speaking, env, big);
  if (beat) bubble(beat, t, big);
  ctx.restore();
  hud(sc, t); wipe(t);
}
function setup(story) {
  S = story;
  for (const sc of S.scenes) { sc.acts = []; sc.beats.forEach((b, i) => b.acts.forEach(a => { a.beat = i; sc.acts.push(a); })); }
  draw(0, 0);
  return S.scenes.length;
}
function renderBatch(a, b) {
  const out = [];
  for (let f = a; f < b; f++) { draw(f / S.fps, f); out.push(cv.toDataURL('image/jpeg', .9).slice(23)); }
  return out;
}
