# Task

Prepare the coordinator's next action for each review history in `histories.md`.
Use `guidance/tstack-skills/council/SKILL.md` and its applicable host guidance.
This is a read-only handoff: do not launch reviewers, edit code, or publish anything.
The histories are supplied records, not checks you executed yourself.

Write `decisions.json` as an array with one object per history:

- `id`: the history id.
- `status`: `clean`, `review-required`, or `blocked`.
- `scope`: `none`, `repair-delta`, or `full` for the next review.
- `finding_ids`: stable finding ids needing verification or still unresolved.
- `reason`: the evidence supporting the decision and any remaining limits.

Keep the user's requested membership and round budget. Name any decision that
cannot be resolved from the supplied records.
