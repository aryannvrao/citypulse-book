TITLE: Bash scripts and cron alarms
HOOK: Make your script run itself, and fail loudly

== title | set=city
B(happy): Welcome to CityPulse! I am Bolt, and this is Mira, our newest engineer.
M(cheer): Hi! Today we teach a script to run itself every half hour, even while we sleep.
B: Our air quality fetch must run all night, so we need a script and a clock.

== talk | set=room
M(sad): Bolt, last night our fetch died halfway. Nobody noticed until breakfast, and the data had gaps.
> 💥 : Silent failure
B(think): That is the worst kind of failure. The script kept going and added empty rows.
> 📸 : Empty rows
B: Bash is the shell, the program that reads and runs your commands. With strict mode, a Bash script stops at the first real failure.
M(think): And who starts it every half hour?
B(happy): Cron, our alarm clock. It is a background program that starts commands at the times you choose.
> ⏰ : cron alarm

== chain | set=lab
B: A script is a recipe card. It is a text file of steps that run from top to bottom.
> 📜 : Script file
B: The first line is the shebang. It names the program that should run the file.
> 🔧 : Shebang line
B: Next comes strict mode, three settings that stop the script when something goes wrong.
> 🛑 : Strict mode
B: Then your steps follow, one after another, in the order you wrote them.
> 🧩 : Your steps
M(think): So the card is read in order, and it halts at the first mistake.

== code | set=lab
| def is_due(minute, step):
|     return minute % step == 0
| result = is_due(30, 30)
| print(result)
B: The function takes a minute and a step, and checks the remainder.
> line 1
> line 2
M(think): Remainder means what is left over after dividing. Thirty divided by thirty leaves nothing.
> line 3
> var minute=30
> var step=30
B(happy): Zero left over means the minute is due, so the job fires at minute thirty.
> line 4
> var result=True
> out True

== term | set=room
B: Let us test the strict script with a broken address, on purpose.
> $ bash scripts/fetch.sh https://api.city/v1/nope
M(think): Two warnings, then an error. That is exactly what I want to see.
> = WARN attempt 1 failed, retry in 5 seconds
> = WARN attempt 2 failed, retry in 10 seconds
> = ERROR gave up after 3 attempts
B(happy): The exit code is the number a program reports when it ends. Zero means success, so one means failure.
> $ echo $?
> = 1

== bars | unit=s
BAR: First wait : 5
BAR: Second wait : 10
B: The waits grow each time, and this is called backoff. A busy server gets time to recover.
> hi 1
M(think): So five seconds, then ten. Why not retry straight away?
> hi 2
B: Because an instant retry hits the same busy server again, and fails again.

== same | set=room
LEFT: ⏰ : Morning alarm clock
RIGHT: 🤖 : cron schedule
M: My alarm wakes me at seven, every morning, even on lazy days.
B: cron works the same way. It wakes up every minute and starts any job whose time has come.
M(happy): So the clock never sleeps, and the script never forgets its steps!

== journey | set=sky
NODE: cr : ⏰ : cron
NODE: sc : 📜 : Script
NODE: api : ☁️ : City API
NODE: lg : 📄 : Log file
B: cron is the trigger. It starts the job with a bare setting, and no terminal attached.
> hi cr
> cr>sc : starts job
M: Then the script uses curl, a tool that sends web requests, to ask for readings.
> sc>api : asks for readings
> api>sc : JSON reply
B(think): JSON is a text format for structured data. The reply arrives as a neat list of readings.
B: Last, the script appends one timestamped line to the log, so we can check the run later.
> sc>lg : one line added
M(think): So when something breaks, the log tells me where to look first.

== trap | set=lab
WRONG: ((attempt++)) under set -e
RIGHT: attempt=$((attempt + 1))
M(shock): I counted retries with double brackets, and the script died on the very first failure!
B: A classic trap. That double bracket reports failure when the old value was zero, and strict mode stops at once.
B: Write a plain assignment instead, as the course example does. It always succeeds.

== quiz | set=class
Q: A blank line sits above the shebang. What happens when you run the file directly?
- Blank lines are ignored, so Bash runs.
* The shebang must be on the first line.
- A shebang is just a comment.
- Bash is always picked anyway.
M(think): A blank line is harmless, surely? Let me think about where the system looks.
B(cheer): Right! The system reads the shebang only on the very first line.

== table | set=lab
HEAD: field | range | example
ROW: minute | 0 to 59 | */30
ROW: hour | 0 to 23 | 9-17
ROW: weekday | 0 to 6 | 1-5
B: A crontab line has five time fields, then the command to run. Here are the three that matter most.
> col 2
M(think): Minute, hour and weekday. Minute goes from zero to fifty nine.
> rows 1
B: Hour runs from zero to twenty three. Weekday uses zero for Sunday, through six for Saturday.
> rows 2,3
M(think): So hours nine to seventeen, on Monday to Friday only, means working hours.
> reset

== recap | set=city
B(cheer): Let us lock in what we learned today.
> A script is a recipe card of steps
M: Strict mode stops at the first real failure.
> set -euo pipefail stops on failure
B: cron is the alarm clock, and its lines use full paths.
> cron runs your job on a schedule
M(think): Always send output to a log file, and check the exit code.
> Log every run, and check the exit code
B(cheer): Great work today, Mira!
> Test with a short schedule, then restore it
