TITLE: Delivering an industry project
HOOK: Ship it, explain it, keep it alive

== title | set=city
B(happy): Welcome to CityPulse! I am Bolt, and this is Mira, our newest engineer.
M(cheer): Hi everyone! Our air model works, but the client cannot use it yet. Today we fix that.
B: Delivery means someone who did not write the code can run it, explain it and keep it alive.

== talk | set=room
M(sad): Bolt, my to-do list has forty items, and the client wants all of them by Friday.
> 📋 : Forty tasks
B(think): Then you need MoSCoW. It sorts every item into Must, Should, Could or Won't.
> 🏷️ : MoSCoW
M(confused): Why would I ever say Won't to a client?
B: Because a list where everything is urgent means nothing ships on time.
> clear

== same | set=server
LEFT: 🧳 : Packing for a trip
RIGHT: 📋 : MoSCoW list
M: When I pack for a trip, the passport goes in first. Nothing else matters if I forget it.
B: A Must is the passport. The product fails without it, so it goes in the bag first.
M(happy): And the phone charger is a Should. I can travel without it, but life is harder.

== versus | set=night
LEFT: ✅ : Must have
RIGHT: 🚫 : Won't have
B: A Must is an item the product cannot ship without. Too many Musts means the list was never sorted.
> L : Product fails without it
> L : Five or fewer per project
M(think): And a Won't? Does it just disappear?
> R : Written down with a reason
> R : Can be pointed at later

== code | set=lab
| remaining = 3
| selected = []
| for effort in [2, 3, 1]:
|     if effort <= remaining:
|         selected.append(effort)
|         remaining -= effort
B: A sprint has a capacity, the number of story points the team can take on. Here it is three.
> line 1
> var remaining=3
> line 3
> var effort=2
M(think): So the loop takes the first item, which costs two. Does it fit in three?
> line 4
B(cheer): Yes! So it is added, and the free space drops to one.
> line 5
> var selected=[2]
> line 6
> var remaining=1
M: Next item costs three. Three does not fit in one, right?
> line 3
> var effort=3
> line 4
B: Right. It is skipped, and the loop keeps going to the smaller items.

== trap | set=room
WRONG: Accept every extra request in chat
RIGHT: Log it as Won't, with a reason
M(shock): The client sent three new features in one message, and I said yes to all of them.
B: A classic trap. Each yes adds work, and nothing is removed from the sprint, so the deadline slips.
M(sad): So the fix is to write each one down, and decide what it pushes out.

== chain | set=city
B: Shipping a release is a chain. Each step must pass before the next one starts.
> 🧪 : Run tests
M(think): So a failing test stops everything before the tag even exists?
> 🏷️ : Tag version one
B: Yes. Then the image is built, and only after that is it pushed.
> 🐳 : Build image
> 🚀 : Push to team

== term | set=lab
B: Here is the tag. It is a permanent name for one exact commit.
> $ git tag -a v1.0.0 -m "CityPulse version one"
M(think): It stays only on my laptop until I push it, right?
> $ git push origin v1.0.0
> = * [new tag]  v1.0.0 -> v1.0.0
B(cheer): Exactly. Now the whole team can see the tag on GitHub.

== journey | set=sky
NODE: pc : 💻 : Your laptop
NODE: gh : ☁️ : GitHub
NODE: mate : 🙂 : Teammate
B: GitHub keeps a copy of the project online, so the team has one place to meet.
> hi gh
M: So my laptop sends the tagged code up to GitHub.
> pc>gh : git push
B: And a teammate copies it down with git clone, using the exact tag.
> gh>mate : git clone
M(happy): Now a stranger can rebuild exactly what we tested.

== table | set=room
HEAD: Module | Authors | Owners
ROW: api | 1 | Risk
ROW: ui | 3 | Safe
ROW: tests | 2 | Safe
B: Bus factor counts the distinct people who can maintain a module. One author means one risk.
M(confused): Does a module with two hundred commits from one person still count as one?
> rows 1
B: Yes, commit count is not the test. A second person must be able to explain and run it.
> col 3
M: So I give the api folder a second owner, someone who did not write it.
> reset

== quiz | set=class
Q: Halfway through a sprint, a stakeholder asks for a new export. What first?
- Add it at once, because the client asked
- Leave it out and never write it down
- Work weekends to fit it in
* Record it and agree what it displaces
M(think): Adding it at once hides the cost, and weekend work avoids the choice. So it must be the recording one.
B(cheer): Correct! Every change is written down, costed and traded against the plan.

== recap | set=city
B: Let us lock in what we learned.
> Must means the product fails without it
M: And the work order is clear.
> Cap the Musts, log every Won't
B: Build thin slices, and test before you tag.
> Tag and push so the team can see it
M(cheer): Keep a handover, so a stranger can run it.
> Second owner for every module
B(cheer): Great work today, Mira!
> Write what you ran, so it can run again
