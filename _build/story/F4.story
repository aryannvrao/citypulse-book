TITLE: Beating hidden tests before you submit
HOOK: Check the awkward inputs before the first press

== title | set=city
B(happy): Welcome back to CityPulse! I am Bolt, and this is Mira, who is about to submit her first lab.
M(cheer): I passed every example the platform showed me. Surely that means I am finished!
B: Not quite. Today we learn to find the inputs that break your code, before the marker does.

== talk | set=room
M(sad): Bolt, my result came back. The examples passed, but I lost a third of the marks.
> 📉 : Marks lost
B: Those lost marks came from hidden tests. They use awkward inputs that the course team chose on purpose.
> 🔒 : Hidden tests
M(think): So the examples only show the shape of the answer, not the traps?
B: Exactly. Visible tests carry about half or more of the marks, and hidden tests carry the rest.

== same | set=lab
LEFT: 🌞 : Sunny day test
RIGHT: 🌊 : Flood test on a bridge
M(confused): A bridge that stands in sunshine is not proven safe. Does the same apply to code?
B: Yes. Your examples are the sunny day test. Edge cases are the flood test, the unusual inputs.
M(happy): So I must test the empty list and the storm, not only the nice readings!

== chain | set=lab
B: Here is the routine every student should follow. Step one is reading the statement carefully.
> 📖 : Read the statement
B: Step two lists the edge cases, then step three writes asserts before any code.
> 🧪 : List edge cases
> 📝 : Write asserts
M(think): Step four writes the function and runs the asserts. Step five checks the speed, then I submit.
> 🔧 : Write the function
> ⚡ : Check speed
> 📤 : Submit

== code | set=lab
| seen = set()
| for item in [1, 2, 1]:
| if item in seen:
| print("duplicate")
| seen.add(item)

M(think): Let us trace it. We start with an empty set, which means nothing seen yet.
> line 1
> var seen=set()
B: The loop takes item one. It is not in the set yet, so we add it.
> line 2
> var item=1
> line 5
> var seen={1}
M(confused): Then item two is new too, so it joins the set. Then one comes back.
> line 2
> var item=2
> line 5
> var seen={1, 2}
B: Yes. Line three finds one already there, so line four reports a duplicate.
> var item=1
> line 3
> line 4
> out duplicate

== trap | set=room
WRONG: return sum(values) / len(values) with no check
RIGHT: if not values: return None, before dividing
M(shock): My average crashed with ZeroDivisionError on an empty list. The examples never had one!
B: A classic trap. Dividing by zero is not allowed, so the guard must come before the division.
M(think): So the guard returns None, which is what the statement asks for.

== term | set=room
B: Let us run a check that fails. The file is stations dot py. Run it with python.
> $ python stations.py
> = Traceback (most recent call last):
> = File "stations.py", line 12
> = AssertionError
M(sad): Oh no. Which check failed?
B(cheer): The traceback names line twelve. Read that line, then ask what the function returned.

== bars | set=night
BAR: Nested loop : 10000
BAR: One loop : 100
BAR: Set lookup : 100
M(think): Here is the speed problem. How many steps for a list of one hundred items?
B: A loop inside a loop does one hundred times one hundred steps. That is ten thousand steps.
> hi 1
M(happy): A single loop with a set needs only about one hundred steps. Much faster on big hidden tests!
> hi 3

== table | set=city
HEAD: input | edge case | returns
ROW: [] | empty | None
ROW: [5] | one item | 5.0
ROW: [1, 1, 2] | rounding | 1.3
B: Each edge case gets a row. Decide what the statement wants before you write any code.
> rows 1
M(think): The empty list returns None, as the statement says. Next, one item.
> rows 2
B: A single item still returns a float, five point zero. Then the rounding row, one point three.
> rows 3
> col 3

== versus | set=lab
LEFT: 👀 : Visible tests
RIGHT: 🔒 : Hidden tests
B: Visible tests show you the shape of the answer, and you can read every one of them.
> L : You can read every input
M(think): And hidden tests?
> R : Inputs chosen to break you
B: They are the awkward cases the course team picked on purpose. They carry the rest of the marks.
> R : Carry the rest of the marks

== quiz | set=class
Q: Your function passes every visible test. What is the right next step?
- Submit now, the visible tests passed
- Submit, then fix it until the score rises
* Write edge-case asserts, then submit
- Delete the visible tests to save time
M(think): Passing the examples feels like finishing. But the first attempt is the one that counts.
M(think): Retrying does not replace the first attempt in the skill score, so one more submit is risky.
B(cheer): The answer is the edge-case asserts. Check the awkward inputs first, then submit once.

== recap | set=city
B: Let us lock in the key habits before you submit.
> Hidden tests carry the rest of the marks
M: Write asserts from the statement before you write the function.
> Write asserts from the statement first
B: Think about empty input, ties, None and spaces.
> Check empty, ties, None and spaces
M(cheer): Return the value the statement asks for, never just print it.
> Return the value, never just print it
B(cheer): Replace nested loops with a set or dictionary. Great work today, Mira!
> Use a set to avoid nested loops
