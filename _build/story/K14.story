TITLE: Six capstone tickets and their checks
HOOK: Each ticket is judged by a command and your own commits.

== title | set=city
B(happy): Welcome, squad! I am Bolt, and this is Mira, a new engineer at CityPulse.
M(cheer): Today we start six capstone tickets. Each one is a real job, and a trainer checks it.
B: Let us see what each ticket asks, and the exact check the trainer runs.

== talk | set=room
M(think): Bolt, what does the squad board look like?
B: Five columns, Backlog, To Do, In Progress, Review and Done.
> 📋 : Five board columns
M(sad): Can I move my ticket to Done myself?
B: No. Only a trainer can do that, after running the test cases.
> word : TRAINER DECIDES DONE
B: Your proof is your commits, pull requests and reviews in the squad repository.

== term | set=lab
B(think): Ticket forty nine asks for a baseline. That is the simplest sensible guess, which your model must beat.
M(confused): Like always guessing the middle value? So I write that guess down?
> $ python src/baseline.py && cat reports/baseline.json
B: Yes. The trainer runs your script, then reads the JSON file it wrote, a text file of labelled values.
> = "metric": "MAE",
> = "value": 10.0,
> = "n_test": 3,
> = "split_date": "2025-06-01"
M(think): The split date must match the holdout date in the config file.
> $ grep holdout_from config.yaml
> = holdout_from: 2025-06-01
B(happy): Same date, and a test row count above zero. Then the baseline passes its check.

== code | set=night
| baseline = 20.0
| model = 15.5
| gap = baseline - model
| improvement_pct = round(gap / baseline * 100, 1)
| print(improvement_pct)
B(think): Ticket fifty trains the industry model. Its error is MAE, the average size of a mistake.
M(think): Lower error is better, so how do we report a gain?
> line 1
> var baseline=20.0
B: Start with the baseline's error, twenty. Then the model's error, fifteen point five.
> line 2
> var model=15.5
M(happy): So the gap is twenty minus fifteen point five, which leaves four point five.
> line 3
> var gap=4.5
B: Divide the gap by the baseline, times one hundred, and round to one decimal.
> line 4
> var improvement_pct=22.5
> line 5
> out 22.5
B(cheer): That is twenty two point five percent better. The trainer's check reads these same numbers.

== journey | set=sky
NODE: ui : 🌐 : Web page
NODE: api : 🔌 : API service
NODE: pc : 💻 : Your laptop
B(happy): Ticket fifty one joins the whole project into one command with Docker Compose, a tool that starts every container together.
M(think): So the web page and the API each run in their own container?
> hi ui
> hi api
B: Yes. A container is one packaged program running alone. The web page sends prediction requests across to the API.
> ui>api : POST /predict
M(shock): Wait, if the page uses the word localhost, it calls itself, not the API!
> hi ui
B: Exactly. Inside a container, localhost means only that container. Use the service name.
M(cheer): So the trainer checks that the API is healthy and gives a real prediction. Simple!
> pc>api : health check
> api>ui : answer 200

== term | set=room
B: Ticket fifty two makes the project easy to hand over. First, the trainer asks GitHub for open issues labelled blocker.
> $ gh issue list -R atria-y2/industry-sq -l blocker --state open
> = no issues match your search
M(think): That message means the blocker list is empty, so that check passes.
> $ pytest -q
> = ........   [100%]
> = 8 passed in 0.31s
B: Pytest is a tool that runs every test on a fresh clone. A failing test names itself, like this one.
> = .F......   [100%]
> = FAILED test_bad_payload_returns_422
> = 1 failed, 7 passed in 0.40s
M(happy): So the test for code four twenty two, which means input rejected, proves the API refuses bad input. Smart!

== table | set=class
HEAD: slide | number | in metrics
ROW: Slide 3 | 12.1 | yes
ROW: Slide 5 | 22.5 | yes
ROW: Slide 6 | 12.2 | no
ROW: Slide 9 | 34.2 | yes
B(happy): Ticket fifty three is the client rehearsal. Every number on the slides must appear in the metrics file.
M(confused): Why would a number be missing? Did I just type it from memory?
> rows 3
B: Yes, that is the usual cause. The trainer's command lists slide numbers that the metrics file lacks.
> keep 3
M(think): So I copy each number from the metrics file, and never type it from memory.
> reset
B(cheer): Exactly. The check prints zero when every slide number is in the metrics file.

== graph | set=server
NODE: a : c1 : 0,2
NODE: b : c2 : 1,2
NODE: t : v1.0 : 2,2
EDGE: a>b
EDGE: b>t
B(happy): Ticket fifty four is mentor sign off. Mentors judge one exact version, so the squad freezes it with a tag.
M(think): A tag is a permanent name for one commit, right?
> hi t
> note tag v1.0 names one commit
B: Right, one saved snapshot of the code, called a commit. The trainer compares that tag's commit with main's newest commit.
> hi b
> note main must point at the same commit
M(shock): So if someone commits to main after the tag, the two names split apart!
> note a new commit breaks the match

== same | set=lab
LEFT: 📜 : Sealed exam paper
RIGHT: 🧪 : Holdout test rows
M(think): A teacher hides the exam paper until test day. Students must never study from it.
B: In a model, the holdout rows are that sealed paper. The model never trains on them.
M(think): So if I fit the scaler on every row, I have peeked at the exam?
B(cheer): Exactly. Fit only on training rows, so the test stays honest.

== trap | set=room
WRONG: git tag v1.0 (only on laptop)
RIGHT: git push origin v1.0, then check
M(happy): I made the tag, version one point oh, on my laptop. The freeze is safe, right?
B: Not yet. A tag that never reaches GitHub is invisible to the trainer.
M(shock): Oh no. The remote check would print no line at all.
B(cheer): Right. Push the tag, then run the remote tags check. Then the freeze is real.

== quiz | set=class
Q: The baseline JSON split date is June 1, but config says July 1. Which test fails?
- TC1, the clone failed
* TC2, the JSON must match config
- TC3, the backlog counts are wrong
- TC4, the booking sheet is old
M(think): The JSON says June, the config says July. Which test compares those two dates?
M(cheer): That is the split date check, so the answer must be the one about the JSON.
B(cheer): Correct! Test case two needs the split date to match the config, so the script must read the date from the config.

== recap | set=room
B: Let us lock in the six tickets.
> Baseline is the guess to beat
> Holdout rows stay sealed until testing
> Blocker issues empty, tests all pass
> Push tags, then check the remote
> Slide numbers come from the metrics file
M: Each check is a command the trainer runs. So run it yourself first.
B(cheer): Great work today, Mira. Prove it, then ask for review!
