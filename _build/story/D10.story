TITLE: Analytical SQL
HOOK: Ask the database smart questions and get clear answers

== title | set=city
B(happy): Welcome to CityPulse! I am Bolt, and this is Mira, our newest engineer.
M(cheer): Today the problem is turning thousands of air readings into answers that clients can use.

== talk | set=room
M(sad): Bolt, a client wants the worst hour for PM2.5 at each station. I have thousands of rows!
> 📸 : Big table
B(happy): Do not panic. SQL is the language for asking a database questions, and it returns a neat table of answers.
> word : SQL = A QUESTION
M(think): So I write the question, and the database does all the searching?
B: Exactly. You say what you want, and SQLite, a small database program, finds the rows for you.
> clear

== same | set=lab
LEFT: 📋 : Records clerk
RIGHT: 🔎 : SQL question
M(think): A records clerk knows where every file is. You ask, and the clerk brings back the papers.
B(happy): A SQL question works the same way. You describe the rows you want, and the database fetches them.
M: So I describe the answer, and I do not write the steps to find it.

== chain | set=server
B(think): Every query is made of parts called clauses, such as FROM, JOIN and GROUP BY. Each one adds a step.
> 📥 : Read readings
M: First I read the readings table, then I join each reading to its station name.
> 🔗 : Join names
B: Next, WHERE drops the empty ones. An empty reading is NULL, which means no value was recorded.
> 🚫 : Skip empty rows
M(cheer): Then I group by station and average. Sorting highest first and keeping five is the last step.
> 📊 : Group by station
> 🏆 : Top five

== code | set=lab
| WITH hourly AS (
|   SELECT l.name AS location, f.pm2_5
|   FROM fact_air_quality AS f
|   JOIN dim_location AS l
|     ON l.location_id = f.location_id
|   WHERE f.pm2_5 IS NOT NULL
| )
| SELECT location, ROUND(AVG(pm2_5), 1) AS avg_pm25,
|        COUNT(*) AS n
| FROM hourly
| GROUP BY location
| ORDER BY avg_pm25 DESC;
B(happy): Here is a shortened worst hour query. Let us read it from the top, one line at a time.
> line 1
M(think): WITH names a temporary step called hourly. The rows inside it are built first.
> line 2
B(happy): The JOIN matches each reading to its station name, using the number key.
> line 4
> line 5
M(think): WHERE drops the empty readings before anything gets counted.
> line 6
B(cheer): GROUP BY makes one row per station, and the highest average comes first.
> line 11
> line 12
> out S1 50.2 from 5 readings

== table | set=room
HEAD: station | hour | pm25
ROW: S1 | 8 am | 42.1
ROW: S1 | 9 am | NULL
ROW: S2 | 8 am | 19.4
ROW: S2 | 9 am | 21.0
M(think): Now the empty readings. What happens to the row where the sensor reported nothing?
> rows 2
B(happy): WHERE removes that row before grouping, so the averages stay honest.
> keep 1,3,4
M(confused): Why can I not just write equal to NULL?
B: Because NULL never equals anything, not even NULL. Test with IS NOT NULL instead.
> reset

== trap | set=city
WRONG: COUNT(*) with LEFT JOIN, empty spot shows 1
RIGHT: COUNT(f.fact_id) counts only real matches
M(shock): Oh no, my empty location shows one reading! The count is wrong.
B: COUNT with a star counts the row itself, even when nothing matched. Count a column from the right-hand table instead.

== array | set=lab
CELLS: 40 44 52 60 55
M(think): How do I smooth a bumpy line of readings? I want one average for every three readings.
> ptr i=0 j=2
> hi 0,1,2
B(happy): A rolling window takes the current reading and the two before it, then averages them.
> note First window: 40 44 52
M(cheer): That gives 45.3. Then the window slides one step right, and I average again.
> ptr i=1 j=3
> hi 1,2,3
> done 0
B: Each slide drops the oldest value and adds the newest. The average moves smoothly along the whole line.
> note Slide: drop 40, add 60
> done 1

== versus | set=lab
LEFT: 🧮 : GROUP BY
RIGHT: 🔲 : Window function
M(think): GROUP BY squashes each station into one row. Is that what I want for a trend?
> L : One row per station
> L : Averages hide the timeline
B(happy): Right. A window function adds a value to each row, and keeps every reading.
> R : Every reading keeps its row
> R : PARTITION BY keeps stations apart
M: So for a trend, the window function is the one.

== term | set=room
B(think): Let us run a saved script from the terminal. It holds the rolling average query.
> $ sqlite3 -header -column citypulse.db < trends.sql
M(happy): Each row comes back with its own rolling average, called ma3. Look at the first one.
> = station_id ts value ma3
> = S1 08:00 40.0 40.0
B: That row has only itself to average, so its value is 40.0. A short window like this is normal.

== quiz | set=class
Q: PM2.5 readings 10, 20, 30, 40. Average of this row and the one before, on row four?
- 25.0
* 35.0
- 30.0
- 40.0
M(think): Row four is 40, and the row before it is 30. So the window holds just those two.
M(think): Forty plus thirty is seventy, and half of seventy is thirty five.
B(cheer): Correct! The frame is the current row plus one row before, so the answer is 35.0.

== recap | set=city
B(happy): Let us lock in what we learned today.
M: First, a JOIN links each reading to its location name.
> A JOIN links readings to location names
B: Next, WHERE drops empty readings before anything is grouped.
> WHERE drops empty readings first
M(think): Window functions keep every row, which is perfect for trends.
> Window functions keep every row
B(cheer): A window result needs an outer query before you can filter it. Great work, Mira!
> Filter window results in an outer query
