TITLE: Project 5: Containerised Air-Quality App
HOOK: Build it once, run it anywhere, and let a robot ship it

== title | set=city
B(happy): Welcome back! I am Bolt, and Mira has a problem from the air-quality team.
M(cheer): Hi! My dashboard works on my laptop, but it breaks on the team's server. Why?

== talk | set=room
M(sad): The server has another Python version and missing libraries. Nothing matches my laptop.
> 🖥️ : Your laptop
> ☁️ : Their server
B(think): That is the problem containers solve. A container is a sealed package with the program and everything it needs inside.
> 📦 : Container
B: The same box runs the same way on any machine. Docker builds and runs these boxes for us.
> 🐳 : Docker

== same | set=lab
LEFT: 🚢 : Shipping container
RIGHT: 🐳 : Docker container
M(happy): A shipping container fits any ship, truck or crane, because every box has the same standard size.
B: A Docker container fits any computer, because everything the program needs is packed inside the box.
M(think): So the box carries its own Python, and the server does not have to match my laptop.

== chain | set=lab
B: Our platform has a data path. First the raw readings are cleaned, so the bad rows get removed.
> 🧹 : Clean readings
B: Then a quality gate checks the rules. A gate is a set of checks that stops the run when one fails.
> 🚧 : Quality gate
B: After that, a model learns from the clean rows and is saved to one file.
> 🧠 : Train model
> 💾 : Saved model file
M(think): So the API never trains. It just loads the saved model file when it starts.

== code | set=lab
| df = load()
| assert df.value.min() >= 0, "negative reading"
| assert df.value.max() <= 500, "out of range"
| print("data-quality checks passed")
M(think): The gate is just a few lines. What does the first line do?
> line 1
> var df=672 rows
B: It loads the cleaned readings into a table called df. Nothing is checked yet, so the table holds 672 rows.
B: Each assert is a claim that must be true. If the smallest value is negative, Python stops with an error.
> line 2
M(shock): So a bad feed stops the run, instead of quietly reaching the model?
> line 3
B(happy): Exactly. A printed warning would let the bad numbers through. An assert stops the whole run.
> line 4
> out data-quality checks passed

== trap | set=room
WRONG: dashboard calls localhost:8000
RIGHT: dashboard calls http://api:8000
M(shock): My dashboard shows connection refused, but the API works. I used localhost!
B: Inside the dashboard container, localhost means that container, not your computer. Use the service name api instead.

== journey | set=sky
NODE: you : 🧑 : You
NODE: ui : 🖥️ : Dashboard
NODE: api : ⚙️ : API
B: Here is one prediction on its way. You type an address into your browser.
> you>ui : open page
M: Then the dashboard asks the API for numbers.
> ui>api : GET stations
B: The API answers in JSON, a plain text layout that programs can read.
> api>ui : JSON reply
M(happy): And the dashboard turns that JSON into a table for me.
> hi ui

== term | set=room
B: Now the two services start together, with one command.
> $ docker compose up
> = Container api-1 Healthy
> = Container ui-1 Started
M(think): Healthy first, then ui started. Does ui wait for the API?
B: Only if we ask it to. With the healthy condition, ui waits until the healthcheck passes.
B: A healthcheck is a command that runs regularly and reports whether the service answers.

== versus | set=lab
LEFT: 🔗 : Plain depends on
RIGHT: 💓 : Healthy condition
B: Compare the two ways of waiting.
> L : Only sets the start order
> L : Never checks the API works
M(think): So the plain version can start ui while the model is still loading?
B: Yes. It starts ui as soon as the API process starts.
> R : Waits for the healthcheck to pass
> R : Starts ui only when the API is ready

== quiz | set=room
Q: A request sends hour 99 to the predict endpoint. Which part rejects it with 422?
- The logging middleware
* The PredictIn model with its limits
- The Dockerfile command line
- The compose healthcheck
M(think): The middleware only writes log lines, so it cannot be that. It must be a check on the input.
B(cheer): Correct! Pydantic checks the limits before my function runs, and the reply is 422.

== bars | set=lab
BAR: ST-01 : 50.3
BAR: ST-02 : 63.2
BAR: ST-03 : 46.4
BAR: ST-04 : 68.8
M(happy): Last picture: the average reading for each station, from the clean data.
> hi 4
B: ST-04 is highest at 68.8 micrograms per cubic metre, so it is the dirtiest station.
> hi 4
M(think): So the table on the dashboard shows these same averages. Good, the numbers agree.

== recap | set=city
B: Let us lock in what we learned.
> Containers pack code and its environment
M: The quality gate uses assert, so bad data stops the run.
> Quality gate uses assert, not warnings
B: Inside containers, call the service name, not localhost.
> Use the name api, not localhost
M: A healthcheck shows a service is ready, not just started.
> Healthcheck shows ready, not just started
B(cheer): And a push to main runs the tests and deploys. Great work, Mira!
> Push to main runs tests and deploys
