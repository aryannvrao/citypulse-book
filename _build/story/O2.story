TITLE: Evidence that ranks you first
HOOK: If it is not in the history, it does not count

== title | set=city
B(happy): Welcome to CityPulse! I am Bolt, and Mira is back with a question about proof.
M(think): Hi! I worked hard all week, but my trainer could not see most of it. How do I prove my work?

== talk | set=room
M(sad): Bolt, I stayed up all night fixing the chart. Then my score came back very low.
> 💥 : Low score
B: The chart may be perfect, but the platform only scores what is in the project history.
> word : NO TRAIL, NO CREDIT
M(confused): That is unfair! My name is on my commits, surely?
> 📸 : Commit history
B: Only if the name is right. Each commit stores an author name and an email, and that is what gets scored.

== same | set=city
LEFT: 🎨 : Unsigned painting
RIGHT: 📝 : Signed commit
M: A painting with no signature is still a painting, right?
B: True, but nobody can prove who painted it. A commit with your name is your signature.
M(happy): So a signed commit is proof of who made the work.

== term | set=room
B: Check your identity once inside your squad repo. Git reads these settings on every commit.
> $ git config user.name
> = Asha Rao
M: Lab computers sometimes have someone else's name already set, so I check the email too.
> $ git config user.email
> = asha.rao@example.com
B: Then check the history. The author column must show your own name on every commit.
> $ git log --format='%h %an %s' -2
> = 3f9a2c1 Asha Rao Add --loc flag to fetch.sh
> = 7b04e8d Asha Rao Add folder layout and .gitignore
M(cheer): Both commits show my name. The platform can match my work to me now!

== trap | set=lab
WRONG: Commit on a shared machine without checking
RIGHT: Set user.name and user.email before the first commit
M(shock): I committed on the lab computer, so the name must be mine, right?
B: Not always. Lab machines often have a default identity, so your work can be recorded under someone else.
B(cheer): Yes, and check again on any different computer you use.

== chain | set=city
B: Every piece of work follows one path. First you start a feature branch, a movable label for your own work.
> 🌿 : Feature branch
B: Then you make small commits on it, each one a clear snapshot with your name.
> 📝 : Small commits
B: Next you open a pull request, which asks others to look at the change and merge it.
> 🔀 : Pull request
M(think): And the last step is a review that runs the branch, before the merge into main.
> ✅ : Review and merge

== versus | set=class
LEFT: 🙄 : LGTM alone
RIGHT: 🔬 : Substantive review
M(think): My reviewer only wrote LGTM. Is that enough?
B: LGTM means looks good to me. On its own it scores zero under the course rules.
> L : Scores zero under the rules
> L : Shows no check was run
M(happy): And a real review?
B: It says what the reviewer ran, what they saw, and what should change.
> R : Names the command it ran
> R : Says what was seen
> R : Asks for one clear change

== table | set=class
HEAD: Score | What it proves
ROW: 0 to 1 | No proof
ROW: 2 | Partly proven
ROW: 3 | Checkable
B: Gates are scored from zero to three. A stranger should be able to confirm a three from the links alone.
> rows 3
M: So a claim with no link or file scores almost nothing.
> rows 1
B: Right. Write the number the file shows, and nothing more.
> reset

== bars | set=city
BAR: Your part : 60
BAR: Team result : 40
M(confused): Why is the grade split this way?
B: Your own commits, reviews and pull requests count for sixty per cent, because they show your contribution.
> hi 1
B: The team result counts for forty per cent. Merge on time, and lift your squad-mates.
> hi 2

== quiz | set=class
Q: Which command shows the author name recorded on each of the last two commits?
- git status
* git log --format='%h %an %s' -2
- git add .
- git push origin main
M(think): Status only lists changed files, push sends commits, and add stages them. So the history view must be git log.
B(cheer): Correct! The log shows the author name, and that is your proof.

== chain | set=room
B: Use a simple formula, and start with a strong verb.
> 🔨 : Verb
B: Then name what you built, and the tool or method you used.
> 🧩 : What you built
> 🔧 : Tool or method
B: Add a number with its unit, and say where a recruiter can see it.
> 📊 : Number and unit
> 🔗 : Where to see it
M(happy): Verb, thing, tool, number, link. Every line has evidence then!

== recap | set=city
B: Let us lock in what we learned.
> Work counts only if it is in the history
M: Check your name on every commit before you push.
> Set your identity before the first commit
B: Reviews need a run, a result and a clear request.
> Substantive beats LGTM
M: And every CV number needs a link I can open.
B(cheer): Exactly. Great work today, Mira!
> Every CV number needs a link
