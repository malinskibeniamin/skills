---
name: make-pr-easy-to-review
description: Clean noisy PR history and add reviewer guidance without changing code behavior.
disable-model-invocation: true
---

Target reviewability without behavior changes; prefer PR description/review notes over code edits.

## Workflow

1. Resolve PR from URL/current branch.
2. Inspect commits, diff size, paths, generated files, and description. For stacks, compare `baseRefName`, record adjacent layers, and operate only on the owning branch.
3. Find noise: stale description, unrelated changes, mixed mechanical/logic commits, missing tests, unclear entry points.
4. Propose before history rewrite/force-push; reorder/fold/cascade needs explicit whole-stack approval.
5. Apply safe improvements; prove tree/diff still matches intent.

## History

Only rewrite history when the user asks or agrees to the plan. Capture identity first:

```bash
gh pr view <PR> --json title,headRefName,baseRefName,state,commits --jq '{title,headRefName,baseRefName,state,commits}'
git fetch origin <headRefName> <baseRefName>
ORIGINAL_TREE=$(git rev-parse origin/<headRefName>^{tree})
```

Prefer dependency order: schema/generated API -> core logic -> wiring -> UI -> tests.

After rewrite print `Original tree: $ORIGINAL_TREE` and `Current tree: $(git rev-parse HEAD^{tree})`; inspect `git diff origin/<headRefName> --stat`. Never push unintended tree changes.

## Guidance

Visual diagrams/file maps belong to `/visual-recap`; this skill edits PR text only.

- Put meaningful `/quantify-impact` `## Proven impact` (`Metric | Before | After | Delta`) first with command/environment. Otherwise use normal value summary; no fake empty table. Below threshold says `Value not proven`.
- Add accurate TL;DR; separate core from generated/mechanical files.
- Name risky behavior, migration order, rollout, tests, and useful issue/dashboard/design links.

## Guardrails

Never hide behavior as cleanup or bypass hooks without explicit request. If notes cannot make the PR reviewable, recommend splitting it.
