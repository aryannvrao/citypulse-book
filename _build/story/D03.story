TITLE: Day 3: Talking to APIs with curl and jq
HOOK: Fetch live air data, check it, and never leak a key

== title | set=city
B(happy): Welcome back to CityPulse! Today Mira learns how a program asks another computer for data.
M(cheer): Hi! Our air sensors publish readings online, and I must fetch them every half hour.
B: Then let us ask a web API the right way, with a status check and a safe key.

== talk | set=room
M(sad): Bolt, downloading the file by hand every half hour is boring, and I will forget.
> 📥 : Manual download
B(happy): So let a script do it. An API is a server built to be called by programs, like a menu.
> 📋 : API menu
M(think): But what if the server says no, or sends back an error page?
B: Then you must check the status before you trust anything. That is the golden rule today.
> word : CHECK STATUS FIRST

== same | set=lab
LEFT: 🍽️ : Restaurant order
RIGHT: 🌐 : HTTP request
M: So a status code is like the receipt, a three digit number that says if the order worked.
B: The body is the food. Only collect the food after the receipt says the order was fine.
M(happy): So 200 means take the food, and anything else means ask again or report it!

== term | set=server
B: Let us try it. A quick status check first, with the body thrown away.
> $ curl -s -o /dev/null -w '%{http_code}' "$URL"
> = 200
M(cheer): Two hundred! The receipt says the order worked.
> $ curl -s -o /dev/null -w '%{http_code}' "$BAD"
> = 404
B: Four oh four means the address does not exist. The body would be an error page, so we skip it.

== trap | set=room
WRONG: curl -s "$URL" | jq .current   (no status check)
RIGHT: check the status is 200 first, then parse
M(shock): I parsed the reply, and my script wrote garbage rows from an error page!
B: A classic trap. A 404 or 500 can still come with a body, so always check the status first.

== journey | set=sky
NODE: pc : 💻 : Your laptop
NODE: api : ☁️ : Air API
B: Your laptop sends a request. The air API sends back a status and a body.
> hi api
> pc>api : GET /v1/air
M(think): So GET asks for data, and it changes nothing on the server?
> api>pc : 200 and JSON
B: Right. GET only reads. POST would send data to be stored or processed.
M(happy): And the time stamp inside the body tells me when each reading was taken.

== code | set=lab
B(happy): Next, Python does the job that the jq select filter does. Watch which readings survive.
> line 1
> line 3
| readings = [{"pollutant": "PM2.5", "value": 42.1},
|             {"pollutant": "NO2", "value": 18.7}]
| pm25 = [
|     r["value"] for r in readings
|     if r["pollutant"] == "PM2.5"
| ]
| print(pm25)
M(think): So the if part keeps only the readings that pass the test, just like select.
> line 5
B: Right. The print line then shows the one value that survived.
> line 7
> out [42.1]
M(confused): Why is it in square brackets? It is only one number, after all.
B: Because the answer is a list, even when it holds a single value.

== term | set=room
M(think): Now the jq step. How do I turn one reading into a CSV row?
B: Pick the fields you need, and print them as CSV. Watch this short sample.
> $ jq -c '.readings[] | {pollutant, value}' payload.json
> = {"pollutant":"PM2.5","value":42.1}
> = {"pollutant":"NO2","value":18.7}
M(cheer): Nice, those are the rows I need for the file.
B(cheer): The raw output flag and the CSV filter quote the text for you.

== chain | set=city
B: Now the whole fetch script, as a chain of steps. Each block is one stage.
> 🌐 : Request sent
> 📥 : Body saved
> ✅ : Status checked
> 🧾 : CSV row added
M(happy): So the body is parsed only after the status check passes. I like that order!
B: Exactly. Save the body to a temp file, check the status, then write one row.

== quiz | set=class
Q: Which option sends the key in a header and keeps it out of the URL?
- curl "$URL?api_key=$KEY"
- curl -d "api_key=$KEY" "$URL"
* curl -H "X-API-Key: $KEY" "$URL"
- curl -o "$KEY" "$URL"
M(think): Hmm, the key should travel in a header line, not in the web address itself.
B(cheer): Correct! Web addresses end up in logs and history, so keys belong in headers.

== recap | set=city
B: Let us lock in what we learned.
> Check the status before the body
M: A web API is a menu, and HTTP is the ordering rule.
> HTTP request, status, body
B: Set a time limit so a stuck server cannot hang your script.
> Always set a time limit
M: Keep API keys in the dot env file, never in the script.
> Keys in .env, chmod 600
B(cheer): Great work today, Mira! Your fetch runs every half hour now.
