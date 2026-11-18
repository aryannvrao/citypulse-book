TITLE: Ensembles, errors and model cards
HOOK: Combine models, find where they fail, and say so

== title | set=city
B(happy): Welcome to CityPulse! I am Bolt, and this is Mira, our newest engineer.
M(cheer): Today's problem: officers act on our pollution forecasts, so we must know when to trust them.

== talk | set=room
M(sad): Bolt, one model gave me a bad forecast last week. The average looked fine, but one day was way off.
> 📉 : Bad forecast
B(think): One model makes its own mistakes, and they often differ from row to row.
B(happy): So we combine several models into one. A group like that is called an ensemble.
> 🤝 : Ensemble
M(think): So a team of models can be wiser than one model?
B: Often, yes. Some mistakes cancel out when the answers are averaged.
> word : MISTAKES CANCEL OUT

== same | set=class
LEFT: 🏫 : Ask three teachers
RIGHT: 🤖 : Ensemble of models
B: Picture a school where one teacher's mark for a pupil is unreliable. The head asks three teachers and averages their marks.
M(happy): So one shaky mark gets smoothed out by the others. That is the same idea as my models!
B: Exactly. An ensemble averages the forecasts of several models, day by day.

== code | set=lab
| a = [10, 20]
| b = [12, 18]
| avg = []
| for x, y in zip(a, b):
|     avg.append((x + y) / 2)
M(think): Two forecast lists, averaged position by position. How does this loop run?
> line 1
> var a=[10, 20]
> line 2
> var b=[12, 18]
B: The zip function pairs position zero of each list, so x is ten and y is twelve.
> line 4
> var x=10
> var y=12
B(happy): Their average is eleven point zero, and that goes into avg.
> line 5
> var avg=[11.0]
M(happy): Then the loop moves on to position one, which gives nineteen point zero.
> line 4
> var x=20
> var y=18
> var avg=[11.0, 19.0]

== bars | set=lab
BAR: Mean guess : 9.64
BAR: Single tree : 6.51
BAR: Boosting : 5.18
M(think): Which model is best? MAE, the mean absolute error, is the average size of a miss. Lower is better.
> hi 1
B: The mean guess misses by nine point six four on average. One single tree gets six point five one.
> hi 2
B(happy): Gradient boosting adds shallow trees one after another, each fixing the last one's errors. It reaches five point one eight.
> hi 3
M(cheer): So boosting wins here, with the lowest average miss.

== table | set=room
HEAD: row | group | abs error
ROW: 1 | A | 2
ROW: 2 | B | 3
ROW: 3 | A | 3
M(confused): Now I must add up the errors for each group. Where do I even start?
B: Walk down the rows. Each row belongs to one group, so its miss goes into that group's total.
> rows 1,3
M(cheer): Rows one and three are group A, so two plus three gives five. Group B has only three.
> col 3

== trap | set=lab
WRONG: group by raw UTC hour
RIGHT: convert to Asia/Kolkata first
M(shock): Oh no. I grouped by the raw hour, so a six pm spike in Indian time showed up at half past twelve.
B: A classic trap. The raw hour is UTC, which runs five and a half hours behind Indian Standard Time, IST. Convert to IST first.

== graph | set=lab
NODE: ma : Model A : 0,0
NODE: mb : Model B : 0,2
NODE: avg : average : 2,1
NODE: err : errors : 4,1
NODE: card : card : 6,1
EDGE: ma>avg
EDGE: mb>avg
EDGE: avg>err
EDGE: err>card
M(think): So both models feed the average, and the average feeds the errors step?
> hi ma,mb
B: Yes. The errors are residuals, which means actual minus predicted for each row.
> hi avg
> note residual: actual minus predicted
M(happy): And the last box is a model card, which records those errors for reviewers.
> hi err
> hi card

== versus | set=lab
LEFT: 📋 : Overall score
RIGHT: 🔍 : Slice scores
M(think): The overall MAE is five point one eight for the whole test set. Is one number enough to trust the model?
B: Not on its own. An average can hide a station where the model is badly wrong.
> L : One number for everything
> R : One station can fail badly
M(shock): Station S T zero four has an MAE of six point one three, above the overall average.
> R : Worst station, above average
B: So slice the errors by station and hour, and always show the count.
> R : Show n for every group
> L : Hides weak spots

== quiz | set=class
Q: Why can an ensemble beat any single model in it?
- More trees always means fewer errors
* Different mistakes partly cancel out
- Averaging always doubles the error
- Every model repeats the same mistake
M(think): Averaging only helps when the models disagree. If they all repeat one mistake, averaging keeps it.
B(cheer): Correct! Different mistakes cancel out, so the average can beat each member.

== recap | set=city
B: Let us lock in what we learned.
> An ensemble averages several models
M: Slice by station and hour, and always show the count.
> Slice errors, show the count
B: A model card states its uses, its data and its known limits.
> Model card states the limits
B(cheer): Great work today, Mira! Honest limits build trust.
> Honest limits build trust
