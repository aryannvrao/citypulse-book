TITLE: Python from zero, part 2: collections
HOOK: Store many readings, look them up and reuse code

== title | set=city
B(happy): Welcome back to CityPulse! I am Bolt, and Mira is here with a big pile of readings.
M(cheer): Hi! Today I learn to store many readings together, look them up by name, and write reusable functions.

== talk | set=room
M(sad): Bolt, I have one hundred air readings in separate variables. My code is a mess.
> 📸 : Messy variables
B(think): Put them in one list instead. A list keeps many values in order, under one name.
> word : ONE NAME, MANY VALUES
M(happy): So each reading has a position, like a seat number in a cinema?
B: Exactly. Positions start at zero, so the first reading sits at index zero.
> clear

== array | set=lab
CELLS: 40 65 52 33
M(think): My list has four readings. Forty, sixty-five, fifty-two and thirty-three.
> ptr i=0
> note list[0] is the first reading
B: Positions start at zero. Negative positions count from the end, so minus one is the last item.
> ptr j=3
> note list[-1] is the last reading
M(happy): So I can reach the last reading with a negative position. Nice!
> hi 3

== table | set=room
HEAD: Station | Reading
ROW: MG Road | 40
ROW: Jayanagar | 65
ROW: Whitefield | 52
M(confused): A dictionary is like this table. But how do I find Whitefield quickly?
B: You look up the key, which is the name on the left. The value is the reading on the right.
> col 2
M: And if the key is missing, square brackets raise an error, but get returns None.
B: So use get with a default, when a missing station is normal.
> reset

== same | set=lab
LEFT: 📇 : Phone contact book
RIGHT: 🐍 : Python dictionary
M: In my phone, I look up a friend by name, and get their number back.
B: A dictionary works the same way. The name is the key, and the number is the value.
M(happy): So the key is the question, and the value is the answer!
B(cheer): Exactly. And each key can appear only once in a dictionary.

== code | set=lab
| stations = ["S1", "S2", "S1"]
| counts = {}
| for sid in stations:
|     counts[sid] = counts.get(sid, 0) + 1
B: Here is the counting pattern. We count how many readings each station sent.
> line 1
M(think): The counts variable starts as an empty dictionary, written with curly braces.
> line 2
> var counts={}
B: For each station id, get returns the count so far, or zero if it is new. Then we add one.
> line 3
> var sid="S1"
> line 4
> var counts={"S1": 1}
M(happy): The next id is S2, which is new, so it starts at one.
> var sid="S2"
> var counts={"S1": 1, "S2": 1}
B(cheer): Last, S1 again. Get finds one, and the new count is two.
> var sid="S1"
> var counts={"S1": 2, "S2": 1}

== versus | set=room
LEFT: 📋 : sorted() function
RIGHT: 🔧 : list.sort() method
B: Both put a list in order, but in different ways. Let me show you the difference.
> L : Returns a new sorted list
> R : Changes the list itself
M(think): So sorted leaves my original alone, but sort changes it?
> R : Returns None, so do not assign it
B: Exactly. The sort method changes the list in place and gives back nothing.
> L : Original list stays unchanged
M(happy): Good. I will remember which one leaves the original alone.

== trap | set=lab
WRONG: def add_item(item, bag=[]):
RIGHT: def add_item(item, bag=None):
M(shock): My second call still had the first item in it! The bag was not empty.
B: A default value is made once, when Python reads the def line. So every call shares the same list.
M(think): So use None as the default, and make the list inside the function.
B: Yes. Then each call without a bag gets a fresh empty list.

== talk | set=night
M(sad): Bolt, one reading was typed as the word forty, and my program crashed.
B(think): Python raises an error when int gets text it cannot read. Catch it with try and except, and the program keeps running.
> 🧯 : Catch the error
M(think): So I put the risky code inside try, and the except block handles the problem?
B(cheer): Exactly. Name the error, like ValueError, so you do not hide other mistakes.
M: Then print a message and return None, which means no value.

== quiz | set=room
Q: The function f(x) runs print(x * 2) and has no return line. What does y = f(3) store?
- 6
- 3
- 0
* None
M(think): The function prints six on the screen, but printing is not returning. So y holds nothing.
B(cheer): Correct! Print shows a value, while return hands it back to the caller.

== recap | set=city
B: Let us lock in the main points.
> A list keeps ordered values by index
M: A dictionary maps each key to its value.
> Use get with a default for missing keys
B: Functions return values, and print only shows them.
> Never use a list as a default
M(cheer): Sorted gives a new list, and sort changes the list itself.
> Catch named errors with try and except
B(cheer): Great work, Mira. Next, we use all of this in a real CityPulse program!
