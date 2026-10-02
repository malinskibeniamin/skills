---
name: what-did-i-get-done
description: Summarize authored git commits over a time period into a concise status update. Use when preparing weekly reviews, retrospectives, shipped-work recaps, or any requested date range.
---

Read commits authored by current Git email in range; start at known last update.
Exclude merges/uncommitted work. Prioritize shipped behavior/architecture, omit
formatting/import/minor renames. Describe function, not motive.

## Output

Always use only these two exact headings:

- `What did you work on since the last update?`
- `What are you going to work on next?`

At most five concise bullets each. First section: actual date range,
weekly/retro likely bug-fix/tech-debt/net-new classification. Next: stated
plans/commitments only; otherwise "Next work not specified."
