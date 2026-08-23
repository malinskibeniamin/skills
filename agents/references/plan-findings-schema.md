# Plan Findings Schema

Planning reviewers evaluate one shared plan against one shared set of facts. They
surface unresolved decisions; they do not invent missing product choices or review a
diff that does not exist yet.

## Evidence packet

The `/grilling` orchestrator gathers this packet once and gives the same packet to every
axis:

```json
{
  "plan_summary": "Exact proposed behavior and delivery steps",
  "spec_sources": ["Issue, path, URL, or quoted user decision"],
  "standards_sources": ["AGENTS.md", "scoped CONTEXT.md", "relevant ADR"],
  "planned_paths": ["src/example.ts"],
  "assumptions": ["Claim not yet established by a source"],
  "tier": "quick | standard | deep-risk",
  "specialist_matches": ["golang"]
}
```

Facts come from the repository, tools, or cited sources. Put unresolved choices in
`assumptions`; never ask the user to discover a fact the orchestrator can inspect.

## Reviewer output

Emit one fenced JSON block:

```json
{
  "reviewer": "plan-product-hat",
  "axis": "product",
  "status": "BLOCKED",
  "checked_sources": ["specs/example.md:12-28"],
  "findings": [
    {
      "id": "SCOPE_UNBOUNDED",
      "section": "spec",
      "evidence": "The plan adds exports, while specs/example.md:18 limits v1 to viewing.",
      "impact": "The first release cannot prove the stated viewing workflow independently.",
      "recommendation": "Remove export work from this plan.",
      "blocking": true,
      "confidence": 0.94
    }
  ],
  "must_answer": ["Is exporting part of v1 or a non-goal?"],
  "test_first": [],
  "skip_reason": null
}
```

## Contract

- `axis`: `product | engineering | design | adversarial-value | resilience |
  specialist:<name>`.
- `status`: `APPROVED | NEEDS_CHANGES | BLOCKED | SKIPPED`.
- `checked_sources`: exact paths, ranges, commands, or user decisions used as evidence.
- `findings`: at most five high-signal root causes. Each needs a `section` (`spec |
  standards | product | engineering | design | adversarial-value | resilience |
  specialist:<name>`), evidence, user or delivery impact, a concrete recommendation,
  `blocking`, and calibrated `confidence` from 0 to 1. Keep each prose field to one
  concrete sentence; omit praise and process narration.
- `must_answer`: unresolved user decisions only. Deduplicate downstream decisions by root
  cause; do not put repository fact-finding here.
- `test_first`: smallest public-contract RED tests implied by the axis; empty when none.
- `skip_reason`: `null` unless `SKIPPED`. A skip needs one line of packet evidence.

`BLOCKED` means at least one unresolved blocking finding or `must_answer` decision
prevents a responsible implementation. `NEEDS_CHANGES` means the plan can be updated
without a new product decision. `SKIPPED` without `skip_reason` is invalid.
