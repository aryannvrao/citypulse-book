TITLE: Pydantic and pytest: stop bad data
HOOK: Bad sensor data never reaches the air charts again.

== title | set=city
B(happy): Welcome to CityPulse! I am Bolt, and this is Mira, our newest engineer.
M(cheer): Hi! Today we fix a problem that quietly ruins the air quality charts.
B: Sensors send readings as text, and some are wrong. Let us stop them at the door.

== talk | set=room
M(sad): Yesterday a sensor sent a humidity of minus five. The chart jumped, and nobody noticed.
> 💥 : Bad reading
B(think): That is the danger. Wrong numbers look normal, so they slip into the database unseen.
> 📉 : Wrong chart
M: Could we just write plain if checks inside every endpoint?
B(happy): You could, but every endpoint repeats them. We want the rules written down once.
> word : RULES IN ONE PLACE

== same | set=class
LEFT: 🛂 : Airport check-in desk
RIGHT: 🧩 : Pydantic model
M: At an airport, a wrong passport stops you at the desk. You never reach the plane.
B: A Pydantic model is that desk. Bad data is stopped before your own code runs.
M(happy): So only clean readings ever get through the door!

== code | set=lab
| from pydantic import BaseModel, Field
| class Reading(BaseModel):
|     humidity: float = Field(ge=0, le=100)
| good = Reading(humidity="42.5")
| print(good.humidity)
| bad = Reading(humidity=-5)
B: A model is a class that inherits from BaseModel. Each field gets a type and some rules.
> line 2
> line 3
M(think): So humidity must be a number from zero to one hundred. What if I send text?
> line 4
B: Pydantic converts the text to a float, because the conversion is exact. Then it checks the rules.
> var humidity=42.5
M(happy): So the text became a real number. Nice!
> line 5
> out 42.5
M(shock): Now a value of minus five. What happens?
> line 6
B: Zero or more is the rule. So Pydantic raises a ValidationError and refuses the object.

== trap | set=room
WRONG: misspelt humidty, no extra rule
RIGHT: extra="forbid" in the model config
M(shock): Wait, I typed humidty with a letter missing. Did the model complain?
B: No! Without the rule, the typo is dropped silently. If humidity has a default, the request still succeeds.
M(sad): So the client thinks its value was used, when it was not.
B(think): Exactly. Add the forbid setting, and a typo becomes a clear error that names the field.

== chain | set=server
B: Every value passes three steps, in a fixed order. Watch the blocks build up.
> 📝 : Raw text
> 🔢 : Type check
> 📏 : Field limits
> ✅ : Your validator
M(think): So a number can pass the type step and still fail the limits?
B: Yes. Coercion only converts. The limits and your validator still decide what is allowed.

== quiz | set=class
Q: A field age is an int. The client sends the text "34". What does Pydantic do?
- It rejects the input because it is text
* It converts the text to the integer 34
- It stores the text, converts it later
- It converts it to the float 34.0
M(think): Text is usually refused for a number, but "34" looks like a whole number.
B(cheer): Right, the conversion is exact, so Pydantic turns it into the integer 34 and accepts it.

== term | set=lab
B: Now the tests. Pytest runs every function whose name starts with test, and reports the result.
> $ pytest -q tests/test_readings.py
> = ............... [100%]
> = 15 passed in 0.08s
M(cheer): Fifteen passed! Each one checks a rule I wrote earlier.
B: Coverage counts which lines ran during the tests. A line that never ran was never checked.
> $ pytest -q
> = TOTAL 21 0 100%
> = 15 passed in 0.10s
> $ echo $?
> = 0
M(think): Exit code zero means success. If coverage falls below sixty per cent, the code becomes one.
B: A code of one turns the check red, and branch protection blocks the merge.

== table | set=server
HEAD: reading | value | result
ROW: CP001 | 42.1 | accepted
ROW: CP002 | -5 | refused
ROW: CP003 | 17.3 | accepted
B: Here is a batch file with three readings. Every row goes through the same model.
> rows 2
M(shock): The minus five row is refused, so that bad value never reaches the chart.
> keep 1,3
B: Good rows are kept. Bad rows go to a quarantine file, where a person can review them.

== talk | set=night
M(think): How do I keep these rules working after every change?
B(happy): Write a test for each rule. Each test calls the code, then asserts that the answer is right.
> 🧪 : Small test
M: For a bad value, I use pytest raises. If nothing is raised, the test fails.
> 🚫 : Refused value
B: A failing assert turns the check red. A passing test proves the rule still holds.
> word : ASSERT = PROOF

== array | set=lab
CELLS: -5 abc 5000 None
B: Parametrize runs one test for each of these bad values, and each one reports on its own line.
> hi 0
> note one test per bad value
M(think): So if one value sneaks through, I still see the others?
> hi 1,2,3
B: Right. All four must be refused, so all four turn green.
> done 0,1,2,3

== recap | set=city
B: Let us lock in what we learned.
> Pydantic checks data at the door
M: Coercion converts, but the rules still decide.
> Coercion is not validation
B: Add extra forbid, so typos fail loudly.
> extra forbid catches typos
M: Every rule gets a test with assert.
> Tests with assert run on each change
B(cheer): Coverage and exit codes block bad merges. Great work today, Mira!
> Coverage gate blocks bad merges
