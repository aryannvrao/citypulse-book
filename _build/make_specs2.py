"""Specs for the second writing pass: deeper Day sections (spec2/Dxx.md) and capstone ticket guides (spec2/Y2-Txx.md)."""
import glob, json, pathlib, re

B = pathlib.Path(__file__).resolve().parent
BOOK, ROOT = B.parent, B.parent.parent
SPEC = B / "spec2"; SPEC.mkdir(exist_ok=True)
(B / "expand").mkdir(exist_ok=True); (B / "tickets").mkdir(exist_ok=True)
import sys; sys.path.insert(0, str(B))
import extend  # noqa: E402

old = (B / "make_specs.py").read_text(encoding="utf-8")
DAYS = {}
for ln in re.search(r'DAYS = """(.*?)"""', old, re.S).group(1).strip().split("\n"):
    n, topics, steps, skills, practice = [x.strip() for x in ln.split(" | ", 4)]
    DAYS[int(n)] = {"topics": [t.strip() for t in topics.split(",")], "steps": steps.split(" > "), "practice": practice}


def one(pattern):
    hits = sorted(glob.glob(str(ROOT / pattern)))
    return hits[0] if hits else None


def title_of(cid):
    p = BOOK / "src" / f"{cid}.md"
    if not p.exists():
        return cid
    for ln in p.read_text(encoding="utf-8").split("\n")[:5]:
        if ln.startswith("TITLE:"):
            return ln[6:].strip()
    return cid


CHAPTERS = "\n".join(f"- {c}: {title_of(c)}  (src/{c}.md)" for c in
                     ["F1", "F2", "F3", "F4"] + [f"D{d:02d}" for d in range(1, 30)] + [f"P{n}" for n in range(1, 7)] + ["O1", "O2"])

for day in range(1, 30):
    g, d = extend.LABS[day], DAYS[day]
    slides, tia = one(f"00 Slides/{day:02d}_*.txt"), one(f"01 Technology in Action/{day:02d}_*.txt")
    funcs = extend.lab_functions(day)
    vis = "\n".join(f"| {v['d']} | {v['w']} |" for v in g["visible"])
    statement = g["statement"].split("\n## Worked example")[0].strip()
    sig = "\n".join(ln for ln in g["starter"].split("\n") if ln.startswith(("def ", "import ", "from ")) or re.match(r"^[A-Z_]+ = ", ln))
    spec = f"""CHAPTER: D{day:02d}   KIND: DAY EXPANSION
OUTPUT FILE: {B / 'expand' / f'D{day:02d}.md'}

READ (in this order, each once):
- {BOOK / 'src' / f'D{day:02d}.md'}   (the current chapter: read its sections "What the quiz tests" and "The graded lab skill" closely, skim the rest)
- {slides}
- {tia}

QUIZ TOPICS (the real Day Quiz has one case-study question on each, in this order):
{chr(10).join('- ' + t for t in d['topics'])}

THE REAL GRADED LAB (as the platform shows it to you; restate it, never solve it)
Title: {g['title']}   Difficulty: {g['difficulty']}   Skills: {g['skills']}
Limits: {g['time']} s, {g['mem']} MB.   Visible tests: {sum(v['w'] for v in g['visible'])} points.   Hidden tests: {g['hiddenCount']} worth {g['hiddenWeight']} points.

Task statement:
<<<
{statement}
>>>

Module-level names in the starter file:
```
{sig}
```

Visible tests (description | points):
| Test | Points |
|---|---|
{vis}

FORBIDDEN FUNCTION NAMES (never write `def` for any of these anywhere in your file): {', '.join(funcs)}

TWIN PROBLEM IDEA (the current chapter may already solve this one; you may reuse and improve it, keeping a different domain from the real lab):
{d['practice']}

CHECK COMMAND:
python "{B / 'check_file.py'}" "{B / 'expand' / f'D{day:02d}.md'}" --forbid {','.join(funcs)}
"""
    (SPEC / f"D{day:02d}.md").write_text(spec, encoding="utf-8")


def md_list(v):
    if isinstance(v, list):
        out = []
        for x in v:
            if isinstance(x, dict):
                out.append("- " + "; ".join(f"**{k}**: {val}" for k, val in x.items()))
            else:
                out.append(f"- {x}")
        return "\n".join(out)
    return str(v)


codes = list(extend.TICKETS)
for i, code in enumerate(codes):
    t = extend.TICKETS[code]
    days = [d for d, cs in extend.DAY_TICKETS.items() if code in cs]
    prev = "\n".join(f"- {c}: {extend.TICKETS[c]['title']}" for c in codes[max(0, i - 3):i]) or "- (none: this is the first ticket)"
    nxt = "\n".join(f"- {c}: {extend.TICKETS[c]['title']}" for c in codes[i + 1:i + 3]) or "- (none: this is the last ticket)"
    related = ", ".join(f"src/D{d:02d}.md" for d in days) or "pick the closest Day chapters from the list below"
    spec = f"""TICKET: {code}   KIND: CAPSTONE TICKET GUIDE
OUTPUT FILE: {B / 'tickets' / f'{code}.md'}
CHECK COMMAND: python "{B / 'check_file.py'}" "{B / 'tickets' / f'{code}.md'}"

READ: this spec, then the related book chapter(s) for the techniques: {related}
(only the sections you need; the whole book is listed at the bottom so you can point the reader to the right chapter)

TICKETS JUST BEFORE THIS ONE (assume they are merged):
{prev}

TICKETS JUST AFTER (do not do their work here):
{nxt}

THE TICKET, exactly as it appears on the capstone board:

Title: {t['title']}
Phase: {t['phase']}   Session: {t['target_day']}   Points: {t['points']}

Description:
{t['description']}

User story:
{t['user_story']}

Acceptance criteria:
{md_list(t['acceptance'])}

Test cases the trainer runs:
{md_list(t['test_cases'])}

Subtasks (with the squad role that owns each):
{md_list(t['subtasks'])}

Definition of done:
{md_list(t['definition_of_done'])}

BOOK CHAPTERS (link as [title](ID.html)):
{CHAPTERS}
"""
    (SPEC / f"{code}.md").write_text(spec, encoding="utf-8")

print("specs:", len(list(SPEC.glob("*.md"))))
