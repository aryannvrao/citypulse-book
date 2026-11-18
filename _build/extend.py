"""Extensions built from the real course data (course_data.json, saved from the learner view on 2026-11-17).

- preprocess(cid, raw): adds "How today is scored" to every Day chapter, swaps in the deeper quiz and
  graded-lab sections from _build/expand/<cid>.md when they exist, and adds "How this project is really
  assessed" to every Project chapter.
- make_ticket_chapters(): writes src/K01.md ... src/K15.md, one chapter per group of capstone tickets,
  from the per-ticket guides in _build/tickets/<code>.md.
Generated chapter files start with a GENERATED line; edit the ticket guides, not the K files.
"""
import json, pathlib, re

B = pathlib.Path(__file__).resolve().parent
SRC = B.parent / "src"
EXPAND, TICKETS_DIR = B / "expand", B / "tickets"
DATA = json.loads((B / "course_data.json").read_text(encoding="utf-8"))
LABS = {g["day"]: g for g in DATA["graded_labs"]}
TICKETS = {t["code"]: t for t in DATA["capstone_tickets"]}


def T(*nums):
    return [f"Y2-T{n:02d}" for n in nums]


GROUPS = [
    ("K01", "Tickets T01–T03: onboarding, squad and charter", T(1, 2, 3)),
    ("K02", "Tickets T04–T07: setup, fetching and scheduling data", T(4, 5, 6, 7)),
    ("K03", "Tickets T08–T10: pull requests, CI gate and first release", T(8, 9, 10)),
    ("K04", "Tickets T11–T12: the Python fetch and clean stages", T(11, 12)),
    ("K05", "Tickets T13–T16: warehouse, SQL views, pipeline and defence", T(13, 14, 15, 16)),
    ("K06", "Tickets T17–T19: IAM, S3 and a hardened VM", T(17, 18, 19)),
    ("K07", "Tickets T20–T22: the DSA track, part 1", T(20, 21, 22)),
    ("K08", "Tickets T23–T25: serverless, architecture and the cloud defence", T(23, 24, 25)),
    ("K09", "Tickets T26–T30: charts, dashboard, report and framing ML", T(26, 27, 28, 29, 30)),
    ("K10", "Tickets T31–T37: features, models, tuning and the model card", T(31, 32, 33, 34, 35, 36, 37)),
    ("K11", "Tickets T38–T41: the API, validation and tests", T(38, 39, 40, 41)),
    ("K12", "Tickets T42–T46: containers, CI/CD, deployment and SLOs", T(42, 43, 44, 45, 46)),
    ("K13", "Tickets T47–T48: the grounded GenAI bulletin and the live defence", T(47, 48)),
    ("K14", "Tickets T49–T54: the industry mini-project", T(49, 50, 51, 52, 53, 54)),
    ("K15", "Tickets T55–T63: CV, portfolio, interviews and hiring day", T(55, 56, 57, 58, 59, 60, 61, 62, 63)),
]
CHAPTER_OF = {code: cid for cid, _, codes in GROUPS for code in codes}

# capstone tickets that use each Day's material (by topic)
DAY_TICKETS = {
    1: T(1, 3), 2: T(4), 3: T(5), 4: T(6, 7), 5: T(8, 10), 6: T(9), 7: T(11), 8: T(12), 9: T(13), 10: T(14),
    11: T(15, 16), 12: T(17), 13: T(18), 14: T(19), 15: T(23, 25), 16: T(20, 21), 17: T(22, 27), 18: T(24, 26, 29),
    19: T(28), 20: T(30, 31, 32), 21: T(33, 34, 35), 22: T(36, 37), 23: T(38, 39), 24: T(40, 41), 25: T(42, 43),
    26: T(44, 45), 27: T(46), 28: T(47, 48), 29: T(49, 50, 51, 52, 53, 54),
}
PROJECT_TICKETS = {1: T(5, 6, 7), 2: T(11, 12, 13, 14, 15, 16), 3: T(17, 18, 19, 23, 24, 25),
                   4: T(26, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37), 5: T(38, 39, 40, 41, 42, 43, 44, 45, 46),
                   6: T(47, 48, 49, 50, 51, 52, 53, 54, 60, 63)}


def ticket_link(code):
    t = TICKETS[code]
    return f"[{code} · {mdx(t['title'])}]({CHAPTER_OF[code]}.html#{slug(code, t['title'])})"


def lab_functions(day):
    return re.findall(r"^def (\w+)\(", LABS[day]["starter"], re.M)


def scored_section(day):
    g = LABS[day]
    vis = sum(v["w"] for v in g["visible"])
    rows = "\n".join(f"| Visible test | {v['d']} | {v['w']} |" for v in g["visible"])
    tickets = "\n".join(f"- {ticket_link(c)}" for c in DAY_TICKETS.get(day, []))
    return f"""## How today is scored

These facts come from the course site itself (the learner view of your batch, checked on 17 November 2026).

| Item | What it is | How it counts |
|---|---|---|
| Slides and the Technology in Action workbook | Reading | Not marked |
| Hands-on lab | The guided seven-step lab | Practice for the quiz, the graded lab and the tickets |
| Day Quiz (case study) | 10 multiple-choice questions, one per topic in the next section | Pass mark 70%, so 7 of 10 |
| Graded Lab | "{g['title']}" ({g['difficulty']}), written in Python | Automatic tests, 100 points |

**The quiz.** You may retake a quiz up to 10 times, but your batch records skill scores from your **first attempt**. Treat the first attempt as the exam: finish this chapter, do the practice questions, then sit it once.

**The graded lab.** Your code is run against two sets of tests. You can see and run the visible tests before you submit. The hidden tests you never see; they check the rules the task statement describes that the examples do not show (empty input, ties, wrong types, boundaries). Each run has {g['time']} seconds and {g['mem']} MB.

| Test | What it checks | Points |
|---|---|---|
{rows}
| Hidden tests ({g['hiddenCount']}) | Not shown to you | {g['hiddenWeight']} |

:::key Passing every visible test is not full marks
The visible tests are worth {vis} of the 100 points. The other {g['hiddenWeight']} come from tests you cannot see, so read every rule in the task statement and test it yourself before you press Submit. The section "The graded lab" below shows how.
:::

**The capstone tickets that use today's material.** These are graded by your trainer on the capstone board (see the ticket chapters):

{tickets}
"""


def project_section(n):
    tickets = "\n".join(f"- {ticket_link(c)}" for c in PROJECT_TICKETS[n])
    return f"""## How this project is really assessed

This was checked on the course site (learner view, 17 November 2026), so it describes your batch, not projects in general.

- **The brief is a reading item.** In the course outline this project appears as a slides item inside its milestone module. No separate graded submission is attached to it.
- **The work is assessed on the capstone board.** Your squad works through 63 numbered tickets (Y2-T01 to Y2-T63). Each ticket has a user story, acceptance criteria written as Given/When/Then, test cases your trainer runs, a definition of done and a points value. Only a trainer can move a ticket to Done, and each ticket gets a gate score from 0 to 3.
- **Commits are the evidence.** Every ticket is judged from what is in your squad's repository: your commits, your pull requests and your reviews. Commit every day; the platform says your daily commits are reviewed in your viva.
- **The viva.** Each viva is scored 0 to 5 on four things, 20 in total: acceptance criteria met, technical depth, contribution and ownership, and your understanding.
- **The final capstone grade.** The platform shows it as 60% your own contribution and 40% your team's score. Trainers can change that split for the batch.

So the Part G challenges below are where this brief stretches you, and the tickets are where the same skills are marked. The tickets that build the same pieces as this project:

{tickets}
"""


def section_span(raw, start_heading, stop_heading):
    """(start, end) character span from '## start' up to '## stop' (exclusive), or None."""
    a = re.search(rf"^## {re.escape(start_heading)}\s*$", raw, re.M)
    b = re.search(rf"^## {re.escape(stop_heading)}\s*$", raw, re.M)
    if not a or not b or b.start() < a.start():
        return None
    return a.start(), b.start()


def preprocess(cid, raw):
    m = re.fullmatch(r"D(\d\d)", cid)
    if m:
        day = int(m[1])
        exp = EXPAND / f"{cid}.md"
        span = section_span(raw, "What the quiz tests", "Say it out loud")
        if span and exp.exists():
            new = exp.read_text(encoding="utf-8").replace("\r\n", "\n").strip()
            raw = raw[:span[0]] + new + "\n\n" + raw[span[1]:]
        at = re.search(r"^## What the quiz tests\s*$", raw, re.M)
        if day in LABS and at:
            raw = raw[:at.start()] + scored_section(day) + "\n" + raw[at.start():]
    m = re.fullmatch(r"P(\d)", cid)
    if m:
        at = re.search(r"^## The architecture\s*$", raw, re.M)
        if at:
            raw = raw[:at.start()] + project_section(int(m[1])) + "\n" + raw[at.start():]
    return raw


BOARD_INTRO = """These chapters walk through the real tickets on your squad's capstone board, in the order the board schedules them. The ticket text (story, acceptance criteria, test cases, subtasks and definition of done) comes from the course site. The guides teach you how to do each ticket yourself and how your trainer will check it.

How the board works:

- A ticket moves Backlog, To Do, In Progress, Review, Done. **Only a trainer can move it to Done**, after running its test cases, and gives it a gate score from 0 to 3.
- Every ticket is judged from commit evidence: your commits, pull requests and reviews in the squad repository. Work done on someone else's laptop does not count for you.
- Each ticket has a points value (the "pts" column). Defence tickets (marked D01, D02 and so on) are where you present and answer questions.
- Your viva scores acceptance criteria met, technical depth, contribution and ownership, and understanding, each 0 to 5. The final capstone grade shown on the platform is 60% your own contribution and 40% your team's.

:::tip How to use a ticket guide
Read the guide the evening before the session that ticket is scheduled for. Do the work yourself, in your squad's repository, and run every test case in "How it is checked" before you ask the trainer to review it.
:::
"""


def make_ticket_chapters():
    TICKETS_DIR.mkdir(exist_ok=True)
    for cid, title, codes in GROUPS:
        rows = "\n".join(f"| [{c}](#{slug(c, TICKETS[c]['title'])}) | {TICKETS[c]['target_day']} | {TICKETS[c]['points']} | {mdx(TICKETS[c]['title'])} |" for c in codes)
        parts = [f"<!-- GENERATED by _build/extend.py from _build/tickets/*.md; edit those files -->",
                 f"TITLE: Capstone {title[0].lower() + title[1:]}",
                 f"SUB: {len(codes)} tickets, {sum(TICKETS[c]['points'] for c in codes)} points. What each one asks, how your trainer checks it, and how to do it yourself.",
                 "", "## How to use these ticket guides", "", BOARD_INTRO,
                 "| Ticket | Session | pts | Title |", "|---|---|---|---|", rows, ""]
        for c in codes:
            t = TICKETS[c]
            body_file = TICKETS_DIR / f"{c}.md"
            parts.append(f"## {c} · {mdx(t['title'])}")
            parts.append(f"\n*Session {t['target_day']} · phase {t['phase']} · {t['points']} points*\n")
            if body_file.exists():
                parts.append(body_file.read_text(encoding="utf-8").replace("\r\n", "\n").strip())
            else:
                parts.append(f"> {t['user_story']}\n\nThe full guide for this ticket has not been written yet.")
            parts.append("")
        text = "\n".join(parts)
        text = text.split("\n", 1)[1]           # drop the GENERATED marker so the title line is first
        (SRC / f"{cid}.md").write_text(text, encoding="utf-8")


def mdx(s):
    """Escape < and > so titles such as data/raw/<date>.csv survive Markdown."""
    return s.replace("<", "&lt;").replace(">", "&gt;")


def slug(code, title):
    from markdown.extensions.toc import slugify
    return slugify(f"{code} · {title}", "-")
