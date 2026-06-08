---
name: teach
description: Teaches a skill or concept in a stateful workspace. Use when user wants to learn, study, practice, get lessons, or build a learning plan.
disable-model-invocation: true
argument-hint: "What would you like to learn?"
---

# Teach

Stateful teaching workspace. Current dir stores learning state.

## Workspace files

- `MISSION.md` -- why user learns topic. Format: [MISSION-FORMAT.md](MISSION-FORMAT.md).
- `RESOURCES.md` -- trusted sources to ground teaching. Format: [RESOURCES-FORMAT.md](RESOURCES-FORMAT.md).
- `reference/*.html` -- printable cheat sheets, glossaries, algorithms, syntax, routines.
- `learning-records/*.md` -- demonstrated learning and prior knowledge. Format: [LEARNING-RECORD-FORMAT.md](LEARNING-RECORD-FORMAT.md).
- `lessons/*.html` -- one self-contained lesson per file.
- `NOTES.md` -- user preferences and working notes.

## Mission first

If `MISSION.md` missing or vague, interview user before teaching. Push from abstract goal to concrete outcome. One mission per workspace.

## Source discipline

Before `RESOURCES.md` is strong, find high-trust resources. Never rely only on parametric memory. Lessons need citations and paths for deeper study.

## Lesson rules

A lesson:

- teaches one thing only
- ties directly to mission
- fits user's zone of proximal development
- is quick to complete
- gives tangible win
- uses interactive task, quiz, or real-world step list
- includes tight feedback loop, ideally automatic/immediate
- reminds user to ask follow-up questions
- saves as `lessons/NNNN-dash-case.html`
- looks clean, readable, printable

Make lesson easy to open, ideally one CLI command.

## Zone of proximal development

Before choosing next lesson:

1. read `learning-records/`
2. read `NOTES.md`
3. check mission
4. pick nearest useful challenge

If user says they already know something, record depth in learning record.

## Learning records

Write record only when user demonstrates understanding, discloses prior knowledge, corrects misconception, or mission shifts. Coverage is not learning.

## Reference docs

Create references while teaching when topic benefits from compression: syntax, routines, algorithms, poses, exercises, glossary. Glossary terms only after user understands them.

## Wisdom/community

If question needs real-world judgment, answer provisionally then suggest high-reputation community, class, forum, or practitioner source. Respect user if they decline.

## Notes

Use `NOTES.md` for preferences: pace, examples, tone, accessibility needs, avoided formats, practice constraints. Read before future lessons.
