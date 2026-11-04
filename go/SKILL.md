---
name: go
description: Author delivery preset through verified PR publication and automatic upkeep; never implicit merge.
disable-model-invocation: true
---

Read and run the [author delivery workflow](../shared/delivery-workflow.md) from the current
owned diff/PR. Verify, dogfood, self-review, publish, then run
[automatic maintenance](../shared/delivery-workflow.md#automatic-pr-maintenance): repair
CI/feedback/conflicts, verify and push; continue through one authorized host wake.
Keep a single owner. Earlier local, commit, push, publication-only or no-monitoring stops win. Preserve draft.
Merge, whole-stack changes, delegation, model changes and persistent setup need scope.
For unfinished implementation, load [development-lifecycle](../development-lifecycle/SKILL.md).
