TITLE: Capstone tickets T31 to T37
HOOK: Seven tickets, and how your trainer checks each one

== title | set=city
B(happy): Welcome to CityPulse! I am Bolt, and this is Mira, our newest engineer.
M(cheer): Hi everyone! My squad is about to start seven capstone tickets, and each has a trainer check.
B: Today we learn what each ticket asks, and exactly how the trainer checks it.

== term | set=room
M(think): First ticket is T31. We build a table where tomorrow never sneaks into today's row.
B: The trainer runs one command. It builds the splits and prints the manifest, a small file that records the cut-off dates.
> $ python -m citypulse.features && cat data/splits/manifest.json
> = {"train_end": "2024-06-30", "val_end": "2024-09-30",
> = "rows": {"train": 1000, "val": 200, "test": 200},
> = "test_sha256": "3f2a..."}
M(happy): So the oldest days train, the next days validate, which means choosing settings, and the newest days test.
B: Yes, and a gap day is dropped at each cut-off, so no target crosses the boundary.

== bars | set=lab | unit=MAE
BAR: Persistence : 12.47
BAR: Linear : 7.94
M(think): T32 asks one plain question. Can a simple model beat the lazy guess called persistence?
B: Persistence says tomorrow equals today. Its error is the bar to beat, and shorter bars are better.
> hi 1
M(happy): So in this made-up chart, the linear model beats the lazy guess?
> hi 2
B: Yes, it is shorter. Next, the squad must write the metric in the log before any test score.
M(shock): But how do I know nobody changed the rules afterwards?
B: A commit is a saved snapshot of changes. The git log lists commits in order, so the trainer can see the metric was fixed first.

== chain | set=server
M(think): T33 is worth eight points, the biggest ticket so far. It packs the preprocessing, which means the cleaning steps before the model, into one Pipeline.
B: A Pipeline is a chain of named steps. Raw rows enter on the left, and predictions leave on the right.
> 📥 : Raw rows
> 🧹 : Fill gaps
> 🧩 : Feature steps
> 🌲 : Model
M(confused): Why does that matter if my notebook already works?
B: The API, the door other programs use to ask our model for a forecast, receives raw rows later. If it rebuilds the steps by hand, the copies drift apart silently.
M(think): So how does the trainer check that?
B: It runs the train script with a config file, a text file of settings. The exit code, a number the program returns, must be zero.

== code | set=lab
| import pandas as pd
| stations = ["A", "A", "B", "B"]
| pm = [10, 20, 30, 40]
| df = pd.DataFrame({"station": stations, "pm": pm})
| df["prev"] = df.groupby("station")["pm"].shift(1)
M(think): T34 adds five engineered features, which are new columns built from old ones. I will test the simplest: the previous reading.
B: Groupby cuts the rows into one group per station. Shift moves each value down one row inside its group.
> line 5
> var prev=[NaN, 10, NaN, 30]
M(confused): Why is station B's first row empty? Shouldn't it read 20 from station A?
B: That is exactly what groupby prevents. Without it, station B would copy station A's last reading.
> out B first row stays NaN

== table | set=class
HEAD: fold | train days | test days
ROW: 1 | Jan to Feb | Mar
ROW: 2 | Jan to Mar | Apr
ROW: 3 | Jan to Apr | May
B: T35 tunes the model with time-series cross-validation. That means several folds, which are splits of the data, each tested on days after its training days. The table is made up.
> rows 2
> col 3
M(happy): Fold two trains on January to March, and tests on April, so the past always comes first.
B: A shuffled fold could train on Tuesday and test on Monday, which is cheating, because the model saw the future.
M(think): So the final test window opens only once, at the very end?
B: Yes. The trainer checks that the log holds exactly one final test entry.

== versus | set=sky
LEFT: 📈 : Tuned linear model
RIGHT: 🌳 : Ensemble models
M(think): T36 is Demo Day. The panel asks whether ensemble models beat the tuned linear model on the same splits.
B: An ensemble is a group of models that vote or average together.
> L : Simple and easy to explain
> R : Many models combined into one
M(think): Averages can hide problems, though. Where is the model weakest?
B: Slice tables split the errors by station, ward and hour. A model right on average can still be badly wrong at rush hour.
> L : Average can hide a weak ward
> R : Slice tables show ward and hour

== term | set=night
M(think): T37 writes the model card, the leaflet inside a medicine box.
B: The trainer counts the card's sections, which must be seven or more, and checks that it names the saved model file.
> $ grep -c '^## ' MODEL_CARD.md
> = 8
> $ grep -n 'model_v1.joblib' MODEL_CARD.md
> = 14: Final model: models/model_v1.joblib
M(shock): If the card says the model is weaker at night, is that enough?
B: No. Every limitation needs a segment and a number, copied from the slice table.

== same | set=room
LEFT: 🏫 : Peeking at answers
RIGHT: 🔮 : Tomorrow in training
M(confused): Why is peeking at tomorrow so bad? My score would look amazing!
B: Peeking at the answer sheet gives a fake high mark. Future rows in training do the same.
M(happy): So a score that looks too good is a warning, not a win!

== trap | set=server
WRONG: random split: train_test_split(shuffle=True)
RIGHT: cut by date, with a gap day left out
M(shock): I shuffled the rows at random, and my scores looked great. Oops.
B: A classic trap. Shuffled days let the future into training. Cut by date instead, with a gap day.
M(cheer): Got it! Oldest days train, the next days validate, and the newest days test.

== quiz | set=class
Q: Which split is safe for hourly air readings?
- Shuffle all rows, then split at random
- Random folds with train_test_split
* Cut by date, with a gap day
- Pick random rows for the test set
M(think): Shuffling mixes past and future rows, so the random options are out. Only a date cut keeps time in order.
B(cheer): Correct! A date cut keeps time in order, and the gap day stops leakage, which is future information sneaking into training, at the boundary.

== recap | set=city
B: Let us lock in the seven tickets.
> Date split with a gap day, never random
> Pipeline holds every preprocessing step
> Remove one feature to see its effect
M: And the trainer checks each one with a command, not a feeling.
> Tune on time-ordered folds, open test once
> Model card: slice errors beside the average
B(cheer): Check every ticket before you ask for review, and good luck, squad!
