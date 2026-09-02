---
name: maintain-verification-skill
description: Audit a project-local verifier and feature map against source and live behavior. Use when either may be stale or hiding regressions.
---

# Maintain a verification skill

Keep a verifier and its feature map honest. Cover every mapped feature from source and live behavior. Return one outcome: **clean**, **changed**, or **blocked**.

## Fence

Edit only the verification skill directory: its `SKILL.md`, feature map, and owned helpers. Never edit product code. A behavior the app no longer provides is documentation drift or a product regression; repair the former and report the latter.

## Pass

1. **Locate.** Use the one project-local `verify-*` skill with Launch, Doctor, Drive, Evidence, Cleanup, and a feature map. If none exists, route to `/create-verification-skill`. If several exist and scope does not identify one, ask which verifier owns the run.
2. **Reconcile the index.** Compare `features/README.md` with sibling feature files. Remove dead entries and add missing concrete user surfaces found in routes, commands, menus, or public docs.
3. **Source coverage.** For every feature, trace current entrypoints, stable handles, prerequisites, and observable outcomes. Record likely drift with source pointers and one live recipe. Inspect sequentially unless the user explicitly authorizes delegation.
4. **Live coverage.** Run the verifier's doctor, then drive every feature at least once. Use one isolated long-lived instance for UI/services or a fresh isolated session per short-lived CLI, as the verifier specifies. Capture evidence before cleanup.
5. **Recover safely.** After a surprising drive, doctor again; when doctor cannot see a wedged state, reset or relaunch. Clean failed-iteration residue without deleting evidence. Re-run every harness repair live.
6. **Triage.** Wrong user description is doc drift. Working behavior the harness cannot drive is a harness gap. Broken product behavior is a product gap: report it and leave product code unchanged.
7. **Finish.** Tear down what the run created and confirm evidence remains. Re-read changed verifier files. Deliver through the caller's requested endpoint.

## Receipt

- **Outcome:** `clean | changed | blocked`.
- **Coverage:** each feature with source and live evidence.
- **Corrections:** map, instructions, or helper fixes plus replay result.
- **Product gaps:** concrete behavior defect and reproduction, not papered over in the verifier.
- **Limits:** unreachable prerequisite, route attempted, and remaining risk.

`clean` requires source and live coverage for every mapped feature. `changed` requires a successful replay of every correction. `blocked` names the exact missing prerequisite.
