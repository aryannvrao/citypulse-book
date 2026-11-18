TITLE: Project 1: Air-quality monitor
HOOK: From raw sensor rows to a live prediction page

== title | set=city
B(happy): Welcome to CityPulse! I am Bolt, and this is Mira, our newest engineer.
M(cheer): Hi! Today we build a real air-quality app, from raw sensor data to a live web page.
B: The app is made of many small files, and they must all work together.

== talk | set=room
M(sad): My app crashed on my first run. The error says FileNotFoundError, which means a file is missing.
> 💥 : Server crash
B(think): The missing file is a saved model. The server loads it when it starts.
B: That model is made by training, and I had not trained yet. Let us see how the pieces fit.
> 🧭 : Project map

== chain | set=lab
B: The app is a chain of steps. Raw readings enter at one end, and a web page comes out at the other.
> 📄 : Raw readings file
B: First, a cleaner removes the bad rows. Then training turns the clean rows into a model.
> 🧹 : Clean rows
> 🧠 : Trained model
M(think): So the server loads the trained model, and then answers web requests.
> 🌐 : Web server

== code | set=lab
| def load(path="data/readings.csv"):
|     df = pd.read_csv(path)
|     before = len(df)
|     df.ts = pd.to_datetime(df.ts, errors="coerce")
|     df = df[df.station_id.isin(STATIONS)]
|     df = df[df.value.between(0, 500)]
|     df = df.dropna(subset=["ts"])
|     keys = ["station_id", "ts", "pollutant"]
|     df = df.drop_duplicates(keys)
|     print(f"clean: {before} -> {len(df)} rows")
|     return df
B: Here is the cleaner, the most important function in this part. It reads the file first.
> line 2
M(think): It also counts the rows before anything is removed, right?
> line 3
> var before=675
B: Yes. Rows with unknown stations and impossible values are dropped next.
> line 5
> line 6
M(happy): At the end it prints the count, so any change in the number is noticed.
> line 10
> out clean: 675 -> 672 rows

== table | set=room
HEAD: station | count | mean
ROW: ST-01 | 168 | 50.3
ROW: ST-02 | 168 | 63.2
ROW: ST-03 | 168 | 46.4
ROW: ST-04 | 168 | 68.8
M(think): This is the station summary. Mean means the average. What does the count tell me?
> col 2
B: Count is how many clean readings each station kept. All four show 168, which is seven days of hours.
M(happy): So the cleaner kept every good row. And ST-04 has the highest mean.
> rows 4

== same | set=city
LEFT: 📚 : Practice questions
RIGHT: 📝 : Unseen exam paper
M(think): When I revise, I study practice questions. Then I sit a paper I have never seen.
B: Training is the practice. The model learns from about eighty per cent of the rows.
M(think): And the rest are the exam paper?
B: Exactly. We hide those rows during training, then grade the model on them.

== array | set=lab
CELLS: 50.7 39.3 50.4 47.5 48.3
B: Next come the features. A feature is an input the model learns from. The first one is the previous reading.
> ptr i=0 j=1
M(think): So for each cell, prev is the cell just before it?
> hi 0,1
> note prev is the reading one hour earlier
B: Right. This shifting is called a lag. The first reading of each station has no earlier one, so it is dropped.

== term | set=room
B: Let us train the model, then start the server. Training runs first.
> $ python train.py
> = MAE 4.89  R2 0.653
M(happy): MAE means mean absolute error, the average mistake. Ours is about four point nine.
B: Now uvicorn, the server program, starts. It loads the model once and waits for requests.
> $ uvicorn main:app --reload
> = Application startup complete.

== journey | set=sky
NODE: dash : 📊 : Dashboard
NODE: api : 🌐 : FastAPI server
NODE: model : 🧠 : Saved model
B: The dashboard is a web page. It asks the API for data using HTTP, the protocol that web pages use.
> dash>api : GET stations
M(think): And when someone types an hour and a reading?
> dash>api : POST predict
B: The API checks the input first. Only valid input reaches the model.
> api>model : predict
M(cheer): So the server is a gatekeeper, and the model is the expert behind it.
> hi api

== trap | set=room
WRONG: start uvicorn before training
RIGHT: run python train.py first, then uvicorn
M(shock): That is exactly what I did! I started the server first, then wondered why it crashed.
B: The server reads the model file the moment the main file is imported. No file, no server.
B: So train first, then start the server. The model file is the bridge between the two steps.

== talk | set=night
M(think): Bolt, if the training error is very low, is the model good?
B: Not necessarily. A model can memorise its training rows and still fail on new ones.
> 🧪 : Test rows only
M(happy): So we report the error on the test rows, the ones the model never saw.
B(cheer): Right. That honest number is the one to quote in a viva.
> 📏 : Honest error

== quiz | set=class
Q: Why does train.py keep twenty per cent of the rows aside?
- To make training run faster.
- To remove the bad rows from the file.
* To test on rows the model never saw.
- To make the saved model file smaller.
M(think): Keeping rows aside cannot speed training up. It also cannot clean anything.
M(think): So it must be for checking the model on data it has not seen before.
B(cheer): Correct! Held-out rows give an honest test of new data.

== journey | set=server
NODE: pc : 💻 : Your laptop
NODE: gh : 🐙 : GitHub
NODE: live : 🌍 : Live server
B: A pipeline is a chain of automatic steps. Every push to GitHub starts one.
> pc>gh : git push
M(think): Then the tests run, and the new version goes online?
> gh>live : deploy
B: Yes, but only when the tests pass. The deploy job waits for the test job.
> hi gh
M(happy): Nobody copies files by hand any more. The robot does it for us.

== recap | set=city
B: Let us lock in what we learned.
> Clean first, then train, then serve
M: The score that matters is on rows the model never saw.
> Honest error comes from test rows
B: Train before you start the server.
> Model file must exist before serving
M(cheer): And pushes run the tests before any deploy.
> Tests must pass before deploy
B(cheer): Great work today, Mira!
> Keep file names exact
