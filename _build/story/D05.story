TITLE: Branches, pull requests and releases
HOOK: Five people, one program, and no broken main

== title | set=city
B(happy): Welcome to CityPulse! I am Bolt, and this is Mira, our newest engineer.
M(cheer): Hi! Five of us work on one program, so today we learn how to share code safely.
B: Our rule is simple. Nobody edits main directly, and every change gets reviewed first.

== talk | set=room
M(sad): Bolt, I pushed my fix straight to main last night. Now everyone's code fails on startup.
> 💥 : Broken main
B(think): A shared line that breaks stops the whole team. So we use a branch, a movable name for your own line of work.
> 🌿 : Branch
B: Your branch is a private draft. You open a pull request when it is ready for an editor to read.
> 📝 : Pull request
M(think): Like a school newspaper, where an editor checks each story before it is printed.

== same | set=room
LEFT: 📰 : Newspaper draft
RIGHT: 🌿 : Git branch
M: The newspaper draft sits on its own sheet until an editor approves it.
B: A branch works the same way. Your change stays separate until a teammate has reviewed it.
M(happy): And when it is approved, the story goes to print, which is main!

== journey | set=sky
NODE: me : 💻 : Author
NODE: gh : ☁️ : GitHub
NODE: rv : 🧑‍💻 : Reviewer
B: Here is one pull request from start to finish. First, the author pushes the branch up.
> me>gh : git push
M: GitHub opens the pull request, and the reviewer gets a request to look at it.
> gh>rv : review requested
B: The reviewer runs the branch, then asks for changes, with evidence of what went wrong.
> rv>gh : request changes
M(think): Then the author pushes a fix to the same branch, so the pull request updates itself.
> me>gh : fix pushed
B(happy): Once the reviewer approves, GitHub merges the work into main.
> gh>me : merged

== term | set=room
B: Let us start a branch the safe way. Update main first, then create the branch.
> $ git switch main && git pull --ff-only
> = Already up to date.
M: Now I make my branch, named after Issue number twelve.
> $ git switch -c feat/12-loc-flag
> = Switched to a new branch 'feat/12-loc-flag'
B: Good. Next we push the branch up to GitHub, so a pull request can start from it.
> $ git push -u origin feat/12-loc-flag
> = branch 'feat/12-loc-flag' set up to track
M(cheer): My branch is online, and the review can begin.

== graph | set=lab
NODE: m0 : base : 0,2
NODE: m1 : main : 1,2
NODE: m2 : main : 2,2
NODE: f1 : feat : 2,1
NODE: f2 : feat : 3,1
NODE: m3 : merge : 4,2
EDGE: m0>m1
EDGE: m1>m2
EDGE: m1>f1
EDGE: f1>f2
EDGE: m2>m3
EDGE: f2>m3
B: Commits form a chain on main. Your branch is a side road that starts at a commit on main.
> hi m0,m1
> note main: the shared line
M(confused): So the feature commits float above main until they are merged?
> hi f1,f2
B: Exactly. The side road grows on its own, and main does not move.
> done f1,f2
B(happy): When the review passes, the side road joins main at the merge.
> hi m3
> note merge: side road joins main

== code | set=lab
| seen = set()
| out = []
| for key in ["S1", "S2", "S1"]:
|     if key not in seen:
|         seen.add(key)
|         out.append(key)
| print(len(out))
B: This Python loop keeps the first copy of each station key, and drops the repeat.
> line 1
> var seen=set()
> line 2
> var out=[]
M(think): The key S1 is new, so it joins seen and out.
> line 5
> var key="S1"
> line 7
> var out=["S1"]
B: The next key S2 is also new, so it is kept too.
> line 4
> var key="S2"
> var out=["S1", "S2"]
M(shock): Then S1 comes back, and the set already holds it.
> line 5
> var key="S1"
B(cheer): So the test is false, the repeat is dropped, and the length printed is two.
> line 7
> out 2

== table | set=lab
HEAD: change | example | next
ROW: Bug fix | sensor typo | v0.2.1
ROW: New feature | loc flag | v0.3.0
B: A release number has three parts: major, minor and patch. The bump depends on what changed.
> rows 1
M(think): A bug fix raises the last number, so zero point two point one.
> rows 2
B: A new feature raises the middle number and resets the last one. Before version one, that is all you need.
> col 3
M(happy): So the number tells users how much to check before they upgrade.
> reset

== trap | set=lab
WRONG: LGTM
RIGHT: Ran it with a space in the name. Failed. Please quote it.
M(shock): I approved a teammate's pull request with just LGTM. I did not even run it!
B: A classic trap. Those letters mean looks good to me, but they show no evidence at all.
B: Say what you ran, the input you used, and what you saw. Then the author can act on it.

== quiz | set=class
Q: Ana's local main is three days old. She creates her branch now. What is the risk?
- It deletes remote main on GitHub.
- It makes main read-only for now.
* Her diff mixes her work with old code.
- It moves the Issue to Done.
M(think): Creating a branch only copies where I stand, right? So old main matters.
B(cheer): Right! Pull main first, then branch, so your diff holds only your change.

== talk | set=room
M(think): Bolt, what stops someone from pushing straight to main anyway?
B(happy): Branch protection, a GitHub rule that blocks direct pushes. It also needs an approval first.
> 🔒 : Main protected
B: The key setting is enforce admins. Without it, the Tech Lead could bypass the rule under deadline pressure.
> word : NO DIRECT PUSHES
M(cheer): So even the boss must use a pull request!
B: Exactly. We test it with a direct push that GitHub must refuse.

== term | set=room
B: Now we publish version zero point two zero. The tag marks the exact commit that was demonstrated.
> $ git tag -a v0.2.0 -m "P2: team workflow"
> $ git push origin v0.2.0
> = * [new tag] v0.2.0 -> v0.2.0
M(think): An annotated tag stores the author, the date and a message, so anyone can check it later.
> $ gh release create v0.2.0 --notes-file notes.md
> = Release v0.2.0 published

== recap | set=city
B(cheer): Let us lock in the workflow.
> Branch from a fresh main
M: Open a pull request, and get a reviewer to run it.
> Review with evidence, never LGTM alone
B: Protect main, so every change goes through review.
> enforce_admins blocks direct pushes
M(think): Squash merge keeps main tidy, one commit per pull request.
> gh pr merge --squash --delete-branch
B(cheer): And tag each release with notes. Great work today, Mira!
> Annotated tag plus release notes
