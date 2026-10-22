# Fit for this harness

**Recommendation: pilot, conditionally.** Use one supervised task to test whether repeated
handoff work is worth automating. This repository supplies delivery instructions and
checks, not evidence that an unattended factory would save time. No infrastructure is
provisioned by this skill.

## Evidence and blind spot

Observed on 2026-10-22: a GitHub origin; [author delivery](../shared/delivery-workflow.md),
[review](../review/SKILL.md), [triage](../triage/SKILL.md), and
[routine setup](../setup-routines/SKILL.md) owners;
[deterministic CI](../.github/workflows/evals.yml); and
[candidate-bound review gates](../scripts/review-gates.ts).
These are reusable building blocks, not proof that agents follow them remotely.
CI does not prove branch protection or review enforcement is enabled; inspect hosted
settings before relying on them.

Unknown: eligible backlog frequency, time spent dispatching or recovering work, rejection
rate, reviewer capacity, provider spend, and required remote/private-network access.
The largest blind spot is whether handoff toil, rather than unclear work or human review,
is the bottleneck. Benefit and savings are **not established**.

## Alternatives

- **No factory:** improve ticket acceptance and the existing `/work` loop. Best when
  tasks are irregular or review is saturated; no new operational surface.
- **Supervised pilot:** manually dispatch one well-scoped task in the existing host;
  preserve its selected model, current branch ownership, checks, and draft-PR endpoint.
  Inspect the outcome before dispatching another. This is not a disposable remote runner.
- **Remote event-driven factory:** only after the pilot demonstrates value and recovery
  semantics. Start with existing GitHub services; add a tracker or workflow engine only
  when an observed integration or durability gap justifies it.

## Proposed first task: ready ticket to draft PR

This is a design contract, not an installed workflow or authority to execute one.

| Part | Initial choice |
| --- | --- |
| Beneficiary | Maintainer repeatedly dispatching bounded, testable changes |
| Trigger | Explicit human request naming one ready ticket and repository |
| Reads | Ticket acceptance, trusted repo instructions, current code and branch state |
| Writes | One owned feature branch and one draft PR; no ticket closure or merge |
| Next trigger | None automatically; maintainer inspects the result |
| Human re-entry | Review the draft or supply missing acceptance; end blocked work visibly |
| Duplicate control | Inspect existing ticket-linked branch/PR before dispatch; no concurrent owner for that ticket |
| Verification | Failing public-contract test, green focused tests, repo checks, applicable review evidence bound to current head/base |
| Limits | One active task; no automatic retry; set deadline and spend ceiling before remote execution |
| Recovery | Retain branch/PR and evidence; reconcile unknown writes before any retry |
| Stop | Scope ambiguity, failed gates, unsafe access, exhausted budget, or draft PR ready for human review |

For a later remote design, fill every slot: GitHub Issues (tracker), human request
(ticket source), GitHub (git host), manually dispatched Actions (orchestrator), hosted
ephemeral CI runner (runner), existing run pages (observability). This is a proposal;
agent availability, auth, costs, network policy, and check parity still need verification.

## Setup dependencies and decision gates

1. **Maintainer:** select eligible tasks, baseline human effort/rework, a bounded observation
   window, and a minimum useful improvement. Record unknown usage as unknown.
2. **Agent, read-only:** inventory current host tools, branch rules, checks, tracker events,
   identities, and required access. Recommend reuse before adding infrastructure.
3. **Maintainer/security owner:** reserve decisions on paid services, credentials/scopes,
   data export/retention, private-network access, and production changes.
4. **Authorized implementer, later:** build one opt-in trigger with durable work claims,
   result lookup, attempt/deadline/spend limits, redacted evidence, and teardown. Prove
   duplicate delivery, crash-after-write recovery, failed checks, and kill-switch behavior.
5. **Maintainer:** compare accepted outcomes and human review/recovery effort against the
   baseline, including agent/runtime spend. Expand only if the agreed benefit is observed.

Disable the trigger to stop new runs, cancel owned active runs through the orchestrator,
reconcile any in-flight writes, and revoke dedicated credentials. Preserve tickets,
branches, PRs, and audit evidence. Revert the opt-in integration to return to manual work.
