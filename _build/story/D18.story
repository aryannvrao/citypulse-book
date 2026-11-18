TITLE: Check your data before you trust it
HOOK: A chart can mislead you if you skip the check-up

== title | set=city
B(happy): Welcome to CityPulse! I am Bolt, and this is Mira, our newest engineer.
M(cheer): Hi everyone! Today a chart told us our air got cleaner, and I almost believed it.
B: Today you will learn how to check data before you trust any number from it.

== talk | set=room
M(sad): Bolt, my chart says the air was cleaner on Tuesday. But Tuesday looks suspicious.
> 📉 : Fake drop
B(think): Let us check first. A doctor measures your pulse before any diagnosis, and data needs the same care.
> 🩺 : Check-up
B: This first careful look is called exploratory data analysis, or EDA for short.
> word : EDA = FIRST CHECK-UP

== chain | set=lab
M(confused): Where do I start? Checking everything at once sounds messy.
B: Follow an order of questions. First comes coverage, meaning how many readings each station made each day.
> 📅 : Coverage first
B: Next, count the blank cells. A blank is a missing value. Pandas, our table library, stores it as NaN, which means not a number.
> 🔢 : Count the gaps
B: Then look at the spread of the values, to find any strange ones.
> 📊 : Spread of values
B: Then check trends over time, and patterns by hour and weekday.
> 📈 : Trends, patterns
M(think): Coverage, gaps, spread, trends. Four questions, always in that order.

== code | set=lab
| import pandas as pd
| df = pd.read_parquet("data/clean/aq_clean.parquet")
| ts = pd.to_datetime(df["ts_utc"], utc=True)
| df["day"] = ts.dt.tz_convert("Asia/Kolkata").dt.date
| counts = df.groupby(["location_id", "day"]).size()
| coverage = counts.unstack(fill_value=0)
| print("incomplete:", int((coverage < 24).sum().sum()))
B: Here is the coverage check from the lesson notebook, one line at a time.
> line 2
M(think): The read parquet call loads the cleaned file into a table called df. Parquet is a compact format, so a text editor cannot open it.
> var df=table
> line 3
B: The to datetime function turns the text into timestamps, labelled UTC.
> line 4
B: Next we change the clock to India time, IST, and keep only the calendar day.
M: So a reading taken at nine in the evening UTC lands on the next Indian day.
> line 5
B: Group the rows by location and day, then count the rows in each group.
> line 6
B: Unstack turns the days into columns. A missing day becomes zero.
> line 7
M(cheer): Last, count the location days with fewer than 24 readings.

== versus | set=city
LEFT: 🟢 : Full day
RIGHT: 🟠 : Gappy day
B: Compare a full day with a gappy day. The full day has 24 hourly readings.
> L : All 24 hours are present
M(think): So a gappy day could look cleaner just because it has less data?
> R : Only 10 hours recorded
B: Exactly. Less evidence means a weaker claim. Count before you compare.
> L : Count first, then compare

== same | set=room
LEFT: 🧾 : Receipt typo
RIGHT: 🏔️ : Tallest mountain
M(think): An outlier is a value far from the rest. Is it always a mistake?
B: Not always. A receipt with an extra zero is a typo, but the tallest mountain is real.
B: The IQR, or interquartile range, is the width of the middle half of the data. Values far beyond it get flagged, then checked.

== table | set=lab
HEAD: Station | Day | Readings
ROW: ST01 | 14 Apr | 24
ROW: ST02 | 14 Apr | 10
ROW: ST03 | 14 Apr | 24
B: Each station has one row per day. A full day has 24 hourly readings.
> rows 2
M(sad): ST02 has only 10 readings, so its daily average rests on fewer hours.
> col 3
B: Show the gaps first, then keep only the complete days, and say how many were dropped.
> keep 1,3
M(think): So I keep the full days and report the dropped row, every time.
> reset

== trap | set=lab
WRONG: df.groupby(df.ts.dt.hour) on raw UTC times
RIGHT: tz_convert to Asia/Kolkata, then take the hour
M(shock): Oh no. My evening peak shows at the wrong time, because I grouped by the raw hour.
B: The clock in the data is UTC, the reference time with no offset. India is five and a half hours ahead.
B: Convert to Asia Kolkata first, then take the hour, and label the axis IST.

== bars | set=room | unit=readings
BAR: Expected : 24
BAR: ST01 : 24
BAR: ST02 : 10
B: Here is the same idea as a bar chart. Each bar shows the readings in one day.
> hi 3
M(think): The expected bar is 24, one per hour. ST02 falls well short.
> hi 3
B: A short bar is a warning sign. Report the count next to every chart you draw.
> hi 3

== term | set=room
B: Now we make the picture. We run the chart script from the terminal.
> $ python chart.py
> = saved pm25_hourly.png
M: The title should say the finding, with a number and a date.
> = title: Hourly PM2.5 peaked on 18 Apr
B(happy): The title is computed from the data, so it stays true on every refresh.
M(think): And the dashed line is the official limit, 60 micrograms per cubic metre.

== quiz | set=class
Q: A file has about two per cent blank PM2.5 cells. What is the honest way to handle them?
- Replace every blank with zero
- Fill blanks with yesterday's value
* Drop them, and report how many were removed
- Treat blanks as clean air readings
M(think): Zero would make a broken sensor look like clean air, so that is out.
M(think): A guess is not evidence, so filling with a made-up value is out too.
B(cheer): Correct! Drop the blank rows, and always report how many you removed.

== recap | set=city
B: Let us lock in what we learned today.
> Coverage first, always
M: A blank is NaN, never zero.
> Blank is NaN, never zero
B: Outliers are checked, not deleted.
> Outliers are checked, not deleted
M: Convert to IST before you group by hour.
> Convert to IST before the hour
B(cheer): And title every chart with its finding. Great work today, Mira!
> Titles state the finding
