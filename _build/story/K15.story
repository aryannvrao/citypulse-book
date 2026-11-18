TITLE: Capstone tickets T55 to T63
HOOK: Nine real tickets. The trainer checks your commits.

== title | set=city
B(happy): Welcome to CityPulse! I am Bolt, and this is Mira, our newest engineer.
M(cheer): Hi! Mira's squad starts the final capstone tickets today, and every one gets checked.
B: A trainer runs test cases on your work, then checks the commits you made yourself.

== term | set=lab
B: Ticket 55 is the gap bridge. You measure your weakest skill before and after practice.
> $ python check_gap_log.py gap_log.csv
> = 5 rows read
> = OK
M(think): So the checker opens the exported log and counts the rows.
B: OK appears only when no field is empty. A blank after measure fails the check.

== term | set=room
B: Ticket 56 is your one page résumé. First, the trainer counts the pages in the PDF.
> $ pdfinfo Sample_Student_Data.pdf | grep Pages
> = Pages:          1
M(happy): One page, and every link must open for a stranger.
B: Then each number must match a file in your repository.
> $ grep -n "1240" metrics.json README.md
> = metrics.json:14:  "tests_run": 1240

== journey | set=sky
NODE: pc : 💻 : Your laptop
NODE: gh : ☁️ : GitHub
NODE: gr : 🤖 : Grading run
B: Ticket 57 is your repository of data structures and algorithms practice. The trainer never grades your laptop. Only commits count.
> pc>gh : git push
M: So I push, and the grader downloads that exact commit?
> gh>gr : clone and checkout
B: Yes. It runs pytest, the test runner, on that fresh copy. Any file you never committed is missing.
> hi gr
M(think): So a file I never committed can make the grader fail?
B: Exactly. Commit everything first, then test.

== chain | set=room
B: Ticket 58 builds a STAR bank. It holds five stories, and each story has four parts.
> 📍 : Situation
M: Where and when did it happen?
> 🎯 : Task
B: What was your own job in that moment?
> 🔧 : Action
M(think): And every action sentence should start with I, not we.
> 📊 : Result
B: End with one clear result, with a number.

== table | set=lab
HEAD: Number | Value | Source
ROW: Invocations | 1440 | cloud-cost.md
ROW: Tests run | 1240 | metrics.json
B: Ticket 59 is the deep-dive note. Every number on your numbers card needs a source file.
> rows 1
M(confused): So if I wrote a number from memory, the trainer catches it?
> col 2
B: Yes. The trainer opens the file and checks that exact line.
> rows 2
M(happy): Good. Copy each value from its file, never from memory.

== term | set=lab
B: Ticket 60 is Demo Day two. The action log records the panel's feedback word for word.
> $ cd citypulse-squad
> $ grep -c "| done |" docs/action-log.md
> = 5
M(happy): Five done rows, one for each student.
B: Use the exact lowercase word done, or the count command misses that row.
M(think): And the links must open a commit dated today?
B: Yes. Open them in your logged in browser, because an anonymous download tool cannot see private pages.

== term | set=room
B: Tickets 61 and 62 are your portfolio and the freeze. Your web address must answer with status 200, which means the page loaded.
> $ curl -sI https://yourname.github.io | head -1
> = HTTP/2 200
M(cheer): And the freeze: GitHub's commit must match the commit I submit.
> $ git ls-remote origin HEAD | cut -f1
> = 3f2a1c9d8e7b6a5f4e3d2c1b0a9f8e7d6c5b4a39
> $ git rev-parse HEAD
> = 3f2a1c9d8e7b6a5f4e3d2c1b0a9f8e7d6c5b4a39
B: Same fingerprint means the trainer checks exactly what you submitted.

== code | set=lab
| components = {"a": 80, "b": 60}
| weights = {"a": 0.5, "b": 0.5}
| total = 0
| for k in weights:
|     total = total + components[k] * weights[k]
| result = total / sum(weights.values())
B: Ticket 63 is hiring day. The trainer rebuilds your final score from its parts, step by step.
> line 3
> var total=0
M(think): The weights here are made up, just for practice.
> line 5
> var total=40.0
B: Each loop round adds one component times its weight. Eighty times a half is forty.
> line 5
> var total=70.0
M(happy): Then the total is seventy, and the weights add to one.
> line 6
> var result=70.0

== same | set=lab
LEFT: 📨 : Sealed exam envelope
RIGHT: 🔏 : Commit SHA fingerprint
M: A sealed exam envelope proves nobody changed the paper after it was closed.
B: A commit SHA works the same way. Change one letter and you get a new fingerprint.
M(happy): So once I submit a SHA, any new commit means a different one!

== trap | set=room
WRONG: pytest passes here, so I submit the SHA now
RIGHT: git status, git add, git commit, push, then clone and test
M(shock): My laptop passed, so I sent the SHA. Oh no, the grader failed!
B: A classic trap. A file you never committed is missing from the clean clone.
M(sad): So my laptop test proved nothing about the grader?
B: Your laptop is not graded. Only the pushed commit is.

== quiz | set=class
Q: Why does the grader clone your repository and check out your SHA?
- To read files still open on your laptop
- To delete your old branches
* To run tests on your submitted commit
- To copy your private CRI scores
M(think): The grader cannot see my laptop, so it must use a fresh copy of one commit.
B(cheer): Correct! It tests exactly the commit you submitted, and nothing else.

== recap | set=city
B: Let us lock in the squad tickets.
> Test cases are the trainer's checks
M: Run each one yourself first, in the same order.
> Run every test case yourself first
B: Every claim needs a number and a link that opens.
> Numbers and links for a stranger
M: The SHA fingerprints one exact commit, so commit and push first.
> Commit and push, then freeze the SHA
B(cheer): Great work today, Mira and squad. Go and check every ticket!
> Nine tickets, one trainer check each
