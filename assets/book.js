(function () {
  'use strict';
  var $ = function (s, r) { return (r || document).querySelector(s); };
  var $$ = function (s, r) { return Array.prototype.slice.call((r || document).querySelectorAll(s)); };
  var calm = matchMedia('(prefers-reduced-motion: reduce)').matches;
  function el(tag, cls, text) { var e = document.createElement(tag); if (cls) e.className = cls; if (text != null) e.textContent = text; return e; }
  function fmt(s) {
    return String(s).replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;')
      .replace(/`([^`]+)`/g, '<code>$1</code>').replace(/\*\*([^*]+)\*\*/g, '<b>$1</b>');
  }
  function store(k, v) {
    try { if (v === undefined) return JSON.parse(localStorage.getItem(k) || 'null'); localStorage.setItem(k, JSON.stringify(v)); } catch (e) { return null; }
  }

  /* theme, menu, reading bar */
  $('#theme').onclick = function () {
    var t = document.documentElement.dataset.theme === 'dark' ? 'light' : 'dark';
    document.documentElement.dataset.theme = t; try { localStorage.setItem('cpm-theme', t); } catch (e) {}
  };
  var side = $('#side');
  $('#menu').onclick = function () { side.classList.toggle('open'); };
  $('main').addEventListener('click', function () { side.classList.remove('open'); });
  var bar = $('#bar');
  addEventListener('scroll', function () {
    var h = document.documentElement; bar.style.width = (h.scrollTop / Math.max(1, h.scrollHeight - h.clientHeight) * 100) + '%';
  }, { passive: true });
  var cur = $('.side a.cur'); if (cur) cur.scrollIntoView({ block: 'center' });

  /* progress */
  var done = store('cpm-done') || [];
  function paint() {
    $$('[data-id]').forEach(function (a) { a.classList.toggle('is-done', done.indexOf(a.dataset.id) >= 0); });
    var total = +document.body.dataset.total || 1, pct = Math.round(done.length / total * 100);
    var ring = $('#ring');
    if (ring) {
      ring.style.setProperty('--p', pct); $('#pct').textContent = pct + '%';
      $('#pcount').textContent = done.length + ' of ' + total + ' chapters complete';
      var next = $$('a.tile').filter(function (a) { return done.indexOf(a.dataset.id) < 0; })[0];
      if (next) { $('#cont').href = next.getAttribute('href'); $('#cont').textContent = (done.length ? 'Continue: ' : 'Start: ') + $('b', next).textContent; }
    }
    var b = $('#done');
    if (b) { var is = done.indexOf(document.body.dataset.ch) >= 0; b.classList.toggle('yes', is); b.textContent = is ? 'Chapter complete (click to undo)' : 'Mark this chapter complete'; }
  }
  var db = $('#done');
  if (db) db.onclick = function () {
    var id = document.body.dataset.ch, i = done.indexOf(id);
    if (i >= 0) done.splice(i, 1); else done.push(id);
    store('cpm-done', done); paint();
  };
  paint();

  /* tables and copy buttons */
  $$('article table').forEach(function (t) { var w = el('div', 'tw'); t.parentNode.insertBefore(w, t); w.appendChild(t); });
  $$('article pre').forEach(function (p) {
    if (p.closest('div.w')) return;
    var b = el('button', 'copy', 'Copy');
    b.onclick = function () { navigator.clipboard && navigator.clipboard.writeText(p.innerText.replace(/\nCopy$/, '')).then(function () { b.textContent = 'Copied'; setTimeout(function () { b.textContent = 'Copy'; }, 1200); }); };
    (p.parentNode.classList.contains('hl') ? p.parentNode : p).appendChild(b);
  });

  /* run a callback the first time an element is mostly on screen */
  function onSeen(node, fn) {
    if (!('IntersectionObserver' in window)) { fn(); return; }
    var io = new IntersectionObserver(function (es) { if (es[0].isIntersecting) { io.disconnect(); fn(); } }, { threshold: 0.5 });
    io.observe(node);
  }

  function head(root, tag, title) {
    var h = el('div', 'wh'); h.appendChild(el('span', 'wt', tag)); h.appendChild(el('span', '', title || '')); root.appendChild(h);
  }

  /* shared step controls for trace and flow */
  var bare = null, stash = [];
  function stepper(root, n, render, ms) {
    if (bare) { bare.n = n; bare.render = render; render(0); return; }
    var i = 0, timer = null, ctl = el('div', 'ctl');
    var back = el('button', '', 'Back'), play = el('button', 'go', 'Play'), next = el('button', '', 'Next');
    var range = el('input'); range.type = 'range'; range.min = 0; range.max = n - 1; range.value = 0; range.setAttribute('aria-label', 'Step');
    var cnt = el('span', 'cnt');
    function go(k) { i = Math.max(0, Math.min(n - 1, k)); range.value = i; cnt.textContent = (i + 1) + ' / ' + n; render(i); }
    function stop() { clearInterval(timer); timer = null; play.textContent = 'Play'; }
    function start() {
      if (i >= n - 1) go(0);
      play.textContent = 'Pause';
      timer = setInterval(function () { if (i >= n - 1) stop(); else go(i + 1); }, ms || 2200);
    }
    play.onclick = function () { if (timer) stop(); else start(); };
    back.onclick = function () { stop(); go(i - 1); };
    next.onclick = function () { stop(); go(i + 1); };
    range.oninput = function () { stop(); go(+range.value); };
    [back, play, next, range, cnt].forEach(function (x) { ctl.appendChild(x); });
    root.appendChild(ctl);
    go(0);
    if (!calm) onSeen(root, function () { if (!timer && i === 0) start(); });
  }

  var W = {};

  W.trace = function (root, d) {
    head(root, 'Step through', d.title);
    var grid = el('div', 'tr'), code = el('div', 'tr-code'), state = el('div', 'tr-state'), cap = el('div', 'cap');
    var lines = d.code.map(function (t, k) {
      var ln = el('div', 'ln'); ln.appendChild(el('i', '', k + 1)); ln.appendChild(el('span', '', t || ' ')); code.appendChild(ln); return ln;
    });
    grid.appendChild(code); grid.appendChild(state); root.appendChild(grid); root.appendChild(cap);
    stepper(root, d.steps.length, function (i) {
      var s = d.steps[i], prev = {};
      if (i > 0) d.steps[i - 1].state.forEach(function (p) { prev[p[0]] = p[1]; });
      lines.forEach(function (ln, k) { ln.classList.toggle('on', k === s.line - 1); });
      var on = lines[s.line - 1];
      if (on) code.scrollTop = Math.max(0, on.offsetTop - code.clientHeight / 2);
      state.innerHTML = ''; state.appendChild(el('small', '', 'Variables'));
      if (!s.state.length) state.appendChild(el('div', 'chip', 'nothing yet'));
      s.state.forEach(function (p) {
        var c = el('div', 'chip' + (i > 0 && prev[p[0]] !== p[1] ? ' chg' : ''));
        c.appendChild(el('b', '', p[0])); c.appendChild(document.createTextNode(' = ' + p[1])); state.appendChild(c);
      });
      cap.innerHTML = fmt(s.note);
    });
  };

  W.flow = function (root, d) {
    head(root, 'Watch it move', d.title);
    var box = el('div', 'fl'), row = el('div', 'fl-nodes'), pkt = el('div', 'pkt jump'), cap = el('div', 'cap');
    var nodes = d.nodes.map(function (t) { var n = el('div', 'node', t); row.appendChild(n); return n; });
    box.appendChild(pkt); box.appendChild(row); root.appendChild(box); root.appendChild(cap);
    function mid(k) { var n = nodes[k]; return row.offsetLeft + n.offsetLeft + n.offsetWidth / 2; }
    stepper(root, d.steps.length, function (i) {
      var s = d.steps[i];
      nodes.forEach(function (n, k) { n.classList.toggle('on', k === s.from || k === s.to); });
      pkt.textContent = s.label || '';
      pkt.style.visibility = s.label ? 'visible' : 'hidden';
      pkt.classList.add('jump'); pkt.style.left = mid(s.from) + 'px';
      void pkt.offsetWidth;
      pkt.classList.remove('jump'); pkt.style.left = mid(s.to) + 'px';
      cap.innerHTML = fmt(s.note);
    }, 2600);
  };

  W.term = function (root, d) {
    head(root, 'Terminal', '');
    var scr = el('div', 'tm'), ctl = el('div', 'ctl'), again = el('button', '', 'Replay'), run = 0;
    root.appendChild(scr); ctl.appendChild(again); root.appendChild(ctl);
    function show(instant) {
      var me = ++run; scr.innerHTML = '';
      var caret = el('span', 'caret');
      function line(k) {
        if (me !== run) return;
        if (k >= d.lines.length) { scr.appendChild(caret); return; }
        var L = d.lines[k], row = el('div');
        scr.appendChild(row);
        if (L.t !== 'cmd') { row.textContent = L.s || ' '; return instant ? line(k + 1) : setTimeout(function () { line(k + 1); }, 90); }
        row.appendChild(el('span', 'p', '$ ')); var c = el('span', 'c'); row.appendChild(c);
        if (instant) { c.textContent = L.s; return line(k + 1); }
        row.appendChild(caret); var j = 0;
        (function type() {
          if (me !== run) return;
          if (j < L.s.length) { c.textContent += L.s.charAt(j++); setTimeout(type, 28); }
          else setTimeout(function () { line(k + 1); }, 420);
        })();
      }
      line(0);
    }
    again.onclick = function () { show(false); };
    if (calm) show(true); else { show(true); onSeen(root, function () { show(false); }); }
  };

  W.quiz = function (root, d) {
    head(root, 'Check yourself', d.qs.length + (d.qs.length > 1 ? ' questions' : ' question'));
    var right = 0, answered = 0, body = el('div'), foot = el('div', 'score'), tally = el('span'), again = el('button', 'btn', 'Try again');
    function build() {
      right = 0; answered = 0; body.innerHTML = '';
      d.qs.forEach(function (q, k) {
        var box = el('div', 'q'), p = el('p');
        p.innerHTML = '<span class="n">' + (k + 1) + '.</span>' + fmt(q.q);
        box.appendChild(p);
        var opts = q.opts.map(function (t, j) {
          var b = el('button', 'opt'); b.innerHTML = fmt(t);
          b.onclick = function () {
            opts.forEach(function (o) { o.disabled = true; });
            opts[q.ans].classList.add('right');
            if (j === q.ans) right++; else b.classList.add('wrong');
            answered++; box.classList.add('ans'); score();
          };
          box.appendChild(b); return b;
        });
        var why = el('div', 'why'); why.innerHTML = fmt(q.why || ''); box.appendChild(why);
        body.appendChild(box);
      });
      score();
    }
    function score() {
      var n = d.qs.length;
      tally.textContent = answered < n ? answered + ' of ' + n + ' answered' :
        'Score: ' + right + ' / ' + n + (right / n >= 0.9 ? ' — ready.' : right / n >= 0.7 ? ' — a pass, but re-read what you missed.' : ' — below the 70% pass mark. Re-read, then try again.');
      again.style.display = answered ? '' : 'none';
    }
    again.onclick = build;
    foot.appendChild(tally); foot.appendChild(again); root.appendChild(body); root.appendChild(foot);
    build();
  };

  W.cards = function (root, d) {
    head(root, 'Flashcards', 'click a card to flip it');
    var g = el('div', 'cards');
    d.cards.forEach(function (c) {
      var b = el('button', 'card'), s = el('span'), f = el('em'), k = el('em');
      f.innerHTML = fmt(c.q); k.innerHTML = fmt(c.a); s.appendChild(f); s.appendChild(k); b.appendChild(s);
      b.onclick = function () { b.classList.toggle('flip'); };
      g.appendChild(b);
    });
    root.appendChild(g);
  };

  $$('.w[data-w]').forEach(function (root) {
    var kind = (root.className.match(/w-(\w+)/) || [])[1];
    try { var data = JSON.parse(root.dataset.w); stash.push([kind, data]); W[kind](root, data); root.removeAttribute('data-w'); } catch (e) { root.textContent = 'This block could not be shown.'; }
  });

  /* narrated explainer: plays the chapter's own animations with speech */
  (function () {
    var art = $('article'), meta = art && $('.meta', art), h1 = art && $('h1', art);
    if (!meta || !h1) return;
    var subText = ($('.sub', art) || {}).textContent || '';
    var scenes = [{ kind: 'title', beats: [h1.textContent + '. ' + subText] }];
    var h2 = $('h2', art), intro = [];
    if (h2) for (var n = h2.nextElementSibling; n && n.tagName !== 'H2'; n = n.nextElementSibling) if (n.tagName === 'P') intro.push(n.textContent);
    var sents = (intro.join(' ').match(/[^.!?]+[.!?]+(?=\s|$)/g) || []).map(function (s) { return s.trim(); }), keep = [], wc = 0;
    sents.some(function (s) { wc += s.split(/\s+/).length; keep.push(s); return wc > 120 || keep.length >= 7; });
    if (keep.length) scenes.push({ kind: 'text', head: h2.textContent, beats: keep });
    stash.forEach(function (w) {
      if (w[0] === 'flow' || w[0] === 'trace') scenes.push({ kind: w[0], d: w[1], beats: [(w[1].title || 'Watch this') + '.'].concat(w[1].steps.map(function (s) { return s.note || s.label || 'Next step.'; })) });
    });
    var cards = stash.filter(function (w) { return w[0] === 'cards'; })[0];
    if (cards) {
      var cs = cards[1].cards.slice(0, 6);
      scenes.push({ kind: 'facts', cards: cs, beats: ['Things to remember.'].concat(cs.map(function (c) { return c.q + ': ' + c.a; })) });
    }
    scenes.push({ kind: 'end', beats: ['That is the outline. Now read the chapter, take its practice quiz, and solve the practice problem before you open the real ones.'] });
    var total = 0, words = 0;
    scenes.forEach(function (s) { total += s.beats.length; s.beats.forEach(function (b) { words += b.split(/\s+/).length; }); });
    var open = el('button', 'btn xp-open', 'Play it interactively · about ' + Math.max(1, Math.round(words / 140)) + ' min');
    var after = $('.vid', art) || meta;
    after.parentNode.insertBefore(open, after.nextSibling);

    var ov, stage, capn, fill, bPlay, bSound, bSpeed, si = 0, bi = 0, playing = false, tok = 0, timer = null, muted = false, rate = 1, voice = null, hook = null;
    function pick() {
      var vs = (window.speechSynthesis && speechSynthesis.getVoices()) || [];
      var order = [/en-IN.*Natural/i, /en-GB.*Natural/i, /Natural.*English/i, /en-IN/i, /Google UK English/i, /en-GB/i, /en-US/i, /^en/i];
      for (var k = 0; k < order.length && !voice; k++) voice = vs.filter(function (v) { return order[k].test(v.lang + ' ' + v.name); })[0] || null;
    }
    function say(text, cb) {
      var w = text.split(/\s+/).length, fired = false, fin = function () { if (!fired) { fired = true; cb(); } };
      if (muted || !window.speechSynthesis) { timer = setTimeout(fin, Math.max(2200, w * 380) / rate); return; }
      speechSynthesis.cancel();
      var u = new SpeechSynthesisUtterance(text.replace(/[`*_]/g, '').replace(/->/g, ' to '));
      u.rate = rate; if (voice) { u.voice = voice; u.lang = voice.lang; } u.onend = fin; u.onerror = fin;
      speechSynthesis.speak(u);
      timer = setTimeout(fin, (w * 650 + 5000) / rate);
    }
    function enter() {
      var s = scenes[si]; stage.innerHTML = ''; hook = null;
      if (s.kind === 'title' || s.kind === 'end') {
        stage.appendChild(el('p', 'kicker', s.kind === 'title' ? 'Explainer' : 'Your turn'));
        stage.appendChild(el('div', 'xp-title', s.kind === 'title' ? h1.textContent : 'Now practise'));
        stage.appendChild(el('p', 'xp-sub', s.kind === 'title' ? subText : s.beats[0]));
      } else if (s.kind === 'text' || s.kind === 'facts') {
        stage.appendChild(el('div', 'xp-head', s.kind === 'text' ? s.head : 'Things to remember'));
        var box = el('div', s.kind === 'text' ? 'xp-lines' : 'xp-facts'), rows;
        if (s.kind === 'text') rows = s.beats.map(function (t) { var p = el('p', '', t); box.appendChild(p); return p; });
        else rows = s.cards.map(function (c) { var d = el('div'); d.appendChild(el('b', '', c.q)); d.appendChild(el('span', '', c.a)); box.appendChild(d); return d; });
        stage.appendChild(box);
        var off = s.kind === 'text' ? 0 : 1;
        hook = function (i) { rows.forEach(function (r, k) { r.className = k === i - off ? 'on' : k < i - off ? 'seen' : ''; }); };
      } else {
        var node = el('div', 'w w-' + s.kind); stage.appendChild(node);
        bare = {}; try { W[s.kind](node, s.d); } catch (e) {} var b = bare; bare = null;
        hook = function (i) { if (i > 0 && b.render) b.render(i - 1); };
      }
    }
    function paint() { bPlay.textContent = playing ? 'Pause' : 'Play'; bSound.textContent = muted ? 'Sound off' : 'Sound on'; bSpeed.textContent = 'Speed ' + rate + 'x'; }
    function beat() {
      clearTimeout(timer); var me = ++tok, s = scenes[si], text = s.beats[bi], seen = bi;
      for (var k = 0; k < si; k++) seen += scenes[k].beats.length;
      if (hook) hook(bi);
      capn.innerHTML = fmt(text); fill.style.width = ((seen + 1) / total * 100) + '%'; paint();
      if (playing) say(text, function () { if (me === tok) timer = setTimeout(next, 350); });
    }
    function next() {
      if (bi + 1 < scenes[si].beats.length) { bi++; beat(); }
      else if (si + 1 < scenes.length) { si++; bi = 0; enter(); beat(); }
      else { playing = false; paint(); }
    }
    function halt() { playing = false; tok++; clearTimeout(timer); if (window.speechSynthesis) speechSynthesis.cancel(); paint(); }
    function jump(d) { var was = playing; halt(); si = Math.max(0, Math.min(scenes.length - 1, si + d)); bi = 0; enter(); playing = was; beat(); }
    function close() { halt(); ov.style.display = 'none'; document.body.style.overflow = ''; }
    function build() {
      ov = el('div', 'xp'); var top = el('div', 'xp-top'), x = el('button', '', 'Close'), bar = el('div', 'xp-bar'), ctl = el('div', 'ctl');
      top.appendChild(el('span', '', h1.textContent)); top.appendChild(x); x.onclick = close;
      stage = el('div', 'xp-stage'); capn = el('div', 'xp-cap'); fill = el('i'); bar.appendChild(fill);
      var bPrev = el('button', '', 'Previous part'), bNext = el('button', '', 'Next part');
      bPlay = el('button', 'go'); bSound = el('button'); bSpeed = el('button');
      bPrev.onclick = function () { jump(-1); }; bNext.onclick = function () { jump(1); };
      bPlay.onclick = function () {
        if (playing) { halt(); return; }
        playing = true;
        if (si === scenes.length - 1 && bi === scenes[si].beats.length - 1) { si = 0; bi = 0; enter(); }
        beat();
      };
      bSound.onclick = function () { muted = !muted; if (window.speechSynthesis) speechSynthesis.cancel(); if (playing) beat(); else paint(); };
      bSpeed.onclick = function () { rate = rate === 1 ? 1.25 : rate === 1.25 ? 0.85 : 1; if (playing) beat(); else paint(); };
      [bPrev, bPlay, bNext, bSound, bSpeed].forEach(function (b) { ctl.appendChild(b); });
      [top, stage, capn, bar, ctl].forEach(function (n) { ov.appendChild(n); });
      document.body.appendChild(ov);
      addEventListener('keydown', function (e) {
        if (ov.style.display === 'none') return;
        if (e.key === 'Escape') close(); else if (e.key === ' ') { e.preventDefault(); bPlay.click(); }
        else if (e.key === 'ArrowRight') jump(1); else if (e.key === 'ArrowLeft') jump(-1);
      });
      if (window.speechSynthesis) { pick(); speechSynthesis.onvoiceschanged = pick; }
    }
    open.onclick = function () {
      if (!ov) build();
      ov.style.display = 'flex'; document.body.style.overflow = 'hidden';
      si = 0; bi = 0; playing = true; enter(); beat();
    };
  })();

  /* gentle reveal as sections scroll in */
  if (!calm && 'IntersectionObserver' in window) {
    var io = new IntersectionObserver(function (es) {
      es.forEach(function (e) { if (e.isIntersecting) { e.target.classList.add('in'); io.unobserve(e.target); } });
    }, { rootMargin: '0px 0px -8% 0px' });
    $$('article h2, article div.w, article .box, .tile').forEach(function (n) {
      if (n.getBoundingClientRect().top > innerHeight) { n.classList.add('reveal'); io.observe(n); }
    });
  }
})();
