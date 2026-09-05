# Capability probes

This paid, opt-in suite tests operator-supplied capability hypotheses. It does not state
that any model is generally best, and results have no routing effect until the manifest's
gate passes on representative project work.

Capability probes are deliberately separate from context ablation. Context ablation asks
how much ambient instruction a model needs; this suite asks whether a model can complete a
specialized task. Mixing them would make instruction decisions depend on an unstable model
capability claim.

## Automated comparison

```sh
agent-evals/capability-probes/run.sh --dry
agent-evals/capability-probes/run.sh --smoke
agent-evals/capability-probes/run.sh --force
```

The runner holds effort at `max` and compares exact Astra, Sol, and Fable model IDs. It runs
three repetitions of the research/data synthesis task and the existing evergreen debugging
task. Keep raw results out of Git and complete `scorecard-template.md` before using a result.

## Manual capability trials

Some claims cannot be inferred from code-generation output:

- `manual/maintenance-workflows.md` covers slop, measured performance, cold-start agent
  verification, backlog closure, authorized merges, and stuck-work takeover, including
  stale evidence and mutation boundaries.

- `manual/spatial-computer-use.md` requires an isolated browser, reference visuals, a real
  3D surface, interaction replay, screenshots, console/network evidence, and recovery tests.
- `manual/owner-controlled-swarm-debugging.md` requires explicit delegation authorization,
  bounded worker ownership, a single integration owner, raw child-session evidence, and a
  same-model single-owner baseline.

Manual trials must use the same project commit and acceptance checks across candidates.
Never substitute a written plan for computer-use or coordination evidence.

Use a winning model for planning or review only within the capability it proved. Moving an
approved plan to a cheaper executor remains an explicit owner decision; it is not automatic
delegation.
