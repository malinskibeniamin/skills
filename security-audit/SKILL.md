---
name: security-audit
description: "Use for source-grounded security questions, vulnerability investigation, focused security reviews, or explicitly requested codebase audits and pen tests. Not dependency scanning or a mandatory general-review step."
---

# Security audit

Apply these host rules, then read the complete [upstream skill](../vendor/cloudflare-security-audit/skills/security-audit/SKILL.md).

- Resolve the **skill directory** to the upstream file's parent, not this adapter
  or the Codex proxy. Resolve companion guides, schema, and validators from there.
- Default to guidance for focused questions/reviews. Explicit codebase audits,
  pen tests, comprehensive reviews, or report requests select the six-phase
  workflow and retained artifacts.
- Delegation needs explicit user consent; an audit request alone is not consent.
  Without consent or delegation tools, provide source-only guidance inline and
  disclose partial coverage, not a full audit or independent verification. Obtain
  consent before a full run. Preserve host model selection and budgets.
- Keep upstream sandbox controls, local-only scope, dummy data, write isolation,
  evidence gates, and validators. Missing execution controls mean source inspection
  plus a needs-validation blocker, not unsandboxed target execution or live probes.
  An audit describes fixes; implement only if requested.

[Provenance and refresh](CREDITS.md). Installation enables no audit hook,
background work, or automatic security-review lane.
