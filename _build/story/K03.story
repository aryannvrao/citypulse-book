TITLE: Capstone tickets eight to ten
HOOK: Three real tickets, and how the trainer checks each one

== title | set=city
B(happy): Welcome back to CityPulse! I am Bolt, and this is Mira, our newest engineer.
M(cheer): Hi! Today my squad starts three capstone tickets, numbers eight, nine and ten. That is eleven points.
B: Each ticket says what to build. Then the trainer runs test cases to check it.

== talk | set=room
M(sad): Five of us edit the same scripts. Last week someone pushed straight to main.
> 💥 : Direct push
B(think): One careless push can break the city data. Ticket eight adds a rule.
> 🛡️ : Protected main
B: The rule is called branch protection. It refuses direct pushes, so every change goes through a pull request.
M(think): So I ask permission before my code joins main?
B(happy): Exactly. Let me show you how one pull request travels.

== journey | set=sky
NODE: pc : 💻 : Your laptop
NODE: gh : ☁️ : GitHub
NODE: rv : 🧑 : Reviewer
B: GitHub is a website that holds the squad repository. You work on a feature branch, a separate line of work.
> hi pc
> pc>gh : git push
M(think): So a pull request asks GitHub to merge my branch into main, after people check it?
> gh>rv : review asked
B: Yes. Two squad-mates run your change and comment on specific lines.
> rv>gh : line comments
M(happy): Then I push fixes to the same branch, and the pull request updates by itself.
> pc>gh : fix commit
B: Right. When it is approved, the pull request merges, and the shared history stays clean.

== term | set=lab
B: Ticket eight checks history after the baseline, the commit where ticket seven ended.
> $ git fetch origin
> $ git log --first-parent --format='%h %s' <base>..origin/main
M(think): Each line should end with a pull request number, so nothing skipped the review.
> = 4b1e2c0 Add usage message (#31)
> = 9d7a3f1 Quote the location variable (#29)
B(cheer): Right. A line with no number means a direct push, so tell your Tech Lead.

== trap | set=class
WRONG: PR body says closes #31 in lower case
RIGHT: PR body says Closes #31 with capital C
M(shock): I wrote closes in lower case, and the trainer's check printed false! What went wrong?
B: The check is case sensitive, so only the exact word Closes counts. Edit the description, and the trainer reads the new text.

== graph | set=night
NODE: b : base : 0,1
NODE: a : conf-a : 1,0
NODE: c : conf-b : 1,2
NODE: r : resolve : 2,1
EDGE: b>a
EDGE: b>c
EDGE: a>r
EDGE: c>r
B(think): Ticket nine begins with a merge conflict. Two branches changed the same lines.
> hi a,c
> note same lines, two versions
M(confused): So Git cannot pick a winner. Do I choose by hand?
> done b
B: Yes. Read both sides, keep what both people meant, then test the script.
> hi r
> note resolve by hand, test, commit

== term | set=server
B(think): ShellCheck is a robot that reads scripts and warns about risky lines.
> $ shellcheck scripts/*.sh; echo "exit=$?"
> = In scripts/fetch_once.sh line 12:
> = wc -l $OUT
> = SC2086 (info): Double quote to prevent globbing.
M(sad): My variable has no quotes around it. What does that actually break?
> = exit=1
B: A value with a space splits into two words, so the command may hit the wrong files. Quote it.
> = fixed: wc -l "$OUT"
M(cheer): Then I run it again, and it exits with zero. Green!
> $ shellcheck scripts/*.sh; echo "exit=$?"
> = exit=0

== table | set=room
HEAD: Run | Change | Result
ROW: 1 | Quote OUT | success
ROW: 2 | Unquoted OUT | failure
B: Ticket nine also needs a red check, then a green one, in the run history.
> col 3
M(think): So the newest run is the success, and the failure sits underneath it?
> rows 1,2
B(happy): Right. History runs newest first, so success above failure proves the fix worked.

== same | set=sky
LEFT: 📒 : Shared class notebook
RIGHT: 🔁 : Rebased commits
M(confused): Rebase replays my commits on a new starting point. Why is that risky on a shared branch?
B: Imagine renumbering the pages of a class notebook everyone already copied.
M(think): So everyone else's copy goes out of step?
B(cheer): Exactly. Merge keeps the history. Rebase rewrites it, so never rebase a branch others have pulled.

== code | set=server
| import csv
| columns = ["station", "value"]
| row = {"value": 42, "station": "S1"}
| with open("demo.csv", "w", newline="") as f:
|     writer = csv.writer(f, lineterminator="\n")
|     writer.writerow(columns)
|     writer.writerow([row[name] for name in columns])
B: Ticket ten starts fetch.py, a Python script. It writes a CSV, a table saved as plain text, with the same header as the Bash script.
> line 2
> var columns=["station", "value"]
M(think): The row here is a dictionary, a set of named values. Does its key order matter?
> line 3
> var row={"value":42,"station":"S1"}
B: No. The columns list sets the order, and each name is looked up in that order.
> line 6
> out station,value
M(happy): So the header prints first, then the row.
> line 7
> out S1,42
B: The line terminator setting keeps plain Linux line endings, so diff finds no difference.
> line 5

== chain | set=city
B: Ticket ten also publishes version zero point two zero. Here are the steps.
> 📝 : Changelog section
M(think): So the notes come from the changelog, not a one line tag message?
B: Yes. Next, an annotated tag. It is a permanent name on one commit, with an author and a date.
> 🏷️ : Annotated tag
> 🚀 : Push the tag
M(happy): Last, a tool copies that changelog section into a notes file, so the release notes always match.
> 📰 : Release notes

== table | set=night
HEAD: No. | Area | Severity
ROW: 1 | Protection | High
ROW: 2 | CI runs | Medium
ROW: 3 | README | Low
ROW: 4 | Release | Medium
B: Ticket ten audits another squad from a fresh clone, a new download into an empty folder, following only their README. You need at least five findings.
> col 3
M(think): Each finding needs evidence, like a file path, plus a severity level.
B: High and Medium findings each need an Issue on the peer repository. Low ones stay in the report.
> keep 1,2,4
M(cheer): So the trainer counts Issues for those three rows.

== quiz | set=class
Q: A teammate approves your pull request and writes only LGTM. What does that review earn?
- Full credit, because it was approved.
* Zero, it says nothing about what ran.
- Half credit, because a review was given.
- Credit for the PR, not the reviewer.
M(think): LGTM means looks good to me. An approval looks like a sign off. Full marks?
B: Check the ticket text. It says a bare LGTM scores zero, because nothing was run or seen.
M(happy): So the answer is zero. A useful review says what it ran, with what input, and what it saw.

== recap | set=city
B: Let us lock in what we learned. Ticket eight protects main and needs one approval.
> Protect main and require one approval
M: And the pull request must say Closes with a capital C, or the check prints false.
> Write Closes with a capital C
B: Ticket nine runs ShellCheck. Quote your variables and keep the check green.
> Quote variables, keep ShellCheck green
M(cheer): Ticket ten tags from the changelog, so the notes match. And never rebase a shared branch.
> Tag from changelog; never rebase shared work
B(cheer): Great work, Mira. Run every test case yourself before the trainer sees it.
> Run every test case before review
