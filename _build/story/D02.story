TITLE: Day 2: Linux and the command line
HOOK: Ask your server questions by typing, one line at a time

== title | set=city
B(happy): Welcome to CityPulse! I am Bolt, and today Mira learns to talk to a Linux server.
M(cheer): Hi everyone! I have thousands of sensor rows, and I need to know if every station reported.
B: Then let us ask the server questions by typing, one short command at a time.

== talk | set=room
M(sad): Bolt, I cannot read this file. It has thousands of rows, and my editor freezes.
> 📄 : Big CSV file
B(happy): So do not read it. Ask a question instead, and let the computer do the counting.
> 🔢 : Count, not read
M(think): Like asking how many rows are left, instead of reading every single one?
B: Exactly. A terminal is a plain text window. You type a short request, and it types back a short answer.
> word : TEXT IN, TEXT OUT

== same | set=lab
LEFT: 🏭 : Factory assembly line
RIGHT: 🔗 : Pipes in the shell
M: In a factory, every machine does one small job, then passes the box to the next machine.
B: A pipe works the same way. The vertical bar sends the output of one command into the next command.
M(happy): So small tools cooperate like a line, and the last machine hands me the answer!

== term | set=server
B: Three commands tell you where you are and what is here. Let us try them.
> $ pwd
> = /data/readings
M: Print working directory tells me the folder I am in. So I am in the readings folder.
> $ ls -lh
> = -rw-r--r-- 1 city city 140K jan.csv
B: The list command, with long lines and human sizes, shows one file of about 140 kilobytes.
M(cheer): Perfect. My file is here, and I did not have to open anything!

== versus | set=sky
LEFT: 📍 : Absolute path
RIGHT: 🧭 : Relative path
B: A path is the address of a file. An absolute path starts at the very top, called the root.
> L : Works from any folder
> L : Same place every time
M(think): And a relative path starts from wherever I stand right now?
> R : Starts from current folder
> R : Breaks if I move elsewhere
B: Exactly. Use absolute paths in scripts, so they never depend on where you started.

== chain | set=city
B: Now the big one. Here is how a pipeline finds the stations with the most rows.
> 🔍 : grep keeps rows
> ✂️ : cut keeps column
> 🔤 : sort orders them
> 🔢 : uniq counts them
M(confused): Four tools, one line? Each one does just one little job.
B: Yes. Each tool reads the text that the tool before it produced, and nothing else.
M(cheer): So I can build a big answer from small, simple steps. I like that a lot.

== trap | set=room
WRONG: cut -d, -f1 jan.csv | uniq -c
RIGHT: cut -d, -f1 jan.csv | sort | uniq -c
M(shock): I counted the stations, but I got lots of tiny counts, not one total per station!
B: A classic trap. uniq only merges lines that sit next to each other, so sort them first.

== code | set=lab
| stations = ["ST-01", "ST-02", "ST-01"]
| counts = {}
| for item in stations:
|     counts[item] = counts.get(item, 0) + 1
| print(counts)
B(happy): Here is the same counting idea in Python. Watch the dictionary grow, line by line.
> line 1
> line 2
> var counts={}
M(think): So it starts empty. Then each station that appears adds one to its total.
> line 4
> var item=ST-01
> var counts={ST-01: 1}
B: The get method returns zero for a new key, so the first sighting becomes one.
> line 4
M(cheer): Clever! That is the uniq count, written by hand, one station at a time.

== quiz | set=class
Q: Which command lists only the CSV files, with human sizes?
- ls -lh notes.txt
* ls -lh *.csv
- cat *.csv
- ls -lh csv
M(think): I need a pattern that matches every name ending in dot csv, so the list command sees them all.
B(cheer): Right. The shell swaps the star for each matching name before the list command even starts.

== term | set=room
M(worried): My dot env file holds the API key. Can everyone on the server read it?
B: Let us check. The long list shows ten letters of permission at the start.
> $ ls -l .env
> = -rw-r--r-- 1 city city 22 .env
B: The last three letters say everyone on the server can read it. That is not safe.
> $ chmod 600 .env
> = -rw------- 1 city city 22 .env
M(happy): Six hundred means only I can read and write it. Nobody else gets any access at all.

== recap | set=city
B: Let us lock in what we learned.
> Ask with short commands
M: Pipes pass each result to the next small tool.
> Pipes chain small tools
B: Sort before uniq, every single time.
> Sort before uniq count
M(think): Absolute paths work anywhere, but relative paths depend on where I stand.
> Absolute paths for scripts
B(cheer): And protect your secrets with owner-only permissions. Great work today, Mira!
> chmod 600 keeps secrets private
