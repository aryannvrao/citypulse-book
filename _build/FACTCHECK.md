# Fact-check brief

You are fact-checking chapters of a study book for a beginner on a software-engineering course (Git, Linux, HTTP and curl, bash and cron, Python, pandas, SQL, AWS, data structures and algorithms, machine learning, FastAPI, Docker, CI/CD, observability, LLM APIs, project delivery). The chapters were drafted by a smaller model. A student will learn from them and then sit quizzes, coding tests and a viva, so a false statement here costs real marks.

Two things are already verified, so skip them: Python blocks tagged ` ```python test ` (they are executed and pass), and which option is marked correct in `quiz` blocks (already audited).

## What to look for

- Statements that are technically false.
- Commands, flags, functions, parameters or syntax that do not exist, or that do something different from what the text says.
- Code outside the tested blocks that would not run, or would not produce the output shown.
- Wrong arithmetic, wrong example output, wrong complexity claims.
- An explanation that contradicts the code or output next to it.
- A quiz `WHY:` line, flashcard, cheat-sheet row or model viva answer that teaches something false.
- A `trace` animation whose line numbers or variable values do not match what the code shown would actually do.

## How to fix

Read each file in full, then fix each error in place with Edit, changing as little text as possible. This is a correction pass only:

- Do not rewrite for style, shorten, reorganise, or add new material.
- Leave things that are simplified for a beginner but still true.
- If you are not confident something is wrong, leave it and list it in your report instead.
- Keep the special syntax intact, because a build script parses it: fenced blocks tagged `trace`, `flow`, `term`, `quiz`, `cards`; step lines with ` :: ` separators; `Q:`, `- `, `* ` and `WHY:` lines in quizzes; and `:::` boxes with their closing `:::`.

## Report

For each file: one line per change (what it said, what it says now), then anything you suspected but left alone. Raw and short; no summary paragraph.
