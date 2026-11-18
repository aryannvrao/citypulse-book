TITLE: Capstone tickets T17 to T19
HOOK: Three real tickets, and how the trainer checks them

== title | set=city
B(happy): Welcome to CityPulse! I am Bolt, and this is Mira, our newest engineer.
M(cheer): Today my squad starts three capstone tickets. They cover cloud access, storage and a server.
B: A trainer marks each ticket by running its tests and reading your commits.

== talk | set=room
M(sad): Bolt, the tickets are long, and I do not really know what they ask.
> 📋 : Ticket board
B(happy): Let us go through them in plain words. Every commit you make is a saved snapshot of your code.
B: Only a trainer can move a ticket to done, after running its test cases.

== chain | set=lab
B: Every ticket travels along the board, left to right. It starts in the backlog.
> 📋 : Backlog
B: Next comes to do, then in progress, then review, where a squad-mate reads your work.
> 📝 : To do
> 🔧 : In progress
> 👀 : Review
M(think): And who decides it is finished?
B: The trainer. They run the test cases, give a gate score from zero to three, and then move it to done.
> ✅ : Done

== term | set=lab
B: Ticket T17 makes a separate cloud user for the pipeline. It may touch one storage box, and nothing else.
M(confused): So how does the trainer check that it is safe?
B: First, a search for wildcards. A wildcard is a star that allows everything, and it is forbidden.
> $ grep -rnE '"(\*|s3:\*)"' infra/iam/
> $ echo $?
> = 1
B: Every command returns a number when it ends. One means the search found nothing. Silence is the pass here.
M(think): Then the six tests, run as the pipeline user. Six lines must all say PASS.
> $ bash infra/iam/test_access.sh citypulse-asha-3m9x
> = PASS allow: aws s3 cp /tmp/probe.txt ...
> = PASS allow: aws s3 ls s3://citypulse-asha-3m9x/raw/
B: Two actions must be allowed. Four must be refused with access denied.
> = PASS deny: aws s3 cp /tmp/probe.txt ... secret/
> = PASS deny: aws s3api delete-object ...
M(happy): That is two allowed and four denied. Good.
> = PASS deny: aws s3 ls
> = PASS deny: aws iam list-users

== same | set=room
LEFT: 🏨 : Hotel key card
RIGHT: 📜 : IAM policy
M(think): Policies sound scary. What is the simplest way to picture one?
B(happy): A key card opens your room and the gym, but never the manager's office. A policy is a list of rules that works the same way.
M: So each rule names one action and the exact place it may touch.
B: Yes. The pipeline rule names one storage box and one folder, and nothing more.

== code | set=lab
| def double(x):
|     return x * 2
| def test_double():
|     assert double(3) == 6
B: Ticket T18 uploads clean data to a private storage box. The trainer checks it with pytest, a Python test runner.
M(confused): Tests in Python? I thought a test was just a list of expected answers.
B: Close. A test is a function whose name starts with test, and assert asks a question that must be true.
> line 3
> line 4
B: This tiny example sits outside the real project. The function double multiplies by two, so double of three is six.
> line 2
> var x=3
B: If the answer is false, the test fails. Passing prints a short summary, like this.
> out 1 passed in 0.01s
M(happy): So the upload key must follow a fixed pattern too?
B: Yes. Clean, then the dataset, then the date written year first. Tests like this never call the cloud.

== journey | set=sky
NODE: pc : 💻 : Your laptop
NODE: vm : 🌐 : Cloud VM
NODE: s3 : 📦 : Storage box
B: Ticket T19 moves the pipeline off your laptop, onto a cloud VM. A VM is a computer rented over the internet.
M(think): So my laptop can sleep, and the data still arrives?
B: Yes. A scheduler called cron starts the job on a timetable, and the trainer wants two runs at least thirty minutes apart.
> hi vm
M: Who may log in to the server?
B: Only your own SSH key. SSH is a secure remote login, and a password login must be refused.
> pc>vm : ssh with key
B: The firewall, a gatekeeper for network doors, admits only your own single address. No stored keys sit on the server; it borrows temporary permission through a role.
> hi vm
B: Each cron run uploads a file to the storage box, and the trainer checks the timestamps match.
> vm>s3 : cron upload
M(happy): So the trainer checks the logs, the bucket, and one refused password.

== trap | set=room
WRONG: test run while the admin profile is still set
RIGHT: check the identity name is the pipeline user first
M(shock): The six tests all said PASS! I am finished, right?
B: Not yet. If your terminal is still signed in as the admin, every test passes and proves nothing.
B: Run the identity check first. The name at the end must be the pipeline user, not your admin.

== quiz | set=room
Q: Your six tests print PASS. Before you trust them, what must you check first?
- Nothing, PASS means the policy is correct
* Your identity is citypulse-pipeline
- The README has a table with three columns
- The bucket is empty
M(think): Six PASS lines look perfect, but they only mean something if the test ran as the pipeline user.
B(cheer): Correct! Check the identity first, then trust the PASS lines.

== recap | set=city
B(happy): Let us lock in what we learned.
> Trainer runs tests and reads your commits
M: Ticket T17 is a scoped pipeline user, checked by a wildcard search and six tests.
> Pipeline user, one bucket, no wildcards
B: Ticket T18 is private storage, with date folders, kept versions and pytest checks.
> Private bucket, dated keys, old versions kept
M: Ticket T19 is a cloud VM with a role, and SSH by key only.
> VM with a role, SSH key only
B(cheer): Before any PASS, check who you are. Great work today, Mira!
> Check identity before trusting PASS
