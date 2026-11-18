TITLE: Project 6: CityPulse capstone
HOOK: From a raw sensor file to a safe live release

== title | set=city
B(happy): Welcome back to CityPulse! I am Bolt, and this is Mira, who is building the whole platform today.
M(cheer): This is our capstone project. Sensors, a web page, a smart model and an automatic release, all in one.
B: Today we learn how the parts connect, which mistakes lose marks, and how to explain it in a viva, a spoken exam.

== talk | set=room
M(sad): Bolt, last week my dashboard showed a blank table, and I had no idea why.
> 📉 : Blank dashboard
B(think): That is why the platform has many small parts, and each part has one clear job.
> 🧩 : Parts with one job
M(confused): So what happens to the data first?
B: The sensors write a file of hourly readings. A cleaner and a quality gate check every row before anything else runs.
> 📄 : Sensor file
> 🧹 : Cleaner

== journey | set=sky
NODE: sen : 📄 : Sensor file
NODE: api : 🌐 : API service
NODE: web : 📊 : Dashboard
NODE: gh : 🚀 : GitHub Actions
B: Data moves along a route. The API is a set of web addresses that other programs can call.
> sen>api : clean rows
M(think): And the dashboard? Does it read the file itself?
B(happy): No. The dashboard asks the API for stations, and the API sends back JSON, a plain text format.
> web>api : request
> api>web : JSON reply
M(cheer): So the page never touches the raw data. Every new code push goes to GitHub Actions first.
> hi gh
> gh>api : deploy image

== chain | set=lab
B: Before the API can answer, the data passes through a line of steps. Each step must finish first.
> 📄 : Raw CSV
B: The cleaner removes unknown stations, broken dates and impossible values.
> 🧹 : Cleaner
B: Then the quality gate stops the run if a rule breaks, so bad numbers never reach the model.
> 🚧 : Quality gate
M(think): Then the model learns from the clean rows, and the notes search gets built.
> 🤖 : Model
> 🔎 : Notes index

== code | set=lab
| readings = [42.0, -3.0, 38.0]
| kept = []
| for value in readings:
|     if 0 <= value <= 500:
|         kept.append(value)
| print(len(kept), "kept")
B: Here is the gate in miniature. Three readings come in, and we watch which ones survive.
> line 1
M(think): So the list starts with three values, and kept is still empty?
> line 2
> var kept=0
B: Yes. Each value must be at least zero and at most 500 to be kept.
> line 3
> line 4
M(happy): The minus three fails the test, so only the other two survive.
> line 5
> var kept=2
B(cheer): Then the last line counts them and prints the answer.
> line 6
> out 2 kept

== trap | set=room
WRONG: curl $URL/metrics || ./deploy.sh $PREV_TAG
RIGHT: curl -f $URL/metrics || ./deploy.sh $PREV_TAG
M(shock): My health check, a quick request to the live service, had no f flag. The rollback never ran!
B: Without the f flag, curl treats an error reply, such as a 500, as a success. So the broken release stays live.
M(think): So the f flag turns a failed reply into a failed command, and then the rollback runs.

== same | set=city
LEFT: 📚 : Library catalogue
RIGHT: 🔎 : TF-IDF search
M(think): How does the notes search pick the right note? Is it like a library?
B(happy): Yes. A librarian looks for rare keywords and ignores words that every book uses.
B: TF-IDF stands for term frequency times inverse document frequency. A word counts more when one note uses it often and others rarely do.
M: Then cosine similarity compares the question with each note. Close to one means the same words, in similar amounts.

== bars | set=lab
BAR: Linear : 4.89
BAR: Boosted : 4.25
B: Let us check the model. The error is the average miss, in micrograms per cubic metre of air.
> hi 1
M(think): The straight line baseline scored 4.89. So a smaller number is better, right?
B(cheer): Right. The boosted model scored 4.25 on rows it never trained on, which is called held-out testing.
> hi 2
M(happy): So I ship the boosted model, and I can say exactly how much better it is.

== quiz | set=room
Q: Which job waits for the test job before it can run?
- The cleaner job
- The dashboard job
* The deploy job
- The data generator
M(think): Tests come first, and the rest must wait for them. So which job should wait?
B(cheer): Correct. The deploy job waits for the tests, then rolls back if the health check fails.

== table | set=city
HEAD: station | mean | max
ROW: ST-01 | 50.3 | 62.9
ROW: ST-02 | 63.2 | 74.9
ROW: ST-03 | 46.4 | 61.3
ROW: ST-04 | 68.8 | 82.0
B: This is the table the dashboard shows. Each row is one station, with its average and its highest reading.
> col 2
M(think): So which station is the dirtiest?
> rows 4
B(happy): ST-04, with a mean of 68.8. We made these with a group by, which splits the rows by station and summarises each group.
M: Each station has 168 readings, which is seven days of hourly data. So the cleaning really worked.

== term | set=lab
B: Now the checks. First we run the test suite, which exercises the cleaner, the API and the search.
> $ pytest -q
> = 6 passed in 7.53s
M(happy): Six passed, so the safety net works. Next I want to see the live numbers, using curl, a tool that sends web requests.
> $ curl -s localhost:8000/metrics
> = {"rows": 672, "requests": 4}
B: The rows count proves the cleaner kept the right number. The request count proves the middleware, a hook that runs on every request, sees every call.

== talk | set=night
B(think): Now the viva. Expect a question that asks you to walk through the path from a git push to a live service.
M(confused): What if they ask why I chose this model or this search?
B: Answer in your own words, and quote what you measured. For the model, that is the error on held-out rows.
> 🎤 : Viva tips
M(happy): And say clearly which parts you wrote yourself, because the viva also scores ownership.
> word : SAY WHAT YOU BUILT

== recap | set=city
B: Let us lock in the capstone.
> Sensor data passes a quality gate first
M: The model is judged on rows it never trained on.
> Judge the model on held-out rows
B: Notes search uses TF-IDF and cosine similarity.
> TF-IDF and cosine find the right note
M: The API uses Pydantic, a checker for types and ranges, so a bad hour gets status 422.
> Pydantic gives 422 for bad input
B(cheer): Deploy needs test, and curl -f triggers the rollback. Great work today, Mira!
> Deploy needs test, rollback on failed check
