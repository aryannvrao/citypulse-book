TITLE: Cloud fundamentals and IAM on AWS
HOOK: Give every program only the doors it needs

== title | set=city
B(happy): Welcome to CityPulse! I am Bolt, and this is Mira, our newest engineer.
M(cheer): Hi! Today our air quality data moves into the cloud, so I must keep it safe.
B: Our goal is simple. Each program gets only the doors it needs, and nothing more.

== talk | set=room
M(sad): Bolt, my upload script worked, but I used the admin key. Now the whole account is exposed.
> 💥 : Admin key
B(think): That is a classic risk. An admin key opens every door, so one leak lets anyone in.
M: So how do I give my script just one door?
B(happy): With IAM. That means identity and access management, the key card system of the cloud.
> word : LEAST PRIVILEGE

== same | set=lab
LEFT: 🏨 : Hotel room key
RIGHT: 🔐 : IAM permission
M(happy): My hotel card opens my room and the gym, but not the manager's office.
B: IAM works the same way. A policy is a written list of doors, and every other door stays locked.
M(think): So a card that opens everything is a master key. That is dangerous.
B: Exactly. Give the smallest set of doors the job needs. That is least privilege.

== chain | set=city
B: Every request passes through IAM before it reaches the bucket. Here is the decision, in order.
> 👤 : Who is calling
B: First, IAM finds out who is calling: a user, or a role, which is an identity borrowed for a while.
> 📜 : Read the policies
B: Next it reads every policy attached to that identity.
> ⛔ : Deny wins
M(confused): Wait, does a deny beat an allow?
B(cheer): Yes! A deny always wins.
> ✅ : Allow needed
B: With no allow at all, the answer is no. That is denied by default.

== code | set=room
| def is_allowed(rules, action, path):
|     allowed = False
|     for rule in rules:
|         if not rule_applies(rule, action, path):
|             continue
|         if rule["effect"] == "Deny":
|             return False
|         if rule["effect"] == "Allow":
|             allowed = True
|     return allowed
M(think): Can you show me the decision loop in code, Bolt?
B: Here is the loop from the lab. It reads the rules one at a time.
> line 2
> var allowed=False
> line 3
B: A rule that does not match this request is skipped, so the loop moves on.
> line 4
> line 5
B: A matching deny returns no at once. That beats everything else.
> line 6
> line 7
M(happy): And a matching allow only sets a flag to true.
> line 8
> line 9
> var allowed=True
B: But a later deny can still win, because the loop keeps going.
> line 6
> line 7
B: If the loop ends without a deny, the final answer is whatever the flag holds.
> line 10

== trap | set=city
WRONG: s3:* on every bucket, to save time
RIGHT: s3:PutObject on one bucket prefix
M(shock): Oh no, I almost gave my script every action on every bucket, to save time!
B: A classic trap. Every action on every bucket means one leak reaches all of your data.
B: Name each action, and scope each resource to one bucket prefix instead. Much safer.

== versus | set=lab
LEFT: 🔑 : Admin user
RIGHT: 🤖 : Pipeline user
M(think): Who should run the CityPulse upload, the admin or the pipeline?
> L : Changes billing and everything
> R : Writes only two folders
B: The pipeline, of course. It is the program that moves the data, and it is limited on purpose.
> R : Cannot change billing
B: The admin is for setup only. Daily work belongs to the limited user.
> L : Setup and account changes only
M(happy): So a leaked pipeline key can only do a little damage.

== term | set=room
M(think): Before I run anything, I check which identity my terminal is using.
B: Good habit. Ask AWS who you are, with the get caller identity command.
> $ aws sts get-caller-identity
> = Arn ends in :user/citypulse-pipeline
M(happy): It says citypulse-pipeline, the scoped user. Not admin, and not root.
B: If it ends in root, stop at once, because root can do anything.

== table | set=lab
HEAD: Test | Expected | Result
ROW: Write raw | allow | PASS
ROW: Write secret | deny | PASS
ROW: Delete object | deny | PASS
ROW: List users | deny | PASS
B: We test both directions. Allowed calls must work, and forbidden calls must be refused.
> rows 2,3,4
M(think): So a policy that only shows its allows is not really tested?
B(cheer): Correct! The denials are the proof. Examiners ask about them in every oral exam.
> col 3
M: Four checks, and every line says PASS.

== journey | set=sky
NODE: pl : 🤖 : Upload script
NODE: iam : 🔐 : IAM check
NODE: s3 : 🗄️ : S3 bucket
B: S3 is cloud file storage, and a bucket is a named container for files. Every call starts at the script.
> hi pl
M: So the request goes to IAM first?
> pl>iam : signed request
B: Right. Signed means it carries proof of who is asking. Only an allowed call goes on to S3.
> iam>s3 : allowed call
B: If IAM says no, the request stops there, and the bucket never receives it.
> iam>pl : AccessDenied

== quiz | set=class
Q: Which mechanism gives a script temporary credentials instead of a permanent secret?
- Hard-coding an admin key
* Assume a role for short-lived keys
- Storing the root password in a file
- A permanent access key never rotated
M(think): A permanent key is a long-lived secret. If it leaks, it keeps working for ever.
B(cheer): Right! A role hands out credentials that expire by themselves.

== talk | set=night
M(sad): Bolt, what if I forget a running server? I could get a huge bill.
> 💸 : Surprise bill
B(happy): That is what a budget is for. It is a spending limit, and AWS emails you when you pass a percentage of it.
> 📧 : Email alert
M(think): So the budget stops the spending automatically?
B: No. It only alerts you, so you must stop or delete the resources yourself.
> 🛑 : You stop it
M(cheer): Then I set alerts at 80 percent and 100 percent. Smart.

== recap | set=room
B: Let us lock in what we learned.
> Admin key opens everything
M: Least privilege means only the doors the job needs.
> Name each action, scope each resource
B: A deny always beats an allow.
> Deny beats Allow
M: Test the denials, not only the allows.
> Denials prove the policy
B(cheer): A budget only alerts, so you stop the spending. Great work, Mira!
> Budgets alert, they do not stop
