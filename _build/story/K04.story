TITLE: Tickets T11 and T12: fetch and clean
HOOK: Passing a ticket means passing its test cases

== title | set=city
B(happy): Welcome to CityPulse! I am Bolt, and this is Mira, our newest engineer.
M(cheer): Hi! Today my squad starts two capstone tickets, eleven and twelve. Are we ready?
B: Ready, if you know what each ticket asks and how the trainer checks it.

== talk | set=room
M(think): How does a ticket become Done on our board? Do I just drag it there?
> 📸 : Ticket board
B: Tickets move from Backlog to To Do, In Progress, Review, and finally Done.
> word : ONLY TRAINERS MOVE DONE
M(shock): Wait, I cannot move my own ticket to Done?
B: Correct. A trainer runs the test cases, reads your commits, the saved snapshots carrying your name, and scores the ticket from zero to three.
> clear

== term | set=lab
B: Ticket eleven moves the fetcher, the program that downloads readings, from an old bash script, a list of shell commands, into Python.
> $ python -m citypulse.fetch; echo $?
> = INFO citypulse.fetch: wrote 24 rows to your output file
> = 0
M(think): The last number is the exit code. Zero means success, and any other number means failure.
B: The trainer also compares the bash and Python rows. Sorting puts both in order, so row order does not matter.
> $ diff <(sort bash_utc.csv) <(sort py.csv)
> = nothing printed, so the rows match
M(happy): So an empty answer is the good answer!

== code | set=room
| from datetime import datetime, timedelta, timezone
| IST = timezone(timedelta(hours=5, minutes=30))
| local = "2026-12-01T18:30:00"
| moment = datetime.fromisoformat(local)
| moment = moment.replace(tzinfo=IST)
| utc = moment.astimezone(timezone.utc)
| text = utc.strftime("%Y-%m-%dT%H:%M:%SZ")
B: Every timestamp must be UTC, the shared world clock. India is five and a half hours ahead, so we name that offset first.
> line 1
> line 2
M(think): Why not just add a Z to the end of the text?
B: The Z is only a label. We must convert the time first, then write the Z.
> line 3
> var local=2026-12-01T18:30:00
> line 4
> var moment=18:30 naive
M(confused): So line four has the time but no zone yet?
> line 5
> var moment=18:30 IST
B: Right. Now it knows it is India time. Next, astimezone shifts it to UTC.
> line 6
> var utc=13:00 UTC
M(happy): So six thirty in the evening in India is one in the afternoon, UTC!
> line 7
> out 2026-12-01T13:00:00Z

== same | set=city
LEFT: 🕕 : Six pm, no city
RIGHT: 🌍 : One world clock
M: If I say meet at six, which six? Pune or London? Nobody knows.
B: A time with no zone is naive, like that. Python calls it naive because nothing is attached to it.
M(think): And an aware time knows its city?
B(happy): Yes. An aware time carries its zone, so converting it to UTC is safe. Only then is the Z label true.

== versus | set=lab
LEFT: 🧾 : Plain print
RIGHT: 📋 : Logging with levels
B: Ticket eleven bans print in the source folder. Print only writes text to the screen.
> L : No level, no time
> L : Gone once the screen clears
M(confused): My print message shows fine, though. Why is it banned?
> R : Levels from DEBUG to ERROR
> R : Adds a time and module name
B: A module is one Python file. Logging writes messages with a level, a time and a name, so a failed run leaves an ERROR line you can search for later.
M(cheer): So the trainer can find the failure in the log!

== table | set=lab
HEAD: ts_utc | location | pm2_5 | src_file
ROW: 06:00Z | Koramangala | 41 | run_1
ROW: 07:00Z | Koramangala | 44 | run_1
ROW: 07:00Z | Koramangala | 45 | run_2
ROW: 07:00Z | Whitefield | 38 | run_1
B: Ticket twelve builds one command. It reads every raw file, cleans them, and writes one Parquet file, a compact format that keeps each column's type.
M(think): Duplicates are repeat readings. Rows two and three share the same time and place.
> rows 2,3
B: The key is time plus location. The rule keeps the copy from the newest run, the last one after sorting by source file name.
> col 4
> keep 1,3,4
M(happy): And every dropped row gets counted, so the trainer can check that zero duplicates remain.

== chain | set=server
B: The clean step runs its rules in one fixed order. Each rule counts what it removes.
> 🔤 : Fix types
> ⏰ : Drop no time
> 🔁 : Drop copies
M(think): Wait, why does the order matter?
> 🚧 : Quarantine bad
> 🧹 : Null rules
> 📚 : Write Parquet
B: A row with no time cannot be placed, so that rule goes first, right after the types are fixed. Otherwise two rules could count one problem twice.
M(happy): And quarantine means impossible values go into a separate file, so nothing vanishes silently.

== trap | set=room
WRONG: def main(): logs the ERROR, returns nothing
RIGHT: return 1 on error, then raise SystemExit(main())
M(shock): But my fetcher logs the ERROR, so the run failed properly, right?
B: Not for the shell. Returning nothing gives exit code zero, so the trainer's 404 test fails. A 404 is the server saying not found.
B: Have the main function return one on error, and pass that result to the exit call. The number must say failure.

== quiz | set=lab
Q: The awk timestamp check prints 3. What does that tell you?
- The rows are sorted alphabetically
* Three timestamps are not UTC ISO text
- Three rows were deleted from the file
- The file has three columns
M(think): Awk scans the file line by line and prints only the rows that fail the timestamp pattern. Which rows could those be?
B(cheer): Correct! Those three timestamps are not in the standard UTC text form, so convert them and run the check again.

== recap | set=city
B: Let us lock in the checks for both tickets.
> The trainer runs tests and reads commits
M: Convert to UTC first, then write the Z.
> Convert to UTC first, then write the Z
B: Use logging with levels, never a bare print.
> Logging with levels, never bare print
M: A failure must give exit code one, never zero.
> Failures exit with one, never zero
B(cheer): Count every dropped row, and rebuild the output on each run. Good luck, squad!
> Count every drop, rebuild, never append
