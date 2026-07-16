# Remaining authors (weights 6 → 2) — calibrated mining

> Depth scaled to weight: diffs read for Engineer E/Engineer F; subject-level profiling below that. Weights ≤4 = context, not convention (per author-weights.md).

## Engineer E (engineer-e) — weight 6

Corpus: 241 cloudv2 frontend commits (2022-07 → 2026-06, cloud-ui/admin-ui) + 20 console. Domain: **visual polish and perceived performance**.

- **P1 — Kill navigation flicker at the media layer** — avatar flickered on every route change because the image fallback re-rendered; fix: `ignoreFallback` + `loading="eager"` on the Avatar (`34775452f3`, 2025-06-20). Class: media fallback/skeleton states firing on remount read as jank; pin them. Related: usermenu styles (`e6b7ae4641`), nav logo alignment (`57514a4c2b`). Enforcement: `skill` — extends Engineer A's "loading reserves layout" (design-taste P13) to the image-fallback layer.
- **P2 — Modals must name their subject** — "fix resource group modal not saying the group" (`5435f3351d`): destructive/confirm dialogs state WHICH entity they act on. Enforcement: `skill`, pairs with the resilience-review destructive-action hat.
- Steady "cleanup" commits (`25d4ad1f4c`, `5511883293`) — leaves panels tidier than he found them.

## Engineer F — weight 5

Corpus: 467 cloudv2 frontend commits (2023-07 → 2024-09 core era, cloud-ui) + 31 console. Domain: **billing/cluster-wizard UX and interaction correctness**.

- **P1 (anti-pattern, validated) — Right requirement, wrong altitude** — cmd/ctrl-click on cluster rows opened nothing because rows navigated via `window.location.href` in an onClick; his fix added a modifier-key check calling `window.open` (`166e31beee`, 2024-09-19). The requirement (native link affordances) was right; the durable fix is a real `<Link>`/anchor — exactly what the 2026-01 TanStack migration + the harness `no window.location` rule institutionalized. Keep as the canonical evidence commit for WHY that hook exists.
- **P2 — Rows that act like links must expand/collapse where users click** — Billing Activity row expands on whole-row click (`8d4db76e72`). Click targets match the visual affordance.
- **P3 — Flag hygiene** — "Cleanup SSO feature flag as it is now enabled for all" (`0bb307473b`) — same flag-removal-as-done discipline Engineer C showed (engineer-c.md P3), one more convergence witness.
- Wizard-step fixes (`f198ab6e67` wrong filter in ClusterSettingsStep, `7b2396c060` GCP project ID in DeleteAgentStep) — multi-step create flows are where his fix-ore concentrates; feeds the resilience-review forms hat.

## Engineer G (engineer-g) — weight 4

Corpus: ~1,450 console commits (2020 → 2024, the OSS predecessor co-founder era, mostly backend/infra + frontend touches) + 156 cloudv2 frontend commits **all since 2026-02** in adp-ui. Recent signal outweighs old: his 2026 run is create-flow unification — "unify create flows on shared shell + AutoForm" (`f009b75ef0`), e2e reconciliation with reworked flows (`f48fa3459b`, `e039e9dcab`), react-doctor strict-gate clears (`3c1bf073db`, `be64564377`). Treat as: **the shared create-flow shell + AutoForm pattern in adp-ui is co-owned by him — exemplar-worthy; his e2e-reconciliation commits show migrations must update tests in the same PR.** Console-era structural patterns: superseded, do not encode.

## Engineer H (engineer-h) — weight 4

Corpus: 303 cloudv2 frontend commits (2022-09 → 2026-07) + ~199 console. Current domain: adp-ui Cedar policy authoring. One standout worth stealing regardless of weight: **convention tests as executable lint** — "test(adp-ui): enforce route files export a Route" + "move non-route helpers out of the route" (`3be474bedd`, `c119052926`, 2026-07-10): repo conventions encoded as unit tests that fail on violation. Same idea as this harness's hooks, living in the repo itself. Also round-trip tests for the Cedar unless-clause parser (`160e765cf9`, `ab65409fd2`) — parser/serializer pairs get round-trip property tests. Enforcement: `skill` (route-file discipline is already a harness rule; the convention-test technique is the transferable part).

## Engineer I (engineer-i) — weight 3

Corpus: 264 cloudv2 frontend commits (2022-10 → 2026-07) + ~64 console. Full-stack, backend-leaning: recent work is adp cost/spending — proto regeneration, AIP-safe renames (`ecdde2e62c` ListSpendingTagKeys → GetSpending...), hook extraction on review feedback (`13e0c6f804`, `f8a8fa3d2a`, `597d8a96db`). Signal: her frontend commits consistently absorb review feedback in dedicated commits — useful as PR-flow context, not as taste evidence. Context only.

## Engineer J — weight 2

Corpus: 78 cloudv2 frontend commits (2023-06 → 2026-06); 1,850+ total cloudv2 commits are overwhelmingly backend/infra. Frontend touches are ops-flavored (Grafana dashboard links, install-pack links, dep overrides, display fields on network pages). Context only; no patterns encoded.

## Engineer K (engineer-k) — weight 2

Corpus: 349 cloudv2 frontend commits (2025-09 → 2026-07) + 105 ui-registry (#2 registry committer) + 59 console. High volume in wizard/onboarding surfaces; subjects skew reactive ("fixes 3 bugs found when testing on integration", "revert wizard route fix", "fixed flakey org delete test", "copy updates"). Per weight 2: **do not use as taste evidence**; her surfaces (signup wizard, org flows) are where reviewers should look hardest. Her ui-registry volume means registry `git blame` hits her often — weight accordingly when using blame as evidence.

## Cross-author convergences added by this tier
- Flag-removal-as-done: Engineer F (`0bb307473b`) + Engineer C (P3) + architecture M1 → three witnesses.
- Native link affordances: Engineer F's `166e31beee` is the "before" proving the harness `<Link>`/no-window.location hook.
- Migrations update their tests in the same PR: engineer-g's 2026 e2e-reconciliation commits + Engineer C's e2e assertions (P3).
