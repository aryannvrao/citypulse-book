TITLE: Capstone tickets T23 to T25
HOOK: Three tickets, three trainer checks, no surprise bills

== title | set=city
B(happy): Welcome to CityPulse! I am Bolt, and this is Mira, our newest engineer.
M(cheer): Hi everyone! My squad is about to start three capstone tickets, numbers twenty three to twenty five.
B: Each ticket has points, and a trainer checks it by running real test cases.

== talk | set=room
M(think): Bolt, how does the trainer know my work is really mine?
B(happy): Every ticket is judged from commit evidence. Your commits and pull requests, which are merge proposals a squad-mate reviews, are the proof.
M: So work on a friend's laptop does not count for me?
B: Correct. Only a trainer can move a ticket to Done, after running its test cases.
> word : NO COMMIT NO CREDIT

== term | set=server
B: Ticket twenty three moves the fetch job into a Lambda function. Lambda runs code only when something calls it.
M(think): So a timer calls it every thirty minutes, and I only pay for those runs?
B: Yes. The trainer counts the log lines that say wrote S3 and a bucket address. A bucket is a container in S3, Amazon's file storage. The count must be at least two.
> $ grep -c 'wrote s3://' T23-logs.txt
> = 2
M(happy): Two scheduled runs, so the timer works. Next, the schedule itself.
> $ aws scheduler get-schedule --name citypulse-fetch-30m
> = {"s": "rate(30 minutes)", "st": "ENABLED"}
B: Good. The schedule must run every thirty minutes, or be switched off.

== code | set=lab
B(think): Now a technique. The file name comes from the time, so each run gets its own name. strftime turns a date into text.
M: So it is like a label made from a clock? H means hour, and M means minute.
B: Yes. Two runs in the same minute write the same name, which is fine, because the new copy replaces the old one.
| from datetime import datetime
| now = datetime(2027, 1, 12, 9, 0)
| key = now.strftime("fetch_%H%M.json")
| print(key)
> line 2
> var now=2027-01-12T09:00
> line 3
> var key=fetch_0900.json
M(think): So the name is fetch, then the hour, then the minute.
B: Right. Then line four prints it.
> line 4
> out fetch_0900.json

== same | set=room
LEFT: 🏨 : Hotel key card
RIGHT: 🔐 : IAM role
M(think): Bolt, why does the function not need a password?
B(happy): A hotel key card opens only your room, and it stops working at checkout. An IAM role, from the AWS system that controls who may do what, is the same idea.
M(cheer): So a copied house key works forever, but a card expires. That is the safer one!
B: Exactly. AWS gives the role short term permissions, so no access key sits inside the function.

== chain | set=class
B: Ticket twenty four is about tidy teardown, plus a diagram and a notebook. A dry run prints every delete without making any.
M(think): So the order matters, because some things cannot go while others still use them?
B: Yes. Stop the trigger first, so nothing starts a new run while you remove things.
> 🗓️ : Schedule
M: Then the function, then the virtual machines, then the bucket.
> ⚡ : Function
> 💻 : Virtual machines
> 🪣 : Bucket
B: Roles go last, because a role cannot be deleted while a policy is still attached to it.
> 🔑 : Roles
M(happy): The trainer reads the dry run, checks each name is mine, and shellcheck, a script checker, must print nothing.

== versus | set=sky
LEFT: 🔐 : Scoped identity
RIGHT: 🌍 : Anonymous visitor
B: Ticket twenty five is the defence. The trainer proves your locks by trying to break them.
M(think): How does a refused request prove a lock works?
> L : Secret prefix write is AccessDenied
> R : A private file gives 403 to strangers
B: AccessDenied means AWS refused the action. A 403 is the web code for forbidden. A 200 would mean the public can read it, the case study mistake.
> L : The profile names who is asking
> R : Never 200 for a private object
M(happy): So AccessDenied and 403 are good news, not errors!

== trap | set=lab
WRONG: Delete the key line in a new commit
RIGHT: Deactivate the key in AWS, then make a new one outside Git
M(shock): I removed my leaked key in a new commit, so it is safe now, right?
B: A classic trap. Git keeps every older commit, so the key can still be read. Switch the key off in AWS, then make a new one outside Git.
M(think): So hiding it is never enough. I must deactivate it first.

== quiz | set=room
Q: Which step stops a leaked key from working, even though Git keeps it?
- Commit a file that removes the key
- Run git push to the main branch
* Deactivate the key in AWS IAM
- Run the teardown script
M(think): Removing a line in a new commit leaves the old one in history. Pushing does not change the key.
M(think): The teardown script deletes resources, not old keys. So the key must be switched off in AWS.
B(cheer): Correct! Deactivate it in AWS, then make a new key. Great thinking, Mira.

== recap | set=city
B: Let us lock in what we learned.
> Ticket 23: scheduled function, proven by logs
M: The trainer's logs and counts are the proof, so keep your own evidence.
> Ticket 24: dry run first, delete in order
B: And a role needs no stored password, because it hands out short term permissions.
> Ticket 25: prove locks by refused requests
M: If a key leaks, switch it off first, then make a new one.
> Never delete a leaked key: deactivate it
B(cheer): Great work, Mira! Your own commits are the evidence, so commit as you go.
> Your own commits are the evidence
