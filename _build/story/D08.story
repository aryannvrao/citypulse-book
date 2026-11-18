TITLE: Pandas cleaning and Parquet files
HOOK: Clean messy sensor data, then store it safely

== title | set=city
B(happy): Welcome to CityPulse! I am Bolt, and this is Mira, our newest engineer.
M(cheer): Hi! Today our air sensors sent messy readings, and I must tidy them before anyone charts them.

== talk | set=room
M(sad): Bolt, my chart says pollution jumped at midnight. I think the data is lying to me.
> 📊 : Strange spike
B(think): Let us check. When the network drops, a sensor sends the same reading twice.
> 💥 : Repeated readings
B: Sometimes it sends a reading with no value at all. Pandas, a Python library for tables, shows that blank as NaN.
> ❓ : Not a number
M(confused): So a blank is not the same as zero?
B: Right. Zero is a real value. A blank means we simply do not know.

== chain | set=lab
B: Our cleaning runs in four stops. Each stop hands its table to the next one.
> 📄 : Raw CSV file
M: CSV is a plain text table, with commas between the columns. It keeps no types.
> 🐼 : Pandas table
B: Pandas loads the table into working memory and applies the cleaning rules.
> 🧹 : Cleaned table
B: The clean table goes into Parquet, a compact file format that keeps the types.
> 🗄️ : Parquet file
M(think): Four stops, and each one has one job. I like that.

== code | set=room
| KEY = ["station_id", "ts", "pollutant"]
| raw = len(df)
| df = df.drop_duplicates(subset=KEY, keep="first")
| after_dedup = len(df)
| df = df.dropna(subset=["value"])
| print("duplicates removed:", raw - after_dedup)
| print("blanks removed:", after_dedup - len(df))
B: Here is the counting code. First, we store the starting row count in a variable called raw.
> line 2
> var raw=12
M: Next we drop repeated keys. A key is the set of columns that names one reading.
> line 3
B: The count after that step is ten, so two rows were repeats. We save that number.
> line 4
> var after_dedup=10
M: Then the blanks go. Do I count them the same way?
> line 5
B: Yes. Every rule is counted in code, so the report always matches what really happened.
> line 6
> out duplicates removed: 2
> line 7
> out blanks removed: 2

== same | set=room
LEFT: 🏥 : Triage desk log
RIGHT: 🧹 : Counted cleaning rules
M: At a hospital triage desk, staff sort patients by urgency, and every arrival gets logged.
B: Our cleaning works the same way. Each rule has a name, runs in a fixed order, and its removals are counted.
M(happy): So no reading disappears without a record, just like no patient vanishes from the desk!

== table | set=lab
HEAD: station | ts | value
ROW: ST-02 | 07:00 | 36.4
ROW: ST-02 | 08:00 | 38.1
ROW: ST-02 | 08:00 | 38.1
ROW: ST-03 | 19:00 | NaN
ROW: ST-06 | 04:00 | NaN
M(think): Look at row three. It repeats row two exactly, so the sensor sent it twice.
> rows 2,3
B: Rows four and five have no value at all. Those are the blanks.
> rows 4,5
M: So I keep one copy of the repeat, and I drop the blanks.
> keep 1,2
B: Rows one and two are clean. Only data we can trust stays in the table.

== trap | set=lab
WRONG: drop_duplicates with keep first, unsorted rows
RIGHT: sort by fetch order, then keep the last copy
M(shock): I dropped duplicates straight away. Which copy did it keep?
B: Whichever copy came first in the rows, which may be an old reading sent late.
B(cheer): The fix is to sort by fetch order first, then keep the last copy, so the newest reading wins.

== versus | set=sky
LEFT: 📄 : CSV text file
RIGHT: 🗄️ : Parquet file
M: Why not keep everything as CSV? Anyone can open it in Notepad.
> L : Anyone can open it in Notepad
B: True, but CSV forgets the types. A date comes back as plain text, and a number may too.
> L : No types, no schema
B: Parquet keeps a schema, which is the written list of column names and types, inside the file.
> R : Keeps types and schema
M(think): And it is smaller, right?
> R : Stores each column separately
B: Yes. Repeated values compress well. You can also read one column alone.
> R : Read one column alone

== bars | set=lab | unit=K
BAR: CSV file : 52
BAR: Parquet : 12
B: Same 1,392 rows, saved in two formats. Here is the disk space each file takes.
> hi 1
M(cheer): The CSV is about four times bigger. That is a lot of waste for the same data.
> hi 2
B: K means kilobytes. Your numbers will differ, but Parquet is usually much smaller.

== array | set=server
CELLS: 21 -4 38 99 12
B: Next, impossible values. A temperature of minus four degrees cannot happen in our city.
> hi 1
M: And ninety nine? That is probably a glitch. Should I delete the whole row?
> hi 3
B: No. Save the bad rows to a quarantine file first, which holds the rejected rows. Then set only the bad cells aside.
> set 1=NaN
> set 3=NaN
> done 0,2,4
> note bad values become NaN

== talk | set=class
M(think): Bolt, one last question. Why is the cleaned Parquet data split into folders?
> 📁 : Folder per station
B: That is partitioning. Pandas makes one folder for each value, such as each station, and stores its rows inside.
B: A query for one station then skips every other folder. But choose a column with few values, or you get too many tiny files.

== quiz | set=class
Q: Which call reads only two columns from a Parquet file?
- read_parquet(path) then select columns
* read_parquet(path, columns=[...])
- read_csv(path, columns=[...])
- read_parquet(path, index=False)
M(think): Selecting after loading would load every column first. So the answer must skip the others on disk.
B(cheer): Correct! The columns argument tells the reader which columns to load.

== recap | set=city
B: Let us lock in what we learned today.
> Blanks are NaN, not zero
M: Each rule runs in a fixed order, and its removals are counted.
> Count every rule, in order
B: Sort by fetch order first, then keep the last copy.
> Keep the newest copy
M: Parquet keeps types and can load one column at a time.
> Parquet keeps types
B(cheer): And quarantine the rejected rows before you drop them. Great work today, Mira!
> Quarantine rejected rows first
