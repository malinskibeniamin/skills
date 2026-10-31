---
description: "Teach the user a new skill or concept within this workspace."
related: ["/skills/development-lifecycle","/skills/tdd","/skills/review"]
search: {"boost":1,"keywords":["teach"]}
sidebar: {"label":"/teach"}
title: "/teach"
type: "skill"
---
![Diagram of the /teach skill](/diagrams/skills/teach.svg)

[Open the editable Excalidraw source](/diagrams/skills/teach.excalidraw)


For context recovery, behavior or rationale explanations, read the [Poteto adaptation](https://github.com/malinskibeniamin/skills/blob/v4.42.0/shared/POTETO-NATIVE.md#orientation-and-explanation).

Learning paths resolve from the invocation workspace; only `*-FORMAT.md` links are skill-relative.

## Files

- `MISSION.md`: learning purpose; [MISSION-FORMAT.md](https://github.com/malinskibeniamin/skills/blob/v4.42.0/teach/MISSION-FORMAT.md).
- `RESOURCES.md`: trusted sources; [RESOURCES-FORMAT.md](https://github.com/malinskibeniamin/skills/blob/v4.42.0/teach/RESOURCES-FORMAT.md).
- `reference/*.html`: printable references.
- `learning-records/*.md`: demonstrated/prior learning; [LEARNING-RECORD-FORMAT.md](https://github.com/malinskibeniamin/skills/blob/v4.42.0/teach/LEARNING-RECORD-FORMAT.md).
- `lessons/*.html`: one self-contained lesson each.
- `assets/*`: reusable styles/widgets/simulators/diagrams.
- `NOTES.md`: preferences and working notes.

## Mission and sources

If mission is missing/vague, interview before teaching: turn abstract goal into one concrete outcome. When mission changes, confirm, update `MISSION.md`, and write a learning record.

Build `RESOURCES.md` from trusted resources before lessons. Never rely only on parametric memory; cite sources and deeper-study paths.

## Lessons

Teach one mission-linked concept at the user's zone of proximal development: quick, tangible win through interactive practice and tight feedback. Build storage strength through retrieval, spacing, interleaving, not fluency. Avoid answer tells: same number of words where possible, no formatting clues, varied correct-answer positions. Link lessons and reference docs with HTML anchors; recommend one primary source and invite questions. Save clean, printable `lessons/NNNN-dash-case.html`.

Reuse `./assets/` first. Extract reusable code/styles rather than inline duplicates; usually start with shared stylesheet.

## Choose the next lesson

Read `learning-records/`, `NOTES.md`, and mission; choose the nearest useful challenge. Record learning only when the user demonstrates understanding, states prior knowledge, corrects a misconception, or changes mission. Coverage is not learning.

Create reference docs for compressed syntax, routines, algorithms, poses, exercises, or glossary. Use [GLOSSARY-FORMAT.md](https://github.com/malinskibeniamin/skills/blob/v4.42.0/teach/GLOSSARY-FORMAT.md); add terms after understanding.

For real-world judgment, answer provisionally and suggest a reputable community/practitioner source; respect a decline. Use `NOTES.md` for pace, examples, tone, accessibility, avoided formats, and constraints.
