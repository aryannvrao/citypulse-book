TITLE: Continuous integration with GitHub Actions
HOOK: A robot checks every change before anyone reviews it

== title | set=city
B(happy): Welcome to CityPulse! I am Bolt, and this is Mira, our newest engineer.
M(cheer): Hi everyone! Today we teach a robot to check our code, every single time.
B: Good plan. Mira has a problem first, so let us start there.

== talk | set=room
M(sad): Bolt, my sensor script worked on my laptop, but it crashed on a teammate's computer.
> 💥 : Broken script
B: That is the classic problem. Nobody ran the checks on a clean computer before the change was shared.
> 🤖 : Checker robot
B(happy): Continuous integration, or CI, fixes that. It runs your checks automatically, on every single change.
M(think): So nobody has to remember to run the tests?
B: Right. Nobody can forget, and nobody can skip it because they are in a hurry.

== journey | set=sky
NODE: pc : 💻 : Your laptop
NODE: gh : 🌐 : GitHub
NODE: rn : 🤖 : Clean runner
B: Your laptop sends a change to GitHub, a website that keeps the project online.
> pc>gh : git push
M(think): And a pull request asks to merge my branch into main, so reviewers can check it.
B: GitHub then starts a runner. A runner is a brand new computer in the cloud, used for one job.
> gh>rn : start job
> hi rn
M(cheer): So it starts with nothing installed and no leftover files from my laptop.
B: Exactly. It copies the code, runs the checks, and reports back on the pull request.
> rn>gh : results

== same | set=lab
LEFT: 📋 : Pilot checklist
RIGHT: 🤖 : CI workflow
M: A pilot runs the same checklist before every flight, even on a boring day.
B: CI does the same thing. The same steps run in the same order, every single time.
M(happy): So nobody skips a step because they are in a hurry. Smart.

== talk | set=class
M(confused): Bolt, what is the workflow file written in? It looks like plain text with indents.
> 📄 : ci.yml file
B: It is YAML, a text format where indentation shows the structure. Use spaces, never tabs.
> word : ON, JOBS, STEPS
M(think): So it is a recipe, read from top to bottom, for the robot?
B(happy): Yes. It says when to run, which computer to use, and the steps in order.

== chain | set=lab
B: A CI workflow runs its steps in order, and each step adds one block.
> 📥 : Copy the code
M: Without the copy step, the runner sees an empty folder, so there is nothing to test.
> 🐍 : Set up Python
B(think): Next, the right Python version is installed. Quote the version number, so YAML reads it as text.
> 📦 : Install packages
M(cheer): Then the packages arrive, and finally the tests run!
> ✅ : Run tests

== code | set=room
| ALIASES = {"pm2.5": "PM25"}
| def normalise(code):
|     c = code.strip().lower()
|     return ALIASES.get(c, code.strip().upper())
| result = normalise("pm2.5")
B: Tests call real code. Here is a tiny cleaning function, and a test would call it like this.
B: Watch the call. Python starts the function with the code holding pm two point five.
> line 5
> var code="pm2.5"
M(think): Then it removes spaces and makes the text lowercase, so the lookup can work.
> line 3
> var c="pm2.5"
B: The lookup finds the alias and returns PM25. The fallback is worked out, but not needed.
> line 4
> line 5
> var result="PM25"

== term | set=room
B: Now the robot runs the tests. Pytest finds every test function and runs it, quietly.
> $ pytest -q
> = ..... 5 passed in 1.84s
M(cheer): Five dots and five passed. Each dot is one test that worked.
> = green tick on the pull request
B: That green tick is the check status. Reviewers see it right on the pull request.

== trap | set=lab
WRONG: scripts/workflows/ci.yml
RIGHT: .github/workflows/ci.yml
M(shock): I saved my workflow in a scripts folder. Did it run?
B: No, and GitHub gives no warning. Only the github folder at the top of the repository is read.

== quiz | set=class
Q: A job has no checkout step and runs pytest. What is in the folder?
- Last run's code, so checkout is optional
- Your laptop folder, copied on each push
* Empty, so pytest finds no files
- The main branch, already installed
M(think): A fresh runner has no memory of earlier runs, so my old files are gone.
B(cheer): Correct! Checkout copies the repository onto the empty runner, so the tests have code to run.

== recap | set=city
B(happy): Let us lock in what we learned today.
> A workflow lives in .github/workflows
M: Every change gets a fresh runner, which starts empty.
> Checkout copies the code first
B: Quote version numbers, such as three point eleven, so YAML reads them as text.
> Quotes stop YAML guessing wrong
M(cheer): A green tick means every check passed. Great learning, Bolt!
B(cheer): Great work today, Mira. Your robot reviewer never forgets a step!
