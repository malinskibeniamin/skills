# Claude model prompting and handoffs

Load for Fable work, Claude prompt changes, or a model handoff.
[Routing](../config/model-routing.json) owns roles and the owner-selected `xhigh`
effort. This guidance changes neither the active host model nor delegation consent.

## Task contract

Describe the result, relevant inputs, scope, permitted actions, proof and endpoint;
let the model choose the implementation path. Name tool-use triggers and expected
results precisely. Prefer observable checks over instructions to think harder or
expose internal reasoning. Keep source documents/logs separate from instructions.

- **Completion:** continue through the requested endpoint. Diagnose routine errors,
  timeouts and empty results; retry safe reads/checks or correct the request. Read
  back uncertain writes before retrying. Advance work independent of an open
  question; stop for deliberately withheld access or a reserved decision.
- **Ownership:** the user owns the repository. Own the requested change end to end,
  reuse existing helpers and repair related in-scope defects. Broad declarations
  that the model owns the whole codebase invite unrequested restructuring.
- **Approval:** name the exact reserved actions and put their authorization exception
  in the same rule. Keep earlier local/read-only stops; routine verification and
  authorized feature-branch delivery need no repeated permission prompt.
- **Progress:** in interactive work, give an opening line and brief updates every few
  tool calls, then a self-contained result with evidence and limits. Status is not
  completion. Reuse [communication](communication.md), not a second report template.

## Fable-specific calibration

Use `xhigh` because the owner chose it, not because it is proven optimal. The official
guide starts at `high`; compare efforts only through an authorized evaluation.
Give outcomes and checks rather than a prescribed reasoning script. Keep actual
user budgets, but omit invented token allowances or large budget reminders.
Keep earlier answers open to correction; Opus chat advice to treat them as finished
does not transfer safely to Fable. Control reply length with the output contract,
not commands to suppress thinking. Trim obsolete cautions instead of stacking more.

At `xhigh`, Fable may start review subagents readily: keep the explicit-consent gate
in the brief. Authorized delegation needs independent value beyond the setup,
context and integration cost; one dependent chain stays with one owner.
For an authorized cross-model agent, pass `xhigh` through the host's explicit effort
control and verify the actual model/effort. Claude Code inherits session effort only
on the same model; built-in Explore can use Opus under a Fable parent. A profile
pointer does not pin a runtime model. Report unsupported controls rather than
silently changing environment defaults or forcing every worker onto Fable.

## Handoff and compatibility

- Switch at a verified checkpoint. Carry objective, constraints, decisions, exact
  paths/revisions, passing/failing checks and remaining work in a compact summary.
  Preserve the endpoint; do not depend on another model reading private thinking.
- Confirm host/provider access before selection. Claude Code needs **2.1.321+** for
  Fable 5.2; use `claude-fable-5-2`, then verify `xhigh` explicitly. Aliases and saved
  effort defaults can differ. Usage-credit consent remains a separate decision.
- For a large existing Claude Code session, compact before an authorized switch or
  use a summarized fresh session when authorized. Switching models does not reuse
  the old model's cache. Do not create a session merely because a route exists.
- Apply system/tool prompt edits to new API conversations. For a live Fable history,
  append new instructions in the newest turn; preserve prior system, tools, messages
  and thinking blocks. Use supported compaction/context editing, not rewritten
  prefixes. A generic retry cannot repair a prefix mismatch.
- **Custom API harnesses only:** keep history append-only, allow adaptive thinking,
  use `tool_choice: auto` with strict tools, and dispatch response blocks by `type`.
  Fable/Opus do not accept disabled thinking or forced tool choice. Progress display
  requires provider-supported thinking updates; text-only rendering can look silent.
  This repository ships guidance, not an API client or a renderer. Confirm SDK and
  platform support before adding beta controls; preserve refusal/access boundaries.

## Evidence and sources

### Skill coverage

The live inventory is `.claude-plugin/plugin.json`, not a second model catalog.
Skills inherit the selected host model; Fable is the demanding-work role, not a
mandatory replacement for every skill. Fresh Fable sessions, compaction and model
switches receive the installed profile pointer. Authorized children receive a
conditional pointer: built-in agents such as Explore need not use their parent's model.

| Skill family | Configuration owner |
|---|---|
| Curated workflows, specialists and the model-neutral Cursor CLI adapter | Session context, this profile and [efficient frontier](../efficient-frontier/SKILL.md); retain each skill's outcome and endpoint |
| Poteto adapters | [Compatibility](POTETO-COMPATIBILITY.md) and generated role assignments; pinned source defaults do not select models |
| Matt Pocock adapters | [Compatibility](MATT-POCOCK.md); preserve explicit-only invocations and scoped ownership |
| Interface adapters | [Compatibility](INTERFACES.md); Opus keeps UI taste ownership, even in a larger Fable-led task |
| tstack adapters | [Compatibility](TSTACK.md); no automatic review panel, session switch or hidden fallback |
| T3/Effect adapters | [Compatibility](T3CODE-SKILLS.md); use the target's verifier rather than repeated generic test reminders |

`bash scripts/generate-skill-catalog.sh --check` validates all registered skill and
agent execution metadata before publishing discovery. Keep models inherited,
effort within the configured policy, and hooks deterministic; skill activation
does not authorize forked contexts or agent/prompt hooks. Verification of review
feedback remains with the author and the deterministic completeness hook.
Use `bun test ./scripts/skill-catalog.test.ts` for known-bad/valid metadata controls.
The guard checks declarative metadata, not arbitrary command bodies or prose.
This is a configuration audit, not a deep behavior evaluation of every skill.

Run existing deterministic route/admission tests for wiring. Use opt-in
[context ablation](../agent-evals/context-ablation/README.md) for prompt comparisons
and [capability probes](../agent-evals/capability-probes/README.md) for task quality.
Hold tasks, effort, acceptance checks and session setup fixed; include hard-tail
failures and observed task cost. Missing paid trials mean behavior and savings are
unmeasured, not a demonstrated improvement or subscription-capacity estimate.

Verified 2026-11-10 against the official
[selection playbook](https://claude.dev/blog/which-claude-model-should-you-build-with/),
[Fable prompting guide](https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/prompting-claude-fable-5-2),
[Opus prompting guide](https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/prompting-claude-opus-5-5),
and [Claude Code configuration](https://code.claude.com/docs/en/model-config).
Agent model/effort inheritance follows the
[Claude Code subagent reference](https://code.claude.com/docs/en/sub-agents).
Owner policy deliberately retains xhigh, Opus UI ownership and Sol review; the
playbook's smaller workers and advisor pattern are not enabled.
