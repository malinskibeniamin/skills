---
name: research
description: Investigate a question against high-trust primary sources and capture a durable research artifact as a Markdown file in the repo. Use when the user wants a cited report, multi-source synthesis, or delegated reading legwork; do not use for a quick official docs lookup.
---

# Research

Repo/code changes: run `/deslop` before commit, push, PR, or merge.

Investigate the question against **primary sources**: official docs, source code, specs, first-party APIs, or standards. Do not rely on secondary summaries when the owning source is reachable. Follow every claim back to the source that owns it.

Use `/read-the-damn-docs` under the hood for official docs facts, but keep the boundary sharp: quick official fact checks belong to `/read-the-damn-docs`; `/research` owns durable research artifacts, cited Markdown files, and multi-source synthesis.

## Process

1. Trigger `/read-the-damn-docs` when docs freshness or official behavior matters; if that fully answers a quick docs lookup, stop there instead of creating a research note.
2. If background agents are available and the user asked for delegated reading legwork, spin one up so the main thread can keep moving. If not, do the research in-session and say so.
3. Find the repo convention for research notes. Save the findings where the repo already keeps such notes; if no convention exists, choose a sensible Markdown path and say where.
4. Write one Markdown file with concise findings, links/citations for each claim, open questions, and what downstream skill or plan should consume the findings.
5. Prefer directly quoted snippets only when the wording itself matters; otherwise summarize and link.

## Output

Return the created file path, the primary sources used, and the decision-ready findings.
