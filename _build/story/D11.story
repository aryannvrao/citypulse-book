TITLE: Data pipelines and quality checks
HOOK: Stop bad data before it reaches the dashboard

== title | set=city
B(happy): Welcome to CityPulse! I am Bolt, and this is Mira, our newest engineer.
M(cheer): Hi! Today we fix a real problem. A broken sensor sent a negative pollution number straight to our dashboard.

== talk | set=room
M(sad): Bolt, a sensor reported the PM2.5 level as minus three. Nobody noticed until the dashboard showed it.
> 💥 : Negative reading
B(think): A pollution level cannot be below zero. So that number was bad data, and it should never have been published.
> ⛔ : Bad data
B(happy): Our answer is a data pipeline. A pipeline is a set of steps that run one after another, and each step uses the output of the step before.
> 🔗 : Pipeline
M(think): So data goes in one end and comes out clean, like a factory line?
B: Exactly. Between the steps we place data-quality checks. A check is a test on the data, such as no reading is negative.
> 🛑 : Quality check

== chain | set=lab
B: Our pipeline has three steps. Extract reads the raw file that the sensor sent us.
> 📄 : Extract
B: Validate tests every reading against the rules. This is the step that can stop the run.
> 🧪 : Validate
B: Load writes the good rows into a database table. A database is a file that stores tables of rows.
> 💾 : Load
M(think): Extract, validate, load. Each step waits for the one before it.

== same | set=city
LEFT: 🏭 : Factory stop cord
RIGHT: 🧪 : Blocking check
M(think): What does a blocking check mean in plain words?
B: Think of an assembly line with a stop cord. Any worker can pull it and halt the line before a faulty part moves on.
M(happy): So a blocking check is the stop cord. If it fails, the run halts before bad readings reach the database.
B: Yes. A check that is not blocking only prints a warning, and the line keeps moving.

== code | set=lab
| readings = [38.7, -3.0, 21.0]
| failures = []
| for value in readings:
|     if value < 0:
|         failures.append(value)
| print("failed:", len(failures))
| exit_code = 1 if failures else 0
B: Let us trace this code. Line one stores three readings. Line two starts an empty list for the failures.
> line 1
> var readings=[38.7, -3.0, 21.0]
> line 2
> var failures=[]
M(think): The loop checks each value. Minus three is below zero, so it goes into the list.
> line 3
> line 4
> line 5
> var failures=[-3.0]
B(cheer): Line six prints one failure. Line seven sets the exit code to one, because the list is not empty.
> line 6
> out failed: 1
> line 7
> var exit_code=1

== term | set=room
B: Here is a real run of the checks. Each check prints one line.
> $ python -m citypulse.dq_checks
> = PASS negative_pm25
> = FAIL rows_last_24h
> = PASS hours_since_newest
M(shock): One failure! The rows check wants at least forty readings in the last day.
> = DQ: 2 passed, 1 failed, 0 warnings
B: The exit code tells the shell that the step failed. Ask for it and you see one.
> $ echo $?
> = 1
M(think): So the number is what the pipeline reads, not the words on the screen.

== table | set=lab
HEAD: station | pm25 | reason
ROW: S2 | -3.0 | negative
ROW: S4 | 14.5 | duplicate
ROW: S5 | 9.9 | missing time
B: Rejected rows do not vanish. They go to a quarantine table, with the reason next to each row.
> rows 1,2,3
M(think): Quarantine, like a sealed box. So if a sensor is broken, we can find its rows later.
> col 3
B(happy): Right. A quarantine keeps the evidence. We set rows aside for checking, and we never throw them away.
> keep 1
> reset

== bars | set=city
BAR: negative : 5
BAR: missing : 2
BAR: duplicate : 1
B: Count the rejects by reason. Then you see which rule breaks most often.
> hi 1
M(happy): Five negative readings in one week. So the sensor near the factory needs a look.
B: Exactly. Counts by reason show you where the problems really are.
> hi 1

== trap | set=room
WRONG: print FAIL, then return nothing
RIGHT: return 1 from main, then sys.exit(main())
M(shock): Wait, the checks printed FAIL, but the script still passed?
B: Yes. A function that returns nothing gives back None. The process then exits with zero, and bad data sails through.
M(think): So returning the number matters more than printing the word.
B(cheer): Exactly. Return one from main, and pass it to sys.exit. Print for people, return a number for the machine.

== versus | set=city
LEFT: 🛑 : Blocking check
RIGHT: 🟡 : Warning
B: Blocking checks stop the run. Use them for data we must never publish, such as negative pollution readings.
> L : Stops the run
> L : Never publish bad data
M(think): And a warning?
> R : Reported, run goes on
B: A warning suits something unusual, like an average that shifts a little. Stopping for it would delay good data.
> R : Run continues
> R : Good for unusual data

== quiz | set=class
Q: Which signal tells the pipeline that a blocking check failed?
- Zero, which means success
* A non zero exit code, such as one
- The word FAIL printed on screen
- A message that says warning
M(think): Zero means success, so that is out. Printed words do not reach the shell.
B(cheer): Correct! Print for people, and return a number for the machine.

== recap | set=city
B: Let us lock in what we learned.
> A pipeline runs steps in order
M: Checks sit between the steps. A blocking check stops bad data.
> Blocking checks stop bad data
B: Count rejects by reason, and keep rejects in quarantine.
> Quarantine keeps rejected rows
M: Fail with a number, not just a printed word.
> Return one on failure
B(cheer): Great work today, Mira! Your data is safer now.
> Reruns must give the same table
