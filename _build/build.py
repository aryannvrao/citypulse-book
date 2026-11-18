"""Build the CityPulse Mastery book.

  python build.py          build every chapter in ../src into ../*.html
  python build.py --test   also run every ```python test block and report failures
"""
import re, sys, json, html, pathlib, subprocess
import markdown
from pygments.formatters import HtmlFormatter

sys.path.insert(0, str(pathlib.Path(__file__).resolve().parent))
import extend

B = pathlib.Path(__file__).resolve().parent
BOOK = B.parent
SRC = BOOK / "src"
ASSETS = BOOK / "assets"

PARTS = [
    ("Start here", ["G0"]),
    ("Part 1 · Foundations", ["F1", "F2", "F3", "F4"]),
    ("Part 2 · Days 1–5 · Tools and teamwork", ["D01", "D02", "D03", "D04", "D05", "P1"]),
    ("Part 3 · Days 6–10 · Python, data and SQL", ["D06", "D07", "D08", "D09", "D10", "P2"]),
    ("Part 4 · Days 11–15 · Pipelines and cloud", ["D11", "D12", "D13", "D14", "D15", "P3"]),
    ("Part 5 · Days 16–20 · Algorithms, analysis, ML", ["D16", "D17", "D18", "D19", "D20", "P4"]),
    ("Part 6 · Days 21–25 · Models, APIs, containers", ["D21", "D22", "D23", "D24", "D25", "P5"]),
    ("Part 7 · Days 26–29 · Shipping it", ["D26", "D27", "D28", "D29", "P6"]),
    ("Part 8 · The capstone tickets", [f"K{i:02d}" for i in range(1, 16)]),
    ("Part 9 · Getting the offer", ["O1", "O2"]),
]
ORDER = [c for _, cs in PARTS for c in cs]
PART_OF = {c: p for p, cs in PARTS for c in cs}

EXT = ["fenced_code", "tables", "codehilite", "sane_lists"]
EXT_CFG = {"codehilite": {"guess_lang": False, "css_class": "hl"}}


def esc(s):
    return html.escape(s, quote=True)


def md_inner(text):
    return markdown.markdown(text, extensions=EXT, extension_configs=EXT_CFG)


def widget(kind, data):
    return f'<div class="w w-{kind}" data-w="{esc(json.dumps(data))}"></div>'


def split3(s):
    parts = [p.strip() for p in re.split(r"\s+::\s*|\s*::\s+", s, maxsplit=2)]
    return (parts + ["", "", ""])[:3]


def p_trace(body):
    title, code, steps, mode = "", [], [], None
    for ln in body.split("\n"):
        s = ln.strip()
        if mode is None and s.upper().startswith("TITLE:"):
            title = s[6:].strip(); continue
        if s.upper() == "CODE:":
            mode = "code"; continue
        if s.upper() == "STEPS:":
            mode = "steps"; continue
        if mode == "code":
            code.append(ln.rstrip())
        elif mode == "steps" and s:
            a, b, c = split3(s)
            m = re.match(r"\d+", a)
            state = []
            for piece in re.split(r";\s+", b):
                if "=" in piece:
                    k, v = piece.split("=", 1)
                    state.append([k.strip(), v.strip()])
                elif piece.strip() and state:
                    state[-1][1] += "; " + piece.strip()
            steps.append({"line": int(m.group()) if m else 0, "state": state, "note": c})
    while code and not code[0].strip():
        code.pop(0)
    while code and not code[-1].strip():
        code.pop()
    if not code or not steps:
        raise ValueError("trace needs CODE: and STEPS:")
    return widget("trace", {"title": title, "code": code, "steps": steps})


def p_flow(body):
    title, nodes, steps, mode = "", [], [], None
    for ln in body.split("\n"):
        s = ln.strip()
        if s.upper().startswith("TITLE:"):
            title = s[6:].strip()
        elif s.upper().startswith("NODES:"):
            nodes = [n.strip() for n in s[6:].split("|") if n.strip()]
        elif s.upper() == "STEPS:":
            mode = "steps"
        elif mode == "steps" and s:
            a, b, c = split3(s)
            m = re.match(r"(\d+)\s*-?>\s*(\d+)", a)
            if not m:
                continue
            f, t = int(m.group(1)), int(m.group(2))
            f = min(max(f, 1), len(nodes)); t = min(max(t, 1), len(nodes))
            steps.append({"from": f - 1, "to": t - 1, "label": b, "note": c})
    if len(nodes) < 2 or not steps:
        raise ValueError("flow needs NODES: and STEPS:")
    return widget("flow", {"title": title, "nodes": nodes, "steps": steps})


def p_term(body):
    lines = []
    for ln in body.split("\n"):
        if ln.startswith("$ "):
            lines.append({"t": "cmd", "s": ln[2:]})
        else:
            lines.append({"t": "out", "s": ln})
    while lines and not lines[-1]["s"].strip():
        lines.pop()
    return widget("term", {"lines": lines})


def p_quiz(body):
    qs, cur, in_why = [], None, False
    for ln in body.split("\n"):
        s = ln.strip()
        if re.match(r"Q\d*[:.)]", s):
            cur = {"q": re.sub(r"^Q\d*[:.)]\s*", "", s), "opts": [], "ans": -1, "why": ""}
            qs.append(cur); in_why = False
        elif cur is None:
            continue
        elif s.upper().startswith("WHY:"):
            cur["why"] = s[4:].strip(); in_why = True
        elif s[:2] in ("* ", "- ") and not in_why:
            if s[0] == "*":
                cur["ans"] = len(cur["opts"])
            cur["opts"].append(s[2:].strip())
        elif s and in_why:
            cur["why"] += " " + s
        elif s and not cur["opts"]:
            cur["q"] += "\n" + ln.rstrip()
    qs = [q for q in qs if len(q["opts"]) >= 2 and q["ans"] >= 0]
    if not qs:
        raise ValueError("quiz has no valid questions")
    return widget("quiz", {"qs": qs})


def p_cards(body):
    cards = []
    for ln in body.split("\n"):
        if "::" in ln:
            a, b = ln.split("::", 1)
            if a.strip() and b.strip():
                cards.append({"q": a.strip(), "a": b.strip()})
    if not cards:
        raise ValueError("cards block is empty")
    return widget("cards", {"cards": cards})


PARSERS = {"trace": p_trace, "flow": p_flow, "term": p_term, "quiz": p_quiz, "cards": p_cards}
FENCE = re.compile(r"^[ \t]*(`{3,})[ \t]*(trace|flow|term|quiz|cards)[ \t]*\n(.*?)\n[ \t]*\1[ \t]*$", re.M | re.S)
PYTEST = re.compile(r"^([ \t]*`{3,})[ \t]*python[ \t]+test[ \t]*\n(.*?)\n[ \t]*`{3,}[ \t]*$", re.M | re.S)
BOX = re.compile(r"^:::[ \t]*(key|trap|tip|answer|quiz|trace|flow|term|cards)\b[ \t]*(.*?)[ \t]*\n(.*?)\n:::[ \t]*$", re.M | re.S)
BOX_LABEL = {"key": "Key fact", "trap": "Trap", "tip": "Tip", "answer": "Show answer"}


class Chapter:
    def __init__(self, cid, path):
        self.cid, self.path = cid, path
        self.tests, self.warnings, self.counts = [], [], {}
        raw = path.read_text(encoding="utf-8").replace("\r\n", "\n").lstrip("﻿")
        self.title, self.sub = cid, ""
        lines = raw.split("\n")
        while lines and (not lines[0].strip() or re.match(r"(TITLE|SUB):|# ", lines[0].strip())):
            s = lines.pop(0).strip()
            if s.startswith("TITLE:"):
                self.title = s[6:].strip()
            elif s.startswith("SUB:"):
                self.sub = s[4:].strip()
            elif s.startswith("# "):
                self.title = s[2:].strip()
        self.raw = extend.preprocess(cid, "\n".join(lines))
        self.words = len(re.findall(r"\w+", self.raw))

    def render(self):
        ph = []

        def hold(h):
            ph.append(h)
            return f'\n\n<div data-ph="{len(ph) - 1}"></div>\n\n'

        def do_test(m):
            self.tests.append(m.group(2))
            return f"{m.group(1)}python\n{m.group(2)}\n{m.group(1).strip()}"

        def do_fence(m):
            kind = m.group(2)
            self.counts[kind] = self.counts.get(kind, 0) + 1
            try:
                return hold(PARSERS[kind](m.group(3)))
            except Exception as e:
                self.warnings.append(f"{kind} block: {e}")
                return hold(f"<pre>{esc(m.group(3))}</pre>")

        def do_box(m):
            kind, title, inner = m.group(1), m.group(2).strip(), m.group(3)
            if kind in PARSERS:          # a widget written with ::: instead of a code fence
                self.counts[kind] = self.counts.get(kind, 0) + 1
                try:
                    return hold(PARSERS[kind](inner))
                except Exception as e:
                    self.warnings.append(f"{kind} block: {e}")
                    return hold(f"<pre>{esc(inner)}</pre>")
            body = md_inner(inner)
            if kind == "answer":
                return hold(f'<details class="box box-answer"><summary>{esc(title or BOX_LABEL[kind])}</summary>{body}</details>')
            head = BOX_LABEL[kind] + (f": {title}" if title else "")
            return hold(f'<div class="box box-{kind}"><div class="box-h">{esc(head)}</div>{body}</div>')

        text = PYTEST.sub(do_test, self.raw)
        text = FENCE.sub(do_fence, text)
        text = BOX.sub(do_box, text)
        text = re.sub(r"^#\s+", "## ", text, flags=re.M)
        m = markdown.Markdown(extensions=EXT + ["toc"], extension_configs={**EXT_CFG, "toc": {"toc_depth": "2-2"}})
        out = m.convert(text)
        self.toc = [(t["id"], t["name"]) for t in getattr(m, "toc_tokens", [])]
        pat = re.compile(r'(?:<p>)?<div data-ph="(\d+)"></div>(?:</p>)?')
        for _ in range(4):
            out, n = pat.subn(lambda mm: ph[int(mm.group(1))], out)
            if not n:
                break
        if re.search(r"<p>:::", out):
            self.warnings.append("unclosed ::: box")
        return out


def nav_html(chapters, current):
    out = []
    for part, cids in PARTS:
        out.append(f'<div class="np">{esc(part)}</div><ul>')
        for c in cids:
            ch = chapters.get(c)
            if ch:
                cls = ' class="cur"' if c == current else ""
                out.append(f'<li><a{cls} href="{c}.html" data-id="{c}">{esc(ch.title)}</a></li>')
            else:
                out.append(f'<li><span class="soon">{c} · not written yet</span></li>')
        out.append("</ul>")
    return "".join(out)


HEAD = """<!doctype html><html lang="en"><head><meta charset="utf-8">
<meta name="viewport" content="width=device-width,initial-scale=1">
<title>{title} · CityPulse Mastery</title>
<link rel="stylesheet" href="assets/book.css?v=VER"><link rel="stylesheet" href="assets/hl.css?v=VER">
<script>(function(){{var t;try{{t=localStorage.getItem('cpm-theme')}}catch(e){{}}
if(!t)t=matchMedia('(prefers-color-scheme: dark)').matches?'dark':'light';document.documentElement.dataset.theme=t}})()</script>
</head><body data-ch="{cid}" data-total="{total}">
<div id="bar"></div>
<header class="top"><button id="menu" aria-label="Contents">&#9776;</button>
<a class="brand" href="index.html">CityPulse Mastery</a><span class="crumb">{crumb}</span>
<button id="theme" aria-label="Switch light and dark">&#9680;</button></header>
<nav class="side" id="side">{nav}</nav>
<main>"""
FOOT = """</main><script src="assets/book.js?v=VER"></script></body></html>"""


def page(ch, chapters, body):
    built = [c for c in ORDER if c in chapters]
    i = built.index(ch.cid)
    prev_c = chapters[built[i - 1]] if i > 0 else None
    next_c = chapters[built[i + 1]] if i + 1 < len(built) else None
    toc = "".join(f'<li><a href="#{a}">{esc(n)}</a></li>' for a, n in ch.toc)
    meta = [f"{max(1, round(ch.words / 200))} min read"]
    if ch.counts.get("quiz"):
        meta.append("practice quiz")
    anim = sum(ch.counts.get(k, 0) for k in ("trace", "flow", "term"))
    if anim:
        meta.append(f"{anim} animation{'s' if anim > 1 else ''}")
    if ch.tests:
        meta.append(f"{len(ch.tests)} tested solution{'s' if len(ch.tests) > 1 else ''}")
    pn = '<div class="pn">'
    pn += f'<a href="{prev_c.cid}.html"><small>Previous</small>{esc(prev_c.title)}</a>' if prev_c else "<span></span>"
    pn += f'<a class="nx" href="{next_c.cid}.html"><small>Next</small>{esc(next_c.title)}</a>' if next_c else "<span></span>"
    pn += "</div>"
    return (HEAD.format(title=esc(ch.title), cid=ch.cid, total=len(ORDER), crumb=esc(PART_OF[ch.cid]), nav=nav_html(chapters, ch.cid))
            + f'<article><p class="kicker">{esc(PART_OF[ch.cid])}</p><h1>{esc(ch.title)}</h1>'
            + (f'<p class="sub">{esc(ch.sub)}</p>' if ch.sub else "")
            + f'<p class="meta">{" · ".join(meta)}</p>'
            + (f'<video class="vid" controls preload="metadata" src="videos/{ch.cid}.mp4?v={int((BOOK / "videos" / f"{ch.cid}.mp4").stat().st_mtime) if (BOOK / "videos" / f"{ch.cid}.mp4").exists() else 0}"></video>'
               if (BOOK / "videos" / f"{ch.cid}.mp4").exists() else "")
            + (f'<details class="toc"><summary>In this chapter</summary><ol>{toc}</ol></details>' if toc else "")
            + body
            + '<div class="done"><button id="done">Mark this chapter complete</button></div>' + pn + "</article>" + FOOT)


def index(chapters):
    cards = []
    for part, cids in PARTS:
        cards.append(f'<h2>{esc(part)}</h2><div class="grid">')
        for c in cids:
            ch = chapters.get(c)
            if ch:
                cards.append(f'<a class="tile" href="{c}.html" data-id="{c}"><b>{esc(ch.title)}</b><span>{esc(ch.sub)}</span>'
                             f'<i>{max(1, round(ch.words / 200))} min</i></a>')
            else:
                cards.append(f'<div class="tile soon"><b>{c}</b><span>Not written yet</span></div>')
        cards.append("</div>")
    hero = ('<article class="home"><p class="kicker">Year 2 · CityPulse Engineering Stack</p><h1>CityPulse Mastery</h1>'
            '<p class="sub">Everything the course tests, taught from zero: 29 days, 6 projects, the Python behind every graded lab, '
            'and how to explain it all in a viva or an interview.</p>'
            '<div class="prog"><div class="ring" id="ring"><span id="pct">0%</span></div>'
            '<div><b id="pcount">0 chapters complete</b><br><a class="btn" id="cont" href="G0.html">Start reading</a></div></div>')
    return (HEAD.format(title="Contents", cid="index", total=len(ORDER), crumb="Contents", nav=nav_html(chapters, None))
            + hero + "".join(cards) + "</article>" + FOOT)


def run_tests(chapters):
    bad = []
    total = 0
    for cid in ORDER:
        ch = chapters.get(cid)
        if not ch:
            continue
        for n, code in enumerate(ch.tests, 1):
            total += 1
            try:
                r = subprocess.run([sys.executable, "-I", "-c", code], capture_output=True, text=True, timeout=20)
                if r.returncode:
                    err = (r.stderr.strip().splitlines() or ["error"])[-1]
                    bad.append(f"{cid} test block {n}: {err}")
            except subprocess.TimeoutExpired:
                bad.append(f"{cid} test block {n}: timed out")
    print(f"tests: {total - len(bad)} of {total} passed")
    for b in bad:
        print("  FAIL", b)
    (B / "test_report.txt").write_text("\n".join(bad) or "all passed", encoding="utf-8")


def main():
    ASSETS.mkdir(exist_ok=True)
    try:
        dark = HtmlFormatter(style="github-dark")
    except Exception:
        dark = HtmlFormatter(style="monokai")
    css = HtmlFormatter(style="default").get_style_defs(".hl") + "\n" + dark.get_style_defs("[data-theme=dark] .hl")
    (ASSETS / "hl.css").write_text(css, encoding="utf-8")
    extend.make_ticket_chapters()
    chapters = {c: Chapter(c, SRC / f"{c}.md") for c in ORDER if (SRC / f"{c}.md").exists()}
    bodies = {c: ch.render() for c, ch in chapters.items()}
    for c, ch in chapters.items():
        (BOOK / f"{c}.html").write_text(page(ch, chapters, bodies[c]), encoding="utf-8")
    (BOOK / "index.html").write_text(index(chapters), encoding="utf-8")
    ver = str(int(max((ASSETS / f).stat().st_mtime for f in ("book.css", "book.js"))))
    for f in BOOK.glob("*.html"):
        f.write_text(f.read_text(encoding="utf-8").replace("?v=VER", "?v=" + ver), encoding="utf-8")
    print(f"built {len(chapters)} of {len(ORDER)} chapters, {sum(c.words for c in chapters.values()):,} words")
    for c, ch in chapters.items():
        k = ch.counts
        flags = []
        if ch.words < 2500 and c != "G0":
            flags.append("SHORT")
        if not k.get("quiz"):
            flags.append("no quiz")
        if not (k.get("trace") or k.get("flow") or k.get("term")):
            flags.append("no animation")
        flags += ch.warnings
        print(f"  {c}: {ch.words} words, quiz {k.get('quiz', 0)}, trace {k.get('trace', 0)}, flow {k.get('flow', 0)}, "
              f"term {k.get('term', 0)}, cards {k.get('cards', 0)}, tests {len(ch.tests)}" + (("  << " + "; ".join(flags)) if flags else ""))
    missing = [c for c in ORDER if c not in chapters]
    if missing:
        print("missing:", " ".join(missing))
    if "--test" in sys.argv:
        run_tests(chapters)


if __name__ == "__main__":
    main()
