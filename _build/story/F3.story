TITLE: Parsing, counting and ranking lab text
HOOK: Turn messy station text into counts and rankings

== title | set=city
B(happy): Welcome to CityPulse! I am Bolt, and this is Mira, our newest engineer.
M(cheer): Hi everyone! Our sensors send messy text, and today I must turn it into averages and rankings.
B: Python has built-in tools for exactly this job. Let us learn them one by one.

== talk | set=room
M(sad): Bolt, each sensor sends one long block of text. How do I get the separate readings out?
> 📄 : Raw text
B: First, splitlines breaks the block into one item per line. Those items sit together in a list.
> 📋 : One item per line
M(think): A list is an ordered row of items, written in square brackets. Got it.

== same | set=lab
LEFT: 📝 : Text on a sticky note
RIGHT: 🧮 : Number in a calculator
M(confused): A 42 written on a sticky note looks like a number. Can I add it to another number?
B: Not yet. Python sees text as characters, even when those characters are digits.
M(happy): So the sticky note becomes a calculator number only after conversion. Clear!

== chain | set=lab
B: Every reading passes through four steps, from raw text to a count. Step one is the raw text itself.
> 📄 : Raw text
B: Step two splits the text into lines, then cuts each line at its commas.
> 🧩 : Split into lines
> 📏 : Split at commas
M(think): Then step three turns the value text into a real number. Step four counts them.
> 🔢 : Convert to number
> 📊 : Count per station

== code | set=lab
| text = "S1,42\nS2,17\n"
| lines = text.splitlines()
| first = lines[0].split(",")
| name = first[0]
| value = int(first[1])
| print(value + 8)

M(think): Let us follow it line by line. The text holds two readings, one per line.
> line 1
B: Line two splits the text into a list. Remember, positions start at zero, not one.
> line 2
> var lines=["S1,42", "S2,17"]
M(confused): So item zero is the S1 line, the first one?
B: Yes. Line three cuts that first line at its comma.
> line 3
> var first=["S1", "42"]
B: Line four keeps the name, and line five turns the text forty two into a real number.
> line 4
> var name="S1"
> line 5
> var value=42
B(cheer): Line six adds eight and prints the answer, which is fifty.
> line 6
> out 50

== trap | set=room
WRONG: value = int(text) with no try, one bad value crashes
RIGHT: try int(text), except ValueError, return None
M(shock): Oh no. One sensor sent 4.2 and my whole program stopped with an error!
B: A classic trap. The int function accepts whole numbers only, so a decimal point raises ValueError.
M(think): So I should catch that error and return None for the bad row instead.

== term | set=room
B: Let us run the test file. The command is python test dot py.
> $ python test.py
> = (no output)
M(happy): Nothing printed. Does that mean it worked?
B(cheer): Yes! Silence means every assert passed. A failed check would print an AssertionError instead.

== bars | set=night
BAR: S1 : 2
BAR: S2 : 1
BAR: S3 : 4
M(think): Now the counting. Three stations sent readings. How many did each one send?
B: A Counter, a built-in tool, tallies the list in one line. It walks through and counts each station name.
> hi 3
M(happy): Station S3 sent the most, four readings. And a missing station counts as zero, not an error.

== table | set=city
HEAD: station | pm25 | day
ROW: S1 | 42 | Mon
ROW: S2 | 17 | Mon
ROW: S3 | 55 | Tue
ROW: S4 | 42 | Tue
B: Now the filter. Say the lab wants readings over thirty only. Watch row two.
> keep 1,3,4
M(think): So S2 fades, because seventeen is not over thirty. Now the sort, highest first.
> rows 3
B: S3 with 55 goes to the top. S1 and S4 tie at 42, so the name breaks the tie.
> rows 1,4

== versus | set=lab
LEFT: 🔍 : Dictionary get
RIGHT: 🧺 : defaultdict(list)
B: Two tools help group readings by station. The first is dictionary get, which reads with a default.
> L : Returns a default when missing
M(confused): So get is read only? It does not save the missing key?
B: Correct. defaultdict is the other tool. A missing key gets an empty list straight away.
> R : Creates an empty list on first use
M(happy): So I can call append without checking first. That is much shorter!

== array | set=lab
CELLS: 4 1 3 2
M(think): A median is the middle value. To find it, the readings must be sorted first.
> swap 0,1
> swap 1,3
B: Now they read one, two, three, four. Four is even, so there are two middle values.
> ptr i=1 j=2
> hi 1,2
> note middle two: 2 and 3
M(happy): So I average two and three, and get two point five, not three. Got it!

== quiz | set=class
Q: What does int("4.2") do?
- It returns 4
- It returns 4.2
- It returns None
* It raises ValueError
M(think): Would int chop off the decimal part and give four? That sounds neat.
M(think): Or does it give back None, like a failed search?
B(cheer): The answer is ValueError. int takes whole numbers only, so wrap the call in try and except.

== recap | set=city
B: Let us lock in what we learned today.
> Split text into lines first
M: Convert text with int or float, inside a try block.
> Convert inside try and except
B: A Counter or defaultdict does the counting.
> Count with Counter or defaultdict
M(cheer): Sort by value, then by name, using a tuple of two values.
> Sort by value, then name
B(cheer): Great work today, Mira! Find the median only after you sort.
> Median needs sorted data
