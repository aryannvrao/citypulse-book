TITLE: Capstone tickets T38 to T41
HOOK: Four real tickets and how your trainer checks them

== title | set=city
B(happy): Welcome back to CityPulse! I am Bolt, and this is Mira, our newest engineer.
M(cheer): Hi! Today my squad starts four capstone tickets, the big final jobs of the course.
B: Each ticket has test cases. A trainer runs them, then checks the commits you made yourself.

== journey | set=sky
NODE: ds : 📊 : Dashboard
NODE: api : 🔌 : CityPulse API
NODE: db : 💾 : Database
M(think): The dashboard team needs our numbers. How do they reach our data?
> ds>api : GET health
B: With an API, a set of web addresses on a server that other programs can call.
> hi api
B: Each address is an endpoint. Version one needs two of them: a health check, and a stats summary.
> api>db : SELECT 1
M(confused): What does SELECT 1 mean?
B: SQL is the language that asks a database questions. It is a tiny question that proves the database answers.
> db>api : one row
M(happy): So if the database is down, health must say so.

== term | set=room
B: Here is the trainer check for health. Ask the address while the database is running.
> $ curl -i localhost:8000/v1/health
> = HTTP/1.1 200 OK
M(think): Curl sends a web request, and the i flag also shows the headers, including the status code, the three digit answer.
B: Now the database runs in a Docker container, a sealed box. Stop the box, then ask again.
> $ docker stop <db-container>
> $ curl -i localhost:8000/v1/health
> = HTTP/1.1 503 Service Unavailable
M(shock): A 503 means the server runs, but the database is down. A plain 200 would fool the dashboard.

== table | set=lab
HEAD: check | result
ROW: Fresh clone | pass
ROW: make setup | pass
ROW: Link to proof | fail
ROW: make reproduce | pass
B: Ticket T39 is a peer audit. A peer squad checks your model repository, the project folder Git tracks, against a twenty item list.
M(think): How many items must pass?
B: Fourteen, which is seventy per cent. Each failure becomes an Issue, a GitHub note that an owner must fix.
> rows 1,2,4
M(happy): So a stranger can clone, meaning copy, the repo, run make reproduce, and get nearly the same number back.
> keep 1,2,4
B: Every pass needs a link to proof, so the trainer can check it.
> reset

== code | set=lab
| sid = "S1"
| sql = "SELECT * FROM readings WHERE id = %s"
| params = (sid,)
| print(sql)
B: Ticket T38 needs one helper, called q, for database questions. Here is the safe technique, step by step.
> line 1
> var sid=S1
M(think): Why not paste the station id straight into the question text?
B: A web visitor could type a trick and rewrite the question. That attack is called SQL injection.
> line 2
> line 3
> var params=(S1,)
B(happy): A question with a placeholder, a percent s mark, is parameterised. The driver, the database library, fills the value in safely.
> line 4
> out SELECT * FROM readings WHERE id = %s

== chain | set=city
B: Ticket T40 hardens the predict endpoint. Every request now passes a chain of checks, in order.
> 📥 : Request arrives
M(confused): Does FastAPI check the fields before my code runs?
> 🧹 : Check the fields
B: Yes. Pydantic, the checking library that FastAPI uses, reads your field rules and sends 422 when a value breaks one.
> 🔎 : Known station?
M(think): An unknown station gets a 404, before the model is ever called.
> 🧠 : Model runs
B(cheer): Then the reply leaves as JSON, a plain text data format, with a request id, a label unique to that request.
> 📤 : Reply sent

== versus | set=lab
LEFT: 🙅 : 422 bad input
RIGHT: 🔍 : 404 unknown station
B: Two status codes get mixed up. 422 means the data broke a rule. 404 means the thing is missing.
M(think): So a humidity of minus five is a 422, because no sensor can measure that.
> L : The body breaks a rule
> L : Humidity cannot be negative
B: A station nobody knows is a 404, even when the body looks perfect.
> R : The body itself is fine
> R : The station is not on our list

== same | set=room
LEFT: 🍕 : Heat oven per order
RIGHT: 🔥 : Oven warm at opening
M(think): Ticket T39 loads the model at startup. Why not load it inside every request?
B: Think of a pizza shop. Heating the oven takes ages, so heat it once before opening.
M(happy): So the model is the oven. Lifespan is the opening time, the startup code that runs once.
B: Right. The model sits in app dot state, so each request reuses it, and stays fast.

== trap | set=lab
WRONG: health returns ok with no query
RIGHT: run SELECT 1, return 503 on failure
B: The most common way to fail ticket T38 is a health check that never asks the database.
M(shock): Oops, that was my first draft. It always answered ok, even with the database down!
B: Catch only the connection error, then send 503. Other bugs must still show up.

== term | set=server
B: Ticket T41 adds automatic tests. A test sends a request, then checks the reply. Pytest, the Python test runner, runs them all.
> $ pytest --collect-only -q
> = 11 tests collected
M(think): Collect only lists them without running. How much of the code do they touch?
B: That is coverage, the share of code lines that ran during the tests. Now a full run.
> $ pytest
> = Required test coverage of 60% reached
M(cheer): So below sixty per cent, the whole run fails. Nice and strict!
> = 11 passed in 1.84s

== graph | set=city
NODE: pr : PR : 0,1
NODE: ci : CI test : 2,1
NODE: red : Red : 4,0
NODE: grn : Green : 4,2
NODE: blk : Blocked : 6,0
NODE: mg : Merge : 6,2
EDGE: pr>ci
EDGE: ci>red
EDGE: ci>grn
EDGE: red>blk
EDGE: grn>mg
B: The last step is the gate. GitHub runs the test job on every pull request, a request to merge your work. The job is part of CI, the automatic checks.
> hi pr,ci
> note PR starts the CI test job
M(confused): And a red check stops the merge by itself?
B: Only when branch protection requires that check. Branch protection is a GitHub rule on the main branch.
> hi red,blk
> note Red check blocks the merge
B(happy): Green lets the merge through. Red stays blocked, so nothing broken reaches main.
> done grn
> hi mg

== quiz | set=room
Q: Which option makes pytest fail when coverage is below 60 per cent?
- --cov-report=term-missing
- --cov=.
* --cov-fail-under=60
- --collect-only
M(think): The report only prints a table. Collect only just lists the tests. So it must be the floor setting.
B(cheer): Correct! Fail under sets the floor.

== recap | set=city
B: Let us lock in what we learned today.
> Health must really ask the database
M: Load the model once, at startup.
> Load the model once at startup
B: Red checks block merges, when branch protection says so.
> Red checks block merges
M: Use 422 for bad input, and 404 for unknown things.
> 422 bad input, 404 unknown
B(cheer): And every commit must be your own work. Good luck, squad!
> Commit only what you wrote
