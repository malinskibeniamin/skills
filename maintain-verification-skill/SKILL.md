---
name: maintain-verification-skill
description: Audit a project-local verifier and feature map against source and live behavior. Use when either may be stale or hiding regressions.
---

For behavior/verifier checks, read [Poteto](../shared/POTETO-NATIVE.md#verification).

Cover every feature in source/live behavior. Return **clean**, **changed** or **blocked**.

## Fence

Edit only the verification skill directory: its `SKILL.md`, feature map, and owned helpers. Never edit product code. Repair doc drift; report product regressions.

## Pass

1. **Locate.** Find the local verifier by capability, not a `verify-*` prefix. T3 Code: use [native verification](../shared/T3CODE-SKILLS.md#native-verification). Uncovered flows: `/create-verification-skill`. Ask if ownership is unclear.
2. **Reconcile the index.** Compare `features/README.md` with sibling feature files. Remove dead entries; add missing surfaces from routes, commands, menus or public docs.
3. **Source coverage.** Trace each feature's entrypoints, stable handles, prerequisites and outcomes. Record source drift and live recipes. Inspect sequentially unless delegation is authorized.
4. **Live coverage.** Run the verifier's doctor, then drive every feature at least once. Use one isolated long-lived instance for UI/services or a fresh isolated session per short-lived CLI, as the verifier specifies. Capture evidence before cleanup. For new, changed or suspect decisive assertions, [prove the check can fail](../create-verification-skill/SKILL.md#prove-the-check-can-fail); use a separate isolated run for the known failure.
5. **Recover safely.** Check [replay packets](../shared/verification-replay.md) for fixture/schema drift and feature fidelity. After a surprising drive, doctor again; when doctor cannot see a wedged state, reset or relaunch. Clean failed-iteration residue without deleting evidence. Re-run every harness repair live.
6. **Triage.** Fix wrong user descriptions and driver gaps. Report broken product behavior without editing it.
7. **Finish.** Tear down run resources; keep evidence. Re-read changes and honor the requested endpoint.

Compare cold-start/journey duration and repeatability against baseline. Diagnose flakes through [test audit](../test-audit/SKILL.md#flaky-checks);
prune obsolete/duplicate recipes only after identifying remaining contract ownership.

## Receipt

- **Outcome:** `clean | changed | blocked`.
- **Coverage:** each feature with source and live evidence.
- **Corrections:** map, instructions, or helper fixes plus replay result.
- **Product gaps:** concrete behavior defect and reproduction, not papered over in the verifier.
- **Limits:** unreachable prerequisite, route attempted, unverified assertion sensitivity, and remaining risk.

`clean` requires source and live coverage for every mapped feature. `changed` requires a successful replay of every correction. `blocked` names the exact missing prerequisite.
