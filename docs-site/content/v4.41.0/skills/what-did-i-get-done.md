---
description: "Summarize authored git commits over a time period into a concise status update. Use when preparing weekly reviews, retrospectives, shipped-work recaps, or any requested date range."
related: ["/skills/development-lifecycle","/skills/tdd","/skills/review"]
search: {"boost":1,"keywords":["what did i get done"]}
sidebar: {"label":"/what-did-i-get-done"}
title: "/what-did-i-get-done"
type: "skill"
---
![Diagram of the /what-did-i-get-done skill](/diagrams/skills/what-did-i-get-done.svg)

[Open the editable Excalidraw source](/diagrams/skills/what-did-i-get-done.excalidraw)


Read current Git email's authored commits in range; start at known last update.
Exclude merges/uncommitted work. Summarize shipped behavior/architecture, not
cosmetics or motives.

## Output

Always use these two exact headings:

- `What did you work on since the last update?`
- `What are you going to work on next?`

Max five concise bullets each. First: actual date range; weekly/retro:
likely bug-fix/tech-debt/net-new classification. Next: stated plans/commitments
only, else "Next work not specified."
