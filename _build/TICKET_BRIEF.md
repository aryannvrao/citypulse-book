# Brief: write the guide for one capstone ticket of "CityPulse Mastery"

## Who reads this and why

One second-year student at Atria University, Bengaluru, on the Learnlytica course "CityPulse Engineering Stack". The course runs as an internship on probation: each squad of about five students builds CityPulse, a Bengaluru city-data platform, by working through 63 numbered tickets (Y2-T01 to Y2-T63) on a capstone board. The student starts from zero, so explain every technical word where it first appears.

How tickets are judged (from the course site): only a trainer can move a ticket to Done, after running its test cases, and gives it a gate score from 0 to 3. Everything is judged from commit evidence in the squad repository (commits, pull requests, reviews). The viva scores four things, 0 to 5 each: acceptance criteria met, technical depth, contribution and ownership, and understanding. The final capstone grade is shown as 60% individual contribution and 40% team.

Your guide must leave the student able to do the ticket **themselves**, prove it passes every test case, show their own contribution in Git, and defend it in the viva.

## How to work

1. Read this brief, `BLOCKS.md` (same folder: the syntax of the special blocks) and your spec file.
2. Read only the parts of the related book chapters you need for the techniques.
3. Write the output file named in your spec with ONE Write call.
4. Run the CHECK COMMAND from your spec. Fix every problem it reports with Edit, then run it again until it prints `OK`.
5. Reply with one line: the output path, the word count and `OK`.

Change no other file.

## Integrity rules (non-negotiable)

- Teach the student to do the ticket; do not do it for them. Show every technique with a small worked example and the command or code for each step, explain how the pieces fit, and leave the squad's own choices (their data source, column names, thresholds, wording) to them. **Never** present the ticket's main deliverable as one finished, copy-ready file (for example a complete `fetch.sh`, `load.py`, `Dockerfile` or workflow file in a single block). Build it up in stages, each stage short and explained, with the student assembling and testing it.
- Where the ticket itself is a test (a contest, a proctored checkpoint, "solve 15 SQL challenges", an audit, a mock interview), teach the skills and give original practice, never answers to the real thing.
- Never write text the student would submit as their own (a charter, a CV bullet, a STAR story, a report). Give the structure, a checklist and a clearly fictional example about a different project, and tell them to write their own.
- Do not invent course facts. The ticket text in the spec is the authority on file names, commands, numbers and deadlines.

## Environment facts

- The lab machine is Linux with bash, cron, git, curl, jq and Python 3; the student's laptop runs Windows (use Git Bash there). Say where each command runs.
- The squad repository is on GitHub; work happens on branches merged through pull requests with at least one squad-mate's approval and no self-merge, unless the ticket says otherwise.
- Squad roles named in subtasks: Backend, Data, QA/DevOps, Scrum/Docs, and "Every student".

## The file you write

Markdown, starting directly with the first `###` heading (no TITLE, SUB or `##` lines; the build adds the ticket's `##` heading). Use these `###` sub-sections, in this order:

1. `### The ticket in plain words` — what the ticket asks and why CityPulse needs it, in everyday words (100 to 250 words). Explain the story in the description (for example a famous failure it mentions) in one or two sentences.
2. `### Before you start` — what must already be merged (from the spec), the tools and accounts you need, and a quick check command for each with the output that means you are ready.
3. `### Words you need` — a two-column table: term, plain meaning. Every technical word the ticket uses.
4. `### How your trainer checks it` — go through **every** acceptance criterion and **every** test case. For each test case: the command broken into its parts, each part explained; what passing output looks like; what a failing output looks like and its usual cause. Include one ` ```term ` animation showing a test case passing.
5. `### Split the work` — a table of the subtasks: id, owner role, what it means, estimate. Then: which piece you should own so your commits show real contribution, the branch name, and 4 to 8 example commit messages in the order you would make them.
6. `### Do it, step by step` — one `####` heading per subtask, in order. For each: the goal; the commands or code, in short stages, each followed by a line-by-line explanation and the output to expect; how to test that stage before moving on. Teach each technique with a small example first if it is new (for example how `flock -n` works, before using it). Include one ` ```flow ` or ` ```trace ` animation where it helps most.
7. `### Prove it before review` — run every test case yourself, in order; then a pull-request description template with headings (What, Why, How to test, Evidence, Checklist) and what evidence to paste (log excerpts, command output, screenshots).
8. `### Definition of done` — the spec's definition of done as a `- [ ]` checklist, each item followed by how you know it is true.
9. `### What goes wrong` — a table: symptom, cause, fix. At least 6 rows, specific to this ticket.
10. `### Defend it in the viva` — 5 questions a trainer would ask about this ticket (at least one on why, one on a trade-off, one on what you personally did), each followed by a model spoken answer inside a `:::answer Model answer` box. Model answers explain reasoning; they do not invent the student's personal history.
11. `### Check yourself` — one ` ```quiz ` block with 3 original questions about this ticket's ideas.

## Accuracy

Commands, flags and code must be real and must do what you say. If a command differs between Linux and Git Bash on Windows, say so. If you are not sure a flag exists, do not use it. Python shown in ` ```python test ` blocks is run by the check command (standard library only, no files or network, under 5 seconds, ending with `assert` lines); use ordinary ` ```python ` for code that needs packages, files or a network.

## Style and length

Plain, direct English in full sentences; short paragraphs; British spelling; address the reader as "you"; no emojis; no filler. After each code block, explain it line by line and say what output to expect.

Length: 2,500 to 4,000 words; up to 5,000 for tickets worth 8 points or more.
