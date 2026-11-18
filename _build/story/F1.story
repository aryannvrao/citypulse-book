TITLE: Python from zero, part 1: values and loops
HOOK: Store values, make decisions and repeat work in Python

== title | set=city
B(happy): Welcome to CityPulse! I am Bolt, and this is Mira, our newest engineer.
M(cheer): Hi! Today I want to write my first real Python programs, the kind that store numbers and repeat work.

== talk | set=lab
M(sad): Bolt, my air quality script crashed last night. The screen filled with red text and I had no idea why.
> 💥 : Crash on screen
B(think): Do not panic. That red text is a traceback, a report that shows where the program failed.
> 📜 : Top to bottom
B: A program is a list of instructions. The computer runs them one by one, from the top of the file down.
> clear

== term | set=room
B: The Python program that reads and runs your instructions is called the interpreter. Let us run a file.
> $ python hello.py
> = Hello from CityPulse
M(happy): It printed my text! So the file ran from top to bottom, one line at a time.
B: Yes. Each line is one step, and the computer does them in order.

== table | set=room
HEAD: Type | Holds | Example
ROW: int | whole numbers | 42
ROW: float | decimals | 3.5
ROW: str | text | "PM2.5"
ROW: bool | yes or no | True
ROW: None | no value | None
M(think): Every value has a type. Is 42 the same as "42"?
B: No! Quotes make it text. The type decides what you can do with a value.
> rows 1
M: So an int is a whole number, and a float has a decimal point.
> rows 2
B: A bool is yes or no. None means there is no value at all.
> rows 4

== trap | set=lab
WRONG: print("42" + 1)  gives a TypeError
RIGHT: print(int("42") + 1)  gives 43
M(shock): I added one to the text forty-two, and Python crashed with a TypeError!
B: A classic trap. Python will not add text to a number, so convert the text first with int.
M(happy): So int of forty-two plus one gives forty-three. Nice.

== same | set=room
LEFT: 💰 : Coin jar total
RIGHT: 🧮 : Accumulator variable
M: Imagine a jar labelled total, where I add one coin each day. A variable is a name that holds a value.
B: That running total is an accumulator. It starts at zero, and each round of the loop adds to it.
M(think): So the jar is the variable, and each coin is one round of the loop?
B(cheer): Exactly! The total grows a little on every round.

== code | set=lab
| total = 0
| for value in [42, 65, 58]:
|     total = total + value
| print(total)
B: Here is the accumulator in code. A list holds the three readings, and total starts at zero.
> line 1
> var total=0
M(think): The loop takes the first reading, forty-two, and adds it to the total.
> line 2
> var value=42
> line 3
> var total=42
B: The second reading is sixty-five, so the total grows to one hundred and seven.
> line 2
> var value=65
> line 3
> var total=107
M(happy): The last reading, fifty-eight, makes the total one hundred and sixty-five.
> line 2
> var value=58
> line 3
> var total=165
B: Finally, print shows the total on the screen.
> line 4
> out 165

== array | set=lab
CELLS: C i t y P u l s e
M(think): Now text. Each letter has a position, called an index. Counting starts at zero, not one.
> ptr i=0
> note index 0 is the letter C
B: So CityPulse has nine letters, from index zero up to index eight.
> ptr i=4
> note index 4 is the capital P
M: Negative indexes count from the end, so minus one is the last letter.
> ptr j=8
B: Yes. A slice from zero to four takes four letters, and stops before index four.
> hi 0,1,2,3
> note slice 0 to 4 gives City

== versus | set=room
LEFT: ➗ : Normal division
RIGHT: 🔢 : Floor division
M: So seven divided by two gives what? I think three point five.
B: With the normal slash, yes. The answer is always a decimal number, called a float.
> L : Seven slash two gives 3.5
> L : Always a float, even if whole
M(happy): And double slash keeps only the whole part, so I get three.
> R : Keeps the whole part, gives 3
B: Watch negative numbers. Minus seven double slash two gives minus four, because it rounds down.
> R : Rounds down, so -4

== quiz | set=room
Q: What does Python show for print(-7 // 2)?
- -3
- -3.5
* -4
- 3
M(think): Floor division rounds down, and minus three point five rounds down to minus four.
B(cheer): Correct! The answer moves further from zero, which is why it catches people out.

== talk | set=sky
B: Now back to your red text. A traceback has parts, and you read it from the bottom up.
> 📜 : Read bottom up
M(think): So the last line gives the error type, and the lines above show the file and line number.
B(cheer): Exactly! The message says what went wrong, and the line number says where.
> 🔎 : Line number
M: A NameError means I used a name that was never stored. Usually it is a typo.
B: Check the spelling first, or store a value in that name before you use it.

== recap | set=city
B: Let us lock in the main ideas.
> Programs run top to bottom
M: Quotes make text, and text is not a number.
> Quotes make text, not numbers
B: Slash gives decimals, double slash whole part.
> Slash gives decimals, double slash whole part
M(cheer): Index starts at zero, and the last index is one less than the length.
> Index starts at zero
B(cheer): And read tracebacks from the bottom up. Great work, Mira!
> Read tracebacks from the bottom up
