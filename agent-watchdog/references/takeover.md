# Take over stuck work

Own the outcome, not the previous implementation. A takeover request authorizes in-scope
repair and redesign, not unrelated deletion, branch replacement, delegation, or merging.

Load [tstack takeover](../../tstack-skills/takeover/SKILL.md) for contributor-credit
and current-architecture checks. This procedure retains execution ownership and the
requested endpoint; no automatic replacement PR or monitoring continuation.

1. Reconstruct the original acceptance criteria from the issue, PR, history, and failed
   attempts. Separate requirements from accumulated speculative scope. Record current
   HEAD, dirty paths, ownership, known-working behavior, and the requested delivery endpoint.
2. Reproduce the blocker at the public entrypoint. Capture a failing contract test or
   runnable reproduction before implementation. Missing verification access is a concrete
   prerequisite to repair, not a reason to keep expanding the plan.
3. Compare repairing the approach with replacing it. Choose the smallest design that
   satisfies the original contract; preserve useful code, tests, and learned constraints.
   Prior effort is not a reason to keep a failed architecture. Credit only sources actually
   inspected or reused; name what was retained, adapted or discarded. For historical revert
   requests, identify the introducing commit and original feature contract before repair.
   Track [progress evidence](../../shared/progress-evidence.md), not growing diff size.
4. Before replacing authorized in-scope work, preserve a recoverable checkpoint of owned
   changes and identify exactly what will be replaced. Keep unrelated/unknown dirty work
   untouched. Starting from scratch means implementing a replacement, not `reset --hard`,
   branch deletion, or erasing someone else's changes. Ask when ownership is unresolved.
5. Execute through `/development-lifecycle` with one owner. Keep a compact attempt ledger:
   hypothesis, change, result, next discriminating check. When the same failure repeats
   without new evidence, stop that approach and pivot through `/diagnosing-bugs`; do not
   repeat equivalent patches or enlarge the spec. If no safe discriminating step remains,
   report the exact external prerequisite or reserved decision.
6. Replay original acceptance criteria, preserved behavior, and a credible failure path.
   Report what was retained/replaced, verification, residual risk, and delivered endpoint.
   Continue through authorized commit/push/PR work; merging still needs explicit permission.
   Apply [remote completion](../../shared/remote-completion.md) to inherited dirty
   files and unpushed commits; a prior agent's local-only report is not delivery.
