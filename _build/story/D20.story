TITLE: Machine learning foundations
HOOK: Predict tomorrow's air honestly, without cheating

== title | set=city
B(happy): Welcome to CityPulse! I am Bolt, and this is Mira, our newest engineer.
M(cheer): Today's problem is big. Can we predict tomorrow's dusty air, so officers can warn people in time?
B: Machine learning can help, but only if we test it honestly. Let us see how.

== talk | set=room
M(sad): My model scored ninety nine percent last night! Then I noticed I had tested it on rows it already saw.
> 💥 : Cheating score
B: That is the classic trap. A score on rows the model learned from is only memory, not skill.
> 📸 : Memorised
M(think): So how do I test it fairly?
B(happy): Hold back some rows the model never sees while it learns. Those are your honest exam.
> word : HOLD BACK TEST ROWS

== same | set=class
LEFT: 🚗 : Driving test route
RIGHT: 🤖 : Model test rows
M(think): A learner who memorises the test route passes that route, then struggles on a brand new road.
B: A model that memorises its training rows looks brilliant, then fails on new air. Same trap, different road.

== chain | set=lab
B: An honest workflow has four stages. First, you frame the problem and fix the target.
> 🧭 : Frame problem
B: Next, the model learns its numbers from training rows only.
> 📚 : Train rows
B: Settings like tree depth are chosen on validation rows.
> 🔧 : Validation picks
M(happy): Last, the chosen model is scored once on the test rows.
> 🏁 : Test score once

== trap | set=room
WRONG: shuffle the daily rows, then split
RIGHT: split by date, oldest rows to train
M(shock): I shuffled all the days randomly, so tomorrow ended up inside my training rows!
B: A classic trap. The model learns from the future, so its score looks better than real use would give.
B: Always split a forecast by date. Earlier rows train, later rows test.

== code | set=lab
| prices = [10, 20, 30, 40, 50, 60, 70, 80]
| n_test = int(len(prices) * 0.25)
| cut = len(prices) - n_test
| train = prices[:cut]
| test = prices[cut:]
M(think): Let me try it with eight prices, oldest first. I want the last quarter held back for testing.
> line 1
> var prices=[10, 20, ..., 80]
B: Eight times a quarter is two, so the test size is two rows.
> line 2
> var n_test=2
B: Cut at position six, which is eight minus two.
> line 3
> var cut=6
B: Slicing keeps the order. Positions before six go to training, the rest to testing.
> line 4
> line 5
> var train=[10, 20, 30, 40, 50, 60]
> var test=[70, 80]
M(happy): The newest two prices stay in order, and they are the ones we test on!

== array | set=server
CELLS: 1 2 3 4 5 6 7 8
M(think): Here is the timeline as boxes. Oldest on the left, newest on the right.
> ptr i=0 j=7
B: Training uses the earlier boxes, so let us colour them green.
> done 0,1,2,3
B: The box at the edge is a gap day. It is dropped so that no target crosses over.
> hi 4
> note Gap day is dropped
B: Validation and test come after the gap, so the future never leaks back.
> hi 5,6,7

== table | set=lab
HEAD: day | today | tomorrow
ROW: Mon | 40 | 55
ROW: Tue | 55 | 61
ROW: Wed | 61 | 48
M(confused): In this table, which column may the model use as an input?
B: Today's value is fine, because it is known when the prediction is made. Tomorrow is the answer.
> col 2
B: Using tomorrow as an input is leakage. It is the answer hidden in the question, so the score becomes fake.
> col 3
M(happy): So the answer column must never sneak into the features.

== quiz | set=class
Q: Why is shuffling daily rows before a forecast split a mistake?
- It makes the training set smaller
- It changes the average of the values
* Training uses days after some test days
- It makes the model slower to fit
M(think): Shuffling keeps the same rows, so the size and the average stay the same. What changes is time.
B(cheer): Yes! Shuffling lets training see future days, so the score looks better than real use would give.

== bars | set=lab
BAR: Naive guess : 12.5
BAR: Our model : 7.9
B: The naive guess always predicts the average, and its average miss is twelve point five.
M(cheer): Our model misses by about seven point nine. So it beat the naive guess!
> hi 2
B: That only counts if both are scored on the same test rows, with the same metric.

== versus | set=lab
LEFT: 📏 : Average miss
RIGHT: 💣 : Big misses hurt
M(think): So which error number should I report to officers?
B: MAE is the average size of a miss, in the same units as the air reading.
> L : Easy to explain to officers
> L : Same units as the reading
M(confused): And RMSE?
B: RMSE squares each miss before averaging, so one huge miss counts much more.
> R : Squaring makes big misses bigger
> R : Use it when big misses are dangerous

== talk | set=room
M(sad): Should I just pick the lowest error and ship it?
B: Not yet. Ask who gets hurt by each mistake. A missed alert and a false alarm cost different things.
> 💬 : Harm question
B: Write both costs down before you pick the metric. Then never change the metric after you see results.
> 📝 : Write it down

== recap | set=city
B: Let us lock in what we learned.
> Test rows must stay unseen
M: Split forecasts by date, and never shuffle them.
> Split by date, never shuffle
B: Compare every model with a naive baseline on the same rows.
> Always beat the naive baseline
M: Pick your metric before the test, and write it down.
> Pick the metric first and log it
B(cheer): Great work today, Mira! Report errors in plain units.
> Report errors in plain units
