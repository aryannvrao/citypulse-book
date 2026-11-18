TITLE: Capstone tickets T20 to T22: DSA part 1
HOOK: Three tickets, fifteen points, checked by tests

== title | set=city
M(sad): Ten million sensor rows, some readings arrive twice, and my duplicate check takes hours.
B(happy): That is what these tickets fix. Your capstone board holds three of them, T20 to T22.
M(cheer): Fifteen points, checked by running tests on our commits, the saved snapshots of our work.

== code | set=lab
| def first_repeat(words):
|     seen = set()
|     for word in words:
|         if word in seen:
|             return word
|         seen.add(word)
|     return None
B(happy): Ticket T20 asks you to find repeats fast. A set is a collection that remembers what it has seen. Say the words are a, b, a, c.
> line 2
> var seen=set()
M(think): Each new word is checked, then added.
> line 3
> var word=a
> line 4
B: Word a is new, so the check is false and a joins the set.
> line 6
> var seen=one item
M(think): Word b is new too, so it joins as well. Then a comes back.
> line 3
> var word=b
> line 6
> var seen=two items
B(cheer): Now the check is true, so the function returns a at once.
> line 3
> var word=a
> line 4
> line 5

== term | set=room
B(happy): Here is the trainer's first check for ticket T20. It runs pytest, the test runner, in quiet mode.
> $ pytest -q
M(cheer): Eighteen passing tests, so my six problems work on my own examples.
> = ..................  [100%]
> = 18 passed in 0.12s
B: The big check runs the applied script on ten million rows. It must finish, not crawl for hours.
> $ python applied/dedup_topk.py trainer_10M.csv
> = rows=...
> = dups=...
> = top=...
M(think): Hours means I probably used a list, not a set.

== versus | set=sky
LEFT: 🐢 : Re-add six values
RIGHT: 🚀 : Running sum
M(think): Why not just add the last six readings again every hour?
> L : Adds all six values every hour
B: You could, but most of the work repeats, because the windows overlap.
B: The running sum is faster. It adds the new value and drops the oldest.
> R : Adds the new value
> R : Drops the oldest value
M(happy): So each reading enters once and leaves once. That is why the ticket wants O of n, work that grows in step with the readings.
> R : Each value enters and leaves once

== code | set=night
| values = [3, 1, 4]
| k = 2
| running = []
| total = 0
| for i, v in enumerate(values):
|     total += v
|     if i >= k:
|         total -= values[i - k]
|     running.append(total)
B(happy): Ticket T21 wants a rolling average and maximum, taken over the latest few readings, called the window. Test the running sum idea on three numbers with a window of two.
> line 1
> line 2
M(think): So total starts at zero.
> line 3
> line 4
> var total=0
B: First value three arrives. The total becomes three, and the window is not full yet.
> line 5
> line 6
> var total=3
> line 7
M: Second value one arrives. The total becomes four, and nothing leaves yet.
> line 6
> var total=4
> line 7
B: Third value four arrives, so the total is eight. Then the oldest value three leaves.
> line 6
> var total=8
> line 8
> var total=5
M(cheer): Five is one plus four, the last two values. My running sum works!
> line 9
> var running=3, 4, 5

== same | set=city
LEFT: 🧍 : Tallest-so-far line
RIGHT: 📈 : Deque of candidates
M(confused): Why can the rolling maximum throw so many readings away?
B: Think of a photo line. A taller person joins at the back.
M(happy): Then the shorter people before them can never be tallest again, so they leave.
B: The deque keeps only those candidates. A deque is a list that is quick to change at both ends. Its front is always the current maximum.

== term | set=server
B: The trainer's check for T21 runs my script on a file exported from a database with SQL, its question language. Then it prints the exit code.
> $ python applied/rolling_window.py applied/data/sql_rolling.csv
> = 96 rows, 0 mismatches
> $ echo $?
M(happy): Zero mismatches means my Python matches the SQL window view, row by row.
B: The final zero is the exit code. Zero means no error.
> = 0

== chain | set=class
B: Ticket T22 asks when PM two point five, a very fine dust, first crosses 200, again and again. So we prepare once.
> 📈 : Running maximum
M(think): Why a running maximum? The raw readings go up and down.
B: Right. It never goes down, so binary search can jump to the first crossing.
> 🔍 : Binary search
M(happy): Then each question takes few steps.
> ⚡ : Quick answer

== code | set=lab
| def first_at_least(xs, target):
|     lo, hi = 0, len(xs)
|     while lo < hi:
|         mid = (lo + hi) // 2
|         if xs[mid] < target:
|             lo = mid + 1
|         else:
|             hi = mid
|     return lo
B(happy): Binary search halves the range at each step. Say the list is two, four, four, seven. Watch it find the first value at least four.
> line 2
> var lo=0
> var hi=4
M(think): The range is the whole list.
> line 3
B: The middle is index two, which holds four.
> line 4
> var mid=2
B: Four is not less than four, so hi moves to the middle.
> line 5
> line 8
> var hi=2
M(think): Middle is index one, also four.
> line 4
> var mid=1
B: Still not less, so hi moves to one.
> line 5
> line 8
> var hi=1
M(confused): Middle is index zero, holding two, which is less than four.
> line 4
> var mid=0
> line 5
> line 6
B(cheer): So lo moves to one. Now lo equals hi, the loop stops, and the answer is one.
> var lo=1
> line 3
> line 9

== term | set=room
B(happy): Now the trainer's check for T22. It runs the first crossing script.
> $ python applied/first_crossing.py
M(cheer): Scan and bisect agree means the fast binary search matches the slow scan of every hour, for every threshold.
> = scan and bisect agree
B: Then the README benchmark needs measured times and a break even number, the count of questions after which preparing once pays off. Never guesses.

== trap | set=class
WRONG: if key in seen_list (a plain list)
RIGHT: seen = set(), add the key tuple
M(think): I kept my rows in a list and checked with in. My small test file passed.
B: Classic trap. On ten million rows, each check scans the whole list, so the pass becomes O of n squared.
M(happy): So I switch to a set of key tuples. A tuple is a fixed group of values, and a list cannot go in a set.

== quiz | set=night
Q: Which structure lets one pass count repeated readings in O(n) time?
- A list searched with in on each row
* A set of key tuples, checked and added to
- A sorted copy scanned with nested loops
- A string you append to and search
M(think): A list with in scans everything on each row. Nested loops are slower.
B(cheer): Correct! A set checks and adds in about one step, so one pass is O of n.

== recap | set=city
B: Let us lock in the three tickets.
> Set remembers what you have seen
M: Running sums add the new value, then drop the old one.
> Running sum: add new, drop old
B: A deque keeps only the maximum candidates, so its front is the answer.
> Deque keeps maximum candidates
M(cheer): And show evidence: pytest output, commits and benchmark numbers.
> Evidence means terminal output, not claims
B(cheer): Good luck, squad!
