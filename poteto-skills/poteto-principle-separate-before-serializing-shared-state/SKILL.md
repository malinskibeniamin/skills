---
name: poteto-principle-separate-before-serializing-shared-state
description: "Poteto: Apply when concurrent actors might write to the same file, branch, key, or state object. Eliminate the sharing first; serialize structurally only when one shared writer is a real invariant."
disable-model-invocation: true
---

Read [harness compatibility rules](../../shared/POTETO-COMPATIBILITY.md) first.
Read and follow the complete [upstream skill](../../vendor/pstack/skills/principle-separate-before-serializing-shared-state/SKILL.md), resolving its relative resources from that source directory.
