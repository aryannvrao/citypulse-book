TITLE: Capstone tickets T47 and T48
HOOK: Two real tickets, one trainer, and the checks that decide

== title | set=city
B(happy): Welcome back to CityPulse! I am Bolt, and Mira is with me again.
M(cheer): Hi! Today our squad starts two real capstone tickets, and a trainer will mark every one.

== talk | set=room
M(sad): Bolt, ticket T47 says it is a spike. What does that even mean?
> 📸 : Spike ticket
B(happy): A spike is a short experiment that answers one question. This one asks if a language model can write a safe bulletin.
M(think): A language model is a program that writes text from a prompt. But can it invent numbers?
> word : INVENTED NUMBERS
B: Yes, it can, and that is the risk. So the checker compares each number with the stats.

== chain | set=lab
B: Ticket T47 is a chain of pieces. First come the daily stats, such as averages and maximums by ward.
> 📊 : Daily stats
M(think): So the model never sees raw readings, only the numbers we already worked out?
> 📝 : Prompt template
B: Right. The prompt is a template with a gap, a placeholder, that code fills in.
> 🤖 : Model call
M(shock): And if the model invents a figure in its reply?
> 🔍 : Number checker
B(happy): Then the checker fails it, and the reader gets a plain template bulletin instead. Nothing false gets out.
> 📰 : Bulletin

== term | set=room
M(think): Show me how the trainer checks this. What do they type?
B(happy): First, the checker runs on each saved sample. A pass prints PASS for that file.
> $ python -m genai.check genai/samples/2026-03-02.json
> = PASS
B: Second, a grounding test checks every fact came from the input. It runs with no model key, so it works offline.
> $ env -u LLM_API_KEY pytest -q tests/test_grounding.py
> = 3 passed in 0.10s
M(cheer): No key, no internet, and it still passes. Good test!

== code | set=lab
| import re
| text = "PM2.5 was 61.2 on 03-02"
| cleaned = re.sub(r"PM\s?(2\.5|10)", "PM", text)
| allowed = {61.2, 3.0, 2.0}
| found = re.findall(r"\d+(?:\.\d+)?", cleaned)
| bad = [n for n in found if float(n) not in allowed]
| print(bad)
B: Here is the heart of the checker. Watch which numbers survive each step.
> line 2
> var text=PM2.5 was 61.2 on 03-02
M(think): Why strip PM2.5 first? To a text pattern search, that 2.5 looks like a number.
> line 3
> var cleaned=PM was 61.2 on 03-02
B: Right. The pollutant name goes, so only real figures are left.
> line 5
> var found=['61.2','03','02']
M(happy): Each one is then compared with the allowed set, built from the stats.
> line 6
> var bad=[]
B(cheer): An empty list means nothing was invented. Good work, Mira!
> line 7
> out []

== same | set=room
LEFT: 🎬 : Stunt double
RIGHT: 🧪 : Monkeypatch in a test
M(think): The hardest idea is monkeypatch. Our tests must never call the real model, so how?
B(happy): Pytest swaps the real call for a fake one, only during that single test. It works like a stunt double in a film.
M(cheer): The real actor stays safe, the scene still runs, and the real call returns afterwards.

== bars | unit=tokens
BAR: Input : 480
BAR: Output : 150
BAR: Output cap : 400
M(think): Now the cost. Ticket T47 point seven asks for the tokens and cost of one call.
B: Providers bill by tokens, roughly one word each. These bars are example counts, and both sides cost money.
> hi 1
> hi 2
M(shock): So a long reply costs more. Could the cost ever run away?
B(happy): No. Max tokens caps each reply at 400, so the worst case is known before we ship.
> hi 3

== trap | set=room
WRONG: model call above the try block
RIGHT: model call inside the try block
M(shock): I put the model call above the try, so a timeout would crash the whole program!
B: A classic trap. A try block catches errors, but only for the code inside it. Move the call inside, and a timeout falls back to the template.
M(happy): To prove it, make the call fail on purpose in a test. The template should appear.

== journey | set=sky
NODE: pc : 💻 : Your laptop
NODE: gh : ☁️ : GitHub
NODE: live : 🖥️ : Live server
M(sad): Ticket T48 is worth thirteen points. The trainer calls the live API and asks us to ship a change.
B(happy): Right. We push a tag, and the deploy, which installs the new version, runs. A tag is a fixed name on one commit, so the live server changes only when we choose.
> hi gh
> pc>gh : git push tag
> gh>live : deploy
M(think): Then the trainer asks for a rollback. How will they know it worked?
> hi live
B: The health answer shows the git sha, a short id for the commit that is live. It must match the older version.

== code | set=lab
| from datetime import date
| def parse_day(raw):
|     d = date.fromisoformat(raw)
|     if d > date.today():
|         raise ValueError("day is in the future")
|     return d
B: Ticket T48 also needs a day check. The bulletin web address must refuse a date in the future.
> var raw=2099-01-01
> line 3
> var d=2099-01-01
M(think): So the text is read as a real date, then compared with today. Why not just accept it?
> line 4
B(happy): A future day has no data yet, so the code raises an error. The server turns that into a 422 refusal.
> line 5
> out ValueError: day is in the future

== term | set=room
B(happy): Two checks. First, a bad ward must get a 422 refusal, not a 200 reply.
> $ curl -o /dev/null -w '%{http_code}' $URL/v1/bulletin?ward=bad
> = 422
M(think): So the bad text is refused before the cache or the model is even touched?
B: Exactly. Second, the same valid day is asked twice, and the log must show one model call.
> $ curl -s 'https://YOUR-URL/v1/bulletin?day=2026-11-01'
> = server log: 1 LLM call for 2 requests
M(cheer): So validation guards the door, and the cache, a saved copy of the first answer, saves a second call. Smart order!

== quiz | set=room
Q: Why must the ward be checked before the cache lookup on the bulletin route?
- Because the cache cannot store any text
* So bad input is refused before any cost
- It makes the model write shorter text
- It removes the need for any test
M(think): Let me reason it out. A bad ward could reach the database, cost a model call, or store a row.
B(cheer): Correct! Checking first means nothing bad is stored and nothing is paid for. The cache never sees it.

== recap | set=city
B: Let us lock in what we learned from these two tickets.
> Trainer runs test cases, checks commits
M: The bulletin is a chain, and the checker guards every number.
> Checker guards every number
B: Monkeypatch swaps the real call for a fake one in tests.
> Monkeypatch swaps calls in tests
M: Call the model inside the try, and validate input before the cache.
> Call inside try, validate first
B(cheer): Great work, Mira! Now build your own and defend it.
> Build it yourself, then defend it
