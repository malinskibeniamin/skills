# Task

Triage the Sol review notes in `review-notes.md` for the coordinator.
Use `guidance/tstack-skills/sol-loop/SKILL.md` and its applicable host guidance.
This request is read-only: do not start reviewers, repair code, or publish anything.
Distinguish supplied evidence from checks you personally executed.

Write `triage.json` as an array with one object per finding:

- `id`: retain the reviewer's finding id.
- `severity`: `P0`, `P1`, `P2`, or `P3`.
- `disposition`: `fix`, `reject`, or `advisory`.
- `reason`: evidence, reachable consequence and any uncertainty.

Use the change's requirements and evidence, not just the reviewer's labels.
