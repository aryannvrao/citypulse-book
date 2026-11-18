TITLE: Capstone tickets T01 to T03
HOOK: Three real tickets and how your trainer checks each

== title | set=city
B(happy): Welcome back to CityPulse! I am Bolt, and Mira's squad is about to start its first capstone tickets, the real jobs for the final project.
M(cheer): Three tickets on a real board. A trainer marks each one, so I want to know exactly what gets checked.
B(happy): Good plan. We will cover T01, T02 and T03, and the test each one must pass.

== talk | set=room
M(sad): Bolt, last term a teammate did great work, but the trainer never counted it.
> 📸 : Wrong account
B(think): Work counts only when it is committed from your own account. Each commit is a saved snapshot, tied to the person who made it.
M(think): So the account matters as much as the code?
B(happy): Yes. Each ticket is judged from GitHub evidence, and each piece of evidence names its author.

== journey | set=sky
NODE: you : 🙂 : You
NODE: gh : ☁️ : GitHub
NODE: org : 🏢 : Org citypulse-y2
B: Ticket T01 is onboarding. GitHub is the website that holds the team's code, so your account must be ready first.
> hi you
M(think): Ready means what, exactly?
> you>gh : real name, photo
B: Your full real name and a photo, plus two-factor login. That means a second code from your phone, not just a password.
> you>gh : two-factor code
M(happy): Then I accept the invite to the course organisation, the group account that holds every squad repository.
> gh>org : invite accepted
B: Then a lab check and the T0 baseline, a first test that measures where you start. Tell your trainer early if anything fails.
> hi org

== table | set=class
HEAD: source | code | first byte
ROW: Source A | 200 | {
ROW: Source B | 200 | <
ROW: Source C | 404 | <
ROW: Source D | 000 | none
B: Ticket T02 is squad forming. Your squad shortlists two data sources, and each must answer with real JSON.
M(think): JSON is a text format for data. What does a JSON answer look like?
B(happy): It starts with a curly bracket or a square bracket. A web page starts with a less than sign.
> rows 1
M(shock): Source B printed 200, yet its first byte is the start of a web page!
> rows 2
B: The status code, such as 200, is the server's reply number. It does not prove the data is JSON.
> col 3
M(think): And 000 means no answer at all within fifteen seconds.
> rows 4
B(cheer): The trainer checks the code, the first byte and a field path. Source A passes.
> rows 1

== versus | set=city
LEFT: 🌐 : HTML web page
RIGHT: 📦 : JSON data
M(think): Why does a web page fail, when it opens fine in my browser?
B: Your browser draws HTML for people to look at. A program needs data it can read.
> L : Built for people to look at
M(happy): JSON is built for programs. Each value sits in a named field.
> R : Built for programs to read
B: A field path is the route to one value. The trainer's jq tool, which reads JSON, uses one to prove the field exists.
> R : Route to one value
> L : Hard for a program to read

== trap | set=lab
WRONG: curl prints 200, so the source is fine
RIGHT: Check 200, then the first byte: { or [
M(shock): Source B printed 200, so I wrote it down as fine. Looks finished, right?
B: A classic trap. A status code alone can hide an HTML page, and that fails the ticket.
B(cheer): Read the first byte too, then run the field path test. Only then is the source really fine.

== graph | set=room
NODE: m1 : main : 0,2
NODE: m2 : main : 1,2
NODE: b1 : branch : 2,1
NODE: b2 : branch : 3,1
NODE: m3 : merge : 4,2
EDGE: m1-m2
EDGE: m2-b1
EDGE: b1-b2
EDGE: b2-m3
EDGE: m2-m3
B: For ticket T03, your work reaches main only through your own branch. A branch is a safe side road.
> hi m1,m2
M(think): So I work on a branch, then open a pull request for a squad-mate to check?
> hi b1,b2
B: Yes. A pull request is a request to merge, with a page where others review it. A squad-mate approves, and you never merge your own.
> note pull request: squad-mate approves
> done b1,b2
M(happy): Then the merge joins my commits to main, and each commit keeps my name as author.
> hi m3
> note merge: commits join main

== term | set=server
B: Ticket T03 asks for a repository, the project folder on GitHub, and a signed charter, the squad's agreement. The trainer counts its authors.
> $ git log --format='%an <%ae>' -- CHARTER.md | sort -u | wc -l
> = 5
M(think): Five different names, so five people signed. Each name comes from a commit.
B: Right. A count of one means everyone committed from one identity, and that fails.
M(cheer): So each of us commits our own signature line, from our own laptop.
B: Exactly. The metric line in the charter also needs a number, a unit and a date.

== same | set=night
LEFT: 🚪 : Bouncer's banned list
RIGHT: 🔍 : grep -x check
M(think): The trainer's check prints nothing when I pass. How can silence mean success?
B: Picture a club bouncer with a banned list. The grep tool works like that: it only prints a name it finds on the list.
M(happy): So silence means my name is not on the list. That is the good result!
B: Right. A printed login means a failure. Its exit status, the returned number, is one when nothing matched.

== quiz | set=class
Q: The check prints nothing, then the exit status is 1. What does that mean?
- Login is listed, so the check failed
- Your invitation is still pending
* Login not listed, so this test passed
- Two-factor login is off
M(think): Nothing printed, then a one. Silence sounds like trouble to me.
M(think): But silence also means no match, and no match is what we want.
B(cheer): Correct. Exit status one means no match, so your login is not listed, and that test passed.

== recap | set=lab
B: Let us lock in the three tickets and their checks.
> Onboarding: two-factor and org invite
M: Read the status code, then the first byte, before you trust a URL.
> Status code and first byte, both
B: Work counts from your own commits, merged after review.
> Own commits, merged by review
M: And silence from a grep check is a pass.
> Empty output from grep means pass
B(cheer): Great work, Mira! Run every test case yourself before you ask for review.
> Run every test case yourself
