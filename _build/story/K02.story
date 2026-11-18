TITLE: Capstone tickets: setup, fetch, schedule
HOOK: Four real tickets, and a trainer who runs the tests

== title | set=city
B(happy): Welcome to CityPulse! I am Bolt, and this is Mira, a new engineer.
M(cheer): Today her squad starts four capstone tickets, from setup to the big demo.
B: Each ticket adds a real piece of our system. A trainer tests it before it counts.

== talk | set=room
M(think): How does the trainer know a ticket is really finished?
B: The trainer runs the test cases, then reads your commits, the saved snapshots in Git.
> ✅ : Test cases
M(confused): So my name must be on every change?
B: Yes. Work done on someone else's laptop does not count.
> 🔍 : Your commits

== journey | set=sky
NODE: pc : 🧑 : New teammate
NODE: gh : ☁️ : GitHub
NODE: box : 📁 : Fresh folder
B(happy): Ticket four asks for a setup guide that a stranger can follow in ten minutes.
M(think): A stranger, like a new teammate with a brand new laptop?
> hi pc
B: Exactly. The trainer clones the project, copying its whole history from GitHub, a code website.
> gh>box : git clone
M(cheer): So every step must be written down. Nothing can live only in my head!

== term | set=lab
B(think): The trainer checks which rule hides each path, and whether a secret file slipped in.
> $ git check-ignore -v .venv .env
> = .gitignore:3:.venv/    .venv
> = .gitignore:4:.env      .env
M: Ignored means Git never tracks that file, so it never reaches GitHub.
> $ git ls-files | grep -E '(^|/)\.env$'
B: Nothing printed is a pass. Secrets, like passwords and keys, must never reach GitHub.

== chain | set=city
B(happy): Ticket five writes one script. curl, a tool that fetches web data, asks for one reading.
> 🌐 : Web reply
M(think): So a row is one line of the day's table, with values split by commas?
B: Yes, a CSV row, short for comma separated values. Before writing, the script checks the status code, where 200 means OK.
> 🚦 : Status check
M(shock): So a bad reply must stop the script before a broken row is written?
> 🔎 : Field check
B(cheer): Exactly. jq, the JSON reader, checks the fields. The row is written only after every check passes.
> 📄 : CSV row

== code | set=night
| STATUS=$(curl -s -o "$TMP" -w '%{http_code}' "$URL")
| if [ "$STATUS" != "200" ]; then
|   echo "ERROR: HTTP $STATUS from $URL" >&2
|   exit 1
| fi
| # only now is the row written
B(think): Here is the status check, line by line. Trainers test it with a 404 address.
> line 1
M: The status code goes into the variable STATUS.
> var STATUS=404
B: A 404 is not 200, so the if test is true. Think of it as a guard at the door.
> line 2
> line 3
> out ERROR: HTTP 404 from .../v1/nope
M(confused): So the script stops before the row is written?
> line 4
> out exit code 1
B: Right. Nothing is written. The error goes to standard error, the error channel, so it cannot pass as data.
> out nothing was written

== chain | set=server
B(happy): Ticket six runs the fetch every thirty minutes, started by cron, a scheduler. First comes a lock, a marker that says I am busy.
> 🔒 : Lock check
M(cheer): And a kill switch! If a file named STOP sits in the ops folder, nothing runs.
> 🛑 : Kill switch
B: Then the fetch retries up to three times, waiting longer each time.
> 🔁 : Retry fetch
M(think): Removing repeats is called dedup. So the script skips any reading already saved.
> 🧹 : Skip repeats
B(cheer): Only then is the row appended, meaning added to the end of the day's file.
> 💾 : Append row

== bars | unit=min
BAR: Last success : 75
BAR: WARN line : 60
BAR: CRIT line : 120
B(happy): Ticket seven is the P1 demo, where the trainer breaks things on purpose. Its healthcheck script reports OK, WARN or CRIT.
M(think): So it measures minutes since the last successful fetch?
> hi 1
B: Yes. The last success was 75 minutes ago. Warning starts at 60, critical at 120.
> hi 2
M(confused): Past warning but short of critical, so WARN?
> hi 2
B: Right. Test CRIT first, because a big age also passes the WARN test.
> hi 3

== table | set=room
HEAD: time | pm25 | temp
ROW: 09:00 | 41 | 24.1
ROW: 10:00 | 44 | 24.8
ROW: 11:00 | 47 | no match
B(happy): Ticket seven adds a weather feed as a second source. A merge script joins both on time and place.
M(think): So each air row gets weather columns beside it?
> col 3
B: Yes. A row with no partner, like the eleven o'clock one, has no weather to add.
> rows 3
M(confused): So what happens to that row? Does the script count them?
B(cheer): It is left out of the merged file, and the script prints how many did not match. A high count can mean the timestamp formats differ.
> keep 1,2
> reset

== same | set=class
LEFT: 🚻 : Occupied sign on door
RIGHT: 🔒 : flock lock on a file
B(think): Here is the hardest idea: a lock, made by a command called flock. Picture one bathroom with one key.
M(think): So the first person hangs the occupied sign on the door?
B: Yes. The second person sees the sign, does not wait, and leaves a note. The lock is released when that run ends.
M(happy): So flock with the no wait option acts like the sign. It never queues.

== trap | set=lab
WRONG: type the key into the script file
RIGHT: read the key from the environment only
M(shock): Oh no. I typed my key into the script, and I just committed it!
B: Git keeps every version forever, so deleting the line later does not help. Rotate the key, meaning make a new one and disable the old one.

== quiz | set=room
Q: Which exit code should the healthcheck return when it prints CRIT?
- 0, which means success
- 1, the same code as WARN
* 2, so a monitor can tell CRIT apart
- 3, because CRIT is the biggest number
M(think): Zero means success, and WARN already uses one. So CRIT needs its own number.
B(cheer): Right, it is 2. Zero is OK, one is WARN, and two is CRIT, so a monitor can react to each.

== recap | set=city
B(happy): Let us lock in what these four tickets taught us.
> Setup guides must pass a cold run
M: The status check comes before any write.
> Check the status before writing a row
B: Locks and kill switches stop overlapping runs.
> Locks stop runs from overlapping
M(happy): Keys come from environment settings, never from a file.
> Keys come from the environment only
B(cheer): Commit your own work, with your name on it. Great work, Mira!
> Your name on every commit
