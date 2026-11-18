TITLE: Capstone tickets T26 to T30
HOOK: Five real tickets, each checked by a test you can run

== title | set=city
B(happy): Welcome to CityPulse! I am Bolt, and this is Mira, a new student engineer.
M(cheer): Hi! My squad starts five capstone tickets, numbered T26 to T30.
B: A trainer marks each ticket by running its tests and checking your own commits.

== chain | set=lab
B: Every ticket travels left to right across the board, starting in the Backlog column.
> 📥 : Backlog
> 📅 : To Do
> 🔨 : In Progress
B: Then it moves to Review, where a squad mate reads the work.
> 👀 : Review
> ✅ : Done
M(confused): Wait, who moves a ticket to Done?
B(happy): Only a trainer does, after running its tests. They also give a gate score from zero to three.

== term | set=lab
M(think): Ticket T26 asks for three charts with titles that state a finding. How do I prove it?
B: First delete the old PNG pictures, so nothing stale gets counted.
> $ rm reports/charts/*.png
B: Then rebuild them and count the files. Three means every chart was saved.
> $ python reports/charts/make_charts.py
> $ ls reports/charts/*.png | wc -l
> = 3
M(happy): And each title must be an f-string, which fills its numbers in from the data, not typed by hand.

== graph | set=server
NODE: a : Stop A : 0,1
NODE: b : Stop B : 1,0
NODE: c : Stop C : 1,2
NODE: d : Stop D : 2,1
NODE: e : Goal E : 3,1
EDGE: a-b
EDGE: a-c
EDGE: b-d
EDGE: c-d
EDGE: d-e
M(confused): Ticket T27 asks for the shortest bus route between wards. How do I find the fewest stops?
B: Picture stops as dots joined by lines. That shape is a graph.
> hi a
> note start at stop A
B: Breadth first search, or BFS, visits every stop one hop away before two hops away. A hop is one step along a line.
> hi b,c
> done a
> note ring one: B and C
M(think): So the first route BFS finds to the goal has the fewest hops?
B: Exactly. Next is ring two, which holds only stop D.
> hi d
> done b,c
> note ring two: D
B: The goal is E, one more hop past D. So the fewest hops is three.
> hi e
> done d
> note goal E: three hops

== code | set=room
| import heapq
| k = 2
| readings = [(30,'A'),(75,'B'),(52,'C'),(18,'D')]
| heap = []
| for pm25, station in readings:
|     heapq.heappush(heap, (pm25, station))
|     if len(heap) > k:
|         heapq.heappop(heap)
| print(sorted(heap, reverse=True))
M(think): My widget shows the five most polluted stations. Must I sort every reading?
B: Sorting works, but a heap of size k is cheaper. It keeps its smallest item at the front.
> line 2
> var k=2
B: Readings thirty and seventy five go in first. The heap holds two.
> line 6
> var heap=[(30, 'A'), (75, 'B')]
B: Reading fifty two makes three items, more than k. So the smallest, thirty, must pop out.
> line 6
> line 7
> var len(heap)=3
> line 8
> var heap=[(52, 'C'), (75, 'B')]
B: The last reading, eighteen, is smaller than both, so it pops straight out.
> line 6
> line 8
M(happy): At the end I sort the survivors. The ticket uses k equals five, so five stations stay.
> line 9
> out [(75, 'B'), (52, 'C')]

== journey | set=sky
NODE: lap : 💻 : Your laptop
NODE: s3 : ☁️ : S3 bucket
NODE: db : 📊 : Dashboard
NODE: ph : 📱 : Phone
M(think): Ticket T28 ships a dashboard. Who may write the data, and who may only read it?
B: The laptop uploads the daily table to an S3 bucket, Amazon's file store, using the pipeline key.
> hi s3
> lap>s3 : upload
B: The dashboard reads that file with a read only key, which can never change it.
> s3>db : read only
M(shock): So if the dashboard key leaks, nobody can overwrite the data?
B: Correct. That is least privilege, giving each identity only the actions it needs.
> db>ph : page

== term | set=room
M(think): Before the trainer tests my dashboard, I run its safety checks myself.
B: First, the secrets check. gitleaks scans all Git history, and only the example file may be tracked.
> $ git ls-files .streamlit
> = .streamlit/secrets.example.toml
> $ gitleaks detect --source . --log-opts=--all
> = no leaks found
B: Second, the read only profile tries to write a small file. That write must fail.
> $ aws s3 cp x s3://<bucket>/clean/agg/x
> = An error occurred (AccessDenied) when calling PutObject
M(cheer): A denied write means the read only policy works!

== term | set=city
M(sad): Ticket T29 is a two-page report. Every number in it needs evidence on the same line.
B: The trainer runs grep, a search tool, to list lines with a digit. Here is one.
> $ grep -nE '[0-9]' reports/mini-report.md
> = 14:Weekly readings rose 9% in March.
B: A second grep, after the pipe bar, drops lines with a link, a view name, or a KPI, which is a headline number. This line survives, so it fails.

== trap | set=room
WRONG: Weekly readings rose 9% in March.
RIGHT: Readings rose 9% in March ([chart](reports/charts/mar.png))
M(shock): Oh no, my report line has a number but no link. Should I just add the word KPI?
B: No. The check reads every line, so hiding the word does not add evidence.
B: Put the link on that same line, to the chart that shows the figure.

== same | set=night
LEFT: 📰 : Tomorrow's paper
RIGHT: 🔮 : Future value in input
M(think): Suppose I predict tomorrow's weather, but I first read tomorrow's newspaper.
B: That is cheating, called target leakage. An input secretly holds the answer, or a future value.
M(happy): So a feature must hold only what is known at prediction time.
B: Exactly. A feature holding tomorrow's pollution reading makes a model look brilliant, then fail.

== table | set=lab
HEAD: Feature | Known at | Safe
ROW: Yesterday mean | 00:00 day d | yes
ROW: Today mean | 23:59 day d | no
ROW: Tomorrow value | day d plus 1 | no
M(think): Ticket T30 ends with a machine learning plan. Each feature, an input column, needs a known at time.
B: Say the prediction is made at eight in the morning of day d. Any feature known after that is cheating.
> rows 1
> col 2
B: Yesterday's mean is known at midnight, so it is safe. Today's mean and tomorrow's value are not.
> rows 2,3
M(happy): So I keep only the safe row, and the model stays honest.
> keep 1

== quiz | set=room
Q: Your heap holds three items but k is two. What should the script do next?
- Keep all items and sort them at the end
* Pop the smallest so the heap holds two
- Print the heap at once, before any pop
- Pop the largest item out of the heap
M(think): Three items, but k is two. The heap must keep only the top two.
M(think): So which item has to leave?
B(cheer): The smallest one leaves, because heappop always removes the item at the front. Correct!

== recap | set=city
B(happy): Let us lock in what we learned today, Mira.
M: Run every test case yourself, in order, before the trainer does.
> Run each test case yourself first.
B: For the shortest route, mark each stop when you queue it, not when you pop it.
> BFS: mark a stop when queued.
M: For top k, pop the smallest whenever the heap grows past k.
> Heaps: pop whenever size passes k.
B(cheer): And every number in a report needs evidence on its own line. Great work, Mira!
> Every number needs evidence on its line.
