TITLE: Serverless and cost awareness
HOOK: Pay only for the seconds your code runs

== title | set=city
B(happy): Welcome to CityPulse! I am Bolt, and this is Mira, our newest engineer.
M(cheer): Hi everyone! Today we learn to run code in the cloud without renting a whole computer.
B: Our job is to fetch Bengaluru air quality every half hour, and to know exactly what it costs.

== talk | set=room
M(sad): Bolt, my fetch script runs on an old virtual machine. That machine stays switched on all month.
> 💻 : Virtual machine
B(think): A virtual machine is a rented server. You pay for every hour it is on, even when it sits idle.
> 💸 : Monthly bill
M(think): So the fix is to run the code only when it is needed?
B(happy): Exactly. That idea is called serverless. Servers still exist, but you do not manage them, and you pay per run.
> word : PAY PER RUN

== same | set=city
LEFT: 🚕 : Taxi, pay per ride
RIGHT: 🚗 : Car parked all day
B: Think of a taxi and a private car. You hail a taxi for each trip and pay only for that ride.
B: The private car sits in the car park all day, and you pay for it whether you drive or not.
M(happy): So for a short job every half hour, the taxi wins by a mile!
B: Right. Lambda is the taxi, and a virtual machine is the car.

== journey | set=sky
NODE: sch : 🕒 : Scheduler
NODE: fn : ⚡ : Lambda function
NODE: api : 🌐 : Open-Meteo API
NODE: s3 : 📦 : S3 bucket
B: Here is one scheduled run. EventBridge Scheduler is a managed timer, also called cron. Every thirty minutes it calls our function.
> hi sch
> sch>fn : invoke
M: So nobody presses a button. The timer does the work.
B: The function asks the Open-Meteo API for readings. An API is a web address that answers a question with data.
> fn>api : ask for readings
B: Open-Meteo replies with JSON, a plain text format for structured data.
> api>fn : JSON reply
B: The function then saves that reply as one file in an S3 bucket. A bucket is a container for files in the cloud.
> fn>s3 : save file
M(happy): Timer, fetch, save. Then nothing runs at all.

== code | set=room
| def handler(event, context):
|     rec = event["Records"][0]["s3"]
|     key = rec["object"]["key"]
|     size = rec["object"]["size"]
|     print(f"validating {key} ({size} bytes)")
|     return {"ok": size > 0, "key": key}
B: Every Lambda function is a handler, a function that Lambda calls. It takes two inputs, event and context.
> line 1
M: So event holds the details of the file that just arrived?
B: Yes. The first line reads the first record from the list inside event.
> line 2
B: Lines three and four read the file path, and the size in bytes.
> line 4
> var size=318
M(think): Size 318, so the file is not empty.
B: Right. The last line returns the answer, and Lambda records it.
> line 6
> var ok=True

== trap | set=room
WRONG: paste an AWS access key into the code
RIGHT: attach a role, AWS gives temporary keys
M(shock): Oh no. I was about to paste my access key into the code, so the function could reach the bucket.
B: A classic trap. Anyone who reads that code now holds the key, and it stays valid until someone deletes it.
M(think): So what do I do instead?
B: Attach an execution role. A role is an identity from IAM, Amazon's access control service, and AWS hands the function short-lived credentials.

== term | set=room
B: Let us check that a run happened. We read the logs.
> $ aws logs tail /aws/lambda/citypulse-validate --since 1m
> = ...a1b2c3 START RequestId: 7f3c-9a21
> = ...a1b2c3 REPORT RequestId: 7f3c-9a21 Duration: 42.70 ms
> = Memory Size: 128 MB  Max Memory Used: 61 MB
M(happy): The REPORT line shows the real time the run took, and the memory used.
> = Billed Duration: 43 ms
B: Yes. The measured time is 42.70 milliseconds, but Lambda bills 43, rounded up to the next whole millisecond.
M(think): So the bill uses the rounded number, not my exact one.
B: Exactly. The function had 128 megabytes, and only 61 were used.

== table | set=class
HEAD: Step | Value | Meaning
ROW: Runs a day | 48 | every 30 min
ROW: Runs a month | 1440 | 48 times 30
ROW: Seconds | 2880 | 1440 times 2
ROW: GB-seconds | 720 | times 0.25 GB
B: Now the cost sums. We fetch 48 times a day for 30 days, so that is 1,440 runs.
> rows 2
M(happy): Each run takes about two seconds, so that is 2,880 seconds in total.
> rows 3
B: The memory is 256 megabytes, which is a quarter of a gigabyte.
M(think): So the total is 720 GB-seconds a month. That is small.
> rows 4
B: Now the same sum in Python.

== code | set=lab
| invocations = 48 * 30
| gb_seconds = invocations * 2 * (256 / 1024)
| print(gb_seconds)
B: Line one gives the number of invocations, which are the runs.
> line 1
> var invocations=1440
M: Line two multiplies by two seconds, then by the memory in gigabytes.
> line 2
B: That gives the GB-seconds. Line three prints it.
> line 3
> out 720.0
M(happy): Seven hundred and twenty point zero. Exactly my hand sum.

== chain | set=lab
B: Last, clean up. Anything left running keeps billing, so teardown deletes things in a fixed order.
> 📅 : Delete schedule
B: The schedule goes first, so nothing fires at a function that is about to vanish.
M(think): Then the function, and last the role?
> ⚡ : Delete function
B: Yes. Each thing is removed before the thing it depends on.
> 🔐 : Delete role

== versus | set=sky
LEFT: 🔍 : Dry run
RIGHT: 🧨 : Apply run
B: The teardown script has two modes. The dry run only prints what it would do.
> L : Prints DRY lines, deletes nothing
M(happy): So I always run it dry first, to read the list.
B: Exactly. The apply option deletes for real.
> R : Deletes tagged resources for real
B: Read every line first. Each should name something tagged with your own owner name.
> L : Read every line before you go on
M(shock): And if I see something I do not recognise?
B: Stop and ask. Never apply a delete you do not understand.
> R : Stop and ask about anything unknown

== quiz | set=room
Q: 48 runs a day, 30 days, 2 seconds each, 256 MB: GB-seconds a month?
- 72
- 7,200
- 737,280
* 720
M(think): Let me work it out. 48 times 30 is 1,440 runs, and each one lasts two seconds.
M(think): Next I turn megabytes into gigabytes, so I divide by 1,024.
B(cheer): Right, 720. Forgetting that division gives the big wrong answer, 737,280.

== recap | set=class
B: Let us lock in what we learned.
> Lambda runs code only when triggered
M: Next, the three numbers that drive the bill.
> GB-seconds: runs x seconds x GB
B: The REPORT line shows the billed time for each run.
> Read REPORT for billed duration
M: And never paste keys into code.
> Use an execution role, no keys
B(cheer): Dry run first, then apply. Great work today, Mira!
> Dry run first, then apply
