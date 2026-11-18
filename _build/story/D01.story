TITLE: Git, GitHub and secure accounts
HOOK: Never lose your work again

== title | set=city
B(happy): Welcome to CityPulse! I am Bolt, and this is Mira, our newest engineer.
M(cheer): Hi everyone! Today I want to learn how real teams save and share their code.

== talk | set=room
M(sad): Bolt, I changed my program last night and now it is broken. I cannot get the old version back.
> 💥 : Broken code
B(happy): That is the exact problem Git solves. Git takes snapshots of your whole project, like save points in a game.
> 📸 : Snapshot
M(think): So I can jump back to any save point I like?
> ⏪ : Go back
B: Any of them. Each snapshot is called a commit, and Git keeps every single one.
> word : COMMIT = SAVE POINT

== same
LEFT: 🎮 : Game save points
RIGHT: 🗂️ : Git commits
M: In a game, I always save just before the boss fight.
B: In Git, you commit just before a risky change. It is the same idea, but for code.
M(happy): And if the boss wins, I simply reload the save!

== chain
B: Every change travels through three places. First is the working folder, where you edit your files.
> 📝 : Working folder
B: Then git add moves the changes you choose into the staging area. Think of it as a packing box.
> 📦 : Staging area
B: Finally git commit seals the box and stores it in the repository for good.
> 🏛️ : Repository
M(think): Edit, add, commit. Three steps, every single time.

== term | set=room
B: Let us try it for real. Git status shows what has changed.
> $ git status
> = modified:   sensor.py
M: One file is modified. Now I add it to the box.
> $ git add sensor.py
B: Then seal it, with a message that says what you did and why.
> $ git commit -m "Fix sensor rounding"
> = [main 3f2a1c9] Fix sensor rounding
M(cheer): My first commit! And git log shows me the whole history.
> $ git log --oneline
> = 3f2a1c9 Fix sensor rounding
> = 9b1d4e2 Add sensor reader

== graph
NODE: c1 : c1 : 0,2
NODE: c2 : c2 : 1,2
NODE: c3 : c3 : 2,2
NODE: f1 : f1 : 3,1
NODE: f2 : f2 : 4,1
NODE: m : merge : 5,2
EDGE: c1>c2
EDGE: c2>c3
EDGE: c3>f1
EDGE: f1>f2
EDGE: f2>m
EDGE: c3>m
B: Commits join up into a chain. This bottom line is the main branch.
> hi c1,c2,c3
> note main: the code everyone trusts
M(confused): Then what are those two commits floating above it?
> hi f1,f2
B: That is a branch. It is a safe side road where you build a feature without touching main.
> note feature branch: your own side road
B: When the feature works, you merge it, and main receives your work.
> done f1,f2
> hi m
> note merge: the side road joins main again

== journey | set=sky
NODE: pc : 💻 : Your laptop
NODE: gh : ☁️ : GitHub
NODE: mate : 🧑‍💻 : Teammate
B: Git lives on your laptop. GitHub is a website that keeps a copy of the project online.
> hi gh
M: So git push sends my commits up to GitHub.
> pc>gh : git push
B: Right. And your teammate runs git pull to bring them down.
> gh>mate : git pull
B: The very first time, a teammate copies the entire project with git clone.
> gh>mate : git clone
M(happy): Now we all share one history.

== versus
LEFT: 🔑 : SSH key + 2FA
RIGHT: 🔓 : Password only
B: GitHub must be sure it is really you. An SSH key is a pair: a private key that stays on your laptop, and a public key that you give to GitHub.
> L : Private key never leaves you
> L : Public key is safe to share
M(think): And if I only use a password?
> R : Can be guessed or leaked
B: Then one leak and a stranger is inside. So also switch on two factor authentication, a second code from your phone.
> L : Second code from your phone
> R : One leak and they are in

== trap
WRONG: git add .   (with API_KEY inside .env)
RIGHT: list .env in .gitignore first
M(shock): Oh no. I just committed a file with my secret key inside it!
B: A classic trap. Git remembers everything, so the secret stays in history. List secret files in git ignore first, and replace any key that has leaked.

== quiz
Q: Which command moves your changes into the staging area?
- git commit
* git add
- git push
- git status
M(think): Commit saves, push uploads, and status only looks. So it has to be git add.
B(cheer): Correct! Add stages, commit saves, push shares.

== recap
B: Let us lock in what we learned.
> A commit is a save point
M: The three steps, in order.
> Edit, git add, git commit
B: Side roads keep main safe.
> Branch for new work, then merge
M: Sharing with the team.
> push sends up, pull brings down
B(cheer): And protect your secrets. Great work today, Mira!
> Secrets go in .gitignore, never in Git
