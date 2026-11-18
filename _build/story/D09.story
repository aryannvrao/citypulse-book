TITLE: Relational modelling and SQL loading
HOOK: Store each fact once, then load without doubling

== title | set=city
B(happy): Welcome to CityPulse! I am Bolt, and this is Mira, who loads sensor data into a real database.
M(cheer): Today we store our readings in linked tables, load them in one go, and check that a second load changes nothing.

== talk | set=room
M(sad): Bolt, our readings sheet repeats the station name on every row. Last week I renamed one station.
> 📋 : One big sheet
B(think): Then you had to edit thousands of rows, and some would still show the old name. That is the problem tables solve.
> 🗃️ : Linked tables
M: So where does each fact live?
B: Each real fact gets one place. A station is stored once, and every reading points back to its station by its id.

== same | set=room
LEFT: 📚 : Library catalogue
RIGHT: 🗃️ : Linked database tables
M: In a library, the catalogue lists each book once, with its shelf location.
B: A loan slip carries only the catalogue number, not a copy of the title. If the shelf moves, only the catalogue changes.
M(happy): So a database table is like one catalogue entry, and a reading is like a loan slip!

== graph | set=lab
NODE: loc : Station : 0,1
NODE: fact : Reading : 2,1
NODE: src : Source : 4,1
EDGE: fact>loc
EDGE: fact>src
B: Our design has one fact table in the middle, holding the measurements. The arrows are foreign keys.
> hi fact
M(think): So a foreign key is an arrow that must point at a real row?
> hi loc,src
B: Exactly. A foreign key is a column whose value must match a row in another table, and the grain says what one row means.
> note grain: one row per place, source, hour
> done fact

== code | set=room
import sqlite3
con = sqlite3.connect("citypulse.db")
con.execute("PRAGMA foreign_keys = ON")
ts = "2026-03-01T00:00:00Z"
row = ("CP-999", ts, "pm25", 44.0)
sql = "INSERT INTO reading VALUES (?, ?, ?, ?)"
try:
    con.execute(sql, row)
except sqlite3.IntegrityError as e:
    print("rejected:", e)
M(think): First I turn the check on. Then I try a reading for a station that does not exist.
> line 3
> line 7
B: The insert is refused, so the error is caught and printed. Nothing is stored.
> line 9
> out rejected: FOREIGN KEY constraint failed

== trap | set=lab
WRONG: set foreign keys on once, in one script
RIGHT: run the PRAGMA on every new connection
M(shock): I wrote the foreign key, so the database must refuse orphans, right?
B: Not in SQLite. Foreign key checks are off by default. A PRAGMA, which is a setting command, must switch them on.
B(cheer): So run that line every time you open a connection. Then the rule holds everywhere.

== journey | set=sky
NODE: pc : 💻 : Your laptop
NODE: pg : 🐘 : Postgres server
NODE: csv : 📄 : Readings file
B: Postgres is a database server. Your laptop connects to it over a network.
> hi pg
M: So the bulk load sends the file to the server in one stream?
> csv>pg : rows stream
B: Right. The server checks every row against the keys, then stores it. It reports how many rows it stored.
> pg>pc : COPY 1392
M(happy): One stream, all 1392 readings, and the server does the checking!

== bars | set=lab
BAR: First load : 1392
BAR: Second load : 1392
BAR: Plain twice : 2784
B: Count the rows after each run. An upsert keeps the count steady, while a plain insert doubles it.
> hi 1
> hi 2
M(think): So the second upsert run gives 1392 again, but a plain insert run twice gives 2784?
> hi 3
B: Exactly. Same file, same rows, and no doubled data.

== table | set=room
HEAD: row | station | value
ROW: 1 | CP-001 | 51.3
ROW: 2 | CP-002 | 47.0
ROW: 3 | CP-999 | 44.0
ROW: 4 | CP-001 | 49.2
M(think): The station list has only CP-001 and CP-002. So which readings are orphans?
> rows 3
B: Row three points at CP-999, which is not in the station list. That is an orphan reading.
> keep 1,2,4
B: Rows one, two and four all have real stations. A foreign key stops the orphan from being stored at all.

== code | set=room
import sqlite3
con = sqlite3.connect("citypulse.db")
SQL = """INSERT INTO reading VALUES (?, ?, ?, ?)
ON CONFLICT (station_id, ts, pollutant)
DO UPDATE SET value = excluded.value"""
ts = "2026-03-01T00:00:00Z"
batch = [("CP-001", ts, "pm25", 51.3)]
with con:
    con.executemany(SQL, batch)
cur = con.execute("SELECT COUNT(*) FROM reading")
print(cur.fetchone()[0])
B: Here is the upsert. It inserts each reading, or updates it if its key already exists.
> line 3
> line 4
M: So if I run it again with the same reading, a second row should not appear.
> line 8
B: Right. The reading's key already exists, so the value is updated and the count stays the same.
> line 11
> out 1392

== talk | set=class
M(think): Bolt, why not delete all the rows and insert them again each time?
> 🔁 : Run it twice
B: If the program crashes halfway, the table is left empty or half full. That is the risk.
B: A transaction groups all the changes. It commits when every row is in, or it rolls back and leaves the table as it was.
> 🛡️ : All or nothing

== quiz | set=class
Q: Which design leaves the same rows after two runs, and keeps the corrected value?
- A plain INSERT with no unique key
- INSERT OR IGNORE, which keeps the old value
- DELETE then INSERT with no transaction
* Upsert on the key, inside one transaction
M(think): A plain insert doubles the rows. Ignore keeps the old value, so the fix is lost. Delete then insert can crash and leave an empty table.
B(cheer): Correct! The upsert updates an existing row, and one transaction keeps the whole load safe.

== recap | set=city
B: Let us lock in what we learned today.
> Each fact lives in one place
M: A key says which columns identify a row, and a foreign key blocks orphans.
> Keys identify, foreign keys protect
B: In SQLite, turn foreign keys on for every connection.
> Foreign key switch on each time
M: An upsert makes a rerun safe, because it updates rather than doubles.
> Upserts make reruns repeatable
B(cheer): And wrap each load in one transaction. Great work today, Mira!
> One transaction per load
