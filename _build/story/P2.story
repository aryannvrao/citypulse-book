TITLE: Project 2: Air-Quality Spike Detector
HOOK: Catch the dust spike before anyone else does

== title | set=city
B(happy): Welcome to CityPulse! I am Bolt, and this is Mira, our newest engineer.
M(sad): Bolt, a station's average looked normal all week, yet one hour hit three times its usual dust. Nobody noticed.
B(think): That is why we built a spike detector. Today we see how it works, and how to explain it in a viva, a spoken exam.

== talk | set=room
M(confused): Bolt, what does PM two point five actually measure?
> 💨 : PM2.5 dust
B(happy): It is very fine dust in the air, measured in micrograms per cubic metre. We watch four stations.
> 🏭 : Four stations
B(think): When one station suddenly reports a value far above its own recent normal, the service flags a spike.
> word : SPIKE = SUDDEN JUMP

== chain | set=lab
B: Every reading follows one path. It starts in a CSV file, plain text with one reading per line.
> 📄 : Raw CSV file
M(think): Then pandas cleans it. Pandas is a Python library for tables.
> 🧹 : Clean with pandas
B: Next an SQL window works out each station's six hour baseline. SQL is the language for asking databases questions.
> 📊 : SQL baseline
B: Two separate tests must both agree before a reading is confirmed.
> ✅ : Two tests agree
M(happy): Then an API, a door other programs knock on, serves the list as JSON data.
> 🌐 : JSON API
> 📺 : Dashboard page

== same | set=room
LEFT: 📊 : Class average
RIGHT: 🎯 : Middle score
M(think): Bolt, why use the median instead of the average? The median is the middle value once sorted.
B: Picture a class test where one student scores far above everyone else. The class average jumps, but the middle score barely moves.
M(happy): So the middle score is the fair yardstick, and the average gets fooled.
B(cheer): Same trick for sensor data. One spike cannot drag the median far.

== array | set=lab
CELLS: 50 52 49 51 180
M(think): Here are five readings from one station. Sorted, the middle one is 51, which looks normal.
> done 3
B(happy): The 180 is the odd one out. A plain average would jump to 76.4, dragged up by that single value.
> hi 4
> note Plain average is 76.4
M(think): So one spike pulls the average up.
B: The median absolute deviation, MAD, is the middle value of all the distances from the median. It barely notices the 180.
> note MAD: median absolute deviation

== code | set=lab
| import statistics
| vals = [50, 52, 49, 51, 180]
| med = statistics.median(vals)
| dev = [abs(v - med) for v in vals]
| mad = statistics.median(dev) + 1e-6
| z = 0.6745 * (180 - med) / mad
| is_spike = z >= 3
M(think): Let us run the spike test on those five readings, one line at a time.
> line 2
> var vals=[50, 52, 49, 51, 180]
B: First the z score, which measures how many steps a value sits from normal. We start with the median, 51.
> line 3
> var med=51
M(confused): Then dev, the distances from that middle. The 180 is 129 away, the rest only one or two.
> line 4
> var dev=[1, 1, 2, 0, 129]
B(happy): Now the MAD. We add one millionth so the division never divides by zero.
> line 5
> var mad=1.000001
M(happy): So z comes out near 87. That is far above the cutoff of three.
> line 6
> var z=87.01
B(cheer): So the flag is true. The 180 is marked as a spike.
> line 7
> var is_spike=True

== trap | set=lab
WRONG: (r.z>=3) and (r.value>r.iqr_hi)
RIGHT: (r.z>=3) & (r.value>r.iqr_hi)
M(confused): Both tests are columns, so I will simply join them with the word and.
B: A classic trap. The word and works on single values, not on a whole column of readings.
M(shock): So it crashes with a value error about the truth value of a series?
B(think): Yes. Use the ampersand sign with brackets around each test, so pandas compares row by row.

== versus | set=sky
LEFT: 📏 : Statistical test
RIGHT: 🌲 : IsolationForest
M(think): We now have two judges. How do they differ?
B: The statistical test judges each station alone, using a fence from the middle half of its data, the IQR.
> L : Judges each station alone
> L : Median and IQR fence
B: The IsolationForest is a machine learning model, which finds patterns itself. It splits data at random, and odd points get isolated fast.
> R : Sees value and deviation together
> R : Unusual points split off fast
M(happy): So a reading must pass both judges to be confirmed. That keeps out false alarms.
> L : Both must agree

== term | set=lab
B(happy): First we make the test data. The script writes 675 rows, with four spikes planted on purpose.
> $ python make_data.py
> = wrote data/readings.csv: 675 rows (4 spikes planted)
M(think): Then pytest, a test runner, runs our four checks. Skip the data step and it fails.
> $ pytest -q
> = 4 passed in 1.69s
B(cheer): All four pass. Remember, run the data script first, every time.

== trap | set=server
WRONG: CMD uvicorn main:app
RIGHT: CMD uvicorn main:app --host 0.0.0.0
M(shock): My Docker container runs, which is a sealed box holding our app. But my browser cannot reach it. What did I miss?
B: Inside Docker, the default host only answers from inside the box. Set the host to zero dot zero dot zero dot zero, meaning all addresses.
M(happy): So one small flag is the difference between a running container and a reachable one.

== quiz | set=class
Q: Which condition must hold before a reading becomes a confirmed spike?
- Either test alone flags it.
* Both tests flag it, and they agree.
- It is the highest value at its station.
- Its value is above 500.
M(think): Hmm, one flag alone could just be noise. Highest value is not a rule.
B(cheer): Correct! Both tests must flag the reading. That is how the detector keeps false alarms low.

== talk | set=sky
M(confused): Bolt, the viva asks hard questions. What do the examiners really want?
B(think): They score four things: did it work, how the statistics and SQL work, which parts were yours, and your limits.
> 🎤 : Viva: four scores
M(happy): So for every answer, I should say why.
B(cheer): Exactly. Say why the baseline leaves out the current reading, because a spike would otherwise hide itself.
> word : SAY THE WHY

== recap | set=city
B: Let us lock in what we learned today.
> Baseline uses six earlier hours
M: The median and MAD ignore one extreme value.
> Median and MAD ignore one extreme value
B: Both tests must agree before a spike is confirmed.
> Both tests must agree to confirm
M: Watch the traps: use the ampersand, not and. And Docker needs the host set to all addresses.
> Use & with brackets, not and
> Docker needs host 0.0.0.0 to reach it
B(cheer): Great work today, Mira. Now go and explain it aloud!
