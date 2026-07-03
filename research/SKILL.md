---
name: research
description: Investigate a question against high-trust primary sources and capture the findings as a Markdown file in the repo. Use when the user wants a topic researched, docs or API facts gathered, or reading legwork delegated to a background agent.
---

# Research

Repo/code changes: run `/deslop` before commit, push, PR, or merge.

Investigate the question against **primary sources**: official docs, source code, specs, first-party APIs, or standards. Do not rely on secondary summaries when the owning source is reachable. Follow every claim back to the source that owns it.

## Process

1. If background agents are available and the user asked for delegated reading legwork, spin one up so the main thread can keep moving. If not, do the research in-session and say so.
2. Find the repo convention for research notes. Save the findings where the repo already keeps such notes; if no convention exists, choose a sensible Markdown path and say where.
3. Write one Markdown file with concise findings, links/citations for each claim, open questions, and what downstream skill or plan should consume the findings.
4. Prefer directly quoted snippets only when the wording itself matters; otherwise summarize and link.

## Output

Return the created file path, the primary sources used, and the decision-ready findings.
