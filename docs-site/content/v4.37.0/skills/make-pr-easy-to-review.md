---
title: "/make-pr-easy-to-review"
description: "Clean noisy PR history and add reviewer guidance without changing code behavior."
type: skill
sidebar:
  label: "/make-pr-easy-to-review"
---
![Diagram of the /make-pr-easy-to-review skill](/diagrams/skills/make-pr-easy-to-review.svg)

[Open the editable Excalidraw source](/diagrams/skills/make-pr-easy-to-review.excalidraw)

Prepare a PR so a reviewer can quickly understand the intent, important files, and risk. The default goal is reviewability without behavior changes.

## Workflow

1. Resolve the target PR from the user-provided URL or current branch.
2. Inspect commits, diff size, changed paths, generated files, and PR description.
   For a stacked PR, compare with `baseRefName`, record its layer and adjacent PRs, and keep
   history operations inside the owning branch.
3. Identify reviewability issues: noisy commits, stale description, unrelated changes, mixed mechanical and logic changes, missing tests, or unclear reviewer entry points.
4. Propose a plan before rewriting history or force-pushing. Reordering, folding, or
   cascading a stack requires explicit whole-stack approval.
5. Apply safe improvements, then verify the tree or diff still matches the intended code.

## History Cleanup

Only rewrite history when the user asks for it or agrees to the plan. Before rewriting:

```bash
gh pr view <PR> --json title,headRefName,baseRefName,state,commits
git fetch origin <headRefName> <baseRefName>
ORIGINAL_TREE=$(git rev-parse origin/<headRefName>^{tree})
```

Good commit groupings usually follow dependency order:

1. Schema/storage or generated API definitions.
2. Core logic.
3. Wiring and integration.
4. UI or surface behavior.
5. Tests.

After rewriting, verify content identity:

```bash
echo "Original tree: $ORIGINAL_TREE"
echo "Current tree:  $(git rev-parse HEAD^{tree})"
git diff origin/<headRefName> --stat
```

Do not push if the tree changed unintentionally.

## Reviewer Guidance

For visual context (diagrams, file maps, annotated walkthrough), run `/visual-recap` -- do not duplicate it here. This skill only tightens the PR text itself:

- When `/quantify-impact` produced meaningful evidence, put its `## Proven impact` block (`Metric | Before | After | Delta`) first, followed by the exact command/environment. If measurement was not useful, keep the normal value summary; no fake empty table. If evidence missed its threshold, say `Value not proven` rather than hiding it.
- Add a TL;DR that matches the actual diff.
- Separate core files from generated or mechanical files.
- Call out risky behavior changes, migration order, rollout plan, and test coverage.
- Link issue trackers, dashboards, or design docs when they explain intent.

## Guardrails

- Never hide meaningful behavior changes inside "cleanup".
- Do not bypass hooks unless the user explicitly asks.
- If the PR is too large to make reviewable with notes, recommend splitting instead of polishing around the problem.
