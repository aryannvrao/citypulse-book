TITLE: Python for engineers
HOOK: Turn a raw sensor file into numbers you can trust

== title | set=city
B(happy): Welcome back to CityPulse! I am Bolt, and this is Mira, our newest engineer.
M(cheer): Hi everyone! Today I learn to read sensor files with Python, using only built-in tools.
B: Good goal. Mira has a messy problem first, so let us start there.

== talk | set=room
M(sad): Bolt, I summarised the pollution file, and my average came out wrong. Some rows were missing.
> 💥 : Wrong average
B: Typical. A CSV file is a plain text table, with commas between the columns, and one bad line can break a script.
> 📄 : readings.csv
B: We need a careful clerk, who checks each form before adding anything up.
M(think): So I should check every row, and not trust the file blindly?
B(happy): Exactly. Read each line safely, turn the text into numbers, and only then count.

== same | set=lab
LEFT: 🧾 : Clerk with forms
RIGHT: 🐍 : Python script
M: A clerk gets a pile of handwritten forms from the air-quality sensors.
B: Before adding anything, the clerk checks which column is which, and writes each value in its box.
M(happy): So the script reads the header first, then each row, in the same careful way.
B: It also ignores any form that does not answer the question being asked.

== chain | set=lab
B: Reading a file is a chain of steps. Each step hands its result to the next one.
> 📂 : Open the file
M: Then the rows come out one at a time, and every value is still text.
> 🧾 : Read each row
B: Text is not a number yet, so we convert it. Python calls that conversion float.
> 🔢 : Convert values
M(cheer): Then we summarise the numbers and print a neat report.
> 📊 : Summarise
> 📰 : Print report

== code | set=room
| lines = ["S1,36.6", "S2,52.1"]
| values = []
| for line in lines:
|     station, text = line.split(",")
|     values.append(float(text))
B: Here is a tiny piece of code. It turns text into numbers, one line at a time.
B: The list holds two lines of text. Each line still has its comma inside it.
> line 1
M(think): The loop takes the first line, and split cuts it at the comma into two pieces.
> line 4
> var station=S1
> var text=36.6
B(happy): The float call turns the text into a real number, and it joins the values list.
> line 5
> var values=[36.6]

== trap | set=lab
WRONG: if row["value"] > 50:
RIGHT: value = float(row["value"]) first
M(shock): I compared the raw value with fifty, and it looked fine. Did I get lucky?
B: Not really. In Python 3, comparing text with a number raises an error, so always convert first.

== term | set=room
B: Now let us run the summary script. It counts the rows, then averages the pm25 readings.
> $ python summarise.py
> = rows: 1440
> = pm25 n: 480
M(cheer): Four hundred eighty pm25 readings, averaged to one decimal place.
> = pm25 avg: 38.7
B: Rounding only changes how the number looks. Inside, the full value is kept.

== table | set=lab
HEAD: station | pollutant | value
ROW: S1 | pm25 | 36.6
ROW: S1 | no2 | 22.9
ROW: S2 | pm25 | 52.1
ROW: S2 | no2 | 18.4
B: Here is a small sensor table. We only want the pm25 rows.
> keep 1,3
M(think): So keep rows one and three, and let the others fade out.
B: A filter like that is a list comprehension, a one-line loop that keeps only the matches.
> col 3
M(happy): Now the value column holds the numbers we average.

== versus | set=room
LEFT: 🔑 : with open(...)
RIGHT: 🔓 : Plain open
B: Opening a file takes care, and the two ways behave differently when things go wrong.
> L : Closes the file at the end
> L : Closes even after an error
M(think): And if I forget the close step?
> R : Relies on reaching close
> R : A crash skips that line
B: So use with, and the file closes safely every time.

== talk | set=class
M(confused): Bolt, my average function printed the answer, but the caller got nothing. Why?
> 📸 : Print vs return
B: Printing shows the value on screen. Only return gives it back to the caller, as a result.
M(think): So a function with no return sends back None, which means no value at all.
B: Right. Always return the answer, and let print belong to the outer code.

== quiz | set=class
Q: A plain dictionary counts readings per station. The first S4 reading arrives. Then what?
- The count for S4 becomes 1 automatically
- The count for S4 becomes None
- The loop skips the reading silently
* KeyError, because S4 is not yet a key
M(think): A plain dictionary does not create a key just because I try to read it.
M(think): So reading a missing key must be an error, not a quiet zero.
B(cheer): Correct! Use a get call with a default of zero, or a Counter, to avoid the crash.

== recap | set=city
B(happy): Let us lock in what we learned today.
> Read the file with csv DictReader
M: Convert text to numbers before you compare them.
> Convert with float first
B: Return the answer, and let print show it.
> Return the answer, do not print it
M(cheer): Use with open, so the file always closes.
> with open closes the file safely
B(cheer): And test your results with assert. Great work today, Mira!
> Test with assert, then trust the result
