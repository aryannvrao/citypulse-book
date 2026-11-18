TITLE: Serverless ingest and daily brief
HOOK: Store readings in the cloud, then forecast tomorrow

== title | set=city
B(happy): Welcome to CityPulse! I am Bolt, and this is Mira, our newest engineer.
M(cheer): Hi! Today we build a pipeline that runs every night, without anyone touching it.

== talk | set=room
M(sad): Bolt, my dashboard showed old numbers this morning. The page looked stale.
> 📊 : Stale dashboard
B(think): Stale means old. Nothing fetched the fresh readings, so the page kept an old copy.
> 📁 : Old copy
M: So who fetches the new readings every night?
B(happy): A scheduled job does. It reads the raw file, cleans it, and saves it in the cloud.
> ⏰ : Nightly job
B: The cloud storage that holds our files is called S3. Think of it as an online filing cabinet.
> 📦 : S3 lake

== chain | set=lab
B: The nightly path has four steps. Each step hands its result to the next one.
> 📄 : Raw CSV file
B: The raw file is a CSV, a plain text table with one row per reading. Some rows are broken.
> 🧹 : Cleaned rows
M(think): Why clean first? Why not save the messy rows and clean them later?
B: Because every later step would have to remember the mess. Clean once, and trust the result.
> 🪣 : Parquet files
B(cheer): Parquet is a compact format that stores each column together, so reading it is fast.
> 📈 : Daily table

== same | set=city
LEFT: 📅 : Yesterday's note
RIGHT: ⏪ : Shift one row
M: When I predict tomorrow, I may only use what I knew before tomorrow.
B: Right. In pandas, a library for tables, shift one moves each value down a row. So each row sees yesterday.
M(happy): So yesterday's note sits on my fridge, and I cannot peek at tomorrow's newspaper!
B(cheer): Perfect comparison. That is the whole idea behind the features.

== code | set=lab
| for dt, part in df.groupby("dt"):
|     buf = io.BytesIO()
|     key = f"readings/dt={dt}/part-0000.parquet"
|     s3.put_object(Bucket=bucket, Key=key, Body=buf)
B: The loop takes one day's rows at a time. This first line starts with the first day.
> line 1
> var dt=2026-03-01
M: Next, the key is the name of the file in the cloud. The f in front puts the day inside the text.
> line 3
> var key=readings/dt=2026-03-01
B: Last, the put object call uploads the bytes to the bucket under that key.
> line 4
> out stored 1 object
M(think): So thirty days means thirty objects. Each file holds exactly one day of readings.

== journey | set=sky
NODE: job : 🧾 : Nightly job
NODE: s3 : 🪣 : S3 lake
NODE: api : 💻 : API server
B: The nightly job writes to the lake, and the API reads from it when a page asks.
> job>s3 : put objects
M: So the API never reads my laptop folder? It reads the bucket in the cloud?
> s3>api : get objects
B: Exactly. Serverless means you rent storage and short-lived computing, instead of running your own machine.
> hi api
M(cheer): So my code runs only when needed, and nobody babysits a server. Nice!

== table | set=room
HEAD: station | count | mean | max
ROW: ST-02 | 24 | 82.4 | 89.1
ROW: ST-01 | 24 | 64.5 | 78.9
ROW: ST-03 | 24 | 58.4 | 66.6
ROW: ST-04 | 24 | 92.0 | 106.5
B: This is the daily table, one row per station per day. A count of 24 means every hour arrived.
> rows 4
M(happy): Mean is the daily average, and max is the highest hour. Both are micrograms per cubic metre.
> col 3
B: Here station four has the highest mean, so it is the dirtiest today.
> keep 4

== trap | set=lab
WRONG: give the model the day's own mean
RIGHT: shift one, so inputs come from earlier days
M(shock): Oh no. If I give the model the answer as an input, its score looks perfect!
B: That is a classic trap called leakage. On a new day the model is useless, because it never had the answer. Every input must come from earlier days.
M(think): So shift one must come first, before the rolling mean of the last three days.

== term | set=room
B: Now let us check the project the way the automatic pipeline does. Run the tests first.
> $ pytest -q
> = .....  [100%]
M: Five dots mean five passing tests. My data gate uses assert, a line that stops the program when a condition is false.
> $ python dq_check.py
> = data-quality checks: 4 passed
B(cheer): If any check fails, Python stops with an error, and the whole workflow turns red.

== quiz | set=class
Q: For tomorrow's row, which days may the three-day rolling mean use?
- The three days including tomorrow
* The three days before tomorrow
- The last three hours of tomorrow
- Only the weekday number
M(think): Using tomorrow itself would be cheating. So the window has to hold earlier days only.
B(cheer): Correct! Shift one first, roll over three, and the history stays honest.

== recap | set=city
B: Let us lock in what we learned.
> One Parquet file per day in the lake
M: Clean first, then check the rules with assert.
> Clean once, then check with assert
B: Shift one, so inputs use only earlier days.
> Shift keeps tomorrow out of inputs
M: The API loads the data and model once, at start up.
> API loads data and model once
B(cheer): Tests run before any deploy. Great work today, Mira!
> Tests run before any deploy
