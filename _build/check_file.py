"""Check one book source file (a day expansion, a ticket guide or a chapter) before it is built.

  python check_file.py <file.md> [--forbid name1,name2]

Reports: unbalanced ``` fences and ::: boxes, quiz questions without exactly one `* ` answer or with
fewer than 3 options, widget blocks the build cannot parse, every ```python test block that fails
when run, and any `def <name>(` for a forbidden function name (the real graded-lab functions).
Exit code 0 means clean.
"""
import pathlib, re, subprocess, sys, tempfile

sys.path.insert(0, str(pathlib.Path(__file__).resolve().parent))
import build  # noqa: E402  (reuses the book's own parsers)


def main():
    path = pathlib.Path(sys.argv[1])
    forbid = []
    if "--forbid" in sys.argv:
        forbid = [x for x in sys.argv[sys.argv.index("--forbid") + 1].split(",") if x]
    raw = path.read_text(encoding="utf-8").replace("\r\n", "\n")
    problems = []

    fences = [i for i, ln in enumerate(raw.split("\n"), 1) if re.match(r"^\s*```", ln)]
    if len(fences) % 2:
        problems.append(f"odd number of ``` fence lines ({len(fences)}); one block is not closed. Fence lines: {fences}")

    depth, opened = 0, []
    for i, ln in enumerate(raw.split("\n"), 1):
        s = ln.strip()
        if re.match(r"^:::\s*\w", s):
            depth += 1; opened.append(i)
        elif s == ":::":
            depth -= 1
            if depth < 0:
                problems.append(f"line {i}: closing ::: with no open box"); depth = 0
            else:
                opened.pop()
    for i in opened:
        problems.append(f"line {i}: ::: box is never closed")

    for m in build.FENCE.finditer(raw):
        kind, body = m.group(2), m.group(3)
        line = raw[:m.start()].count("\n") + 1
        try:
            build.PARSERS[kind](body)
        except Exception as e:
            problems.append(f"line {line}: {kind} block does not parse: {e}")
        if kind == "quiz":
            q = None
            for ln in body.split("\n"):
                s = ln.strip()
                if re.match(r"Q\d*[:.)]", s):
                    if q: check_q(q, problems)
                    q = {"text": s[:70], "line": line, "opts": 0, "ans": 0, "why": False}
                elif q and s.upper().startswith("WHY:"):
                    q["why"] = True
                elif q and not q["why"] and s[:2] in ("* ", "- "):
                    q["opts"] += 1; q["ans"] += s[0] == "*"
            if q: check_q(q, problems)
        if kind == "trace":
            code = re.search(r"CODE:\s*\n(.*?)\n\s*STEPS:", body, re.S)
            n = len(code.group(1).strip("\n").split("\n")) if code else 0
            for s in re.findall(r"^\s*(\d+)\s*::", body, re.M):
                if not 1 <= int(s) <= n:
                    problems.append(f"line {line}: trace step points at code line {s}, but the code has {n} lines")

    for m in build.PYTEST.finditer(raw):
        line = raw[:m.start()].count("\n") + 1
        code = m.group(2)
        with tempfile.NamedTemporaryFile("w", suffix=".py", delete=False, encoding="utf-8") as f:
            f.write(code)
        try:
            r = subprocess.run([sys.executable, "-I", f.name], capture_output=True, text=True, timeout=20)
            if r.returncode:
                problems.append(f"line {line}: python test block FAILS:\n    " + "\n    ".join(r.stderr.strip().split("\n")[-6:]))
        except subprocess.TimeoutExpired:
            problems.append(f"line {line}: python test block timed out (20 s)")
        finally:
            pathlib.Path(f.name).unlink(missing_ok=True)

    for name in forbid:
        for m in re.finditer(rf"^\s*def {re.escape(name)}\s*\(", raw, re.M):
            problems.append(f"line {raw[:m.start()].count(chr(10)) + 1}: defines `{name}`, a function of the real graded lab. "
                            "Rename it and change the problem so it is a twin, not the lab's solution.")

    words = len(re.findall(r"\w+", raw))
    heads = [ln for ln in raw.split("\n") if re.match(r"^#{2,3} ", ln)]
    tests = len(build.PYTEST.findall(raw))
    quizzes = sum(1 for m in build.FENCE.finditer(raw) if m.group(2) == "quiz")
    print(f"{path.name}: {words} words, {len(heads)} headings, {quizzes} quiz blocks, {tests} python test blocks")
    if problems:
        print(f"{len(problems)} PROBLEM(S):")
        for p in problems:
            print(" -", p)
        sys.exit(1)
    print("OK")


def check_q(q, problems):
    if q["ans"] != 1:
        problems.append(f"line {q['line']}: quiz question has {q['ans']} answers marked with `* ` (needs exactly 1): {q['text']}")
    if q["opts"] < 3:
        problems.append(f"line {q['line']}: quiz question has only {q['opts']} options (needs 3 or 4): {q['text']}")


if __name__ == "__main__":
    main()
