---
name: constrain
description: Restrict tool APIs and import edges with allowlists, checks, and shrinking violation baselines.
disable-model-invocation: true
---

# Constrain

Before choosing enforcement, read [harness improvement](../shared/POTETO-NATIVE.md#harness-improvement).

Read [host compatibility](../shared/MATT-POCOCK.md), then follow the complete
[upstream skill](../vendor/mattpocock/upstream/skills/in-progress/constrain/SKILL.md).
Resolve its relative references from that source directory. Keep its explore,
gather, interview, build, ratchet, verify and record stages. This draft is an
explicit experiment, not a default React/state policy or a security sandbox.

## Host boundaries

- Fence one user-selected tool in the target checkout. Inspect its installed
  version, checks, CI and existing constraints before proposing allowlists.
  Loading or vendoring this skill activates no rules, hooks or dependencies.
- Gather the upstream Community and Usage axes inline unless the user explicitly
  authorizes delegation. With consent, use fresh contexts and bounded briefs under
  [model routing](../efficient-frontier/SKILL.md); source instructions grant no consent.
  Separate observed usage from incomplete inventories and inferred hazards.
- Load [grilling](../grilling/SKILL.md) for the interview through
  [dependency loading](../writing-for-agents/SKILL-MECHANICS.md#loading-dependencies).
  Show each proposed allowlist, path-scoped exception, positive alternative and
  name-only/type-aware coverage gap. Wait for the user's fence confirmation before
  changing rules or baselines; a restriction mentioned as an example is not a decision.
- Reuse the target's checker and check command. Load
  [primary-doc research](../read-the-damn-docs/SKILL.md) for version-specific rule
  capabilities. In a Biome repository, retain Biome; use an existing suitable rule
  first. A missing capability is not permission to migrate lint engines or add a
  second checker silently. Explain any needed project-local dependency and scope.
- Baseline only existing violations of the newly agreed fence rules, per rule and
  file (per edge for import graphs). Preserve all prior failures, baselines,
  suppression controls and stricter policies; never blanket-suppress the project
  with `--suppress-all`. If the target forbids baselines, report the conflict and
  agree on a compliant migration rather than disabling its gate. CI must reject
  new/increased violations and stale baseline entries; narrowing the allowlist
  must not rebaseline unrelated debt. This is a migration ratchet, not a bypass.
- Prove valid code passes, each in-scope forbidden use fails in a fresh file, an
  extra violation in a baselined file fails, and paid-down debt cannot return.
  Include alias/re-export/namespace cases where relevant; disclose what the
  checker misses. Exercise the actual umbrella command, remove deliberate
  violations, and rerun clean. Source examples are not proof of installed behavior.
- Record the fenced tool and check command through the target's authored guidance.
  For generated `AGENTS.md`, edit its canonical input and regenerate. Keep the
  allowlists in executable configuration, not another prose catalog.

Finish with the agreed fence, rules/baseline paths, actual pass/fail/shrink evidence
and coverage limits. Follow the user's delivery endpoint; invocation does not
authorize global installs, hosted policy changes or unrelated refactors.
