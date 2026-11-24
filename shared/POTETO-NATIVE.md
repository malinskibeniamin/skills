# Native Poteto composition

Existing skills load only their linked section below, automatically within their
own task. Apply these host adaptations under [compatibility](POTETO-COMPATIBILITY.md).
Source links record provenance, not instructions to invoke explicit-only workflows.
Load a full upstream workflow through its namespaced adapter only when the user
requests it. Preserve the selected model, endpoint, read-only scope and permission
boundaries; no section grants delegation, setup, tool installation or background work.

The [lock](../vendor/pstack.lock.json) owns the current revision. Verify complete
source coverage, section targets and reciprocal owner links with
`python3 scripts/vendor-poteto.py --check-routing`. This checks instruction wiring,
not whether a model followed it. Reuse guidance already loaded; skip unrelated sections.

## Execution

Owners: [lifecycle](../development-lifecycle/SKILL.md), [publication](../commit-push-pr/SKILL.md).

For multi-step implementation, name the outcome and smallest independently verifiable
unit. On an agent mistake, use the [correction tree](#harness-improvement) before repairing.
Delete superseded work before adding scaffolding; use a repeatable tool when it
does or proves the work more reliably than manual edits. Verify each unit before the
next. For migrations, converge on the target without throwaway internal compatibility;
preserve public contracts and a usable delivery sequence. Continue reversible choices
within the requested endpoint. Keep long-run decisions, evidence and pause triggers in
the existing local checkpoint, not a second mandatory log or a new approval gate.

Sources: [mode](../vendor/pstack/skills/poteto-mode/SKILL.md),
[figure it out](../vendor/pstack/skills/figure-it-out/SKILL.md),
[decision trail](../vendor/pstack/skills/show-me-your-work/SKILL.md),
[build the lever](../vendor/pstack/skills/principle-build-the-lever/SKILL.md),
[outcome-oriented execution](../vendor/pstack/skills/principle-outcome-oriented-execution/SKILL.md),
[verifiable units](../vendor/pstack/skills/principle-sequence-verifiable-units/SKILL.md),
[subtract first](../vendor/pstack/skills/principle-subtract-before-you-add/SKILL.md),
[reversible decisions](../vendor/pstack/skills/principle-never-block-on-the-human/SKILL.md).

## Design

Owners: [codebase design](../codebase-design/SKILL.md), [domain modeling](../domain-modeling/SKILL.md),
[frontend invariants](../frontend-invariants/SKILL.md), [resilience review](../resilience-review/SKILL.md).

When interfaces, types or shared state change, sketch caller success and failure before
implementation. Put domain rules in the owning data shape, parse external data at the
seam, and trust validated internal types. Prefer deletion and fewer layers over a new
wrapper. Migrate internal callers before deleting the old API; preserve required public
compatibility. Isolate independent writers before introducing locks. For retryable writes,
derive the next action from observed state; probe a second run and recovery after a
meaningful partial write. Leftover locks, claimed jobs and temporary files need a stale-state
test that remains valid wherever the prior run stopped; their presence alone proves neither
liveness nor completion. Verify reconciliation preserves completed effects without duplicates.
Use the [curated structural probe](POTETO-ENGINEERING.md#probe-the-shortest-wrong-edit)
on the relevant invariant. Preserve useful rationale and external constraints in comments;
encode recurring enforceable rules instead of blindly deleting their explanation.
For a correction, choose its owning layer with the [correction tree](#harness-improvement).

Sources: [architect](../vendor/pstack/skills/architect/SKILL.md),
[comments and constraints](../vendor/pstack/skills/no-comments/SKILL.md),
[foundations](../vendor/pstack/skills/principle-foundational-thinking/SKILL.md),
[domain model](../vendor/pstack/skills/principle-model-the-domain/SKILL.md),
[boundary discipline](../vendor/pstack/skills/principle-boundary-discipline/SKILL.md),
[type discipline](../vendor/pstack/skills/principle-type-system-discipline/SKILL.md),
[TypeScript](../vendor/pstack/skills/typescript-best-practices/SKILL.md),
[laziness](../vendor/pstack/skills/principle-laziness-protocol/SKILL.md),
[reader load](../vendor/pstack/skills/principle-minimize-reader-load/SKILL.md),
[first principles](../vendor/pstack/skills/principle-redesign-from-first-principles/SKILL.md),
[migrate callers](../vendor/pstack/skills/principle-migrate-callers-then-delete-legacy-apis/SKILL.md),
[separate shared state](../vendor/pstack/skills/principle-separate-before-serializing-shared-state/SKILL.md),
[idempotency](../vendor/pstack/skills/principle-make-operations-idempotent/SKILL.md).

## Product and planning

Owners: [product](../product/SKILL.md), [grilling](../grilling/SKILL.md), [prototype](../prototype/SKILL.md).

For a material product or design fork, name the beneficiary and the question whose answer
changes the decision. Resolve observable facts with the cheapest faithful probe. For novel
interactions without precedent, compare a few distinct prototypes rather than polish the
first idea. Tighten the central user or caller journey; do not grow scope merely to make
the task sound deeper. Reserve genuine preference and irreversible decisions for their
owner; a resolved reversible assumption does not need a planning pause.

Sources: [sharpen](../vendor/pstack/skills/sharpen/SKILL.md),
[experience first](../vendor/pstack/skills/principle-experience-first/SKILL.md),
[design space](../vendor/pstack/skills/principle-exhaust-the-design-space/SKILL.md).

## Verification

Owners: [TDD](../tdd/SKILL.md), [test audit](../test-audit/SKILL.md), [dogfood](../dogfood/SKILL.md),
[blast radius](../blast-radius/SKILL.md), [create verifier](../create-verification-skill/SKILL.md),
[maintain verifier](../maintain-verification-skill/SKILL.md), [formal laws](../bend-laws/SKILL.md).

Apply [proportionate verification](verifiability.md#proportionate-verification): reuse
existing checks, adding a public-contract regression only for a credible uncovered risk.
When added, it must fail for the intended reason and survive internal refactoring.
Prove the result at the relevant entrypoint with the smallest decisive check; keep output
temporary unless it has a concrete maintenance purpose. Missing runtime prerequisites are
coverage gaps, not passing evidence. Prefer the existing project verifier.
When verification exposes an agent mistake, apply the [correction tree](#harness-improvement)
before adding another test, warning or instruction.

When the task explicitly asks for formal verification or a checked statechart, select the
tool for the property and stated bounds, then replay model counterexamples against real
code. A model proof does not prove implementation equivalence. Report unchecked rules,
state bounds and abstractions. Do not automatically run the vendored `statechart` wrapper:
its first run installs Java/TLC through mise and its rendering path has external tooling.
Use the host's authorized rendering/media tools; missing tools remain a named gap.

Sources: [TDD](../vendor/pstack/skills/tdd/SKILL.md),
[blast radius](../vendor/pstack/skills/blast-radius/SKILL.md),
[create verifier](../vendor/pstack/skills/create-verification-skill/SKILL.md),
[maintain verifier](../vendor/pstack/skills/maintain-verification-skill/SKILL.md),
[create formal verifier](../vendor/pstack/skills/create-formal-verification-skill/SKILL.md),
[maintain formal verifier](../vendor/pstack/skills/maintain-formal-verification-skill/SKILL.md),
[statechart](../vendor/pstack/skills/statechart/SKILL.md),
[prove it works](../vendor/pstack/skills/principle-prove-it-works/SKILL.md),
[behavior tests](../vendor/pstack/skills/principle-test-behavior-not-implementation/SKILL.md).

## Review and diagnosis

Owners: [review](../review/SKILL.md), [diagnosis](../diagnosing-bugs/SKILL.md).

For a suspected defect, state the intended result and construct a counterexample through
the real interface. Execute the check when safe and available; distinguish source-grounded
findings from unexecuted hypotheses under the review owner's evidence rules. Deduplicate
root causes and retain exact commands/results. Review stays read-only; fixes need author
scope. Debug from the first incorrect transition rather than adding symptom guards.
After two failed repairs sharing a premise, write it down and predict an observation that
would differ if it were false. Run that probe before another repair; compare which cases
fail, not only failure size. Follow the result back to the cause rather than adding cleanup
that repeatedly compensates for it. Adversarial axes run inline unless delegation was
explicitly requested; do not import upstream's automatic worktrees, reviewer panel or agents.
For authorized repairs, use the [correction tree](#harness-improvement); a passing
regression is not permission to keep the same mistake available in an unchecked caller.

Sources: [interrogate](../vendor/pstack/skills/interrogate/SKILL.md),
[root causes](../vendor/pstack/skills/principle-fix-root-causes/SKILL.md),
[attack the premise](../vendor/pstack/skills/principle-attack-the-premise/SKILL.md).

## Measurement

Owner: [quantify impact](../quantify-impact/SKILL.md).

Before measuring or reporting a number, write the decision it could change and the noise
floor. Identify the limiter with a profile or runtime counters, not a source-reading guess.
Rule out errors, omitted work, caching, untuned comparisons and load-generator limits.
Keep run count, spread and limiter with the result. For benchmarks apply the full validity
checklist; model/eval claims also need representative trials. Preserve the impact owner's
worthwhile-delta and suppression rules; an unexplained number is not an improvement claim.

Sources: [benchmark checklist](../vendor/pstack/skills/benchmark-checklist/SKILL.md),
[explain the number](../vendor/pstack/skills/principle-explain-the-number/SKILL.md).

## Orientation and explanation

Owners: [prime](../prime/SKILL.md), [research](../research/SKILL.md), [teach](../teach/SKILL.md),
[show me](../show-me/SKILL.md).

For a resume, explanation or design-history question, separate observed behavior, recorded
rationale and inference. Recheck branch and live state before trusting earlier chat claims.
Trace behavior from entrypoint to owner and cite decisive source/history, not plausible
intent. Summarize what changed and genuine pending human decisions without inventing asks.
Use bounded reads and durable pointers when context fills; bulk output alone never grants
delegation. Keep teaching's existing exercises and the smallest useful visual.
When teaching terminology, ground it in the user's actual problem and a verified example;
distinguish what transfers from neighboring fields from where the analogy breaks.

Sources: [how](../vendor/pstack/skills/how/SKILL.md),
[why](../vendor/pstack/skills/why/SKILL.md),
[recall](../vendor/pstack/skills/recall/SKILL.md),
[ketchup](../vendor/pstack/skills/ketchup/SKILL.md),
[in your own words](../vendor/pstack/skills/in-your-own-words/SKILL.md),
[reframe](../vendor/pstack/skills/reframe/SKILL.md),
[teach](../vendor/pstack/skills/teach/SKILL.md),
[context window](../vendor/pstack/skills/principle-guard-the-context-window/SKILL.md).

## Writing

Owners: [docs](../docs/SKILL.md), [UX copy](../ux-copy/SKILL.md), [agent writing](../writing-for-agents/SKILL.md).

For prose, preserve intent, facts, uncertainty and exact identifiers while replacing jargon
and filler with plain words. Match the document to the reader's task: tutorial, how-to,
reference or explanation. Agent instructions stay executable; UI copy stays accessible.
Follow the existing [reader-attention contract](communication.md), not another reply format.
Only an explicit video-recap request selects the `ketchup-video` adapter: use real captured
evidence, inspect rendered subtitles and holds, and report rendering failure honestly.
Do not generate a video merely because a status or PR was requested.

Sources: [plain language](../vendor/pstack/skills/bro/SKILL.md),
[technical writing](../vendor/pstack/skills/technical-writing/SKILL.md),
[unslop](../vendor/pstack/skills/unslop/SKILL.md),
[video recap](../vendor/pstack/skills/ketchup-video/SKILL.md).

## Harness improvement

Owners: [agent writing](../writing-for-agents/SKILL.md), [hook audit](../hook-audit/SKILL.md),
[harness extension](../extend-harness/SKILL.md), [feedback repair](../resolve-pr-feedback/SKILL.md),
[retrospectives](../retro/SKILL.md), [factory planning](../software-factory/SKILL.md).

### Correction tree

Use on the **first agent correction**, not only after repetition. Name the mistaken
behavior, intended invariant, affected callers and a concrete counterexample. Improve the
environment that produced the mistake, not just the current output. Reuse an existing
enforcement owner; a check that already caught the error needs a repair, not a duplicate.

Choose the earliest effective layer within scope; explain why a stronger layer is unsuitable:

| Layer | Action and proof |
| --- | --- |
| **Design it out** | Remove the invalid choice through the owning API, data shape, state owner or directory seam. Migrate affected callers and old examples; show the shortest wrong use is rejected while valid use works. Avoid an unrelated rewrite. |
| **Check it statically** | Encode a mechanical invariant in existing types, schema, lint, compiler or CI. Give an actionable diagnostic and supported alternative. Replay the known-bad case and valid control through the actual check. |
| **Verify behavior** | For runtime intent, drive the real entrypoint with a representative failure/recovery case. Use existing tests and project verifiers; add coverage only for an uncovered risk. Name what the evidence cannot prove. |
| **Write scoped guidance** | For judgment no check can express, keep one short instruction at its loaded owner, with scope, reason and exceptions. Retire only the prose the new mechanism actually supersedes; preserve rationale, domain constraints and useful documentation. |
| **Human judgment** | Surface unresolved intent, inaccessible evidence or a reserved decision with a precise question. Mandatory review and approval policy still apply at every layer. |

Close the correction in the existing PR, review reply or checkpoint: mistake class,
chosen owner, counterexample, valid result and residual gap. No new mandatory ledger.
Do not lower thresholds, suppress failures or substitute screenshots for speech, side
effects or algorithmic proof. Clear stale in-scope examples so the next agent copies the
supported path rather than a justified workaround. One passing case is not a universal ban.

For runtime verification, use the feature map and driver owned by the existing verifier;
an artifact must demonstrate the requested outcome, not merely show that the app ran.
Formal models and property-based checks are additional tools for suitable invariants.
Name the properties and implementation paths actually linked; a checked model alone
does not establish that the shipped code implements it.

Strengthen this inner loop before recommending more agents, recurring release fuzzing
or a software factory. Human review cost, accepted outcomes and rework matter; token
budgets and merge counts alone establish no trust. Retain explicit merge, deployment,
delegation, spending and persistent-setup permissions. Read-only reflection proposes
corrections; it does not apply them. Missing telemetry stays unknown.

This operationalizes [Lauren Tan's trust pyramid](https://www.youtube.com/watch?v=O_zcc6Xl12g&t=123s)
and [correction principle](https://www.youtube.com/watch?v=O_zcc6Xl12g&t=551s),
without importing team-specific bans or automatic-merge authority.

When the selected improvement deliberately narrows a tool's allowed API or import
edges, recommend the explicit-only [constrain](../constrain/SKILL.md) owner. It
confirms the allowlist and proves a shrinking migration baseline; it is not an
automatic retro action or a replacement for the target's stricter existing checks.

Sources: [correct](../vendor/pstack/skills/correct/SKILL.md),
[reflect](../vendor/pstack/skills/reflect/SKILL.md),
[automate me](../vendor/pstack/skills/automate-me/SKILL.md),
[encode lessons](../vendor/pstack/skills/principle-encode-lessons-in-structure/SKILL.md).

## Delegation

Owners: [swarm](../swarm/SKILL.md), [efficient frontier](../efficient-frontier/SKILL.md).

Only an explicit delegation request enters this branch. Partition independent ownership
for coverage work; use bounded candidates and a common acceptance check for a requested
bakeoff. Review each result, rerun decisive claims and synthesize in the primary context.
Prefer independent end-to-end outcomes over handoffs between frontend/backend layers.
Bound active lanes by operator review/repair capacity as well as verified allowance; finish
or checkpoint a lane before admitting another. A waiting agent or spare subscription
capacity does not outrank the current outcome. Use [priority admission](communication.md#admit-work-by-priority).
Keep the host's model, isolation, tool and lifecycle contracts. No automatic nested agents,
extra provider, background worker or upstream orchestration daemon.

Sources: [swarm](../vendor/pstack/skills/swarm/SKILL.md),
[arena](../vendor/pstack/skills/arena/SKILL.md).

## Setup and automation

Owners: [routine setup](../setup-routines/SKILL.md), [triage](../triage/SKILL.md).

For an explicit pstack/Benny/webhook setup request, select the matching namespaced adapter
and verify host integrations, permitted model roles, secrets delivery, trigger scope and
readiness before enabling anything. Keep triage thread-scoped and deduplicate by cause;
uncertain evidence is not permission to create a ticket or claim a fix. Reproduction
requires a real before/after journey before a bounded draft PR. Missing bot, Slack, tracker
or control tools block only that requested integration. Importing source activates none
of it; do not install Tailscale, expose a server or create a routine as incidental setup.

Sources: [help](../vendor/pstack/skills/poteto-help/SKILL.md),
[pstack setup](../vendor/pstack/skills/setup-pstack/SKILL.md),
[bot UI](../vendor/pstack/skills/make-bot-ui/SKILL.md),
[Benny setup](../vendor/pstack/automations/benny/skills/setup-benny/SKILL.md),
[Benny triage](../vendor/pstack/automations/benny/skills/triage-issue-reports/SKILL.md),
[Benny reproduction](../vendor/pstack/automations/benny/skills/reproduce-and-fix-issues/SKILL.md).
