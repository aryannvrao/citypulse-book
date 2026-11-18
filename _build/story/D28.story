TITLE: Generative AI and LLM APIs
HOOK: Let an AI write, then check every number it wrote

== title | set=city
B(happy): Welcome to CityPulse! I am Bolt, and this is Mira, our newest engineer.
M(cheer): Today we ask an AI to write a bulletin for residents about the city air.
B: Our code will then check that bulletin. Let us see why that matters.

== talk | set=room
M(sad): Bolt, the AI wrote that AQI reached 180 today. But our data has no AQI at all!
> 📸 : Draft bulletin
B(think): AQI means air quality index, a score for how clean the air is. So that number is invented.
M(confused): Why would a computer invent a number?
B: A large language model, or LLM, writes text by guessing one piece at a time. It can sound right and still be wrong.
> 🤖 : LLM writes text
B(happy): So our code must check every number before a resident reads it.
> word : CHECK EVERY NUMBER

== same | set=lab
LEFT: 🔎 : Fact-checker
RIGHT: 🔢 : Number checker
M: A newspaper fact-checker circles every figure and asks where it came from.
B: Our code is the fact-checker. It compares every number in the text with the numbers we allowed.
M(happy): So the AI writes the sentences, and the code decides which numbers may pass.

== journey | set=sky
NODE: me : 💻 : Your program
NODE: api : 🌐 : LLM API
NODE: chk : 🔍 : Your checker
B: Your program calls an API, a defined way to ask a service for help. It sends the request over HTTPS, which is encrypted.
> hi api
> me>api : prompt and key
B: The API replies with the text and a count of tokens. A token is a small piece of a word, and you pay per token.
> api>me : text and usage
M(think): Then my program hands the text to the checker before anyone reads it.
> me>chk : candidate text

== code | set=lab
| def call_llm(prompt):
|     key = os.environ["LLM_API_KEY"]
|     client = anthropic.Anthropic(api_key=key)
|     msg = client.messages.create(
|         model=os.environ["LLM_MODEL"],
|         max_tokens=400,
|         temperature=0.2,
|         messages=[{"role": "user", "content": prompt}],
|     )
|     return msg.content[0].text
B: Here is the call wrapper. The key comes from an environment variable, not from the file.
> line 2
M(think): An environment variable is a named value my computer holds, so the secret never sits in the file.
> line 2
> var key=(secret)
B: The client sends one request. The model name is read from the environment too, so we can change it.
> line 3
> line 5
M(cheer): And temperature zero point two keeps the wording steady.
> line 7
B: Careful, though. Low temperature does not stop invented numbers. Only the checker can do that.
> line 10

== term | set=room
B(happy): Let us run it for real. Type python advisory dot py.
> $ python advisory.py
M(happy): It prints one advisory sentence.
> = Air quality is unhealthy for sensitive groups
> = in 24 tokens, out 31 tokens
M(cheer): Thirty one output tokens, so I can work out what each call costs.

== chain | set=city
B: Every bulletin takes four steps. First the stats come from our data, never from the model.
> 📝 : Stats from data
M(think): Then the model writes its reply as JSON, a tidy text format with named fields like headline and body.
> 🤖 : Model writes text
M(think): Then the number check reads every figure in that text.
> 🔍 : Number check
B(cheer): Only a bulletin that passes goes out. If the check fails, we serve a safe template.
> ✅ : Safe to publish

== trap | set=room
WRONG: api_key="sk-ant-123" typed in the code
RIGHT: read it from os.environ, and gitignore .env
M(shock): Oh no. I typed my API key straight into the file, then committed it!
B: The key is a secret that proves who you are and spends your money. Git stores every commit, so the key stays in the history.
B: Read the key from the environment, keep the dot env file out of Git, and replace any key that leaked.

== table | set=lab
HEAD: number | in data | verdict
ROW: 61.2 | yes | pass
ROW: 180 | no | fail
ROW: 24 | yes | pass
M(think): So the checker looks up each number in the data, one by one.
> rows 2
B: The 180 is not in the data, so this bulletin fails. The resident never sees it.
> rows 2
M(think): Then the safe template is served, and it uses only numbers from our own stats.
> reset

== quiz | set=class
Q: The bulletin says AQI reached 180, but the data has no AQI. What keeps the rule?
- Add the word accurate to the prompt
- Lower max tokens to 20
* Let the checker reject unknown numbers
- Trust the bulletin, since it reads well
M(think): Asking for accuracy is only a wish. A shorter reply can still invent numbers.
B(cheer): Correct! Only code can check the numbers, so the checker rejects the 180.

== recap | set=city
B: Let us lock in what we learned.
> The LLM writes text, not facts
M: Keep the API key in the environment, never in code.
> Key lives in the environment
B(cheer): Ask for JSON, check every number, and fall back to a safe template.
> Check every number in code
> Fall back to a template
