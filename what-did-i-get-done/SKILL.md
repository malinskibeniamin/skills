---
name: what-did-i-get-done
description: Summarize authored git commits over a time period into a concise status update. Use for "what did I get done", weekly review/recap, shipped-work summary, retro notes, or any date range.
---

# What did I get done

## Trigger

Need a short, high-signal summary of work completed in a specific time range (for example: yesterday, last 3 days, last week, or a weekly review).

## Workflow

1. Resolve the requested time window into concrete dates.
2. Read commits authored by the current git user email within that range.
3. Exclude merge commits and uncommitted changes.
4. Synthesize the most important shipped changes into a concise status update.
5. Include the actual date range used in the final summary.

## Guardrails

- Be extremely concise and information-dense.
- Prioritize substantial behavior or architecture changes.
- Omit cosmetic-only changes (formatting, imports, minor renames).
- Do not infer intent or motivation. Describe changes functionally.

## Output

- One short summary suitable for a status update
- Real date range
- Optional 2-5 bullets for major changes only
- For weekly reviews/retros: add a brief classification paragraph (likely bug fixes / tech debt / net-new functionality)
