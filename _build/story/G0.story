TITLE: The game plan: how this course is scored
HOOK: Your first attempt is the one that counts

== title | set=city
B(happy): Welcome to CityPulse! I am Bolt, and this is Mira, our newest engineer.
M(cheer): Hi everyone! Today we learn how this course is scored, and how to come first.

== talk | set=room
M(sad): Bolt, I opened the real quiz on day two, before reading the chapter. My score was low.
> 📸 : Low score
B(think): That first attempt is the one the platform keeps as your skill score.
> word : FIRST TRY IS THE SCORE
M: So retrying the quiz fixes it, right?
B: Retries exist, but they do not replace the first result. Let us see the rules.
> clear

== same | set=lab
LEFT: 🎮 : Practice level
RIGHT: 🏆 : Ranked match
M: In a game, a practice level costs nothing. I can lose there and still learn something.
B: The practice quiz is that level. The real quiz is the ranked match, and only it counts.
M(happy): So I should make my mistakes in practice, not in the real thing!

== chain | set=room
B: Every day follows one routine. First, read the chapter and do the hands-on lab.
> 📖 : Read chapter
B: Next, take the practice quiz. Aim for nine out of ten before you go on.
> 🧪 : Practice quiz
B: Then solve the practice problem yourself, before you open any answer.
> 🐍 : Practice problem
B: Only now open the real quiz, and after that the graded lab.
> ✅ : Real quiz
> 🏁 : Graded lab
M(think): Read, practise, code, quiz, lab. That order protects my first attempt.

== bars | unit=marks
BAR: Visible : 60
BAR: Hidden : 40
B: A graded lab is a Python problem. One example split is sixty marks visible, forty hidden.
M(shock): So the hidden tests can carry almost half my marks?
B: Yes. Hidden tests are checks you cannot see. They try awkward inputs, like an empty list.
> hi 2
M(think): So the strange cases matter as much as the easy ones. Good to know.

== code | set=lab
| answers = [True, True, False, True]
| score = 0
| for right in answers:
|     if right:
|         score = score + 1
| ready = score / len(answers) >= 0.9
B: This is a practice score in Python. A list is a numbered collection, and this one has four answers.
> line 1
M: Each True means I got that answer right. The score starts at zero.
> line 2
> var score=0
B: The loop checks each answer in turn. Only the right answers add one.
> line 3
> line 4
> line 5
> var score=3
M(think): One answer was wrong, so it was skipped. The final score is three.
> line 6
> var ready=False
B: Three out of four is below nine out of ten, so ready is false. Not yet!

== table | set=room
HEAD: Item | Marked by | Target
ROW: Day quiz | Answers | 70 percent
ROW: Graded lab | Tests | 100 marks
ROW: Viva | Talking | 20 marks
B: Here is how each item is marked. A day quiz needs seventy percent to pass.
> rows 1
M(happy): The graded lab is out of one hundred, marked by its tests.
> rows 2
B: The viva is spoken. A mentor questions you, and it is scored out of twenty.
> rows 3
M(think): So every item leads to marks. I should prepare for each one.

== trap | set=lab
WRONG: Open the real quiz, then read the chapter
RIGHT: Read, practise, score nine, then open it
M(shock): I did exactly that on day two! I read the chapter after the quiz.
B: A classic trap. The quiz records your first try, so the practice quiz must come first.
M: So I practise until I score nine out of ten, and only then go for the real one.

== quiz | set=room
Q: You scored six out of ten on the practice quiz. What do you do next?
- Open the real quiz, retries are allowed
* Re-read missed topics, retake practice
- Skip the quiz and do the graded lab first
- Read the next day chapter to save time
M(think): Retries exist, but they do not replace the first result. So I should not gamble.
B(cheer): Correct! Practise until you reach nine out of ten, then open the real quiz.

== talk | set=sky
M(happy): Bolt, what is a viva? It sounds scary!
> 🎤 : Viva
B: A viva is a spoken exam about your own work. A mentor asks questions, and you answer out loud.
B: Each of four things gets zero to five marks. That makes twenty in total.
M(think): So I must practise my answers out loud, not only in my head?
B(cheer): Exactly! Every day chapter ends with a say it out loud section. Use it.
M: My Git history shows my own work, so my contribution counts toward my grade.

== recap | set=city
B: Let us lock in what matters most.
> Your first attempt sets the score
M: The routine is read, practise, code, quiz, then the lab.
> Practice quiz first, aim for nine of ten
B: Hidden tests can carry up to half the marks.
> Test empty input, ties and missing values
M(cheer): And say your viva answers out loud, every single day.
> Viva is scored out of twenty
B(cheer): Great start, Mira. Now go and practise!
> Commit your own work under your name
