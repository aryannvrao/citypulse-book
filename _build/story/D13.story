TITLE: Object storage with S3 and boto3
HOOK: Store files safely and find one day fast

== title | set=city
B(happy): Welcome back to CityPulse! I am Bolt, and Mira is uploading today's air quality data.
M(cheer): Hi! I need a safe place for it, where the whole team can find one day quickly.
B: Our answer is S3, Amazon's file storage. It keeps files as objects inside buckets, which are named containers.

== talk | set=room
M(sad): My file went up, but a friend found it on the internet. Oh no!
> 🌍 : Public on the web
B(think): A bucket must stay private, so only trusted accounts can read it.
M: How do I check that it is really private?
B(happy): Turn on Block Public Access. It is a set of four switches that overrides any public setting.
> 🔒 : Four switches on
B: Then turn on encryption, which scrambles stored files, and versioning, which keeps old copies.
> word : PRIVATE BY DEFAULT

== same | set=lab
LEFT: 📦 : Box on a shelf
RIGHT: 🏷️ : Object key
M(think): In a warehouse, every box has a shelf label. That is my key, right?
B: Exactly. The bucket is the warehouse, and the key is the full name printed on each box.
M(happy): So the key holds the whole name, including the date.
B: Yes. S3 has no real folders. The slashes only look like folders.

== chain | set=city
B: Each upload moves through three steps. First, the script builds the key from the date.
> 🧮 : Build the key
B: Then boto3 sends the bytes to S3 with put object. boto3 is the Python library for AWS.
> 📤 : Upload bytes
B: Finally S3 stores the object and replies with success, or with an error code.
> ✅ : Stored or refused
M(think): Build, send, then check the reply. The reply is the part I must never ignore.

== code | set=room
| import datetime
| day = datetime.date.fromisoformat("2026-12-17")
| key = f"clean/aqi/date={day}/aq.parquet"
| print(key)
M(think): Show me the key builder, Bolt. I want to see how the date is handled.
B: Line one loads the datetime module, which does the date work.
> line 1
B: Line two turns the text into a real date. A bad date text raises an error here.
> line 2
> var day=2026-12-17
M(happy): Then line three builds the key, with the date in the middle.
> line 3
B: Line four prints it. Year, then month, then day, so the keys sort in calendar order.
> line 4
> out clean/aqi/date=2026-12-17/aq.parquet

== trap | set=city
WRONG: clean/aqi/date=17-12-2026/aq.parquet
RIGHT: clean/aqi/date=2026-12-17/aq.parquet
M(shock): Oh no, I typed the day first. That still looks like a date, so it must be fine.
B: A classic trap. Text sorts by its first characters, so the days and years get mixed up.
M(cheer): So always year, month, then day. Got it!

== journey | set=sky
NODE: pl : 🤖 : Upload script
NODE: iam : 🔐 : IAM check
NODE: s3 : 🗄️ : S3 bucket
B: The script sends each file to the bucket, but IAM checks the request first.
> hi pl
M: So the request goes to IAM before it reaches the bucket?
> pl>iam : signed request
B: Right. Only an allowed call goes on to S3.
> iam>s3 : allowed call
B: A refused call comes back as an error, and the script must report it.
> iam>pl : AccessDenied

== term | set=room
M(think): Let me try a real upload. Which command runs it?
B: We run the upload module in Python, with the file and the date.
> $ python -m citypulse.upload \
> =     --src a.csv --dataset aqi --date 2026-12-17
> = uploaded clean/aqi/date=2026-12-17/a.csv
M(happy): It says uploaded, with the key I expected. Nice!
B: Check the exit code with the echo command. Zero means success.
> $ echo $?
> = 0

== table | set=lab
HEAD: Day | Objects | Status
ROW: 2026-12-17 | 1 | uploaded
ROW: 2026-12-18 | 1 | uploaded
ROW: 2026-12-19 | 0 | missing
B: Here is the listing for three days. A prefix returns only the keys for one day.
> rows 1,2
M(think): So if I ask only for December 18, I get one row back?
> keep 2
B(cheer): Exactly, that is partitioning. The listing reads one day and skips the others.
> reset
M: Ask by prefix, and the cost stays small.

== talk | set=night
M(sad): What if the upload fails, but the script still says uploaded? That would be awful.
> ❌ : Silent failure
B(think): That is the second trap. Catch only the error AWS raises, print it, and return exit code one.
B(happy): Then a failed upload tells the shell about the problem, and the team sees it at once.
M: So a broad except that just passes would hide every error?
B: Yes, never do that. Catch the ClientError, and let real bugs show.
> clear

== quiz | set=class
Q: After AWS refuses an upload, which exit code should the script return?
- Zero, because the script finished
* One, to report the failure
- Ten, a random error number
- Nothing, the shell ignores it
M(think): Zero means success, so a failure must be a different number.
B(cheer): Right! One is the usual failure code.

== recap | set=room
B: Let us lock in what we learned.
> Private bucket, encrypted, versioned
M: Keys use year, month, day, so they sort by date.
> Date keys: YYYY-MM-DD
B: boto3 uploads, but never hard-code secret keys.
> Credentials come from the chain
M: Versioning keeps the old copy when a file changes.
> Versioning protects overwrites
B(cheer): Catch the error, return one, and show it. Great work, Mira!
> Errors must never pass silently
