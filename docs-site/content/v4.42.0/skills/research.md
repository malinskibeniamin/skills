---
description: "Research primary sources and save cited findings. Use when durable reports, documentation surveys, API fact sets, reading passes, or design-rationale archaeology are required."
related: ["/skills/development-lifecycle","/skills/tdd","/skills/review"]
search: {"boost":1,"keywords":["research"]}
sidebar: {"label":"/research"}
title: "/research"
type: "skill"
---
![Diagram of the /research skill](/diagrams/skills/research.svg)

[Open the editable Excalidraw source](/diagrams/skills/research.excalidraw)


Recovery/explanation: [Poteto](https://github.com/malinskibeniamin/skills/blob/v4.42.0/shared/POTETO-NATIVE.md#orientation-and-explanation).

Research inline by default; background work requires explicit delegation or `/swarm`.
Authorized agents: fresh contexts, task/source pointers; no chat forks.

1. Trace every claim to **primary sources**: official docs, source, specs, first-party APIs.
2. Write one Markdown artifact, citing each claim; flag what you could not confirm and where you looked.
3. Follow repo notes convention: surveys stay scratch/memory; only decision-ready findings go in `docs/`.

## Routing

- Immediate API/version fact -> `/read-the-damn-docs` inline, no artifact.
- Why code or design exists -> read [DESIGN-RATIONALE.md](https://github.com/malinskibeniamin/skills/blob/v4.42.0/research/DESIGN-RATIONALE.md); trace
  source history and decision evidence without inventing intent.
- Video -> `/video-research`; use timestamped transcript/OCR/frames as evidence.
- Adversarial multi-source report -> deep-research harness.
- This skill -> focused reading with cited Markdown.
