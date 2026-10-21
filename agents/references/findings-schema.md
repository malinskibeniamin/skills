# Structured Findings Schema

All reviewer agents (`self-reviewer`, `code-reviewer`, `adversarial-reviewer`) MUST output findings as a single JSON block. This enables programmatic triage, autofix routing, and cross-reviewer deduplication.

The executable contract is [findings-schema.jq](findings-schema.jq), version 1.
The bundled SubagentStop hook validates it in either host when the host supplies
a recognized reviewer event. Native agent output enforcement remains best effort;
the coordinator must validate reports when no matching hook event is available.
Old/unversioned reports must be re-emitted; invalid output stays retryable and is
not recorded as completed coverage. Schema validity proves shape, not truth.

## Output Format

```json
{
  "schema_version": 1,
  "reviewer": "code-reviewer",
  "status": "NEEDS_CHANGES",
  "findings": [
    {
      "id": "user-response-1",
      "title": "Profile crashes when the user is missing",
      "severity": "P1",
      "file": "src/components/UserProfile.tsx",
      "line": 42,
      "category": "error-handling",
      "why_it_matters": "Users cannot open their profile after account deletion.",
      "scenario": "The API returns user: null and the component reads user.name.",
      "evidence": "src/components/UserProfile.tsx:42 dereferences user without a guard.",
      "verification": "Return user: null and render the empty state without crashing.",
      "autofix_class": "gated_auto",
      "suggested_fix": "Handle a missing user before rendering the profile.",
      "pre_existing": false,
      "confidence": 0.85
    }
  ],
  "testing_gaps": [
    "No test for error state when API returns 500",
    "Missing edge case: empty array response"
  ],
  "simplification_opportunities": [
    "handleSubmit and handleUpdate share 80% logic -- extract shared validator"
  ]
}
```

### Incomplete coverage

Use `SKIPPED` for a non-applicable lane, `UNAVAILABLE` for missing access/tooling or
scope, and `FAILED` for an attempted review that did not complete. Each requires
a non-empty reason and empty findings; none counts as approval:

```json
{
  "schema_version": 1,
  "reviewer": "adversarial-reviewer",
  "status": "UNAVAILABLE",
  "reason": "The pinned source snapshot is unavailable.",
  "findings": []
}
```

Completed statuses are `APPROVED`, `CONCERNS`, and `NEEDS_CHANGES`.
Completed reviews require `findings`, `testing_gaps`, and
`simplification_opportunities` arrays. Every finding requires all documented
fields, a positive integer line, boolean `pre_existing`, confidence in [0, 1],
and defined enum values. The reviewer must match the dispatched role. Unknown
extension fields remain allowed for cross-model notes and checklists.
An introduced P0/P1 finding or failed critical Karpathy check requires
`NEEDS_CHANGES`; `APPROVED`/`CONCERNS` cannot hide it. All present
`karpathy_checks` values must be `pass`, `fail`, or `n/a`.

## Gate receipts

[Review gates](../../review/GATES.md) use the same versioned jq validator through
[the typed adapter](../../scripts/review-results.ts), not a second event contract.
The adapter selects gate mode to validate the configured gate id and require a
non-empty `sufficiency` for clean gate reviews. Native reviewer events retain their
existing identity, required fields, incomplete statuses and strict verdict checks.
An approval contradicting introduced blockers, testing gaps or critical checks is
rejected, not silently relabeled. Re-emit a consistent report.

`cross_model_findings`, when present, use the same finding fields and participate
in blocking validation. Native events preserve that context; gate receipts also
merge it into findings without dropping the original field. Gate ids remain stable
across rounds: when omitted, the adapter derives them from category, file and title.
Duplicate/conflicting ids fail gate collection. Relative paths cannot escape the repo.
Additional domain categories: correctness, compatibility, dependency, license,
product, claims and operations. Applicable gates cannot pass incomplete coverage.
Gate mode also derives critical-check failure from the canonical check list; it
cannot be hidden or cleared by refuting an unrelated finding.

## Field Reference

### severity

Values: `P0 | P1 | P2 | P3`.

| Level | Meaning | Action |
|-------|---------|--------|
| `P0` | Blocks merge: breakage, exploitable vuln, data loss | Fix immediately |
| `P1` | Should fix: defects in normal usage, breaking contracts | Fix before review |
| `P2` | Fix if easy: edge cases, perf regression, maintainability | Fix or acknowledge |
| `P3` | Discretionary: minor improvements, style nits | Skip or log |

### autofix_class

Values: `safe_auto | gated_auto | manual | advisory`.

| Class | Meaning | Handling |
|-------|---------|----------|
| `safe_auto` | Trivial fix, no behavior change (missing import, typo, formatting) | Apply without asking |
| `gated_auto` | Likely correct but changes behavior (error handling, edge case fix) | Apply only inside an authorized fix endpoint; pause for reserved decisions |
| `manual` | Needs human judgment (architecture, trade-offs) | Report only |
| `advisory` | Informational, no action needed now | Log for compound phase |

### pre_existing

`true` if the issue existed before this session's changes (found in dirty baseline). Pre-existing findings are reported but NEVER block merge -- they're logged for future cleanup.
Compare the cited behavior/hunk against the supplied baseline; a dirty file list
alone cannot establish provenance.

### confidence

Calibrated 0.0-1.0 per finding:
- **0.80+**: High -- can trace execution path to the issue
- **0.60-0.79**: Moderate -- pattern match but not fully verified
- **<0.60**: Low -- suspicion only, flag as advisory

## Rules

1. Output MUST be a single fenced JSON code block (` ```json ... ``` `)
2. `findings` array MAY be empty (when status is APPROVED)
3. Every finding MUST have all fields -- `suggested_fix` may be `null` only for manual/advisory
4. `title` max 10 words -- it's a label, not an explanation
5. `why_it_matters` explains impact, not symptom -- "Users see stale data after mutation" not "Missing cache invalidation"
6. Deduplicate: if same issue appears in multiple files, report once with the most impactful instance
7. Keep `why_it_matters` and `suggested_fix` to one concrete sentence each
8. Omit praise, preambles, code walkthroughs, and repeated root causes
9. Review-only reports never authorize edits, regardless of `autofix_class`
10. The coordinator rechecks serious claims against the pinned source and records
    fixed, rejected, duplicate, or blocked dispositions with proof. Agreement
    between reviewers is not proof; unavailable evidence stays explicit.
