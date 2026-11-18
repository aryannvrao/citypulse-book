# Storyboard brief: cartoon explainer videos

You are writing the storyboard for a 3 to 4 minute **cartoon** video that teaches one chapter of a study book. A program turns your storyboard into an animated video with two talking characters, so you write a small text file in a fixed format. You do not draw anything.

The viewer is a complete beginner on a software-engineering course who must pass quizzes, coding tests and a viva on this chapter. After watching, they should understand the chapter's main ideas well enough that reading the chapter feels easy.

## The cast

- **Mira (M)**: a new student engineer at CityPulse, a company that monitors a city's air quality. Curious, makes the mistakes a beginner makes, asks the questions the viewer is thinking.
- **Bolt (B)**: a friendly robot mentor. Explains with everyday comparisons, never talks down, short sentences.

The video is a conversation between them. Mira should speak about 40% of the lines. She guesses, gets things wrong sometimes, and sums up in her own words.

## How to work (keep token use low)

1. Read this brief and the worked example `_build/story/D01.story`.
2. Read the chapter source you were given (`src/<ID>.md`) once, in full.
3. Write `_build/story/<ID>.story` with one Write call.
4. Run the checker: `python "C:/Users/lenovo/Documents/Default Project/learnlytica/Book/_build/make_cartoons.py" --check <ID>`
5. Fix what it reports with Edit and re-run until it prints `OK`. Then do the next chapter.
6. Reply with one line per chapter: the ID and the checker's OK line. Nothing else.

Do not read other files. Do not change any file except your `.story` files.

## What a good storyboard does

- **Opens with a problem Mira actually has** at CityPulse (lost work, a slow script, a crashed server, a wrong number on a dashboard), not with a definition.
- **Teaches the 4 to 6 ideas that matter most** in the chapter. Take them from the chapter's sections "The idea in one minute", "What the quiz tests" and "The graded lab skill" (project chapters: what the project builds and how to defend it). Skip minor details. Every idea gets a picture: a comparison, a moving diagram, a code step-through or a terminal demo.
- **Uses one everyday comparison** (a `same` scene) for the hardest idea.
- **Shows a real mistake** (a `trap` scene) that beginners make in this chapter, and the fix.
- **Asks one question** (a `quiz` scene) that tests understanding, in your own words. Mira reasons it out loud.
- **Ends with a recap** of the 4 or 5 things to remember.
- Is accurate. Commands, code and facts must match the chapter. Code shown in `code` scenes must be correct Python that does what the dialogue says, with the variable values it would really have.
- Is fun: a little humour, Mira's reactions, a running comparison. Never silly at the cost of being correct.

## Speech rules

- Every speech line is spoken aloud by a voice **and** shown in a speech bubble. Write it exactly as it should be said.
- At most 32 words per line; most lines 10 to 22 words. Plain words, short sentences.
- No symbols in speech: none of `` ` \ / _ = < > { } [ ] | # * @ $ ``. Say "git commit with a message", not the flags. Say "the dot env file", "x equals five", "greater than". Symbols belong in the pictures (code, terminal, labels), not in speech.
- Explain every technical word the first time it is used.

## File format

```
TITLE: short chapter title (44 characters at most)
HOOK: one-line promise shown on the title card (60 at most)

== sceneType | set=setName
DATA lines for this scene type (if it has any)
M(mood): what Mira says
> action that happens on screen while she says it
B: what Bolt says
> action
> another action
```

- A scene starts with `== type`. `| set=name` is optional and picks the background: `city`, `night`, `room`, `sky`, `server`, `class`, `lab`. Vary it.
- Data lines come straight after the `==` line, before any speech.
- Speech lines start with `M:` or `B:`. A mood in brackets is optional: `happy`, `think`, `confused`, `shock`, `sad`, `cheer`. Use moods often; they drive the character's face and arms.
- Lines starting with `> ` are actions. They belong to the speech line directly above and play one after another while it is spoken. At most 4 per speech line.
- Leave a blank line between scenes. No other text, no comments, no Markdown.

Totals the checker enforces: 9 to 14 scenes, 34 to 60 speech lines, 430 to 780 spoken words. First scene `title`, last scene `recap`. At least one each of `same`, `trap`, `quiz`. At least 4 different types from the "moving picture" group below. At most 3 `talk` scenes, never two in a row.

## Scene types

Each has a limit on speech lines (shown in brackets) and on text lengths, because the text must fit on screen.

### Story scenes

**`title`** (2–3 lines). No data, no actions. Bolt and Mira greet the viewer and say what today's problem is.

**`talk`** (2–6 lines). The two characters talk, large on screen. Actions:
- `> 📸 : Snapshot` pops up a picture card: one emoji, then ` : `, then a label (18 characters at most). The last four cards stay on screen.
- `> word : COMMIT = SAVE POINT` shows a big banner (26 at most).
- `> clear` removes the cards.

**`same`** (2–4 lines). A comparison: an everyday thing next to the technical thing. Data: `LEFT: 🎮 : Game save points` and `RIGHT: 🗂️ : Git commits` (labels 22 at most). The left picture shows on the first line, the right one on the second. No actions.

**`trap`** (2–3 lines). A mistake and its fix. Data: `WRONG: what the beginner does` and `RIGHT: what to do instead` (64 at most; code or words). The wrong one shows on the first line, the right one on the second. No actions.

**`quiz`** (2–3 lines). Data: `Q: question` (90 at most), then 3 or 4 options (42 at most) each on its own line, wrong ones starting `- ` and the single right one starting `* `. The answer is revealed when the last speech line starts, so the earlier line(s) are Mira thinking. No actions.

**`recap`** (3–6 lines). Each `> text` action (46 at most) adds a ticked item; use 3 to 5 in total.

### Moving pictures (use at least 4 different ones; 2–8 lines each)

**`journey`**: things that send something to each other (browser to server, laptop to GitHub, script to database).
Data: 2 to 5 lines `NODE: id : 🙂 : Label` (label 16 at most; id is a short word you choose).
Actions: `> pc>gh : git push` sends a packet from one node to another with a label (22 at most); `> hi gh` makes a node glow.

**`chain`**: steps in order, or layers. Each action `> 📦 : Staging area` adds the next block (label 18 at most). 3 to 6 blocks, joined by arrows left to right. Write `== chain | dir=pile` to stack them bottom to top instead (3 to 5 blocks) for layers.

**`code`**: step through real code.
Data: 2 to 12 code lines, each starting with `| ` (52 characters at most after the bar; keep the indentation after the bar).
Actions: `> line 3` moves the highlight to code line 3 (counting from 1); `> var total=12` shows or updates a variable (up to 6 variables); `> out Hello` prints a line of output (up to 4).

**`term`**: a terminal session. Actions: `> $ git status` types a command; `> = modified: sensor.py` prints an output line (62 at most each, 14 lines at most per scene).

**`versus`**: two things compared side by side.
Data: `LEFT: 🔑 : Title` and `RIGHT: 🔓 : Title` (20 at most).
Actions: `> L : point about the left one` or `> R : point about the right one` (38 at most, up to 4 per side).

**`table`**: rows of data (pandas, SQL, CSV).
Data: `HEAD: city | pm25 | day` (2 to 5 columns) and 2 to 6 lines `ROW: Pune | 82 | Mon` (cells 14 at most).
Actions: `> rows 1,3` highlights rows (counting from 1); `> col 2` highlights a column; `> keep 1,3` keeps those rows and fades the rest (a filter); `> reset` clears.

**`bars`**: compare sizes (speed, cost, counts, accuracy).
Data: 2 to 7 lines `BAR: label : number` (label 12 at most). Optional `| unit=ms` on the `==` line.
Actions: `> hi 2` highlights the second bar.

**`array`**: a row of boxes with pointers, for lists, strings and algorithms.
Data: `CELLS: 3 8 1 9 4` (3 to 10 values separated by spaces, 4 characters at most each).
Actions (indexes count from 0): `> ptr i=0 j=4` places or moves named arrows; `> hi 2,3` highlights cells; `> done 0,1` turns cells green; `> swap 0,4` swaps two cells; `> set 2=7` changes a value; `> note text` shows a caption (60 at most).

**`graph`**: circles joined by lines, for trees, networks, commit history, state machines.
Data: 3 to 9 lines `NODE: id : label : col,row` (label 8 at most; col 0 to 6 from the left, row 0 to 3 from the top; no two nodes in the same place), then `EDGE: a-b` for a line or `EDGE: a>b` for an arrow.
Actions: `> hi a,b` highlights nodes; `> done a` turns them green; `> note text` shows a caption (60 at most).

## Checklist before you finish

- The picture changes on most speech lines (add actions); a scene where nothing moves is dull.
- Speech and picture agree: when Bolt says "line three", the action is `> line 3`.
- Labels are short enough (the checker tells you).
- Emoji are single, common ones.
- The checker prints `OK`.
