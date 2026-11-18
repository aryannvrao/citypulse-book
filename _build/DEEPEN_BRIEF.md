# Brief: deepen one Day chapter of "CityPulse Mastery"

## Who reads this and why

One second-year student at Atria University, Bengaluru, on the Learnlytica course "CityPulse Engineering Stack" (29 days; the internship qualifier). The student starts from zero: explain every technical word where it first appears. They want to come first, and asked for much more detail on two things for every Day: **the Day Quiz** and **the Graded Lab**.

You write the replacement for two sections of one Day chapter. The build script swaps your file in for the chapter's current sections "What the quiz tests" and "The graded lab skill", and adds a "How today is scored" section before them (you do not write that one).

## How to work

1. Read this brief, `BLOCKS.md` (same folder: the syntax of the special blocks) and your spec file.
2. Read the files your spec lists, once each.
3. Write the output file named in your spec with ONE Write call.
4. Run the CHECK COMMAND from your spec. Fix every problem it reports with Edit, then run it again until it prints `OK`.
5. Reply with one line: the output path, the word count and `OK`.

Read nothing else and change no other file.

## Integrity rules (non-negotiable)

The Day Quiz and the Graded Lab are assessed work, and the batch scores the first attempt.

- **Quiz:** write original practice questions on the listed topics. You have not seen the real questions and must not guess at them.
- **Graded lab:** you may restate the task in plain words and explain the rules, the concepts, the edge cases and a method. You must **not** write a solution to it: never `def` any name in the spec's FORBIDDEN list, and never show code that would solve the real task with the names changed. Code you write is for a **twin problem**: a different domain and different data, but the same skills.
- If the current chapter's practice problem is too close to the real lab (same structure with only the nouns changed, or the same rules in the same order), change it.

## The file you write

Markdown, starting directly with the first `##` heading (no TITLE or SUB lines). Exactly two `##` sections, in this order, with these headings:

### `## What the quiz tests`

1. A short opening (150 to 250 words): the real format (10 case-study multiple-choice questions on today's topics, one per topic; pass mark 70%; the first attempt is what your skill score keeps), and **how to answer a case-study question**: read the last line first to find what is asked, underline the facts in the scenario that matter, eliminate options that are true in general but do not fix this scenario, and watch for "most", "first" and "best".
2. One `###` sub-section per topic in the spec, in that order. Turn the tag into a readable heading (`pandas-groupby` becomes `### Grouping rows with groupby`). Each sub-section has:
   - **What it is**, from zero, with a small concrete example (code, command or table) and what it outputs. 150 to 300 words.
   - **How it shows up in a case study**: a short CityPulse-style scenario (a team, a symptom, a constraint) and the reasoning that reaches the right decision. 80 to 150 words.
   - A `:::trap` box: the tempting wrong answer and why it is wrong.
   - A ` ```quiz ` block with **three** original case-study questions on this topic. Each question: a 2 to 4 sentence scenario, then the question; four options, one correct (`* `), the correct one in a different position each time across the chapter; a `WHY:` line that explains the right answer and why the most tempting wrong option fails.
3. Close the section with a `### Quick self-test` containing one ` ```quiz ` block of 10 mixed questions, one per topic, harder than the ones above.

### `## The graded lab`

1. `### The task in plain words` — restate the real lab from the spec: the scenario, then each function by name with its signature and **every rule** in the statement, as a bulleted list in plain English. Include the limits and the scoring table from the spec (visible tests with points; hidden tests as a count and total points). Explain what hidden tests are and why they decide the top marks.
2. `### What each function needs` — for each function, the Python ideas it needs (for example `dict.get`, `sorted` with a key, `round`, `isinstance` and why `bool` is a subclass of `int`, slicing, `statistics.median`, `sqlite3` placeholders), each taught with a tiny standalone example **unrelated to the lab's data**. Do not assemble these into the lab's functions.
3. `### The rules people miss` — a table with columns *Rule in the statement*, *What a careless solution does*, *How to check yours*. Cover every rule a hidden test could check: empty input, ties and tie-break order, rounding (and when to round: at the end), types (booleans, strings that look like numbers), boundaries (inclusive or exclusive), ordering of output, not mutating inputs. Take them only from the statement's own rules.
4. `### A method that works for every graded lab` — numbered steps: read the starter file; write the examples from the statement as `assert` lines first; add your own asserts for every row of the table above; implement one function at a time, running the asserts after each; check types and rounding last; run the visible tests; submit once.
5. `### Worked twin problem` — a different-domain problem that needs the same skills (the spec gives an idea). State it like a lab task, then solve it in full: one ` ```python test ` block with the functions and `assert` lines that cover normal cases and every edge case. Then explain the code line by line. Add one ` ```trace ` animation stepping through the trickiest function.
6. `### Your turn` — a second, new twin problem stated like a lab task, with 5 to 8 `assert` lines the reader should make pass. Put a full solution in a `:::answer Show a solution` box as a ` ```python test ` block.
7. `### Before you press Submit` — a checklist of 6 to 10 items specific to this lab (as a `-` list), ending with "Run the visible tests one more time."

## Python test blocks

Each ` ```python test ` block is run by the build and by your check command: standard library only, no files, network or input, finishes in under 5 seconds, ends with `assert` lines. Make sure each one really passes: work out the expected values by hand, and run the check command.

## Style and length

Plain, direct English in full sentences; short paragraphs; British spelling; address the reader as "you"; no emojis; no filler ("Let's dive in", "In conclusion"). Explain code after it, line by line, and say what output to expect. Technical facts must be correct; if you are not sure of a detail, leave it out.

Length: "What the quiz tests" 5,000 to 7,000 words; "The graded lab" 3,000 to 4,500 words.
