TITLE: Observability: logs, uptime and SLOs
HOOK: Know your API is healthy before users tell you

== title | set=city
B(happy): Welcome to CityPulse! I am Bolt, and this is Mira, our newest engineer.
M(cheer): Hi everyone! Today we learn how to know our API is healthy before anyone complains.
B: We will use logs, uptime checks and a reliability score called an error budget.

== talk | set=room
M(sad): Bolt, yesterday our API stopped answering for an hour. The dashboard team told us, not our own alarms.
> 💥 : Silent outage
B(think): That is a painful way to learn. Observability fixes it, by letting us see what a running program is doing.
M(confused): From what? Our program does not talk to us.
> 📸 : Program diary
B: It does, through its records. Every request writes one line in a diary, called a log.
> 📝 : One line each

== code | set=lab
| import json
| record = {
|     "path": "/v1/predict",
|     "status": 200,
|     "latency_ms": 47.2,
| }
| print(json.dumps(record))
B: Each request writes one structured log line. Structured means it has named fields, in a text format called JSON.
> line 2
M(think): So each value has a name stuck to it?
> line 3
> var path=/v1/predict
B: Yes. Path says which address was called. Status says how it ended.
> line 4
> var status=200
M(happy): And latency is how long the request took, in milliseconds.
> line 5
> var latency_ms=47.2
B(happy): Then print turns the record into one JSON line that a log tool reads field by field.
> line 7
> out {"path": "/v1/predict", "status": 200}

== table | set=server
HEAD: path | status | latency_ms
ROW: /v1/predict | 200 | 47
ROW: /v1/predict | 503 | 900
ROW: /v1/health | 200 | 12
ROW: /v1/readings | 500 | 310
M(think): Each line is a row, and each name is a column. So I can filter the log like a spreadsheet.
> col 2
B: Right. Ask for status 500 or more, and keep only those rows.
> keep 2,4
M(shock): Two server errors, a 503 and a 500. Those are our team's job to fix.

== journey | set=sky
NODE: chk : 🤖 : Uptime checker
NODE: api : 🌐 : CityPulse API
NODE: team : 👥 : Squad channel
B: An uptime check is an outside probe. A probe is an automatic request that tests something, here every minute.
> chk>api : GET health
> hi api
M(think): So the checker calls the health address from outside, like a customer would?
> api>chk : status 200 and ok
B: Exactly. It passes only when the status is 200 and the body contains the word ok.
M(confused): And when it fails?
> chk>team : alert
B: After two failures in a row, an alert goes to the squad channel. That is our early warning.
> hi team

== trap | set=lab
WRONG: Status 200 means the API is fine
RIGHT: Also check that ok is in the body
M(shock): Oh no. My check only read the status, and an error page can still come back with 200.
B: A classic trap. Match the body too, so a fake healthy answer fails the check.

== chain | set=lab
B: The SLI, short for service level indicator, is a measured share of good requests. We build it step by step.
> 📝 : JSON log lines
B: First, every request leaves one JSON line in the log.
> ✅ : Good requests
M(think): Then we count the good ones: not server errors, and fast enough.
> 📏 : SLI ratio
B(happy): Good divided by valid gives the SLI. Valid skips the caller's own mistakes.
> 🎯 : SLO target
M: The SLO is the promise, such as 99.5 percent over seven days.
> 💰 : Error budget
B: And the error budget is the failure that promise still allows.

== same | set=room
LEFT: 📱 : Mobile data plan
RIGHT: 🎯 : SLO and error budget
M(happy): My data plan works like a promise. I get a monthly amount, and the rest is my budget.
B: Exactly. The SLO is the plan, and the error budget is the data you have left.
M(cheer): And when the data runs out, I stop streaming until next month!
B: CityPulse works the same way. When the budget is spent, the squad stops new features and fixes reliability.

== bars | unit=ms
BAR: p50 : 48
BAR: p95 : 74
BAR: p99 : 86
BAR: max : 1895
M(think): What is p99? It is the latency that 99 out of 100 requests beat.
> hi 3
B: Right. A percentile is the value below which a share of requests falls. The p50 is the median.
> hi 1
M(shock): Wait, the slowest request took almost two seconds!
> hi 4
B: Those few slow calls are the tail. An average would hide them, so we read percentiles.

== versus | set=lab
LEFT: 📉 : Average latency
RIGHT: 🐢 : p99 latency
M(think): The average looks healthy, so why not alert on it?
> L : Looks healthy most of the time
> R : Shows what unlucky users wait
B: Right. The average hides a slow tail, because a few very slow calls barely move it.
> L : Hides the slow tail
> R : 99 of 100 requests beat it

== term | set=room
B: Let us run the budget script for real. It prints the numbers for the window.
> $ python3 budget.py
> = SLO target: 99.5%
> = error budget: 25 failed requests
> = spent: 3
M(think): So three failures are used, and twenty-two are still left.
> = remaining: 22 (88% of budget)
B(happy): When the status says HEALTHY, the squad keeps shipping features.
> = status: HEALTHY - ship features

== quiz | set=lab
Q: Which statement is a proper SLO for predict requests?
- The API will be fast and reliable.
- The CPU stays below 70 percent.
- The API will never fail, ever.
* 99 percent of requests succeed over 7 days.
M(think): An SLO needs a measure, a number and a time window. The CPU line measures a machine, not a promise to users.
B(cheer): Correct! It has a measure, a number and a window. Promising never to fail is impossible.

== recap | set=city
B: Let us lock in what we learned.
> Logs are one JSON line per request
M: An uptime check tests the service from outside.
> Two failures in a row, then alert
B: The SLI measures success, and the SLO promises it.
> SLI measures, SLO promises
M: The error budget tells us when to stop features.
> Budget spent means fix reliability
B(cheer): Know your API before users tell you. Great work today, Mira!
> Watch it, measure it, protect the budget
