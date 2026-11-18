TITLE: Viva and interview mastery
HOOK: Explain your work with proof and a limit

== title | set=city
B(happy): Welcome to CityPulse! I am Bolt, and this is Mira, our newest engineer.
M(cheer): Hi everyone! My viva is coming up, and I want to answer every question with confidence.

== talk | set=room
M(sad): Bolt, an examiner asked me why I chose my design, and my mind went completely blank.
> 💥 : Blank mind
B(happy): That happens to everyone. A viva is a spoken exam, so you must answer out loud, with a real person listening.
> word : EVIDENCE AND LIMIT
M(think): So what are they actually scoring?
B: Four things, each from zero to five. Criteria met, technical depth, ownership and understanding.
> 📸 : Four scores

== versus | set=class
LEFT: 🙈 : Weak answer
RIGHT: 🎯 : Strong answer
M(think): Let me try two answers to the same question. Why store readings in a database?
B: The weak answer says databases are better, and everyone uses them. Nothing about your own work.
> L : Appeals to popularity
> L : No claim, no evidence
M(happy): Now the strong answer, please.
B: It names the real need, one station over one date range, and admits the cost.
> R : Names the real need
> R : Admits the cost

== chain | set=lab
B: Every strong answer has three parts, in this order. First, the claim: one direct sentence.
> 🎯 : Claim
B: Second, the evidence. Name a file, a command, a test or a result from your own work.
> 🔍 : Evidence
B(think): Third, the trade-off. That is the cost you accepted for the result, and why it was fine.
> 💰 : Trade-off
M(cheer): Claim, evidence, trade-off. I can say that in under a minute!

== same | set=room
LEFT: 🚲 : Choosing a bike
RIGHT: 🗂️ : Choosing a database
M: A trade-off still sounds abstract to me. Let us think about buying a bike.
B: A light bike is fast, but it has no room for shopping. A sturdy bike carries more but feels heavy.
M(happy): So a database is quick to query, but I must maintain a table schema, the list of columns and types.
B: Exactly. Name the cost, and the examiner knows you thought about the alternatives.

== table | set=class
HEAD: Score area | Examiner wants
ROW: Criteria met | Proof it works
ROW: Tech depth | Tool knowledge
ROW: Ownership | Your decisions
ROW: Understanding | The reason why
B: Here is what examiners look for in each of the four scores. Let us check the first two rows.
> rows 1,2
M: Proof, tool knowledge, my decisions and the reason behind them. That is a lot to remember.
B: Yes, and a five always has evidence and a limit. Look at the last two rows.
> rows 3,4
M(think): A limit means a sentence about what the work does not do yet.

== code | set=lab
| def average_pm25(readings):
|     values = []
|     for r in readings:
|         if r.get("pm25") is not None:
|             values.append(r["pm25"])
|     if not values:
|         return None
|     return sum(values) / len(values)
M(think): Let me walk through this function. Where do I start?
B: Start with the purpose, in one sentence. This function gives the average P M two point five reading.
> line 1
> line 2
> var values=[]
B: It loops over the readings and keeps only those with a value. A missing value would break the sum.
> line 3
> line 4
> line 5
> var values=[40, 60]
M(confused): What if nothing has a value?
B: Then the function returns None, so the caller knows there is no average.
> line 6
> line 7
M(cheer): And with forty, nothing, and sixty, the answer is fifty!
B: Exactly. I tested it with an empty list and a list with one missing value.
> line 8
> out 50.0

== trap | set=room
WRONG: This is a list comprehension
RIGHT: This keeps only readings with a value
M(shock): I would say this line is a list comprehension, and then stop. Is that wrong?
B: It is true, but it is only syntax. The examiner wants to hear what the code does to the data.
B(cheer): Yes! Explain the data, not the grammar.

== bars | set=city | unit=s
BAR: Whiteboard : 120
BAR: One decision : 45
BAR: STAR story : 90
B: Timing matters, because long silences worry examiners. Here are the targets from the chapter, in seconds.
> hi 1
M(think): Two minutes for the whiteboard walkthrough? That seems long.
B: It is a calm pace. Draw the four boxes first, then talk, and practise until you can speak without reading.
> hi 1
M: And one decision, claim, evidence and trade-off, under forty five seconds.
> hi 2
B: A behaviour answer in STAR form takes about ninety seconds.
> hi 3

== chain | set=room
M: What if you do not know the answer at all? I would say I don't know and stop there.
B: That ends the conversation. Use three steps instead.
B: First, say what you do know, even if it is only a nearby idea.
> ✅ : What you know
B: Second, say how you would check. Name the tool, the document or the command.
> 🔎 : How to check
B(think): Third, if you offer a guess, label it clearly as a guess.
> 💭 : Labelled guess

== quiz | set=class
Q: The examiner asks how fast your script runs. You never measured it. Best response?
- It is fast enough for this project.
- The database is very fast, so it is fine.
* Not measured yet. I would time a full run.
- Speed does not matter for students.
M(think): Saying it is fast enough claims a result I never saw. The examiner would ask what fast means.
B(cheer): Right! An honest admission, plus a specific way to measure, is the strong answer.

== recap | set=city
B: Let us lock in what we learned.
> A claim, evidence and a trade-off
M: Name real files and numbers as evidence.
> Evidence from your own work
B: Always name one limit, and never bluff.
> Name one limit, never bluff
M: And explain what the code does to the data.
B(cheer): Great work today, Mira!
> Explain the data, not the grammar
