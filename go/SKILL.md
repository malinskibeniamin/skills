---
name: go
description: Author delivery preset through verified PR readiness, without merging.
disable-model-invocation: true
---

Read and run the [author delivery workflow](../shared/delivery-workflow.md) from the current
owned diff/PR. This selects ship: verify, dogfood, self-review, prepare evidence, publish,
repair CI and resolve applicable feedback through verified readiness. Keep a single owner.

Earlier explicit local, commit, push or draft-only stops win. `/go` does not authorize merge,
whole-stack publication, history cleanup, delegation, model changes or unattended scheduling.
For unfinished implementation, load [development-lifecycle](../development-lifecycle/SKILL.md).
