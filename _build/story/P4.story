TITLE: Air-quality forecaster
HOOK: Clean data, honest tests, and a live forecast page

== title | set=city
B(happy): Welcome back to CityPulse! I am Bolt, and Mira is building the forecaster today.
M(cheer): Hi! The page predicts pollution hour by hour, for six stations across the city.

== talk | set=room
M(sad): Bolt, the page shows a peak of 69 for one station. How do I know that number is trustworthy?
> 📍 : Six stations
B(think): Good question. We need clean data, an honest test, and a model you can explain.
> 🧪 : Honest test
M: What do you mean by honest? Surely a test is a test.
> 🔮 : Forecast curve
B(happy): Honest means the test uses hours the model never saw while it learned. Then the score is fair.

== chain | set=lab
B: The project has four stages. Each stage gives its output to the next one.
> 📄 : Raw readings
B: First, the readings are loaded from a CSV file, which is a plain text table.
> 🧹 : Clean rows
B: Next, a quality gate checks the rules. A rule is a condition the data must meet.
> 🔒 : Quality gate
M(think): Then the features are built, and the model learns from them. What is a feature?
> 📈 : Trained model
B(cheer): A feature is an input column the model learns from, such as yesterday's reading.

== code | set=lab
| def load(path="data/readings.csv"):
|     df = pd.read_csv(path)
|     df["ts"] = pd.to_datetime(df.ts, errors="coerce")
|     before = len(df)
|     df = df[df.station_id.isin(STATIONS)]
|     df = df[df.value.between(0, 500)]
|     df = df.dropna(subset=["ts"])
|     print(f"clean: {before} -> {len(df)} rows")
B: This function loads the CSV, then removes rows that cannot be right. Watch the row count.
> line 1
> line 2
M: The to datetime step turns text into real times. Anything unreadable becomes not a time.
> line 3
> line 4
> var before=4323
B: Next, the station check keeps only the six known stations. An unknown station is dropped here.
> line 5
B: The between step keeps values from zero to five hundred, so a negative reading is dropped.
> line 6
M(happy): Last, dropna removes the broken times, and the count prints.
> line 7
> line 8
> out clean: 4323 -> 4320 rows

== same | set=city
LEFT: 🎓 : Practice, then exam
RIGHT: ⏳ : Time-ordered folds
M: If I shuffle the hours and test on random ones, is that fair?
B: Not for a forecast. Shuffling lets the model train on hours that come after the test hours.
M(think): So it is like studying next week's exam paper before the real exam?
B(happy): Exactly. Each fold, or split, trains on the past and tests on later hours.

== trap | set=lab
WRONG: shuffle the rows, then cross-validate
RIGHT: TimeSeriesSplit, with test blocks after train
M(shock): Oh no, my score looks much better than the holdout test. Why?
B: Because shuffled folds leak. The model sees neighbouring hours from the future, so its error looks too small. Treat that score as a warning sign.
M(think): So the honest number is the one from the time-ordered test.

== table | set=room
HEAD: model | CV MAE | spread
ROW: RandomForest | 3.928 | 0.116
ROW: Gradient Boost | 3.689 | 0.115
B: Two models were scored with five time-ordered folds. MAE is the average miss, in micrograms per cubic metre.
> keep 2
M(happy): Gradient boosting has the lower error, so it wins on cross-validation.
> col 2
B: The spread is how much the score moved between folds. A small spread means a steady score.
> col 3

== array | set=lab
CELLS: 40 42 41 41 0
B: A recursive forecast, which means each step uses the last output, predicts one hour at a time.
> ptr i=1 j=3
> hi 1,2,3
> note last three values: 42, 41 and 41
M(think): So each guess becomes history, and the next guess uses it?
B(cheer): Yes. The average of 42, 41 and 41 is 41.3, and that joins the history.
> set 4=41.3
> done 4
M: Then the window slides one step, and the next guess uses that new value.
> ptr i=2 j=4

== journey | set=sky
NODE: dash : 💻 : Dashboard
NODE: api : 🔧 : FastAPI service
NODE: llm : 🧠 : Language model
B: The dashboard asks the FastAPI service for a forecast. FastAPI is a library that builds web endpoints.
> hi api
> dash>api : ask for forecast
M: And the reply comes back as JSON, which is plain text with named values inside curly braces.
> api>dash : JSON reply
B: Then the dashboard asks the small language model for one sentence of advice on the peak.
> dash>llm : one short prompt
M(cheer): So three parts talk, and each one has a single job.

== term | set=room
B: Now let us run the tests the way the pipeline does. Each test is a function with an assert in it.
> $ pytest -q
> = ....  [100%]
> = 4 passed in 1.67s
M: Four dots, four passing tests. One test checks that a bad station gets an error back, not a crash.
B(cheer): A status code is the reply number. The 422 means the input broke a rule, so nothing ran.

== quiz | set=class
Q: Why is each new prediction added to the history list?
- So predictions can be saved to the card.
- So the model retrains after every hour.
- So the output list is sorted by time.
* So the next hour's features can use it.
M(think): The next row is built from the history. So the new guess has to join the history first.
B(cheer): Correct! The guess becomes a feature, and that is how the forecast reaches further ahead.

== recap | set=city
B: Let us lock in what we learned.
> Clean data, then check with asserts
M: Use time-ordered folds, never shuffled ones.
> TimeSeriesSplit keeps the future out
B: On the last twenty per cent of time, the average error was 3.55 micrograms per cubic metre.
> Holdout MAE 3.55, R2 0.864
M: Predictions feed forward, so long forecasts drift.
> Recursive forecasts drift with horizon
B(cheer): Bad input gets a clear 422 error. Great work today, Mira!
> Bad input gets a clear 422 error
