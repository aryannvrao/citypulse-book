TITLE: Dashboards with Streamlit
HOOK: Three numbers that tell a city what to do

== title | set=city
B(happy): Welcome to CityPulse! I am Bolt, and this is Mira, our newest engineer.
M(cheer): Today we build a dashboard that shows the city's air quality on one page.

== talk | set=room
M(sad): My first dashboard had twenty five charts, and the officer could not find anything.
> 📸 : Too many charts
B: Less is more. A car dashboard shows speed and fuel, not every sensor in the car.
> 🚗 : Car dashboard
M(think): So we show only the few numbers that decide what to do next.

== versus | set=night
LEFT: 🎯 : Three clear KPIs
RIGHT: 🧾 : Twenty five charts
B: A KPI is one number with a clear formula, a unit and a good direction.
> L : Each one answers one question
M(think): But showing everything feels complete, right?
> R : Nobody knows what matters
B: Exactly. Users stop opening the page when every chart looks equally urgent.
> R : Users stop opening the page

== chain | set=lab
B: Streamlit turns a Python script into a web page. When a user changes a widget, the whole script runs again.
> 📅 : Date changed
B: The server runs every line from top to bottom, and sends the new page back.
> 🐍 : Script reruns
> 🎨 : Page redraws
M(confused): So every click runs everything again? Even a slow file download?
B: Yes. That is why we must keep slow steps from repeating.

== same | set=city
LEFT: 🍲 : Sunday soup pot
RIGHT: 💾 : Cached result
M: I cook one big pot on Sunday and eat from it all week. I do not cook again each time I am hungry.
B: A cache works the same way. Compute the answer once, keep it, and reuse it.
M(happy): And when the leftovers expire, I cook fresh. For our data, that is ten minutes.

== code | set=lab
| reads = 0
| cache = {}
| def load_daily():
|     global reads
|     if "daily" not in cache:
|         reads += 1
|         cache["daily"] = [1, 2, 3]
|     return cache["daily"]
| for click in range(2):
|     data = load_daily()
M(think): Let me trace it by hand. The read counter starts at zero.
> line 1
> var reads=0
B: Next, an empty cache. The function is defined here, but nothing runs yet.
> line 2
> var cache={}
M: First click. The daily key is missing, so the if body runs.
> line 5
> line 6
> var reads=1
B(happy): The data is saved in the cache, and the function returns it.
> line 7
> line 8
M(cheer): Second click. The key is already there, so the if body is skipped.
> line 9
> line 5
> out reads is still 1

== trap | set=room
WRONG: read the file at the top level
RIGHT: read it inside a cached function
M(shock): Oh no, I read the S3 file at the top of my script. Every click downloads it again!
B: Classic trap. Put the read inside a function, and decorate that function with cache data and a ten minute time to live.

== table | set=lab
HEAD: day | pm25 | over
ROW: Mon | 72 | yes
ROW: Tue | 48 | no
ROW: Wed | 66 | yes
ROW: Thu | 35 | no
B: Now the sidebar filter. Pick Tuesday to Wednesday, and the table keeps only those two days.
> keep 2,3
M(happy): Good. Column three shows the days over the limit, so the cards count only what I picked.
> col 3

== quiz | set=lab
Q: Which setting makes a rise in PM two point five show in red?
- Normal colour setting
* Inverse colour setting
- Hidden label setting
- Stop the script first
M(think): A rise in pollution is bad news, so it must be red. Normal would show green.
B(cheer): Correct! Inverse flips the colour rule, so a rise turns red.

== journey | set=sky
NODE: pc : 💻 : Your laptop
NODE: gh : 🐙 : GitHub
NODE: sc : 🚀 : Streamlit Cloud
B: Your code travels through Git. GitHub keeps the online copy, and Streamlit Cloud runs the app from it.
> pc>gh : git push
> gh>sc : deploy main
M(think): And the secrets? They cannot travel with the code.
> hi sc
B: Right. You paste the real secret settings into the cloud app's Secrets box by hand.

== term | set=room
B: Let us run it on your laptop first. One command starts the server.
> $ streamlit run app/dashboard.py
> = You can now view your Streamlit app in your browser.
> = Local URL: http://localhost:8501
M(cheer): Now I open that address and see my dashboard. Three cards, and a chart.

== trap | set=night
WRONG: git add everything, including secrets.toml
RIGHT: list secrets.toml in the git ignore file first
M(shock): Wait, I just added everything. Did my real keys go into Git?
B: Maybe. Git remembers every commit, so a key once committed stays in history. Rotate the key at once, and ignore the secrets file before you commit.

== recap | set=city
B: Let us lock in what we learned.
> Each change reruns the whole script
M: Slow reads go inside a cached function.
> Cache slow reads with a time limit
B: Filter into a new variable, never the cache.
> Filter into a new variable, not the cache
M: Pollution colours need the inverse option.
> Use inverse colour for pollution metrics
B(cheer): And keep secrets in a git ignored file, never in Git. Great work, Mira!
> Secrets stay out of Git
