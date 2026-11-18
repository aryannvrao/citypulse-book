TITLE: Pipelines, features and tuning
HOOK: One recipe card that never peeks at the test rows

== title | set=city
B(happy): Welcome to CityPulse! I am Bolt, and Mira has a crashing API today.
M(sad): The API crashed last night! A new station code appeared, and my model had never seen it.
B: Today we build a Pipeline, one recipe card for every step. Then we tune it honestly.

== same | set=class
LEFT: 🥖 : Bakery recipe card
RIGHT: 🧩 : Pipeline object
B: Think of a bakery recipe card. Weigh the flour, add the yeast, bake for 25 minutes.
M(happy): Anyone who follows the card gets the same loaf.
B: A Pipeline is that card for a model. Same steps, same order, every time.

== chain | set=lab
B: Inside the Pipeline, raw rows pass through each step in order. First, missing numbers get filled.
> 🧽 : Fill gaps
B: Next, numbers are scaled, and station names become columns of zeros and ones.
> 📏 : Scale numbers
> 🔤 : Encode stations
M(think): The final step is the model, which turns the features into a prediction.
> 🎯 : Predict

== trap | set=room
WRONG: scale the whole table, then split
RIGHT: scaler inside the Pipeline, fit per fold
M(shock): I scaled every row first, then split. The test rows quietly changed my average!
B: That is leakage. Put the scaler inside the Pipeline, so each training fold learns its own numbers.

== code | set=lab
| import pandas as pd
| st = ["S1", "S1", "S2"]
| pm = [10, 12, 7]
| df = pd.DataFrame({"station": st, "pm25": pm})
| df["lag1"] = df.groupby("station")["pm25"].shift(1)
M(think): I want a lag, the value from one row earlier, for each station. Let us build it.
> line 1
B: The import loads pandas. Then the station names go into a list.
> line 2
> var st=["S1", "S1", "S2"]
B: Next, the readings. Then the table is built.
> line 3
> var pm=[10, 12, 7]
> line 4
B: Grouping by station keeps the shift inside each station.
> line 5
> var lag1=[NaN, 10, NaN]
M(shock): The first S2 row shows NaN, not twelve from station S1. Grouping saved us!

== versus | set=lab
LEFT: 🔧 : fit
RIGHT: 🔮 : predict
M(think): Two verbs matter most. What does fit do?
B: Fit learns numbers from the training rows only.
> L : Learns from training rows only
M(think): And predict?
B: Predict reuses those learned numbers on new rows, and never refits.
> R : Reuses the learned numbers
> R : Never refits
M(cheer): So the API applies the same recipe as training. No drift!

== quiz | set=class
Q: A new station code appears at predict time. What does handle_unknown ignore do?
- It raises an error and stops the service
- It maps the row to the common station
* Every encoded column is zero for that row
- It refits the encoder on the new row
M(think): The default would crash the service. Refitting on one new row would change the recipe, so that cannot be right.
B(cheer): Correct! The new station gets zeros, so the model still predicts without refitting.

== table | set=lab
HEAD: feature | delta | noise
ROW: lag1 | 0.9 | 0.2
ROW: festival | 0.1 | 0.2
M(think): Each feature gets a delta. That is how much the error changes when we remove it.
B: These numbers are made up for practice. The lag looks strong.
> rows 1
B: The festival delta is smaller than the noise floor, so the honest verdict is no evidence.
> rows 2
M(happy): Noise floor means the spread from random seeds. Good, I will write no evidence.

== array | set=server
CELLS: 1 2 3 4 5 6 7 8
M(confused): Time series folds cannot be shuffled. So how do they work?
B: Each fold trains on the past and checks the period right after it. A gap of rows sits between them.
> done 0,1,2
> hi 4,5
> note Fold one: train left, check right
M(shock): So a shuffled K fold would be wrong here.
B: Right. It would train on hour ten while checking hour eleven, and those readings are almost the same.
> done 4
> hi 6,7

== talk | set=room
M(sad): Should I just pick the lowest validation score and call it done?
B: Almost. Pick settings on validation folds only, then score the test rows exactly once.
> 🔒 : Test rows locked
B: Log that one number, and never tune after you have seen it.
> 📝 : Log it once

== term | set=lab
B: Let us run the tuning script and read what it prints.
> $ python3 tune.py
> = Fitting 5 folds for each of 2 candidates, totalling 10 fits
M(happy): So ten fits: two candidates times five folds. Then the winner shows up.
> = {'randomforestregressor__n_estimators': 300} 0.749
B(cheer): Right. The number is a mean R2, and the winning setting carries its step name.

== recap | set=city
B: Let us lock in today's lessons.
> Pipeline is one recipe card
M: Fit learns, predict only reuses.
> Fit learns, predict reuses
B: Put scaling and imputing inside the Pipeline.
> Scaler lives inside the Pipeline
M: Tune with time ordered folds and a gap.
> Time ordered folds, with a gap
B(cheer): Open the test rows once, log it, and never tune again. Great work, Mira!
> Test rows get one honest look
