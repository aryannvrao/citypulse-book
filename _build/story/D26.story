TITLE: CI and CD: the automatic factory
HOOK: Let a robot test and ship every change for you

== title | set=city
B(happy): Welcome to CityPulse! I am Bolt, and this is Mira, our newest engineer.
M(cheer): Hi everyone! Today a broken change reached our air quality API, and nobody caught it.
B(think): Nobody ran the tests before it went live. Let us build a robot that checks and ships for us.

== talk | set=room
M(sad): I pushed my change, then copied the files to the server by hand. The API crashed within minutes.
> 💥 : Server crashed
B(think): Manual steps are slow, and tired people skip them. So we give the checking to a machine.
> 🤖 : Robot checker
B(happy): That idea is called continuous integration, or CI. Every push runs the tests on a fresh computer.
> word : CI = AUTO TESTS
M(think): And the shipping part? Is that the same robot?
B: Yes. Continuous deployment, or CD, puts the tested version live, with no hand copying at all.

== chain | set=lab
B: Think of a car factory line. A part moves on only after the inspection passes.
> 🔍 : Tests
B: Then the robot seals the part in a container, a box holding the program and everything it needs.
> 📦 : Container image
B: Finally the image goes to a registry, a warehouse for images, ready to ship.
> 🏬 : Registry
M(think): So the tests are the inspection, and the image is the finished part. Nice.

== same | set=room
LEFT: 🏃 : Relay race baton
RIGHT: ⚙️ : Waits for test
M: In a relay race, the next athlete starts only when the first one finishes the lap.
B: In a workflow, a job that needs test waits for the test job to pass. Same rule.
M(happy): So if the first athlete falls, the next one never starts. That is the safety.

== code | set=lab
| from app import aqi_band
| def test_good():
|     assert aqi_band(8) == "Good"
B: This is the gate, a test file the robot runs first. It imports the function that labels air quality.
> line 1
B: The test calls the function with eight, then checks the answer is Good.
> line 3
> var label="Good"
> out 1 passed
M(confused): What if it returned Poor instead? The check would fail, right?
B(cheer): Exactly. A failed check, called an assert, stops the test, so the pipeline stops too.

== journey | set=sky
NODE: pc : 💻 : Your laptop
NODE: gh : ☁️ : GitHub
NODE: run : 🖥️ : Fresh runner
B: GitHub watches your repository. When you push, it hands the work to a fresh runner.
> hi gh
> pc>gh : git push
M: A runner is a clean computer for one job, right? Nothing from the last run is left?
> gh>run : start jobs
B: Right. Each job gets a fresh runner, so every test result is honest.
> hi run

== term | set=lab
B: Let us run the tag script. It asks git for the short SHA, the code that names one exact snapshot.
> $ bash tag.sh
> = built citypulse:e610ea4
M(happy): So the image name carries the commit code. I can match a running app to its code.
B: Yes. That short SHA is the serial number of the part.

== versus | set=lab
LEFT: 🏷️ : Tag latest
RIGHT: 🔢 : Tag commit SHA
B: The latest tag is a sticky label. It moves to the newest image on every push.
> L : Moves on every push
> L : Hides which code runs
M(think): And a SHA tag?
> R : Always the same commit
B: Right. Rollback can name the exact old image, with no guessing.
> R : Fixed target for rollback

== trap | set=room
WRONG: password: "my-token" typed in ci.yml
RIGHT: password: secrets.GITHUB_TOKEN from the store
M(shock): Oh no, I just typed my token into the workflow file!
B: A classic trap. Git keeps every version, so the token stays in the history even after you delete it.
B(cheer): Revoke that token now, and read secrets from the store instead. The run gets them safely.

== quiz | set=class
Q: A pull request into main runs the workflow. Does the build push job push an image?
- Yes, it pushes under the tag latest.
* No, the job is skipped entirely.
- Yes, it pushes under the branch name.
- Only the test job runs, and it pushes.
M(think): The if line only allows the job on a push to main. A pull request does not meet that rule.
M(think): So the job is skipped, and an unreviewed branch never becomes a deployable image.
B(cheer): Correct! Only a push to main builds and stores the image.

== chain | set=night
B: Shipping is a second workflow. It starts when you push a version tag, like version one point four point two.
> 🏷️ : Version tag
B: It tells Cloud Run, a managed service that runs containers, to use the same image CI already tested. Nothing gets rebuilt.
> 🚀 : Deploy image
B: Then a smoke test, a quick check that the live app answers correctly, runs against the health address.
> 🩺 : Smoke test
M(think): Wait, does the smoke test stop a bad version going live?

== talk | set=night
B: No. The smoke test runs after the deploy, so a red result means roll back right away.
> ⏪ : Rollback
M(sad): Rolling back means rebuilding the old image, which takes ages, right?
B(happy): No, that is the best part. Cloud Run keeps old revisions, which are saved versions, so moving traffic back takes seconds.
> clear

== recap | set=room
B: Let us lock in what we learned.
> A green test gate blocks broken changes
M: Tag every image with its commit SHA, never latest.
> Tag every image with its commit SHA
B: A push to main builds the image, and a version tag deploys it.
> Push to main builds, tag deploys
M: Rollback moves traffic back. It does not rebuild anything.
> Rollback moves traffic back
B(cheer): And keep secrets out of files. Great work today, Mira!
> Secrets never go in Git
