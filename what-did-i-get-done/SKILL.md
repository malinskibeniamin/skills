---
name: what-did-i-get-done
description: Summarize authored git commits over a time period into a concise status update. Use when preparing weekly reviews, retrospectives, shipped-work recaps, or any requested date range.
---

## Workflow

1. Resolve concrete date range, using the last update as the start when known.
2. Read commits by current git user email in range.
3. Exclude merges and uncommitted work.
4. Synthesize important shipped changes.
5. Use stated plans or explicit commitments for next work; if none are known, say "Next work not specified."

Be concise and dense. Prioritize substantial behavior/architecture; omit formatting/import/minor rename. Never infer motive; describe functionally.

## Output

Always reply in two sections, using these exact headings:

- `What did you work on since the last update?`
- `What are you going to work on next?`

Use at most five concise bullets per section. Keep all content in these two sections;
prioritize rather than fill the slots. Include the actual range in the first section.
Weekly/retro updates include brief likely bug-fix/tech-debt/net-new classification
within completed-work bullets.
