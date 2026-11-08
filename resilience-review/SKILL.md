---
name: resilience-review
description: Run a risk-ranked Murphy review when credible failure could cause data loss, security or privacy harm, irreversible action, broken contracts, or a likely user dead end.
---

On interface/type/shared-state changes, read [Poteto](../shared/POTETO-NATIVE.md#design).

Murphy pass, not edge-case harvest.

## Evidence first

Credibility needs a trust boundary, irreversible effect, contract, incident, demonstrated scale, or likely path. Could happen is insufficient; skip low-risk work.

Map action, state changes, effects, dependencies, scale. Codex runs inline unless explicit agents or `/swarm` were requested. Probe:

- **Input:** malformed/stale trust-boundary data.
- **Timing:** duplicate/out-of-order corruption or deception.
- **System:** dependency failure breaks contract.
- **State:** reachable impossible state.
- **Recovery:** user stuck/fake success; retryable writes: repeat and resume after a partial effect per Poteto.

Findings need evidence, trigger, expected behavior, smallest guard and public-contract test. No evidence means no finding.

Security/privacy/data loss/destructive actions fail closed. Otherwise prefer clear failure over speculative retries/fallbacks/caches/flags/observability.

Use `/read-the-damn-docs` for external contracts, `/diagnosing-bugs` to confirm real defects, then one RED regression test. `/visual-review` only for customer recovery UI.

## Output

```md
## Resilience review
Risk surface:
Evidence:
Credible findings: | Scenario | Evidence | Smallest guard | Contract test |
Verdict: PASS | NEEDS_GUARDS | BLOCKED
```

Cite files/routes/forms/API; rank, do not count. High-impact gaps block; hypothetical edges do not. [Reference](REFERENCE.md).
