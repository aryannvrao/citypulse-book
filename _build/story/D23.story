TITLE: Serving a model with FastAPI
HOOK: Honest status codes and a model loaded once

== title | set=city
B(happy): Welcome back to CityPulse! I am Bolt, and this is Mira, who is building our first web service.
M(cheer): Today's problem: the dashboard team cannot import our model, so how do they get predictions?

== talk | set=room
M(think): Bolt, can the dashboard team just import my model file and call it?
> 💻 : Dashboard
B(happy): Not really. They send a request to a web address and read back a reply. That is a service.
> 📨 : Request
M(think): So a service is a program that waits, then answers each request?
> 📬 : Reply
B: Exactly. An API is the agreed list of web addresses and reply formats that clients can use.
> word : A SERVICE WAITS

== same | set=class
LEFT: 💊 : Pharmacy counter
RIGHT: 🌐 : Web API
B: At a hospital pharmacy, staff do not walk to every ward. You write a request at the window, and the answer comes back in a standard form.
M(happy): So the window is the API, and the medicine stays behind it. I get that!
B: Exactly. The model stays behind the window, and clients never open its files.

== journey | set=sky
NODE: dash : 💻 : Dashboard
NODE: api : 🧩 : FastAPI app
NODE: db : 💾 : Postgres
B: The dashboard never touches the database directly. It sends its request to our app first.
> dash>api : GET health
> hi api
M(think): So the app asks Postgres for the data, then sends a reply back?
> api>db : SELECT 1
B: Yes. The smallest question is SELECT one, which checks that the database is alive.
> db>api : answer
> api>dash : JSON reply

== term | set=lab
M(think): Let me test it from the terminal. Curl is a tool that sends a request for us.
> $ BASE=http://localhost:8000
> $ curl -i $BASE/v1/health
> = HTTP/1.1 200 OK
> = {"status":"ok"}
B(happy): The minus i flag also prints the status line. Two hundred means the data really is there.
> $ curl -i $BASE/v1/stations/DOES_NOT_EXIST/readings
> = HTTP/1.1 404 Not Found
B: A station that does not exist must return four oh four, never an empty list with two hundred.

== code | set=lab
| def health():
|     try:
|         q("SELECT 1")
|     except psycopg.OperationalError:
|         raise HTTPException(
|             status_code=503,
|             detail="database unavailable",
|         )
|     return {"status": "ok"}
M(confused): Why does the try block exist at all?
> line 2
B: It watches for database errors. If Postgres is stopped, the connection fails right at the query.
> line 3
M(think): So the exception jumps to the except part, and raises an HTTP exception?
> line 4
> line 5
B(happy): Right. An HTTP exception stops the function and sends the status code we choose.
> var status=503
B: Service unavailable tells the dashboard it is down, not that the data is empty.
M(cheer): So the dashboard shows service down, while no data means a real empty answer.

== trap | set=lab
WRONG: f"SELECT * FROM stations WHERE id = '{sid}'"
RIGHT: q("SELECT * FROM stations WHERE id = %s", (sid,))
M(shock): So I can put my station id straight into the quotes? That looks simple.
B: Never. A user could type SQL into that id and run their own question. Use a placeholder, and pass the value in a small group called a tuple.

== chain | set=lab
M(think): Let us follow one POST request through the parts. It arrives with a JSON body.
> 📥 : Request body
B: First stop is validation. FastAPI checks each field against your class before anything else.
> ✅ : Validation
M(think): And a bad field stops there? My function never sees it?
B: Yes. If a field is bad, FastAPI answers four twenty two, and your code never runs. Good input goes on.
> 🧠 : Your function
> 📤 : JSON reply

== table | set=room
HEAD: code | meaning | cause
ROW: 200 | OK | data found
ROW: 404 | Missing | unknown id
ROW: 422 | Bad input | wrong type
ROW: 503 | Down | db stopped
B(happy): Each status code tells the dashboard something different. Here is the honest table.
> rows 2,3
M(think): So 404 and 422 mean my request is wrong, and 503 means the server is in trouble?
B: Right. Four hundred codes mean the client must fix the request. Five hundred codes mean the server failed.
> rows 4
M(cheer): Got it. A client error is my fault to fix, and a server error is ours.

== versus | set=lab
LEFT: 🐢 : Load per request
RIGHT: ⚡ : Load at startup
M(think): Joblib reads a saved model back from disk. Should each route call it?
B: No. Reading the file takes time, so every request would pay that cost again.
> L : Reads the file every time
> L : Latency climbs under load
M(think): And if I load it once at startup?
> R : Loaded once, kept in memory
B(cheer): Yes. If the file is missing, the server fails at startup, not on every request.
> R : Fails fast if the file is missing

== quiz | set=class
Q: Which status code should a missing station return?
- 200 with an empty list
* 404 Not Found
- 500 with a traceback
- 422 Unprocessable Entity
M(think): An empty list with 200 would say the station exists, with no readings. The number must say not there.
B(cheer): Correct! Four oh four means the thing does not exist, so the dashboard knows exactly what happened.

== recap | set=city
B: Let us lock in what we learned.
> Status codes must tell the truth
M: Validation runs before your code, so bad input never reaches it.
> Pydantic checks the body first
B: Load the model once, at startup, then reuse it.
> Use plain def for database calls
M: Test each route with curl, then open the docs page.
> Test with curl and the docs page
B(cheer): Great work today, Mira! Your dashboard can now tell no data from service down.
