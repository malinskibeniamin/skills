---
name: research
description: Research primary sources and save cited findings. Use when a durable report, documentation survey, API fact set, or reading pass is required.
---

# Research

Research inline by default. A background agent requires explicit delegation or `/swarm`.

Its job:

1. Investigate the question against **primary sources** -- official docs, source code, specs, first-party APIs -- not a secondary write-up of them. Follow every claim back to the source that owns it.
2. Write the findings to a single Markdown file, citing each claim's source.
3. Save it where the repo already keeps such notes; match the existing convention, and if there is none, put it somewhere sensible and say where. In this skills repo, exploratory surveys stay in scratch or memory -- only decision-ready findings land in `docs/`.

## Routing

- Need a fact **right now** to keep coding (API shape, current flag, version behavior) -> `/read-the-damn-docs` inline instead; no background agent, no artifact.
- Video URL or attachment -> `/video-research` first; treat its timestamped transcript, OCR, and frames as source evidence.
- Multi-source fact-checked **report** with adversarial verification -> the deep-research harness.
- This skill is the middle: focused reading legwork with a cited Markdown artifact.
