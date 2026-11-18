"""Quiz answer-key audit.

  python audit.py extract   write every quiz question to audit/batch_N.txt (about 60 questions each)
  python audit.py apply     apply audit/fix_N.json files: move the correct-answer marker in the chapter sources
"""
import re, sys, json, pathlib

B = pathlib.Path(__file__).resolve().parent
SRC = B.parent / "src"
AUD = B / "audit"; AUD.mkdir(exist_ok=True)
OPEN = re.compile(r"^\s*(`{3,}|:::)\s*quiz\s*$")
CLOSE = re.compile(r"^\s*(`{3,}|:::)\s*$")
QLINE = re.compile(r"^\s*Q\d*[:.)]")


def questions(path):
    """Yield (question_number, [line indexes of its option lines], marked_index, text_lines)."""
    lines = path.read_text(encoding="utf-8").split("\n")
    inq, cur, out = False, None, []
    for i, ln in enumerate(lines):
        if not inq:
            if OPEN.match(ln):
                inq = True
            continue
        if CLOSE.match(ln):
            inq, cur = False, None
            continue
        s = ln.strip()
        if QLINE.match(ln):
            cur = {"opts": [], "marked": [], "text": [s], "why": False}
            out.append(cur)
        elif cur is not None and s:
            if s.upper().startswith("WHY:"):
                cur["why"] = True
            if s[:2] in ("* ", "- ") and not cur["why"]:
                if s[0] == "*":
                    cur["marked"].append(len(cur["opts"]))
                cur["opts"].append(i)
            cur["text"].append(s)
    return lines, out


def extract():
    for f in AUD.glob("batch_*.txt"):
        f.unlink()
    batch, count, n = [], 0, 1
    def flush():
        nonlocal batch, count, n
        if batch:
            (AUD / f"batch_{n}.txt").write_text("\n".join(batch), encoding="utf-8")
            n += 1; batch, count = [], 0
    total = 0
    for path in sorted(SRC.glob("*.md")):
        lines, qs = questions(path)
        block = []
        for k, q in enumerate(qs, 1):
            block.append(f"### {path.stem} Q{k}")
            o = 0
            for t in q["text"]:
                if t[:2] in ("* ", "- ") and o < len(q["opts"]) and not t.upper().startswith("WHY:"):
                    o += 1
                    block.append(f"{o}) {t[2:]}" + ("   <== MARKED CORRECT" if t[0] == "*" else ""))
                else:
                    block.append(t)
            block.append("")
        if count and count + len(qs) > 70:
            flush()
        batch += block; count += len(qs); total += len(qs)
    flush()
    print(total, "questions in", n - 1, "batches")


def apply():
    changed, notes = 0, []
    fixes = {}
    for f in sorted(AUD.glob("fix_*.json")):
        for item in json.loads(f.read_text(encoding="utf-8")):
            fixes[item["id"].strip()] = item
    by_ch = {}
    for fid, item in fixes.items():
        ch, q = fid.split()
        by_ch.setdefault(ch, []).append((int(q[1:]), item))
    for ch, items in by_ch.items():
        path = SRC / f"{ch}.md"
        lines, qs = questions(path)
        for qn, item in items:
            if qn > len(qs):
                notes.append(f"{ch} Q{qn}: no such question"); continue
            q = qs[qn - 1]
            c = item.get("correct")
            if isinstance(c, int) and 1 <= c <= len(q["opts"]):
                for j, li in enumerate(q["opts"]):
                    body = re.sub(r"^(\s*)[*-] ", r"\1", lines[li])
                    ind = re.match(r"\s*", lines[li]).group()
                    lines[li] = ind + ("* " if j == c - 1 else "- ") + body.strip()
                changed += 1
            if item.get("note"):
                notes.append(f"{ch} Q{qn}: {item['note']}")
        path.write_text("\n".join(lines), encoding="utf-8")
    print("markers moved:", changed)
    for nline in notes:
        print(" ", nline)


if __name__ == "__main__":
    {"extract": extract, "apply": apply}[sys.argv[1]]()
