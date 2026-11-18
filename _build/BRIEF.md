# Brief: write one chapter of the book "CityPulse Mastery"

## The reader and the goal

One second-year student at Atria University, Bengaluru, taking the Learnlytica course "CityPulse Engineering Stack" (29 days; builds an air-quality data platform called CityPulse). The course is the qualifier for an internship, and the student wants to finish first and get a strong offer.

The student starts from zero: has not used a terminal, has not programmed. Explain every technical word in the sentence where it first appears, including ones that feel obvious (file, command, variable, function, server). Each chapter must stand alone.

The book exists to make the student score on four things the course platform measures, so everything you write should serve one of them:

1. The day quiz: 10 multiple-choice case-study questions, pass mark 70%, and the FIRST attempt is the one that counts. Your spec lists the 10 topics that day's quiz covers.
2. The hands-on lab: a guided 7-step exercise. Your spec lists the steps.
3. The graded lab: a Python problem (write a few functions) marked by visible tests and hidden tests. Hidden tests punish missed edge cases.
4. The viva and interviews: explaining out loud what was built and why.

## How to work (keep it cheap)

- Read this brief, then your spec file, then only the source files your spec lists. Read nothing else. Do not open PDFs; they cannot be rendered on this machine.
- Write the whole chapter with ONE Write call to the output path in your spec. Do not read it back afterwards.
- Reply with one line: the output path and the approximate word count. Nothing else.

## Sources and accuracy

The source `.txt` files are automatic extractions of the course slides and workbook. Line breaks are arbitrary (long commands are split and must be rejoined) and code indentation is lost (restore it). They are the authority on course facts: code, file names, commands, ticket IDs. Do not invent course facts.

Add standard background from your own knowledge to teach the fundamentals the slides skip. If you are not sure of a detail, leave it out rather than guess.

The platform's real quiz questions and real graded-lab problem are the student's own work to do. Do not try to reproduce or solve them. Write original practice questions on the listed topics, and an original practice problem that trains the same skills.

## Style

Plain, direct English in full sentences; short paragraphs; British spelling. Address the reader as "you". No emojis. No warm-up or wrap-up filler (no "In this chapter we will", "Let's dive in", "In conclusion"). Prefer a concrete example over a general statement. After every code block, explain it line by line, including each flag and symbol, and say what output to expect.

Length: 3,500 to 5,000 words. Dense, not padded.

## File format

Markdown. The file starts with two header lines, then sections:

```
TITLE: Day 7 — Python for engineers
SUB: One sentence saying what the reader will be able to do.

## First section heading
```

Use `##` for sections and `###` for sub-sections. Never use a single `#`. Use fenced code blocks with a language tag (`bash`, `python`, `sql`, `yaml`, `json`, `dockerfile`, `text`). Tables are fine.

### Special blocks

The book is an interactive web page. These blocks become animations and widgets, so follow the syntax exactly. The fields are separated by ` :: ` (space, two colons, space). Never use ` :: ` anywhere else inside these blocks.

**Step-through animation of code** (`trace`). The reader presses play and watches one line light up at a time while the variables change. Each step is `line number :: variables :: what just happened`. Variables are `name=value` pairs separated by `; `. Use 6 to 14 steps.

````
```trace
TITLE: Counting readings per station
CODE:
counts = {}
for sid in ["S1", "S2", "S1"]:
    counts[sid] = counts.get(sid, 0) + 1
STEPS:
1 :: counts={} :: Start with an empty dictionary.
2 :: sid="S1"; counts={} :: The loop takes the first station id.
3 :: sid="S1"; counts={"S1": 1} :: "S1" was not there, so get returns 0, and 0 + 1 is stored.
2 :: sid="S2"; counts={"S1": 1} :: Second time round the loop.
```
````

**Moving-parts animation** (`flow`). Boxes in a row with a message travelling between them. Use it for anything that moves between machines, programs or stages. 3 to 6 nodes, 4 to 10 steps. Each step is `from>to :: short label on the message :: what is happening`, where from and to are node numbers starting at 1.

````
```flow
TITLE: What happens when you push
NODES: Your laptop | GitHub | CI runner
STEPS:
1>2 :: git push :: Your new commits travel to GitHub.
2>3 :: start workflow :: GitHub hands the code to a fresh machine to test it.
3>2 :: tests passed :: The result is reported back and shown as a green tick.
```
````

**Typed terminal session** (`term`). Lines starting with `$ ` are commands (typed out one character at a time); other lines are output.

````
```term
$ git status
On branch main
nothing to commit, working tree clean
```
````

**Quiz** (`quiz`). One or more questions, separated by a blank line. Exactly four options; the correct one starts with `* `, the others with `- `. Put the correct option in a different position from question to question. `WHY:` explains why the answer is right and what makes the most tempting wrong option wrong.

````
```quiz
Q: A script must stop if curl gets a 404. Which flag makes curl exit with an error on HTTP failures?
- -s
- -o
* --fail
- -L
WHY: --fail makes curl return a non-zero exit code on HTTP errors. -s only hides the progress meter, so the script would carry on.
```
````

**Flashcards** (`cards`). One per line, `front :: back`.

````
```cards
idempotent :: Running it twice leaves the same result as running it once.
```
````

**Tested solution** (` ```python test `). A Python block tagged `python test` is run automatically when the book is built, and the build fails if it errors. It must be self-contained, use only the Python standard library, need no files, network or input, finish in under 5 seconds, and end with `assert` lines that check the functions, including edge cases.

**Callout boxes.** Open with `:::` and a type, close with `:::` on its own line. Types: `key` (must-know fact), `trap` (common mistake), `tip` (exam or interview tactic), `answer` (hidden until clicked). Markdown and code blocks work inside.

```
:::trap Forgetting -r
Without `-r`, jq prints the string with its quotes.
:::
```

## Sections of a DAY chapter (use these headings, in this order)

1. `## The idea in one minute` — what the day's tools are for and what you will be able to do, in under 150 words, with one everyday analogy.
2. `## Starting from zero` — every background concept the day relies on, taught from nothing with small examples.
3. `## The tools` — one `###` per technology in the slides: what it is, why CityPulse uses it instead of the alternatives, how it works, then the slide code explained line by line, then the mistakes to avoid as `:::trap` boxes. Include at least one `flow` and at least one `trace` or `term` animation in this section, placed where seeing it move helps most.
4. `## The worked example` — the workbook's example taken step by step: goal, code, explanation, output.
5. `## The hands-on lab, step by step` — one `###` per lab step from your spec: what you do, the command or code you would type, what you should see, and how you know it worked.
6. `## What the quiz tests` — one `###` per quiz topic in your spec (all ten): exactly what you must know, in 3 to 6 sentences, and the trap examiners set. Go beyond the slides where the topic needs it. Then one `quiz` block with ten original case-study questions, one per topic, in the same order.
7. `## The graded lab skill` — explain the Python techniques listed in your spec from scratch. Then set the practice problem from your spec as a clear task statement with an example, give an edge-case checklist (empty input, ties, ordering, types, rounding, missing fields), and put the full solution in a `python test` block inside an `:::answer` box, followed by a line-by-line explanation in the same box.
8. `## Say it out loud` — five questions an interviewer or viva examiner would ask about this day, each with a model spoken answer of 3 to 5 sentences inside an `:::answer` box.
9. `## Cheat sheet` — a table of every command, flag, function and rule from the day.
10. `## Flashcards` — one `cards` block with 8 to 12 cards.

Project, foundation and offer chapters use the sections given in their spec instead.
