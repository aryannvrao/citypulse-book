TITLE: Recursion, search, graphs and heaps
HOOK: Find the answer fast by throwing half away

== title | set=city
B(happy): Welcome to CityPulse! I am Bolt, and this is Mira, our newest engineer.
M(cheer): Hi everyone! Today we fix a slow script, and the trick is to skip work we do not need.

== talk | set=room
M(sad): Bolt, my script checks every reading in a whole year to find when the air first turned unhealthy. It takes ages.
> 🐢 : Slow script
B(think): Checking every item is the slow way. Today you learn to throw away most of the data safely.
> 🔎 : Smarter search
M(happy): Throw data away? Show me how!

== array | set=lab
CELLS: 0 15 30 45 60 75 90 105 120 135
M(think): Say I want the time when the reading reached ninety. Do I check each timestamp from the start?
> ptr i=0 j=9
B: No, that is the slow way. Start at the middle. Index four holds sixty.
> hi 4
> note middle is 60
B: Sixty is smaller than ninety, so ninety can only sit on the right side.
> done 0,1,2,3,4
M(happy): So five items vanished after one single check!
> note one check, half gone
B: Repeat on what is left. Each step halves the range. That is binary search.
> ptr i=5 j=9
B: It works like a dictionary. Open near the middle, then tear out the half you no longer need.

== same | set=room
LEFT: 🪆 : Nested dolls
RIGHT: 🔁 : Recursive function
M: I open a doll and find a smaller doll inside. So I open that one too.
B: A recursive function works the same way. It calls itself on a smaller problem each time.
M(think): And when do I stop opening dolls?
B(happy): At the tiny doll with nothing inside. That is the base case, and it ends the chain.

== code | set=lab
| def total(values):
|     if not values:
|         return 0
|     return values[0] + total(values[1:])
| print(total([3, 5, 7]))
B: Here is a recursive function that adds up a list of numbers. Watch the highlight move.
> line 1
M(think): Let me try it with three, five and seven. What runs first?
> line 2
> var values=[3, 5, 7]
B: Line two asks whether the list is empty. It is not, so Python skips down to line four.
> line 4
> var values=[5, 7]
M(confused): Wait, the function calls itself with a shorter list? When does that end?
> line 2
B: When the list is empty. Then line three returns zero, and the waiting calls finish.
> line 3
> var values=[]
M(happy): Fifteen! Each call adds its first item to the answer from the call below it.
> line 5
> out 15

== trap | set=night
WRONG: def total(v): return v[0] + total(v[1:])
RIGHT: if not v: return 0 comes first
M(shock): Wait, my version never checks for an empty list. Will it crash?
B: Yes. It keeps calling itself until Python stops it with a RecursionError. That is the classic trap.
M(think): So the base case always goes first, and it must be reachable.

== array | set=lab
CELLS: 120 90 210 180 240
M(sad): My readings go up and down, like 120, then 90, then 210. Can I binary search them directly?
B: No. Binary search needs sorted values. Instead, keep the running maximum, the biggest value seen so far.
> set 1=120
> set 3=210
> note this list never goes down
M(happy): Now it reads 120, 120, 210, 210, 240. It only climbs, so binary search works on it.
> hi 2
B: The first crossing of two hundred is at index 2. Build this once, then search as often as you like.
> note two hundred first reached at index 2

== graph | set=sky
NODE: s1 : S1 : 0,1
NODE: s2 : S2 : 1,0
NODE: s4 : S4 : 1,2
NODE: s3 : S3 : 2,0
NODE: s5 : S5 : 2,2
NODE: s6 : S6 : 3,1
NODE: s7 : S7 : 4,1
NODE: s8 : S8 : 5,1
NODE: s9 : S9 : 6,1
EDGE: s1-s2
EDGE: s1-s4
EDGE: s2-s3
EDGE: s2-s6
EDGE: s3-s5
EDGE: s4-s5
EDGE: s5-s6
EDGE: s6-s7
EDGE: s7-s8
EDGE: s8-s9
B: Here is the station network. Each circle is a sensor station, and each line is a link.
> hi s1
M(think): I want the fewest hops from S1 to S9. Which stations should I check first?
B: Breadth first search checks neighbours in rings. First come S2 and S4, the neighbours of S1.
> hi s2,s4
> note first ring
M(confused): Then the next ring is S3, S5 and S6, right?
B: Yes! Each ring is one hop further out, and a queue keeps the order straight.
> hi s3,s5,s6
> note second ring
B: Then S7, S8 and finally S9. The first time we reach S9, the route is the shortest.
> done s1,s2,s4
> hi s7,s8,s9
> note route S1 S2 S6 S7 S8 S9: five hops

== table | set=lab
HEAD: station | pm25
ROW: S1 | 60
ROW: S3 | 142
ROW: S5 | 120
ROW: S8 | 103
ROW: S7 | 88
M(think): I have readings for many stations. I only need the three worst, and sorting them all feels wasteful.
> col 2
B: Right. Keep a small heap of size three, with the smallest reading on top so it can leave first.
> rows 2,3,4
M(confused): So I add a reading, and if the heap has four, I remove the smallest one?
B: Exactly. The heap never holds more than three items, even with thousands of stations.
> keep 2,3,4

== code | set=lab
| import heapq
| def top_k(readings, k):
|     heap = []
|     for s, v in readings:
|         heapq.heappush(heap, (v, s))
|         if len(heap) > k:
|             heapq.heappop(heap)
|     return sorted(heap, reverse=True)
B: Here is the heap version. Watch the heap, because it never grows past three items.
> line 3
> var k=3
M(think): The first three readings fit, since the heap is still small enough.
> line 5
> var heap=[(88,s7),(142,s3),(97,s9)]
B: Now the fourth reading, sixty, arrives. The heap has four items, which is one too many.
> line 6
> line 7
> var heap=[(88,s7),(142,s3),(97,s9)]
M(happy): So sixty leaves, the smallest one. The heap is back to three, and sorting gives the top three.
> line 8
> out [(142, 's3'), (97, 's9'), (88, 's7')]

== quiz | set=class
Q: Which search method needs its list sorted before it can work?
- Breadth first search on a network.
- Heap pop to get the smallest item.
* Binary search, halving the range.
- Depth first search with a stack.
M(think): Breadth first and depth first walk graphs, so they do not need sorted lists. Heap pop does not search at all.
M(happy): Binary search is the one that relies on order. It halves the range, because one comparison rules out half the list. So it must be binary search!
B(cheer): Correct! Sorted data lets one check throw away half the answers.

== talk | set=night
M(cheer): Bolt, I can see the whole plan now. Let me sum it up in my own words.
M(happy): Recursion breaks a big job into smaller copies, and each copy needs a base case to stop. Search can skip half. Graphs use rings and queues.

== recap | set=city
B: Let us recap.
> Binary search halves a sorted list
M: Recursion needs a base case, or it never stops.
> Recursion needs a base case
B: Breadth first search finds the fewest hops.
> BFS uses a queue, ring by ring
M: A heap keeps the top few items cheaply.
> Heap of size k keeps the top few
B(cheer): Build a running maximum before searching unsorted data. Great work today, Mira!
> Build a running max before you search
