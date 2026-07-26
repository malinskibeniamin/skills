---
name: resilience-review
description: Run a risk-ranked Murphy review when credible failure could cause data loss, security or privacy harm, irreversible action, broken contracts, or a likely user dead end.
---

# Resilience Review
Murphy pass for credible risk, not an exhaustive edge-case harvest.

## Evidence first

A risk is credible when supported by a trust boundary, irreversible effect,
specified contract, observed incident, demonstrated scale, or likely user path.
"Could happen" is insufficient. Skip low-risk work without ceremony.

Map the action, state change, side effects, dependencies, and current scale.
Probe only relevant classes, inline. Native Codex uses agents only when the user
explicitly requests them or invokes `/swarm`.
- **Input:** malformed or stale data crossing a trust boundary.
- **Timing:** duplicate or out-of-order work that can corrupt or mislead.
- **System:** dependency failure that breaks a required contract.
- **State:** an impossible state with a likely path to reach it.
- **Recovery:** a normal user can become stuck or receive fake success.

For each credible finding, state evidence, trigger, expected behavior, smallest
guard, and smallest public-contract test. No evidence means no finding.

Security, privacy, data loss, and destructive actions fail closed. Otherwise,
prefer clear failure over speculative retries, fallbacks, caches, flags, or
observability.

Use `/read-the-damn-docs` when external behavior defines the risk. Confirm real
defects through `/diagnosing-bugs`; then add one RED regression test. Use
`/visual-review` only for a customer-facing recovery flow.
## Output
```md
## Resilience review
Risk surface:
- ...
Evidence:
- ...
Credible findings:
| Scenario | Evidence | Smallest guard | Contract test |
Verdict: PASS | NEEDS_GUARDS | BLOCKED
```

Rules: cite files/routes/forms/API. Rank findings; do not reward quantity. A
real high-impact gap blocks. A hypothetical edge case does not become work.

See [REFERENCE.md](REFERENCE.md).
