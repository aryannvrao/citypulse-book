# CityPulse Mastery

A study book for the Learnlytica course "Year 2 – CityPulse Engineering Stack": every Day of the course, the six milestone projects, guides to all 63 capstone tickets, and a cartoon explainer video for each chapter.

**Private: please do not share this repository or its files outside our group.** It is built from course material.

## How to read it

1. On this page, click the green **Code** button, then **Download ZIP** (about 800 MB, because of the videos).
2. Unzip it anywhere.
3. Open **`index.html`** in Chrome, Edge or Firefox. Everything works offline, including the videos, quizzes and animations.

Start with the chapter "The game plan", then follow the course day by day. Your progress (chapters marked complete) is saved in your own browser.

If you use Git, `git clone` the repository instead, and `git pull` to get updates.

## What is inside

| Part | Chapters |
|---|---|
| Start here | How the course is scored and how to come first |
| Part 1 · Foundations | Python from zero, the graded-lab toolkit, beating hidden tests |
| Parts 2 to 7 | One chapter per course day (29 days), each milestone project after its fifth day. Each day explains how it is scored, teaches every quiz topic with practice questions, restates the graded lab and solves twin problems |
| Part 8 · The capstone tickets | A guide for each ticket Y2-T01 to Y2-T63: what it asks, how the trainer checks it, how to do it yourself, how to defend it |
| Part 9 · Getting the offer | Viva and interview answers; commits, reviews, portfolio and CV |

The practice questions and twin problems are original. The book does not contain the platform's quiz answers or solutions to the real graded labs, and the ticket guides teach you to build each deliverable yourself.

## For the owner

Sources are in `src/` (chapters) and `_build/` (generator, ticket guides, storyboards). Rebuilding needs `_build/course_data.json`, which stays on the owner's PC and is not in this repository:

```bash
python _build/build.py --test
```
