# Native Poteto composition

Existing skills load only their linked section below, automatically within their
own task. Apply these host adaptations under [compatibility](POTETO-COMPATIBILITY.md).
Source links record provenance, not instructions to invoke explicit-only workflows.
Load a full upstream workflow through its namespaced adapter only when the user
requests it. Preserve the selected model, endpoint, read-only scope and permission
boundaries; no section grants delegation, setup, tool installation or background work.

The [lock](../vendor/pstack.lock.json) owns the current revision. Verify complete
source coverage and reciprocal owner links with
`python3 scripts/vendor-poteto.py --check-routing`. This checks instruction wiring,
not whether a model followed it. Reuse guidance already loaded; skip unrelated sections.

## Execution

Owners: [lifecycle](../development-lifecycle/SKILL.md), [publication](../commit-push-pr/SKILL.md).

For multi-step implementation, name the outcome and smallest independently verifiable
unit. Delete superseded work before adding scaffolding; use a repeatable tool when it
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
compatibility. Isolate independent writers before introducing locks. For retries and
partial failures, derive the next action from observed state and prove reruns converge.
Use the [curated structural probe](POTETO-ENGINEERING.md#probe-the-shortest-wrong-edit)
on the relevant invariant. Preserve useful rationale and external constraints in comments;
encode recurring enforceable rules instead of blindly deleting their explanation.

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

For changed behavior, use a public-contract regression that fails for the intended reason
and survives internal refactoring. This harness's TDD requirements win over upstream's
narrower opt-in policy. Prove the result at the real entrypoint and keep the smallest
rerunnable decisive check. Missing runtime prerequisites are coverage gaps, not reasons
to weaken journeys. Prefer the existing project verifier; maintain it when it drifts.

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
After two failed repairs sharing a premise, write that premise down and test it before
another repair. Adversarial axes run inline unless delegation was explicitly requested;
do not import upstream's automatic worktrees, reviewer panel or agents.

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

Sources: [how](../vendor/pstack/skills/how/SKILL.md),
[why](../vendor/pstack/skills/why/SKILL.md),
[recall](../vendor/pstack/skills/recall/SKILL.md),
[ketchup](../vendor/pstack/skills/ketchup/SKILL.md),
[in your own words](../vendor/pstack/skills/in-your-own-words/SKILL.md),
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

Owners: [agent writing](../writing-for-agents/SKILL.md), [hook audit](../hook-audit/SKILL.md).

When a correction repeats, find the mistake class and encode it at the strongest existing
owner: architecture, types, lint/runtime checks, tests, then prose for irreducible judgment.
Prove a new check catches a real past mistake and accepts valid work. Transcript reflection
is inline and recommend-only unless edits were requested; telemetry gaps stay unknown.
Update the existing skill instead of adding a competing mode. Personal mode creation,
automation and configuration changes require their own requested scope.

Sources: [correct](../vendor/pstack/skills/correct/SKILL.md),
[reflect](../vendor/pstack/skills/reflect/SKILL.md),
[automate me](../vendor/pstack/skills/automate-me/SKILL.md),
[encode lessons](../vendor/pstack/skills/principle-encode-lessons-in-structure/SKILL.md).

## Delegation

Owners: [swarm](../swarm/SKILL.md), [efficient frontier](../efficient-frontier/SKILL.md).

Only an explicit delegation request enters this branch. Partition independent ownership
for coverage work; use bounded candidates and a common acceptance check for a requested
bakeoff. Review each result, rerun decisive claims and synthesize in the primary context.
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
