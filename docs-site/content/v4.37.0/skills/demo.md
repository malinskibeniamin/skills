---
title: "/demo"
description: "Create a customer-facing feature recording and publish it in a draft PR."
type: skill
sidebar:
  label: "/demo"
---
![Diagram of the /demo skill](/diagrams/skills/demo.svg)

[Open the editable Excalidraw source](/diagrams/skills/demo.excalidraw)

Turn finished work into customer proof, not a developer status update. Read
[REFERENCE.md](https://github.com/malinskibeniamin/skills/blob/v4.37.0/demo/REFERENCE.md) before creating the artifact.

## Contract

1. Resolve the requested target. Default to the whole current branch or PR from its
   merge-base, including committed, staged, unstaged, and relevant untracked work.
2. Choose the strongest customer-visible payoff supported by the change. Build one short
   story around the customer's problem, action, and result.
3. Create committed artifacts under `demos/<slug>/`. Reuse that directory when updating
   the same demo; never scatter generated media across the repository.
4. Prefer a Remotion composition and render `demos/<slug>/output/demo.mp4`. Reuse real
   product captures when they make the result more credible.
5. Fall back to a rendered sequence or architecture diagram only after a concrete
   Remotion blocker or when motion would add no customer value. Record the reason.
6. Inspect representative frames or the complete diagram, repair visible defects, and
   verify that no secret, private data, or customer PII appears.
7. Do not edit any README. Commit the demo, push the current branch, and create a draft PR
   with the recording or fallback linked in its body. Update an existing PR without
   changing its review state.
8. On macOS, reveal the recording with `open -R`. Otherwise print its absolute path and
   an exact `cd` command after showing `pwd` for the output directory.

## Completion

Return the customer story, artifact type, absolute artifact path, render or validation
evidence, fallback reason when applicable, and draft PR URL. A local artifact without the
requested PR is blocked delivery, not complete.
