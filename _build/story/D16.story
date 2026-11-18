TITLE: Choosing the right container
HOOK: Same answer, far less waiting

== title | set=city
B(happy): Welcome to CityPulse! I am Bolt, and this is Mira, our newest engineer.
M(cheer): Hi! Today our sensor feed has millions of rows, and my first program is painfully slow.

== talk | set=room
M(sad): My duplicate check takes hours. For each new reading, I scan every old reading from the top.
> 🐢 : Slow scan
B(think): That is a hidden loop. Checking a list means reading it item by item, so the work grows with every new row.
> 💥 : Too much work
B(happy): The fix is often not a faster computer. It is a better container for the data.
> word : RIGHT CONTAINER

== same | set=room
LEFT: 📜 : Reading the whole list
RIGHT: 🗂️ : Set of seen keys
M: To check if Asha is in the register, I read every name from the top of the page.
B: A set is more like a sign-in sheet that already groups the names. You never read the whole page.
M(think): So the check stays quick, even when the register gets huge?
B(happy): Yes. Python computes a hash, which is a number made from the key, and it uses that number to find the right slot.

== code | set=lab
| seen = set()
| for row in rows:
|     key = tuple(row[:3])
|     if key in seen:
|         continue
|     seen.add(key)
M(think): So I need a set, not a list. Let me follow one row through this loop.
> line 1
> var seen=empty set
B: Each row becomes a key: its first three fields, station, time and pollutant, packed into a tuple. A list would fail here.
> line 3
> var key=S1 10h PM25
M(happy): If that key is already in the set, the row is a repeat.
> line 4
> line 5
B: Then we skip it. Otherwise we add the key to the set and keep going.
> line 6
> var seen=one key

== array | set=lab
CELLS: 4 2 12 3 8 1
B: Now the rolling average over three hours. Picture a window that slides along the readings.
> ptr i=0 j=2
> hi 0,1,2
> note window of three readings
M(think): Do I add all three values again at every step?
> ptr i=1 j=3
> hi 1,2,3
> note add 3, drop 4
B: No, that is wasteful. Add the new value, and subtract the one that slid out on the left.
> ptr i=2 j=4
> note add 8, drop 2
M(happy): So each value joins the total once and leaves once. The whole pass stays quick.
> ptr i=3 j=5
> note add 1, drop 12

== table | set=class
HEAD: hour | value | average
ROW: 0 | 4 | 4.00
ROW: 1 | 2 | 3.00
ROW: 2 | 12 | 6.00
ROW: 3 | 3 | 5.67
ROW: 4 | 8 | 7.67
ROW: 5 | 1 | 4.00
M(confused): Hold on. Why does the second row say 3.00? Its window holds only two readings.
> rows 2
B: Exactly. Early windows are not full yet, so we divide by the count we really have.
> col 3
M(think): So the first hour's average is just that one reading, 4 divided by one.
> rows 1

== trap | set=lab
WRONG: total / k on every row (1.33 first)
RIGHT: total / min(i + 1, k)
M(shock): I divided by three from the very first row. So my first answer was 1.33, which is wrong!
B: A classic trap. The SQL view averages the rows it really has. Divide by the number of values in the window.

== bars | set=lab | unit=ms
BAR: Recompute : 741
BAR: Running sum : 19
M(happy): Let us time it. Recomputing every window from scratch takes 741 milliseconds on the course machine.
> hi 1
B: The running sum takes about 19 milliseconds on the same data. That is roughly thirty-nine times faster.
> hi 2
M(cheer): And the gap widens as the window gets bigger. Same answer, far less waiting!

== code | set=lab
| dq = deque()
| for i, v in enumerate(values):
|     while dq and values[dq[-1]] <= v:
|         dq.pop()
|     dq.append(i)
|     if dq[0] <= i - k:
|         dq.popleft()
|     out.append(values[dq[0]])
M(think): Our deque keeps positions, not values. Let us run the first three readings.
> line 1
> var dq=empty
B: The first reading is 4. The deque is empty, so position 0 joins the back.
> var i=0
> line 5
> var dq=0
> out 4
M(confused): Now 2 arrives. Is the 4 still the biggest?
> var i=1
> line 3
> line 5
> var dq=0 1
B: Yes, so 2 waits behind it. The front always holds the biggest value still in the window.
> out 4
M(shock): Next, 12 arrives. Both older values are smaller, so they must leave!
> var i=2
> line 4
> line 5
> var dq=2
B: Exactly. The old positions leave from the back, and 12 becomes the only candidate for the maximum.
> out 12
M(happy): Later, when the front position is too old, popleft removes it in constant time.
> line 7
B(cheer): Each position joins and leaves once, so the whole pass stays quick. Great progress, Mira!

== quiz | set=class
Q: To update a rolling sum over k hours, what happens for each new reading?
- Add up all k values again
* Add the new value, drop the old one
- Sort the window and take the middle
- Start the total again at zero
M(think): Recomputing every window is slow. Sorting does not help a sum. So it must be the change in the total.
B(cheer): Correct! Two small changes per step keep the work low, however long the feed is.

== recap | set=city
B: Let us lock in what matters today.
> Use a set for "have I seen this" checks
M: Keep one running total instead of rebuilding it.
> Keep a running sum, update it, do not rebuild
B: Divide by the number of values the window really holds.
> Divide by what the window really holds
M(cheer): A deque keeps the biggest value at its front.
> Deque front gives the window maximum
B(cheer): And always state the time and space cost. Great work today, Mira!
> State time and space for every answer
