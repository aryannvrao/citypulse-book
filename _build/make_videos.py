"""Render a narrated MP4 explainer for each chapter into ../videos/.

  python make_videos.py D02 D03      render these chapters
  python make_videos.py --all        render every chapter that has no video yet
  python make_videos.py --all --force
  python make_videos.py D02 --frames DIR   only save one PNG per beat into DIR (no audio, no encoding)

Frames are drawn with Pillow, narration is spoken by the Windows speech engine, ffmpeg joins them.
Run build.py first: the story is read from the built chapter pages.
"""
import re, sys, json, html, wave, subprocess, tempfile, pathlib, functools
from PIL import Image, ImageDraw, ImageFont
import imageio_ffmpeg

B = pathlib.Path(__file__).resolve().parent
BOOK = B.parent
OUT = BOOK / "videos"
W, H, FPS = 1280, 720, 12
GAP = 0.4                                   # silence after each spoken line, in seconds
BG, PANEL, INK, MUTED, LINE = (18, 21, 28), (26, 31, 41), (230, 233, 239), (154, 164, 178), (43, 51, 66)
ACC, ACCD, CODE = (45, 212, 191), (18, 51, 47), (14, 17, 23)
TOP, BOTTOM = 84, H - 140                    # content area between header and caption
FONTS = r"C:\Windows\Fonts"


@functools.lru_cache(None)
def font(name, size):
    return ImageFont.truetype(f"{FONTS}\\{name}", size)


def SANS(s): return font("segoeui.ttf", s)
def BOLD(s): return font("segoeuib.ttf", s)
def MONO(s): return font("consola.ttf", s)
def MONOB(s): return font("consolab.ttf", s)


def wrap(text, fnt, width):
    out = []
    for para in str(text).split("\n"):
        cur = ""
        for w in para.split(" "):
            trial = (cur + " " + w).strip()
            if fnt.getlength(trial) <= width:
                cur = trial
                continue
            if cur:
                out.append(cur)
            while fnt.getlength(w) > width and len(w) > 1:
                k = len(w)
                while k > 1 and fnt.getlength(w[:k]) > width:
                    k -= 1
                out.append(w[:k]); w = w[k:]
            cur = w
        out.append(cur)
    return out


def clip(text, fnt, width):
    if fnt.getlength(text) <= width:
        return text
    while text and fnt.getlength(text + "…") > width:
        text = text[:-1]
    return text + "…"


def plain(s):
    return re.sub(r"\s+", " ", html.unescape(re.sub(r"<[^>]+>", "", s))).strip()


def unmark(s):
    return re.sub(r"[`*]", "", s)


def speakable(s):
    s = unmark(s).replace("->", " to ").replace("==", " equals ").replace("!=", " is not equal to ")
    s = s.replace(">=", " is at least ").replace("<=", " is at most ").replace("_", " ").replace("&", " and ")
    return re.sub(r"\s+", " ", s).strip() or "Next."


# ---------------------------------------------------------------- story

def story(cid):
    t = (BOOK / f"{cid}.html").read_text(encoding="utf-8")
    title = plain(re.search(r"<h1>(.*?)</h1>", t, re.S).group(1))
    m = re.search(r'<p class="sub">(.*?)</p>', t, re.S)
    sub = plain(m.group(1)) if m else ""
    scenes = [{"kind": "title", "beats": [f"{title}. {sub}"], "sub": sub}]
    m = re.search(r"<h2[^>]*>(.*?)</h2>(.*?)(?=<h2|$)", t, re.S)
    if m:
        text = " ".join(plain(p) for p in re.findall(r"<p>(.*?)</p>", m.group(2), re.S))
        keep, wc = [], 0
        for s in re.findall(r"[^.!?]+[.!?]+(?=\s|$)", text):
            keep.append(s.strip()); wc += len(s.split())
            if wc > 120 or len(keep) >= 7:
                break
        if keep:
            scenes.append({"kind": "text", "head": plain(m.group(1)), "beats": keep})
    cards = None
    for k, raw in re.findall(r'class="w w-(\w+)" data-w="([^"]*)"', t):
        d = json.loads(html.unescape(raw))
        if k in ("flow", "trace"):
            notes = [unmark(s.get("note") or s.get("label") or "Next step.") for s in d["steps"]]
            scenes.append({"kind": k, "d": d, "beats": [unmark(d.get("title") or "Watch this") + "."] + notes})
        elif k == "cards" and cards is None:
            cards = d["cards"][:6]
    if cards:
        scenes.append({"kind": "facts", "cards": cards,
                       "beats": ["Things to remember."] + [unmark(f"{c['q']}: {c['a']}") for c in cards]})
    scenes.append({"kind": "end", "beats": ["That is the outline. Now read the chapter, take its practice quiz, "
                                           "and solve the practice problem before you open the real ones."]})
    return title, scenes


# ---------------------------------------------------------------- drawing

def base(title, caption, progress):
    im = Image.new("RGB", (W, H), BG)
    d = ImageDraw.Draw(im)
    d.text((40, 24), "CityPulse Mastery", font=BOLD(20), fill=ACC)
    d.text((W - 40, 26), clip(title, SANS(18), 760), font=SANS(18), fill=MUTED, anchor="ra")
    d.line((40, 62, W - 40, 62), fill=LINE)
    d.rectangle((0, H - 128, W, H - 6), fill=PANEL)
    d.line((0, H - 128, W, H - 128), fill=LINE)
    for size, lh, most in ((25, 34, 3), (21, 29, 3), (18, 25, 4)):
        lines = wrap(caption, SANS(size), W - 140)
        if len(lines) <= most:
            break
    lines = lines[:most]
    y = H - 128 + (122 - len(lines) * lh) // 2
    for ln in lines:
        d.text((W // 2, y), ln, font=SANS(size), fill=INK, anchor="ma")
        y += lh
    d.rectangle((0, H - 6, W, H), fill=LINE)
    d.rectangle((0, H - 6, int(W * progress), H), fill=ACC)
    return im, d


def heading(d, text, y=TOP + 8, size=32):
    lines = wrap(text, BOLD(size), W - 120)[:2]
    for ln in lines:
        d.text((60, y), ln, font=BOLD(size), fill=INK)
        y += size + 10
    return y + 10


def draw_title(d, kicker, big, small):
    lines = wrap(big, BOLD(54), W - 160)
    size = 54 if len(lines) <= 3 else 42
    lines = wrap(big, BOLD(size), W - 160)[:4]
    sub = wrap(small, SANS(27), W - 200)[:4]
    total = 30 + len(lines) * (size + 12) + 20 + len(sub) * 38
    y = TOP + max(10, (BOTTOM - TOP - total) // 2)
    d.text((80, y), kicker, font=BOLD(19), fill=ACC); y += 40
    for ln in lines:
        d.text((80, y), ln, font=BOLD(size), fill=INK); y += size + 12
    y += 20
    for ln in sub:
        d.text((80, y), ln, font=SANS(27), fill=MUTED); y += 38


def draw_text(d, sc, bi):
    y0 = heading(d, sc["head"])
    blocks = [wrap(s, SANS(26), W - 140) for s in sc["beats"][:bi + 1]]
    first = 0
    while sum(len(b) * 36 + 16 for b in blocks[first:]) > BOTTOM - y0 and first < len(blocks) - 1:
        first += 1
    y = y0
    for k in range(first, len(blocks)):
        for ln in blocks[k]:
            d.text((70, y), ln, font=SANS(26), fill=INK if k == bi else MUTED)
            y += 36
        y += 16


def draw_facts(d, sc, bi):
    y0 = heading(d, "Things to remember")
    rows = []
    for c in sc["cards"][:bi]:
        a = wrap(unmark(c["q"]), BOLD(21), 250)[:3]
        b = wrap(unmark(c["a"]), SANS(21), 800)[:3]
        rows.append((a, b, max(len(a), len(b)) * 29 + 24))
    first = 0
    while sum(r[2] + 10 for r in rows[first:]) > BOTTOM - y0 and first < len(rows) - 1:
        first += 1
    y = y0
    for k in range(first, len(rows)):
        a, b, h = rows[k]
        d.rounded_rectangle((60, y, W - 60, y + h), 10, fill=PANEL, outline=ACC if k == bi - 1 else LINE, width=2)
        for i, ln in enumerate(a):
            d.text((80, y + 12 + i * 29), ln, font=BOLD(21), fill=ACC)
        for i, ln in enumerate(b):
            d.text((360, y + 12 + i * 29), ln, font=SANS(21), fill=INK)
        y += h + 10


def draw_flow(d, sc, bi, p):
    data = sc["d"]
    heading(d, unmark(data.get("title") or "How it moves"), size=30)
    nodes, n = data["nodes"], len(data["nodes"])
    gap = 18
    bw = (W - 120 - gap * (n - 1)) / n
    top, bh = 300, 120
    cx = [60 + i * (bw + gap) + bw / 2 for i in range(n)]
    for x in range(int(cx[0]), int(cx[-1]), 16):
        d.line((x, top + bh // 2, x + 8, top + bh // 2), fill=LINE, width=2)
    step = data["steps"][bi - 1] if bi >= 1 else None
    for i, name in enumerate(nodes):
        on = step is not None and i in (step["from"], step["to"])
        x0 = cx[i] - bw / 2
        d.rounded_rectangle((x0, top - (6 if on else 0), x0 + bw, top + bh - (6 if on else 0)), 14,
                            fill=ACCD if on else PANEL, outline=ACC if on else LINE, width=3 if on else 2)
        size = 21
        lines = wrap(unmark(name), BOLD(size), bw - 20)
        if len(lines) > 3:
            size = 17; lines = wrap(unmark(name), BOLD(size), bw - 16)[:4]
        yy = top + bh / 2 - len(lines) * (size + 6) / 2 - (6 if on else 0)
        for ln in lines:
            d.text((cx[i], yy), ln, font=BOLD(size), fill=INK, anchor="ma"); yy += size + 6
    if step is not None:
        e = p * p * (3 - 2 * p)
        x = cx[step["from"]] + (cx[step["to"]] - cx[step["from"]]) * e
        label = clip(unmark(step.get("label") or ""), MONOB(18), 420)
        if label:
            wlab = MONOB(18).getlength(label) + 36
            x = min(max(x, 40 + wlab / 2), W - 40 - wlab / 2)
            d.rounded_rectangle((x - wlab / 2, top - 74, x + wlab / 2, top - 36), 19, fill=ACC)
            d.text((x, top - 55), label, font=MONOB(18), fill=(6, 32, 29), anchor="mm")
        d.text((W // 2, top + bh + 44), f"Step {bi} of {len(data['steps'])}", font=SANS(20), fill=MUTED, anchor="ma")


def draw_trace(d, sc, bi):
    data = sc["d"]
    y0 = heading(d, unmark(data.get("title") or "Step through the code"), size=30)
    code, n = data["code"], len(data["code"])
    step = data["steps"][bi - 1] if bi >= 1 else None
    cur = step["line"] - 1 if step else -1
    size, lh = (20, 30) if n <= 13 else (17, 25)
    room = (BOTTOM - y0 - 24) // lh
    start = 0 if n <= room else min(max(0, cur - room // 2), n - room)
    shown = code[start:start + room]
    x0, x1 = 60, 800
    d.rounded_rectangle((x0, y0, x1, y0 + len(shown) * lh + 24), 12, fill=CODE, outline=LINE, width=2)
    y = y0 + 12
    for k, ln in enumerate(shown):
        idx = start + k
        if idx == cur:
            d.rectangle((x0 + 2, y - 2, x1 - 2, y + lh - 4), fill=ACCD)
            d.rectangle((x0 + 2, y - 2, x0 + 7, y + lh - 4), fill=ACC)
        d.text((x0 + 48, y), str(idx + 1), font=MONO(size), fill=MUTED, anchor="ra")
        d.text((x0 + 66, y), clip(ln.replace("\t", "    "), MONO(size), x1 - x0 - 84), font=MONO(size), fill=INK)
        y += lh
    vx = 824
    d.text((vx, y0 + 2), "VARIABLES", font=BOLD(15), fill=MUTED)
    y = y0 + 32
    prev = dict(map(tuple, data["steps"][bi - 2]["state"])) if bi >= 2 else {}
    state = step["state"] if step else []
    if not state:
        d.text((vx, y), "nothing yet", font=MONO(17), fill=MUTED)
    for k, v in state:
        lines = wrap(f"{k} = {v}", MONO(17), W - 60 - vx - 24)[:4]
        h = len(lines) * 23 + 14
        if y + h > BOTTOM:
            d.text((vx, y), "…", font=MONO(17), fill=MUTED)
            break
        changed = bi >= 2 and prev.get(k) != v
        d.rounded_rectangle((vx, y, W - 60, y + h), 8, fill=PANEL, outline=ACC if changed else LINE, width=2)
        for i, ln in enumerate(lines):
            d.text((vx + 12, y + 7 + i * 23), ln, font=MONO(17), fill=INK)
        y += h + 8


def frame(title, sc, bi, progress, p=1.0):
    im, d = base(title, sc["beats"][bi], progress)
    k = sc["kind"]
    if k == "title":
        draw_title(d, "EXPLAINER", title, sc.get("sub", ""))
    elif k == "end":
        draw_title(d, "YOUR TURN", "Now practise", sc["beats"][0])
    elif k == "text":
        draw_text(d, sc, bi)
    elif k == "facts":
        draw_facts(d, sc, bi)
    elif k == "flow":
        draw_flow(d, sc, bi, p)
    elif k == "trace":
        draw_trace(d, sc, bi)
    return im


# ---------------------------------------------------------------- audio

PS = r"""
Add-Type -AssemblyName System.Speech
$s = New-Object System.Speech.Synthesis.SpeechSynthesizer
try { $s.SelectVoice('Microsoft Zira Desktop') } catch {}
$s.Rate = 0
$fmt = New-Object System.Speech.AudioFormat.SpeechAudioFormatInfo(22050, [System.Speech.AudioFormat.AudioBitsPerSample]::Sixteen, [System.Speech.AudioFormat.AudioChannel]::Mono)
$items = Get-Content -Raw -Encoding UTF8 'JSONPATH' | ConvertFrom-Json
$i = 0
foreach ($t in $items) { $i++; $s.SetOutputToWaveFile((Join-Path 'OUTDIR' ('{0:D4}.wav' -f $i)), $fmt); $s.Speak([string]$t) }
$s.SetOutputToNull(); $s.Dispose()
"""


def narrate(lines, tmp):
    """Speak every line to its own WAV; return (joined wav path, [seconds per line incl. gap])."""
    jp = tmp / "lines.json"
    jp.write_text(json.dumps([speakable(x) for x in lines]), encoding="utf-8")
    script = PS.replace("JSONPATH", str(jp)).replace("OUTDIR", str(tmp))
    subprocess.run(["powershell", "-NoProfile", "-Command", script], check=True, capture_output=True)
    joined, secs, params = bytearray(), [], None
    for i in range(1, len(lines) + 1):
        with wave.open(str(tmp / f"{i:04d}.wav"), "rb") as w:
            params = params or w.getparams()
            data = w.readframes(w.getnframes())
        pad = b"\0" * (int(GAP * params.framerate) * params.sampwidth * params.nchannels)
        joined += data + pad
        secs.append((len(data) + len(pad)) / (params.framerate * params.sampwidth * params.nchannels))
    out = tmp / "all.wav"
    with wave.open(str(out), "wb") as w:
        w.setparams(params); w.writeframes(bytes(joined))
    return out, secs


# ---------------------------------------------------------------- render

def render(cid, frames_dir=None):
    title, scenes = story(cid)
    beats = [(si, bi) for si, sc in enumerate(scenes) for bi in range(len(sc["beats"]))]
    if frames_dir:
        frames_dir.mkdir(parents=True, exist_ok=True)
        for n, (si, bi) in enumerate(beats):
            frame(title, scenes[si], bi, (n + 1) / len(beats)).save(frames_dir / f"{cid}_{n:03d}.png")
        return len(beats), 0
    OUT.mkdir(exist_ok=True)
    with tempfile.TemporaryDirectory() as td:
        tmp = pathlib.Path(td)
        wav, secs = narrate([scenes[si]["beats"][bi] for si, bi in beats], tmp)
        target = OUT / f"{cid}.mp4"
        cmd = [imageio_ffmpeg.get_ffmpeg_exe(), "-y", "-loglevel", "error", "-f", "rawvideo", "-pix_fmt", "rgb24",
               "-s", f"{W}x{H}", "-r", str(FPS), "-i", "-", "-i", str(wav), "-c:v", "libx264", "-preset", "veryfast",
               "-crf", "24", "-tune", "stillimage", "-pix_fmt", "yuv420p", "-c:a", "aac", "-b:a", "80k",
               "-shortest", "-movflags", "+faststart", str(target)]
        ff = subprocess.Popen(cmd, stdin=subprocess.PIPE)
        t, done, prev = 0.0, 0, None
        for n, (si, bi) in enumerate(beats):
            sc = scenes[si]
            t += secs[n]
            count = max(1, round(t * FPS) - done)
            done += count
            prog = (n + 1) / len(beats)
            final = frame(title, sc, bi, prog)
            used = 0
            step = sc["d"]["steps"][bi - 1] if sc["kind"] == "flow" and bi >= 1 else None
            if step and step["from"] != step["to"]:
                used = min(count - 1, 11)
                for j in range(used):
                    ff.stdin.write(frame(title, sc, bi, prog, (j + 1) / (used + 1)).tobytes())
            elif prev is not None:
                used = min(count - 1, 4)
                for j in range(used):
                    ff.stdin.write(Image.blend(prev, final, (j + 1) / (used + 1)).tobytes())
            raw = final.tobytes()
            for _ in range(count - used):
                ff.stdin.write(raw)
            prev = final
        ff.stdin.close()
        if ff.wait():
            raise RuntimeError("ffmpeg failed for " + cid)
    return len(beats), t


def main():
    args = sys.argv[1:]
    frames_dir = pathlib.Path(args[args.index("--frames") + 1]) if "--frames" in args else None
    ids = [a for a in args if re.fullmatch(r"[A-Z]\d+", a)]
    if "--all" in args:
        ids = sorted(p.stem for p in BOOK.glob("*.html") if p.stem != "index")
    for cid in ids:
        if not frames_dir and (OUT / f"{cid}.mp4").exists() and "--force" not in args:
            continue
        try:
            n, t = render(cid, frames_dir)
            if frames_dir:
                print(f"{cid}: {n} frames saved", flush=True)
            else:
                mb = (OUT / f"{cid}.mp4").stat().st_size / 1e6
                print(f"{cid}: {int(t // 60)}m{int(t % 60):02d}s, {n} beats, {mb:.1f} MB", flush=True)
        except Exception as e:
            print(f"{cid}: FAILED {e}", flush=True)


if __name__ == "__main__":
    main()
