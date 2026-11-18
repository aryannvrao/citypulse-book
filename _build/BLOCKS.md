# Special blocks (the build turns these into animations and widgets)

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
