"""Cartoon explainer videos: storyboard (.story) -> narrated MP4.

  python make_cartoons.py --check D02 D03     validate storyboards only
  python make_cartoons.py --sheet D02         contact sheets of every scene (no voice)
  python make_cartoons.py --at D02 12.5 40    full frames at given seconds (no voice)
  python make_cartoons.py D02 D03             render videos
  python make_cartoons.py --all [--force]

Drawing: _build/cartoon/cartoon.js on a canvas in headless Edge (Playwright).
Voice: Microsoft neural voices through edge-tts (free, no key). Encoder: ffmpeg.
"""
import asyncio, base64, hashlib, io, json, pathlib, re, subprocess, sys, wave
import numpy as np

HERE = pathlib.Path(__file__).resolve().parent
BOOK = HERE.parent
STORY, TTS, OUT = HERE / "story", HERE / "tts", BOOK / "videos"
STAGE = HERE / "cartoon" / "stage.html"
FPS, SR = 24, 24000
VOICE = {"M": "en-US-AvaNeural", "B": "en-US-AndrewNeural"}
RATE = "+6%"

TYPES = ["title", "talk", "same", "journey", "code", "term", "chain", "versus",
         "table", "bars", "array", "graph", "trap", "quiz", "recap"]
TECH = {"journey", "code", "term", "chain", "versus", "table", "bars", "array", "graph"}
SETS = ["city", "night", "room", "sky", "server", "class", "lab"]
MOODS = ["happy", "think", "confused", "shock", "sad", "cheer"]
ALIAS = {"worried": "sad", "nervous": "sad", "upset": "sad", "surprised": "shock", "shocked": "shock", "scared": "shock",
         "excited": "cheer", "proud": "cheer", "curious": "think", "thinking": "think", "puzzled": "confused",
         "smile": "happy", "relieved": "happy", "determined": "happy", "calm": "happy"}
DEFAULT_SET = {"title": "city", "talk": "city", "same": "class", "journey": "sky", "code": "room",
               "term": "room", "chain": "lab", "versus": "class", "table": "lab", "bars": "lab",
               "array": "lab", "graph": "night", "trap": "night", "quiz": "class", "recap": "city"}
SPEECH = re.compile(r"^([MB])(?:\((\w+)\))?:\s*(\S.*)$")
BADSPEECH = re.compile(r"[`\\/_=<>{}\[\]|#*@^~$]")

# spoken form of words the voice would mangle (captions keep the original)
SAY = {"jq": "J Q", "boto3": "boto three", "IAM": "I A M", "pytest": "pie test", "Pydantic": "pie dantic",
       "pydantic": "pie dantic", "sudo": "soo doo", "chmod": "C H mod", "numpy": "num pie", "NumPy": "num pie",
       "uvicorn": "you vee corn", "README": "read me", "venv": "V env", "SLO": "S L O", "SLOs": "S L Oz",
       "scikit": "sy kit", "nginx": "engine X", "stdout": "standard out", "stderr": "standard error",
       "stdin": "standard in", "regex": "rej ex", "matplotlib": "mat plot lib", "sklearn": "S K learn",
       "kwargs": "keyword args", "str": "string", "int": "integer", "dict": "dictionary", "ARN": "A R N",
       "PRs": "P Rs", "PR": "P R", "CI": "C I", "CD": "C D", "DQ": "D Q", "ERD": "E R D", "VM": "V M", "CRI": "C R I", "2FA": "two F A", "MoSCoW": "Moscow", "logrotate": "log rotate", "shellcheck": "shell check", "TestClient": "test client", "ECR": "E C R", "README": "read me", "DSA": "D S A", "EDA": "E D A", "ETL": "E T L", "TTL": "T T L", "cron": "kron"}


def ints(s):
    return [int(x) for x in re.split(r"[,\s]+", s.strip()) if x]


def emoji_label(s):
    a, _, b = s.partition(" : ")
    a, b = a.strip(), b.strip()
    if not a or not b or ord(a[0]) < 0x2000:
        raise ValueError("expected `EMOJI : label`")
    return {"emoji": a, "label": b}


def data_line(sc, line):
    """Parse a data line of a scene. Raises ValueError with a message."""
    t, d = sc["type"], sc["data"]
    key, _, val = line.partition(":")
    key, val = key.strip(), val.strip()
    if t == "code" and line.startswith("|"):
        d.setdefault("code", []).append(line[2:] if line.startswith("| ") else line[1:])
    elif t == "same" and key in ("LEFT", "RIGHT"):
        d[key.lower()] = emoji_label(val)
    elif t == "versus" and key in ("LEFT", "RIGHT"):
        d[key.lower()] = emoji_label(val) if " : " in val else {"emoji": "", "label": val}
    elif t == "journey" and key == "NODE":
        p = [x.strip() for x in val.split(" : ")]
        if len(p) != 3 or ord(p[1][0]) < 0x2000:
            raise ValueError("expected `NODE: id : EMOJI : label`")
        d.setdefault("nodes", []).append({"id": p[0], "emoji": p[1], "label": p[2]})
    elif t == "graph" and key == "NODE":
        p = [x.strip() for x in val.split(" : ")]
        if len(p) != 3 or len(ints(p[2])) != 2:
            raise ValueError("expected `NODE: id : label : col,row`")
        c, r = ints(p[2])
        d.setdefault("nodes", []).append({"id": p[0], "label": p[1], "col": c, "row": r})
    elif t == "graph" and key == "EDGE":
        m = re.match(r"^(\w+)\s*([->])\s*(\w+)$", val)
        if not m:
            raise ValueError("expected `EDGE: a-b` or `EDGE: a>b`")
        d.setdefault("edges", []).append({"a": m[1], "b": m[3], "dir": m[2] == ">"})
    elif t == "table" and key == "HEAD":
        d["head"] = [x.strip() for x in val.split("|")]
    elif t == "table" and key == "ROW":
        d.setdefault("rows", []).append([x.strip() for x in val.split("|")])
    elif t == "bars" and key == "BAR":
        a, _, b = val.rpartition(" : ")
        d.setdefault("bars", []).append({"label": a.strip(), "value": float(b)})
    elif t == "array" and key == "CELLS":
        d["cells"] = val.split()
    elif t == "trap" and key in ("WRONG", "RIGHT"):
        d[key.lower()] = val
    elif t == "quiz" and key == "Q":
        d["q"] = val
    elif t == "quiz" and line[:2] in ("- ", "* "):
        d.setdefault("options", []).append({"text": line[2:].strip(), "ok": line[0] == "*"})
    else:
        raise ValueError(f"not a valid data line for a `{t}` scene (speech lines start with `M:` or `B:`)")


def action(sc, s):
    """Parse the text after `> `. Raises ValueError with a message."""
    t = sc["type"]
    head, _, rest = s.partition(" ")
    rest = rest.strip()
    if t == "talk":
        if s == "clear":
            return {"k": "clear"}
        if s.startswith("word :"):
            return {"k": "word", "text": s[6:].strip()}
        return {"k": "prop", **emoji_label(s)}
    if t == "chain":
        return {"k": "add", **emoji_label(s)}
    if t == "recap":
        return {"k": "item", "text": s}
    if t == "term":
        if s.startswith("$ "):
            return {"k": "cmd", "text": s[2:]}
        if s.startswith("= ") or s == "=":
            return {"k": "out", "text": s[2:]}
        raise ValueError("in a term scene use `> $ command` or `> = output line`")
    if t == "versus":
        m = re.match(r"^([LR]) : (.+)$", s)
        if not m:
            raise ValueError("expected `> L : text` or `> R : text`")
        return {"k": "pt", "side": m[1], "text": m[2].strip()}
    if t == "journey":
        m = re.match(r"^(\w+)>(\w+) : (.+)$", s)
        if m:
            return {"k": "hop", "a": m[1], "b": m[2], "label": m[3].strip()}
        if head == "hi":
            return {"k": "hi", "ids": [x for x in re.split(r"[,\s]+", rest) if x]}
        raise ValueError("expected `> a>b : label` or `> hi id`")
    if t == "code":
        if head == "line":
            return {"k": "line", "n": int(rest)}
        if head == "var" and "=" in rest:
            n, _, v = rest.partition("=")
            return {"k": "var", "name": n.strip(), "value": v.strip()}
        if head == "out":
            return {"k": "out", "text": rest}
        raise ValueError("expected `> line N`, `> var name=value` or `> out text`")
    if t == "table":
        if head in ("rows", "keep"):
            return {"k": head, "rows": ints(rest)}
        if head == "col":
            return {"k": "col", "n": int(rest)}
        if s == "reset":
            return {"k": "reset"}
        raise ValueError("expected `> rows 1,2`, `> col 2`, `> keep 1,3` or `> reset`")
    if t == "bars":
        if head == "hi":
            return {"k": "hi", "n": int(rest)}
        raise ValueError("expected `> hi N`")
    if t == "array":
        if head == "ptr":
            return {"k": "ptr", "ptrs": {a: int(b) for a, b in (x.split("=") for x in rest.split())}}
        if head in ("hi", "done"):
            return {"k": head, "idx": ints(rest)}
        if head == "swap":
            i, j = ints(rest)
            return {"k": "swap", "i": i, "j": j}
        if head == "set":
            i, _, v = rest.partition("=")
            return {"k": "set", "i": int(i), "value": v.strip()}
        if head == "note":
            return {"k": "note", "text": rest}
        raise ValueError("expected ptr / hi / done / swap / set / note")
    if t == "graph":
        if head in ("hi", "done"):
            return {"k": head, "ids": [x for x in re.split(r"[,\s]+", rest) if x]}
        if head == "note":
            return {"k": "note", "text": rest}
        raise ValueError("expected `> hi a,b`, `> done a` or `> note text`")
    raise ValueError(f"a `{t}` scene takes no `>` action lines")


def parse(path):
    st = {"title": "", "hook": "", "scenes": []}
    errs, sc, beat = [], None, None
    for n, raw in enumerate(path.read_text(encoding="utf-8-sig").splitlines(), 1):
        line = raw.rstrip()
        if not line.strip():
            continue
        try:
            if line.startswith("TITLE:"):
                st["title"] = line[6:].strip()
            elif line.startswith("HOOK:"):
                st["hook"] = line[5:].strip()
            elif line.startswith("=="):
                parts = [p.strip() for p in line[2:].split("|")]
                typ = parts[0].lower()
                opts = dict(p.split("=", 1) for p in parts[1:] if "=" in p)
                if typ not in TYPES:
                    raise ValueError(f"unknown scene type `{typ}`; use one of {', '.join(TYPES)}")
                if opts.get("set", "city") not in SETS:
                    raise ValueError(f"unknown set; use one of {', '.join(SETS)}")
                sc = {"type": typ, "set": opts.get("set") or DEFAULT_SET[typ], "opts": opts,
                      "data": {}, "beats": [], "line": n}
                st["scenes"].append(sc)
                beat = None
            elif sc is None:
                raise ValueError("text before the first `== scene` line")
            elif sc["type"] == "code" and line.startswith("|"):
                data_line(sc, line)
            elif line.startswith(">"):
                if beat is None:
                    raise ValueError("a `>` action must come after a speech line")
                beat["acts"].append(action(sc, line[1:].strip()))
            elif SPEECH.match(line) and not (sc["type"] == "code" and line.startswith("|")):
                m = SPEECH.match(line)
                mood = ALIAS.get(m[2], m[2]) if m[2] else ""
                if mood and mood not in MOODS:
                    raise ValueError(f"unknown mood `{m[2]}`; use one of {', '.join(MOODS)}")
                beat = {"who": m[1], "mood": mood, "text": m[3].strip(), "acts": [], "line": n}
                sc["beats"].append(beat)
            elif beat is not None:
                raise ValueError("data lines must come before the first speech line of the scene")
            else:
                try:
                    data_line(sc, line)
                except ValueError:
                    if sc["type"] != "code":
                        raise
                    sc["data"].setdefault("code", []).append(line)     # code line written without the bar
        except (ValueError, IndexError) as e:
            errs.append(f"line {n}: {e}   ->   {line[:60]}")
    return st, errs


def check(st):
    """Rules a storyboard must satisfy. Returns a list of messages."""
    E = []
    scs = st["scenes"]
    if not st["title"] or len(st["title"]) > 44:
        E.append("TITLE: is missing or longer than 44 characters")
    if not st["hook"] or len(st["hook"]) > 60:
        E.append("HOOK: is missing or longer than 60 characters")
    if not scs:
        return E + ["no scenes"]
    types = [s["type"] for s in scs]
    beats = [b for s in scs for b in s["beats"]]
    words = sum(len(b["text"].split()) for b in beats)
    if types[0] != "title": E.append("the first scene must be `== title`")
    if types[-1] != "recap": E.append("the last scene must be `== recap`")
    if not 9 <= len(scs) <= 14: E.append(f"need 9 to 14 scenes, found {len(scs)}")
    if not 34 <= len(beats) <= 60: E.append(f"need 34 to 60 speech lines, found {len(beats)}")
    if not 430 <= words <= 780: E.append(f"need 430 to 780 spoken words in total, found {words}")
    for need in ("same", "trap", "quiz"):
        if need not in types: E.append(f"add a `{need}` scene")
    if len(set(types) & TECH) < 4:
        E.append(f"use at least 4 different scene types from: {', '.join(sorted(TECH))}")
    if types.count("talk") > 3: E.append("at most 3 `talk` scenes")
    if any(a == b == "talk" for a, b in zip(types, types[1:])): E.append("two `talk` scenes in a row")
    if not {"M", "B"} <= {b["who"] for b in beats}: E.append("both M and B must speak")

    def lim(s, n, what, where):
        if len(s) > n: E.append(f"{where}: {what} is {len(s)} characters, limit {n}: {s[:40]}")

    for i, s in enumerate(scs, 1):
        t, d, bs = s["type"], s["data"], s["beats"]
        w = f"scene {i} ({t}, line {s['line']})"
        acts = [a for b in bs for a in b["acts"]]
        lo, hi = {"title": (2, 3), "same": (2, 4), "trap": (2, 4), "quiz": (2, 3), "talk": (2, 6),
                  "recap": (3, 6)}.get(t, (2, 8))
        if not lo <= len(bs) <= hi: E.append(f"{w}: needs {lo} to {hi} speech lines, has {len(bs)}")
        for b in bs:
            n = len(b["text"].split())
            if n > 32: E.append(f"line {b['line']}: speech is {n} words, limit 32")
            m = BADSPEECH.search(b["text"])
            if m: E.append(f"line {b['line']}: speech contains `{m[0]}`; write it the way it is spoken")
            if len(b["acts"]) > 5: E.append(f"line {b['line']}: more than 4 actions on one speech line")
        if t in TECH - {"table", "bars"} and not acts:
            E.append(f"{w}: no `>` actions, so nothing would move")
        try:
            if t == "talk":
                for a in acts:
                    if a["k"] == "prop": lim(a["label"], 18, "prop label", w)
                    if a["k"] == "word": lim(a["text"], 26, "word", w)
            elif t == "same":
                for k in ("left", "right"): lim(d[k]["label"], 22, k, w)
            elif t == "journey":
                ids = [n["id"] for n in d["nodes"]]
                if not 2 <= len(ids) <= 5: E.append(f"{w}: needs 2 to 5 NODE lines")
                for n in d["nodes"]: lim(n["label"], 16, "node label", w)
                for a in acts:
                    for x in ([a["a"], a["b"]] if a["k"] == "hop" else a["ids"]):
                        if x not in ids: E.append(f"{w}: unknown node id `{x}`")
                    if a["k"] == "hop": lim(a["label"], 22, "hop label", w)
                if not any(a["k"] == "hop" for a in acts): E.append(f"{w}: add at least one `> a>b : label` hop")
            elif t == "code":
                code = d["code"]
                if not 2 <= len(code) <= 12: E.append(f"{w}: needs 2 to 12 code lines")
                for c in code: lim(c, 56, "code line", w)
                for a in acts:
                    if a["k"] == "line" and not 1 <= a["n"] <= len(code): E.append(f"{w}: `line {a['n']}` is out of range")
                    if a["k"] == "var": lim(a["name"] + a["value"], 30, "var", w)
                    if a["k"] == "out": lim(a["text"], 40, "out", w)
                if len({a["name"] for a in acts if a["k"] == "var"}) > 6: E.append(f"{w}: more than 6 variables")
                if sum(a["k"] == "out" for a in acts) > 4: E.append(f"{w}: more than 4 out lines")
                if not any(a["k"] == "line" for a in acts): E.append(f"{w}: add `> line N` actions")
            elif t == "term":
                for a in acts: lim(a["text"], 62, "terminal line", w)
                if len(acts) > 14: E.append(f"{w}: more than 14 terminal lines")
                if not any(a["k"] == "cmd" for a in acts): E.append(f"{w}: add a `> $ command`")
            elif t == "chain":
                mx = 5 if s["opts"].get("dir") == "pile" else 6
                if not 3 <= len(acts) <= mx: E.append(f"{w}: needs 3 to {mx} blocks, has {len(acts)}")
                for a in acts: lim(a["label"], 18, "block label", w)
            elif t == "versus":
                for k in ("left", "right"): lim(d[k]["label"], 20, k + " title", w)
                for side in "LR":
                    if sum(a["side"] == side for a in acts) > 4: E.append(f"{w}: more than 4 points on side {side}")
                for a in acts: lim(a["text"], 38, "point", w)
            elif t == "table":
                head, rows = d["head"], d["rows"]
                if not 2 <= len(head) <= 5: E.append(f"{w}: needs 2 to 5 columns")
                if not 2 <= len(rows) <= 6: E.append(f"{w}: needs 2 to 6 rows")
                for r in rows:
                    if len(r) != len(head): E.append(f"{w}: a ROW has {len(r)} cells but HEAD has {len(head)}")
                for c in head + [c for r in rows for c in r]: lim(c, 14, "cell", w)
                for a in acts:
                    if a["k"] in ("rows", "keep") and not all(1 <= x <= len(rows) for x in a["rows"]): E.append(f"{w}: row number out of range (rows count from 1)")
                    if a["k"] == "col" and not 1 <= a["n"] <= len(head): E.append(f"{w}: col out of range (count from 1)")
            elif t == "bars":
                bars = d["bars"]
                if not 2 <= len(bars) <= 7: E.append(f"{w}: needs 2 to 7 BAR lines")
                for b in bars:
                    lim(b["label"], 12, "bar label", w)
                    if b["value"] < 0: E.append(f"{w}: bar values must be 0 or more")
                for a in acts:
                    if not 1 <= a["n"] <= len(bars): E.append(f"{w}: `hi {a['n']}` out of range (count from 1)")
            elif t == "array":
                cells = d["cells"]
                if not 3 <= len(cells) <= 10: E.append(f"{w}: needs 3 to 10 cells")
                for c in cells: lim(c, 4, "cell", w)
                for a in acts:
                    idx = a.get("idx", []) + list(a.get("ptrs", {}).values()) + [a[k] for k in ("i", "j") if k in a]
                    if not all(0 <= x < len(cells) for x in idx): E.append(f"{w}: index out of range (cells count from 0)")
                    for p in a.get("ptrs", {}): lim(p, 4, "pointer name", w)
                    if a["k"] == "note": lim(a["text"], 60, "note", w)
                    if a["k"] == "set": lim(a["value"], 4, "set value", w)
            elif t == "graph":
                nodes = d["nodes"]
                ids = [n["id"] for n in nodes]
                if not 3 <= len(nodes) <= 9: E.append(f"{w}: needs 3 to 9 nodes")
                if len({(n["col"], n["row"]) for n in nodes}) < len(nodes): E.append(f"{w}: two nodes share a position")
                for n in nodes:
                    lim(n["label"], 8, "node label", w)
                    if not (0 <= n["col"] <= 6 and 0 <= n["row"] <= 3): E.append(f"{w}: node `{n['id']}` position must be col 0-6, row 0-3")
                for e in d.get("edges", []):
                    if e["a"] not in ids or e["b"] not in ids: E.append(f"{w}: EDGE uses an unknown node id")
                for a in acts:
                    if a["k"] == "note": lim(a["text"], 60, "note", w)
                    for x in a.get("ids", []):
                        if x not in ids: E.append(f"{w}: unknown node id `{x}`")
            elif t == "trap":
                lim(d["wrong"], 64, "WRONG", w); lim(d["right"], 64, "RIGHT", w)
            elif t == "quiz":
                lim(d["q"], 90, "Q", w)
                o = d["options"]
                if not 3 <= len(o) <= 4: E.append(f"{w}: needs 3 or 4 options")
                if sum(x["ok"] for x in o) != 1: E.append(f"{w}: exactly one option must start with `* `")
                for x in o: lim(x["text"], 44, "option", w)
            elif t == "recap":
                if not 3 <= len(acts) <= 5: E.append(f"{w}: needs 3 to 5 `> item` lines, has {len(acts)}")
                for a in acts: lim(a["text"], 46, "recap item", w)
        except KeyError as e:
            E.append(f"{w}: missing data line {e}")
    return E


def load(cid):
    p = STORY / f"{cid}.story"
    if not p.exists():
        return None, [f"{p.name} does not exist"]
    st, errs = parse(p)
    st["cid"] = cid
    return st, errs + (check(st) if not errs else [])


# ---------- voice ----------
def speakable(text):
    return re.sub(r"[A-Za-z0-9]+", lambda m: SAY.get(m[0], m[0]), text)


def ffmpeg():
    import imageio_ffmpeg
    return imageio_ffmpeg.get_ffmpeg_exe()


def wav_path(who, text):
    h = hashlib.sha1(f"{VOICE[who]}|{RATE}|{speakable(text)}".encode()).hexdigest()[:20]
    return TTS / f"{h}.wav"


async def synth(jobs):
    import edge_tts
    sem, ff = asyncio.Semaphore(4), ffmpeg()

    async def one(who, text):
        wav = wav_path(who, text)
        if wav.exists():
            return
        mp3 = wav.with_suffix(".mp3")
        async with sem:
            for attempt in range(6):
                try:
                    await edge_tts.Communicate(speakable(text), VOICE[who], rate=RATE).save(str(mp3))
                    if mp3.stat().st_size > 800:
                        break
                except Exception:
                    pass
                await asyncio.sleep(1.5 * (attempt + 1))
            else:
                raise RuntimeError(f"voice failed for: {text[:60]}")
        subprocess.run([ff, "-y", "-loglevel", "error", "-i", str(mp3), "-ar", str(SR), "-ac", "1", str(wav)], check=True)
        mp3.unlink()

    await asyncio.gather(*(one(*j) for j in jobs))


def run_async(coro):
    """Playwright owns this thread's event loop, so the voice calls run on their own thread."""
    import threading
    box = {}

    def go():
        try:
            asyncio.run(coro)
        except Exception as e:
            box["e"] = e
    th = threading.Thread(target=go)
    th.start()
    th.join()
    if "e" in box:
        raise box["e"]


def read_wav(p):
    with wave.open(str(p)) as w:
        a = np.frombuffer(w.readframes(w.getnframes()), dtype=np.int16).astype(np.float32) / 32768
    loud = np.flatnonzero(np.abs(a) > 0.012)
    if loud.size:
        a = a[max(0, loud[0] - SR // 25): loud[-1] + SR // 12]
    return a


# ---------- timeline ----------
def timeline(st, fake):
    """Give every scene, beat and action a time. Returns the speech clips to mix."""
    clips, t = [], 0.5
    for sc in st["scenes"]:
        sc["t0"] = t
        t += 0.75
        for b in sc["beats"]:
            if fake:
                dur, clip = len(b["text"].split()) / 2.7 + 0.3, None
            else:
                clip = read_wav(wav_path(b["who"], b["text"]))
                dur = clip.size / SR
            b["t0"], b["t1"] = t, t + dur
            hold = max(dur + 0.32, 0.25 + 0.55 * len(b["acts"]) + 0.7)
            for k, a in enumerate(b["acts"]):
                a["t"] = t + 0.2 + 0.55 * k
            if clip is not None:
                clips.append((t, clip))
            t += hold
        t += 0.45
        sc["t1"] = t
    st["dur"] = t + 1.2
    st["fps"] = FPS
    return clips


def sfx(kind):
    def chirp(f0, f1, dur, decay):
        n = int(SR * dur)
        ph = 2 * np.pi * np.cumsum(np.linspace(f0, f1, n)) / SR
        return np.sin(ph) * np.exp(-np.arange(n) / SR * decay)
    if kind == "pop":
        return 0.10 * chirp(520, 1150, 0.09, 30)
    if kind == "ding":
        return 0.10 * (chirp(988, 988, 0.6, 7) + 0.7 * np.pad(chirp(1319, 1319, 0.5, 7), (int(SR * .1), 0))[: int(SR * .6)])
    if kind == "bonk":
        return 0.16 * chirp(210, 80, 0.28, 12)
    n = int(SR * 0.5)                                    # whoosh
    noise = np.convolve(np.random.default_rng(7).standard_normal(n), np.ones(24) / 24, "same")
    return 0.10 * noise * np.hanning(n)


def soundtrack(st, clips):
    n = int(st["dur"] * SR)
    speech = np.zeros(n, np.float32)
    for t, c in clips:
        i = int(t * SR)
        speech[i:i + c.size] += c[: n - i]
    fx = np.zeros(n, np.float32)

    def put(kind, t):
        s = sfx(kind).astype(np.float32)
        i = int(t * SR)
        if 0 <= i < n:
            fx[i:i + s.size] += s[: n - i]

    for sc in st["scenes"]:
        put("whoosh", sc["t0"] - 0.25)
        for b in sc["beats"]:
            for a in b["acts"]:
                put("pop", a["t"])
        if sc["type"] == "quiz": put("ding", sc["beats"][-1]["t0"] + 0.4)
        if sc["type"] == "trap": put("bonk", sc["beats"][0]["t0"] + 0.35)
        if sc["type"] == "recap": put("ding", sc["beats"][-1]["t1"])
    # mouth envelope: loudness of the speech in each video frame, 0..1
    hop = SR // FPS
    nf = n // hop
    rms = np.sqrt((speech[: nf * hop].reshape(nf, hop) ** 2).mean(1))
    top = np.percentile(rms[rms > 0.005], 92) if (rms > 0.005).any() else 1
    st["env"] = [round(float(min(1, x / top)), 2) for x in rms]
    mix = np.clip(speech * 1.15 + fx, -1, 1)
    return (mix * 32767).astype(np.int16)


# ---------- drawing ----------
class Stage:
    def __init__(self):
        from playwright.sync_api import sync_playwright
        self.pw = sync_playwright().start()
        self.br = self.pw.chromium.launch(channel="msedge", headless=True)
        self.pg = self.br.new_page(viewport={"width": 1280, "height": 720})
        self.pg.on("pageerror", lambda e: print("  JS error:", e))
        self.pg.goto(STAGE.as_uri())

    def setup(self, st):
        self.pg.evaluate("s => setup(s)", st)

    def frames(self, a, b):
        return [base64.b64decode(s) for s in self.pg.evaluate("([a, b]) => renderBatch(a, b)", [a, b])]

    def close(self):
        self.br.close()
        self.pw.stop()


def clean(st):
    return json.loads(json.dumps(st))


def render(stage, cid, force):
    out = OUT / f"{cid}.mp4"
    mark = TTS / f"{cid}.done"
    src = STORY / f"{cid}.story"
    if out.exists() and mark.exists() and mark.stat().st_mtime > src.stat().st_mtime and not force:
        return print(cid, "up to date")
    st, errs = load(cid)
    if errs:
        return print(cid, "SKIPPED,", len(errs), "storyboard errors; first:", errs[0])
    TTS.mkdir(exist_ok=True)
    run_async(synth([(b["who"], b["text"]) for s in st["scenes"] for b in s["beats"]]))
    clips = timeline(st, fake=False)
    pcm = soundtrack(st, clips)
    wavp = TTS / f"_{cid}.wav"
    with wave.open(str(wavp), "wb") as w:
        w.setnchannels(1); w.setsampwidth(2); w.setframerate(SR); w.writeframes(pcm.tobytes())
    stage.setup(clean(st))
    n = int(st["dur"] * FPS)
    tmp = OUT / f"_{cid}.mp4"
    ff = subprocess.Popen([ffmpeg(), "-y", "-loglevel", "error", "-f", "image2pipe", "-framerate", str(FPS),
                           "-c:v", "mjpeg", "-i", "-", "-i", str(wavp), "-c:v", "libx264", "-preset", "veryfast",
                           "-crf", "23", "-pix_fmt", "yuv420p", "-c:a", "aac", "-b:a", "96k",
                           "-movflags", "+faststart", "-shortest", str(tmp)], stdin=subprocess.PIPE)
    for a in range(0, n, 24):
        for jpg in stage.frames(a, min(n, a + 24)):
            ff.stdin.write(jpg)
    ff.stdin.close()
    if ff.wait() != 0:
        return print(cid, "FAILED in ffmpeg")
    tmp.replace(out)
    wavp.unlink()
    mark.write_text("ok")
    print(f"{cid} ok  {st['dur'] / 60:.1f} min  {out.stat().st_size / 1e6:.1f} MB", flush=True)


def stills(cid, times, outdir):
    """Frames without voice, for checking the drawing."""
    from PIL import Image
    st, errs = load(cid)
    if errs:
        return print("\n".join(errs))
    timeline(st, fake=True)
    st["env"] = [0.5] * int(st["dur"] * FPS)
    stage = Stage()
    stage.setup(clean(st))
    outdir.mkdir(parents=True, exist_ok=True)
    if times:
        for t in times:
            f = int(t * FPS)
            (outdir / f"{cid}_{t:g}.jpg").write_bytes(stage.frames(f, f + 1)[0])
    else:
        shots = []
        for sc in st["scenes"]:
            f = int((sc["t1"] - 0.75) * FPS)
            shots.append(Image.open(io.BytesIO(stage.frames(f, f + 1)[0])).resize((640, 360)))
        for k in range(0, len(shots), 6):
            sheet = Image.new("RGB", (1280, 1080), "white")
            for j, im in enumerate(shots[k:k + 6]):
                sheet.paste(im, (j % 2 * 640, j // 2 * 360))
            sheet.save(outdir / f"{cid}_sheet{k // 6 + 1}.jpg", quality=85)
    stage.close()
    print("frames in", outdir)


def main():
    args = [a for a in sys.argv[1:] if not a.startswith("--")]
    flags = {a for a in sys.argv[1:] if a.startswith("--")}
    if "--check" in flags:
        bad = 0
        for cid in args:
            st, errs = load(cid)
            if errs:
                bad += 1
                print(f"{cid}: {len(errs)} problem(s)")
                for e in errs[:25]:
                    print("  -", e)
            else:
                bs = [b for s in st["scenes"] for b in s["beats"]]
                print(f"{cid}: OK  {len(st['scenes'])} scenes, {len(bs)} lines, {sum(len(b['text'].split()) for b in bs)} words")
        sys.exit(1 if bad else 0)
    scratch = HERE / "frames"
    if "--sheet" in flags:
        return stills(args[0], [], scratch)
    if "--at" in flags:
        return stills(args[0], [float(x) for x in args[1:]], scratch)
    ids = sorted(p.stem for p in STORY.glob("*.story")) if "--all" in flags else args
    OUT.mkdir(exist_ok=True)
    stage = Stage()
    for cid in ids:
        try:
            render(stage, cid, "--force" in flags)
        except Exception as e:
            print(cid, "FAILED", repr(e)[:300], flush=True)
    stage.close()


if __name__ == "__main__":
    main()
