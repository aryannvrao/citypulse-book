TITLE: Capstone tickets T13 to T16
HOOK: Four tickets, twenty nine points, and tests that decide

== title | set=city
B(happy): Welcome to CityPulse! I am Bolt, and this is Mira, our newest engineer.
M(cheer): Hi everyone! Our squad starts the last four capstone tickets today, worth twenty nine points.
B: Each ticket has a trainer running real test commands. Let us learn what they check.

== term | set=room
M(think): Ticket thirteen builds a loader, the program that copies cleaned readings into a database. What if it runs twice?
B: It must be idempotent: a second run leaves the same result as the first. The trainer clears the old file first.
> $ rm -f /tmp/t.db
> $ SQLITE_PATH=/tmp/t.db python -m citypulse.load
M(think): Then the trainer counts the fact table, which holds the measurements.
> $ sqlite3 /tmp/t.db 'SELECT COUNT(*) FROM fact_air_quality'
> = 1392
B(happy): Run it again. Both counts must match, and be above zero.
> $ SQLITE_PATH=/tmp/t.db python -m citypulse.load
> $ sqlite3 /tmp/t.db 'SELECT COUNT(*) FROM fact_air_quality'
> = 1392

== graph | set=server
NODE: loc : location : 0,0
NODE: src : source : 0,2
NODE: fact : readings : 2,1
EDGE: fact>loc
EDGE: fact>src
M(confused): What is a schema, and how do the tables link?
B: The schema is the written plan of tables. The fact table holds readings, each linked to a place and a source.
> hi fact
> note fact table: the readings
B: That link is a foreign key: its value must match a row in another table. Every table needs a primary key, a unique row identifier.
> hi loc,src
> done fact
M(think): So the place rows must exist before a reading can point at one?
B(cheer): Exactly, Mira. Parents load first, then children.
> note parents first, then children

== table | set=city
HEAD: UTC time | India day
ROW: Dec 5 20:00 | Dec 6
ROW: Dec 5 08:00 | Dec 5
ROW: Dec 4 23:00 | Dec 5
M(think): Ticket fourteen answers client questions with views. What exactly is a view?
B: A view is a named query stored in the database. Readings are stored in UTC, the world clock standard.
> rows 1
M(shock): The first reading is December 5th in UTC, but India says December 6th?
B: India is five and a half hours ahead. Adding three hundred thirty minutes moves that reading to the next day.
> col 2
> rows 1,3
B: Every view that groups by hour or day must add those minutes, and say so in a comment.
> reset

== term | set=lab
M(think): How does the trainer check the views? By building a fresh database from nothing.
B: The views file runs in the database shell, statement by statement. A drop line removes any old copy first.
> $ sqlite3 /tmp/v.db < sql/views.sql
> = (no output)
M(happy): Then the trainer counts the views stored in the database. Eight means a pass.
> = 8
B: Each view must also return at least one row, and running the file again must print nothing.

== chain | set=lab
B: Ticket fifteen wires the whole pipeline into one script. Each step uses the output of the one before.
> 📥 : Fetch data
> 🧹 : Clean data
M(think): Then the load writes the database, and views read from it.
> 🗄️ : Load database
> 📊 : Build views
B(cheer): The last stage runs data quality checks, small tests on the data. The trainer breaks the data on purpose and expects a failure.
> ✅ : Quality checks

== code | set=lab
| res = [("ids",True,True),("range",True,False)]
| failed = sum(1 for _,b,ok in res if b and not ok)
| warned = sum(1 for _,b,ok in res if not b and not ok)
| passed = len(res) - failed - warned
| print(f"DQ: {passed} passed, {failed} failed,",
|       f"{warned} warnings")
| raise SystemExit(1 if failed else 0)
M(think): Each check is a tuple, a fixed group of items in round brackets: name, blocking flag, passed flag.
> line 1
B: The first sum counts blocking checks that did not pass. Here that is one.
> line 2
> var failed=1
M(think): And a check that is not blocking only gives a warning, so it does not stop anything?
> line 3
> var warned=0
B: Right. Passed is the total minus failures and warnings, so passed is one. The print gives the summary line.
> line 4
> var passed=1
> line 5
> out DQ: 1 passed, 1 failed, 0 warnings
B(cheer): The last line exits with one. An exit code is the number a program hands back to the shell, and one means stop the pipeline.
> line 7

== journey | set=sky
NODE: pc : 💻 : Your laptop
NODE: sts : ☁️ : AWS STS
NODE: iam : 🔑 : IAM user
B: Ticket sixteen is the defence, plus a secure cloud account. The trainer runs aws sts get-caller-identity, which asks AWS who you are.
> hi pc
> pc>sts : who am I?
B: STS, the Security Token Service, finds the access key on your laptop. An access key is a pair of codes for the command line tool.
> sts>iam : look up key
M(think): So the answer is an ARN, a unique address for that identity. It must end with my admin user name, never root.
> iam>pc : user ARN
M(shock): Root is the all powerful login, so daily work must never use it.
> hi iam

== same
LEFT: 📋 : Name on a list
RIGHT: 🗂️ : Upsert rows
M: If I write my name on the class list twice, I still appear only once.
B: That is an idempotent load: running it twice gives the same result. An upsert inserts a new row, or updates an existing one.
M(happy): So the second run replaces the same rows, and nothing doubles.
B: Right. The key decides whether a row is new or already there.

== trap | set=room
WRONG: print FAIL, then no return
RIGHT: return 1, then exit with that number
M(shock): My check printed FAIL, so why did the pipeline still pass?
B: Because the function returned nothing. Python then exits with zero, and the shell reads zero as success.
B(cheer): Return one on a blocking failure, and pass that number to the exit. Then the stop is real.

== quiz | set=class
Q: The loader runs twice and the fact table doubles. Which fix works?
- Add an index on the pm2_5 column
- Remove the foreign key check
* Add UNIQUE key, upsert on same columns
- Use plain INSERT with no key
M(think): The table doubles, so each repeat looks like a brand new row. It needs a way to recognise the same reading.
B(think): A UNIQUE key says which columns make a row one of a kind, such as place, source and time.
B(cheer): Correct, Mira! With that key, the upsert finds the old row and updates it, so nothing doubles.

== recap | set=city
B: Let us lock in what we learned today.
> Same run twice, same count
M: Parents load before children, and foreign keys point back to them.
> Foreign keys point to parents
M: Views are named queries that answer one client question each.
> Views answer client questions
B: A pipeline stops when a blocking check fails, and the exit code says so.
> Blocking failure stops the run
B(cheer): Return a number, never silence. Great work today, Mira!
> Return a number, never silence
