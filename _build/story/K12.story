TITLE: Capstone tickets T42 to T46
HOOK: Ship five capstone tickets your trainer can check

== title | set=city
B(happy): Welcome to CityPulse! I am Bolt, and Mira's squad is about to start its capstone tickets.
M(cheer): Five real tickets, twenty nine points, and a trainer who checks every one of them.
B: A ticket is a job card on the squad board, saying what to build and how it gets tested.

== talk | set=room
B: Each ticket moves across the board, from To Do to In Progress, then Review and Done.
> 📋 : Board columns
M(confused): Who decides when a ticket is Done?
B: Only a trainer moves it to Done, after running its test cases, the fixed checks for that ticket.
> 🎓 : Trainer checks
M(think): So my commits, which are saved snapshots of my code in Git, must prove the work.
> 💾 : Commit

== term | set=lab
B: Ticket T42 packs the API into a container, a sealed box that runs the same anywhere.
M(think): The trainer starts from a fresh clone, a new copy holding only committed files.
> $ docker build -t cp-test .
> = naming to docker.io/library/cp-test done
B: Docker reads your Dockerfile recipe and builds an image, a packed copy of the app. Then they run it.
> $ docker run -d -p 8000:8000 --env-file .env.example cp-test
M(cheer): Port 8000 is a numbered door. The p flag connects that door to my laptop. The trainer also names the container cp.
> $ curl -i localhost:8000/v1/health
> = HTTP/1.1 200 OK
B: The status line must say 200 OK, or the ticket fails its first test.

== chain | set=server
B: Ticket T43 makes the image smaller and safer, and it is built in stages.
> 🔨 : Builder stage
M(think): The builder installs the packages. Then the final stage copies only the finished environment.
> 📦 : Clean runtime
B: That final stage runs as user 10001, not as root, the administrator account.
> 👤 : User 10001
M(happy): So an attacker cannot change the whole machine. Smart.
B: A health check asks the app every 15 seconds if it is alive. The trainer checks that the user number is not zero.
> 💓 : Health check

== same | set=class
LEFT: 🍰 : Cake layers
RIGHT: 🐳 : Docker layers
M(think): Layers are my hardest idea. Each Dockerfile line makes one layer, like a floor of cake.
B: Think of a cake. If you change only the icing, you do not bake the sponge again.
M(happy): So Docker reuses unchanged layers. That is why pip, Python's package installer, must run before my code is copied.
B: Exactly. Code changes often and packages rarely, so put the rare things at the bottom.

== graph | set=night
NODE: l : lint : 0,1
NODE: t : test : 2,1
NODE: b : build : 4,1
EDGE: l>t
EDGE: t>b
B: Ticket T44 builds a pipeline, a set of automatic steps that run on every change.
> hi l
M(think): First, lint checks style and Dockerfile mistakes without running the code.
> note lint: style and Dockerfile checks
B: Then test runs pytest, the Python test runner, plus a coverage check that counts lines the tests run.
> done l
> hi t
M(cheer): Then build pushes the image to a registry, a storage shelf for images, tagged with its commit SHA.
> done t
> hi b
B: A SHA is a unique code name for one commit. The trainer checks the latest main run is green, with three jobs.
> note trainer: green run, three jobs

== journey | set=sky
NODE: pc : 💻 : Your laptop
NODE: gh : ☁️ : GitHub
NODE: run : 🚀 : Cloud Run
B: Ticket T45 puts the API live on Google Cloud Run, a service that runs containers, at a public HTTPS address.
> hi gh
M(think): So pushing a version tag starts the deploy by itself?
> pc>gh : push tag v0.9.0-rc1
B: Yes. A tag is a permanent name on one commit, and a tag starting with the letter v starts the deploy.
> gh>run : deploy this SHA
M(confused): Does it build the image again?
B: No. It deploys the image that CI, the automatic test machine, already tested, so tested code goes live.
> hi run
M(sad): And if the new version is broken?
> run>gh : smoke test
B: A smoke test is a quick check of the live app. If it fails, rollback sends users back to the old version.

== table | set=room
HEAD: path | status | ms
ROW: /v1/health | 200 | 5
ROW: /v1/predict | 200 | 120
ROW: /v1/predict | 404 | 30
ROW: /v1/predict | 503 | 900
B: Ticket T46 adds an alert for when the service stops answering, plus one SLO, a service level objective.
> rows 1
M(think): Let us count these four requests the way the trainer does.
B: The health row goes out first. Health checks always pass, so they would flatter the score.
> keep 2,4
M(confused): The 404 is a client error, so it should not count against us, right?
B: Right. Only server errors count. Row four is a 503, so let us check it.
> rows 4
M(cheer): That one is slow and a server error, so it is not good. Row two is good.
> rows 2
B: One good out of two valid is one half. That measured ratio is the SLI, the service level indicator.

== trap | set=server
WRONG: COPY . . then pip install
RIGHT: COPY requirements.txt, install, then COPY code
M(shock): I copied the whole folder first, then ran pip install. My builds take minutes!
B: A classic trap. Any code edit changes the layer above the install, so everything reinstalls.
M(think): So copy requirements first, install, then copy the code folders?
B: Yes. The install layer stays cached, so a code edit rebuilds in seconds.

== quiz | set=room
Q: Which command prints the user number inside the running container?
- docker logs cp
* docker exec cp id -u
- docker stop cp
- docker images citypulse-api
M(think): Logs show what the app wrote, and stop would end the container. Which one runs a command inside?
B(cheer): Correct! docker exec runs a command inside a running container, and id with the u flag prints the number.

== recap | set=city
B: Let us lock in the five tickets.
> Only a trainer marks a ticket Done
M: My commits are my evidence, and I run every test case myself first.
> Build in stages, run as user 10001
B: Copy requirements before code, so cached installs keep builds fast.
> Copy requirements before code
M: Deploy the exact tested SHA, and check it with a smoke test.
> Deploy the SHA, smoke test, rollback
B(cheer): Measure with an SLO, do your own work, and prove it in Git. Great start, Mira!
> Prove it in Git, with your own work
