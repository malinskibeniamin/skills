---
title: "/resilience-review"
description: "Run a risk-ranked Murphy review when credible failure could cause data loss, security or privacy harm, irreversible action, broken contracts, or a likely user dead end."
type: skill
sidebar:
  label: "/resilience-review"
---
![Diagram of the /resilience-review skill](/diagrams/skills/resilience-review.svg)

[Open the editable Excalidraw source](/diagrams/skills/resilience-review.excalidraw)


Murphy pass for credible risk, not edge-case harvest.

## Evidence first

Credibility needs a trust boundary, irreversible effect, contract, incident, demonstrated scale, or likely path. Could happen is insufficient; skip low-risk work.

Map action, state change, side effects, dependencies, scale. Native Codex runs inline unless explicit agents or `/swarm` were requested. Probe relevant:

- **Input:** malformed/stale trust-boundary data.
- **Timing:** duplicate/out-of-order corruption or deception.
- **System:** dependency failure breaks contract.
- **State:** reachable impossible state.
- **Recovery:** normal user stuck or shown fake success.

Each credible finding needs evidence, trigger, expected behavior, smallest guard, smallest public-contract test. No evidence means no finding.

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

Cite files/routes/forms/API; rank, do not count. Real high-impact gaps block; hypothetical edges do not. See [REFERENCE.md](https://github.com/malinskibeniamin/skills/blob/v4.39.0/resilience-review/REFERENCE.md).
