# CI remediation verification

Candidate `92e3c69332d555f6eb4633025ea01d7b5f707367`; actual merge-base `5afa36171641321cc55e1897e1c7e67ec1e1f9ee`.

- Reproduced Biome format failure; narrow format fix passes quality gate.
- Translation freshness: 36 stale / 279 current -> 315 current, after source/locale review and reconciliation of 15 pages. Exactly 36 reviewed stamps changed.
- Lifecycle matcher fixture RED: 2 failures -> GREEN: 40 assertions. Slash invocations still rejected; dependency file paths not treated as invocation ceremony. Case-insensitive imperative matcher preserves both required dependency paths; 13 release-workflow assertions pass.
- Restored single-owner, volatile-unknown, smallest-change, failure-loop and exit-criterion contracts; token caps unchanged. Lifecycle 2891 bytes (cap 2900), delivery 3307 (cap 3375).
- Required lint:fix/type:check, quality gate and 24 typed tests passed. Docs check: 1194 pages, zero issues; docs build passed.
- Normal focused browser run: 96 passed. Reviewed 34 base/candidate pairs, 24 new locale baselines and 22 intended updates. No blanket update or threshold relaxation.
- Hook suite: 617 passed, 4 skipped; six suites passed.
- Full local eval run in clean copy: 5196 passed, 5 failed. Two failures replay green after path canonicalization and the case-aware matcher repair. Three local qualification failures remain (session-summary CLI qualification, lockfile drift and inverse drift); local Bun/agent CLIs differ from pinned CI. Remote CI is authoritative, not claimed from local proxies.
- Inline review: instruction contracts, translation source comparison, dependency links, snapshot layout and matcher false positives inspected. No remaining candidate defect observed in this scope. Future agent compliance/productivity unproven.
- Dogfood: current CI task exercised canonical lifecycle and delivery guidance without delegation; docs navigation, scroll and keyboard focus exercised. No downstream installs or spec execution.

Original full browser baseline-drift disclosure remains: 95 passed / 38 failed; all 38 failing actuals byte-identical to rebuilt base. This is not a full-browser-suite PASS.
