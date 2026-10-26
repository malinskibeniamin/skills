# Frontend Skills Harness

Skills + hooks for agentic dev. Goal: safer, more reviewable, consistently high-quality AI-assisted work.

## Language

**Skill**:
Specialist instructions expanded into an agent's context when invoked or selected.
Instructions guide behavior; their presence does not prove they were followed.
_Avoid_: Runtime extension, enforcement

**Skill snapshot**:
An immutable copy of upstream skill instructions and their supporting resources,
with source revision, licenses, file digests and executable modes. A snapshot is
reference material, not an installed runtime or proof of behavior.
_Avoid_: Live upstream, runnable checkout

**Skill adapter**:
The local discoverable entrypoint that loads a skill snapshot under host-specific
scope, tooling and permission rules. Keep adaptations separate from upstream bytes.
_Avoid_: Upstream fork, permission grant

**Software factory**:
A system that repeatedly turns ready work into verified code changes through agents,
execution infrastructure, and review gates. Its configured endpoint may be a draft PR;
the term grants no unattended-execution or merge authority.
_Avoid_: Skill collection, automatic merge

**Factory run**:
One execution of a factory task, from trigger to recorded result. It may contain several
agent sessions. A production remote run ends rather than waiting for a human; later
authorized input starts another run from durable tracker, git-host, and orchestrator state.
_Avoid_: Agent session, interactive conversation

**Settings hook**:
An event-triggered command configured by the harness for deterministic checks or
workflow signals. Separate from a mod's typed middleware hook.
_Avoid_: Mod, skill

**Review gate**:
A named review responsibility with applicability, evidence and blocking rules. A skill
supplies guidance; a gate records whether that responsibility was actually reviewed.
_Avoid_: Extra agent, installed skill, human approval

**Gate plan**:
The discovered gate set and routing reasons bound to one candidate and its review inputs.
Missing applicability decisions require review rather than an unexplained skip.
_Avoid_: General implementation plan, permission to delegate

**Gate result**:
A validated review receipt with executor provenance and findings for a gate plan.
Its presence proves neither that its claims are true nor that a human approved the work.
_Avoid_: Sign-off, merge authorization, release certification

**Mod**:
A Claude Code plugin's TypeScript runtime extension for session behavior, commands,
or interface rendering. It runs with the host's machine access, not a security boundary.
_Avoid_: Skill, shell hook, sandbox

**Customer-facing surface**:
Any screen, command output, generated report, interface, or flow an end user sees or acts on. Includes web, mobile, CLI, TUI, desktop, rendered docs, reports.
_Avoid_: UI when not graphical; web page when non-web.

**Workflow brief**:
User-configured objective, guardrails, verification and stop condition that a mod
can add beside future prompts when explicitly enabled. Guidance, not a permission
grant, proof of adherence or persistent project memory.
_Avoid_: System prompt, enforcement, automatic skill selection

**Surface review**:
Multi-hat review of a customer-facing surface: product clarity, design quality, interaction quality, engineering resilience, backed by evidence. Broader than screenshot diff; narrower than code review.
_Avoid_: Visual QA, pixel check, vibe check.

**Prime**:
Session-start orientation brief that gives an agent enough current repo, branch, and collaboration context to begin a new chat in the right state without a handoff.
_Avoid_: Index, cache, memory, handoff

**Handoff**:
Continuation brief produced at the end of a session for another agent or fresh session.
_Avoid_: Prime, onboarding

**Credible risk**:
A failure supported by a trust boundary, irreversible effect, requirement,
observed incident, demonstrated scale, or likely user path. A merely imaginable
edge case is not credible.
_Avoid_: Every possible edge case, defensive completeness

**Demonstrated scale**:
The current measured or explicitly required workload used to justify
performance machinery. Future scale matters when a concrete threshold or
migration trigger exists.
_Avoid_: Web scale, future-proof

**Author workflow**:
One owner implements or repairs an outcome, selects applicable verification and evidence,
and continues through the requested endpoint. The `/work` front door selects this path.
_Avoid_: Manual skill chain, automatic merge

**Review workflow**:
Read-only assessment of existing changes, regardless of who authored them. Explicit repair
or posting intent grants only the named additional actions.
_Avoid_: Pulling code, automatic repair, authorship-based permission

**Requested endpoint**:
The externally visible stopping point named by the user: answer, local implementation,
commit, push, PR, or full ship. Prerequisites logically required by that endpoint are
authorized; later endpoints are not.
_Avoid_: Always ship, stop whenever

**Completion status**:
The final evidence-bearing line on an action turn: done, awaiting a specific decision,
or blocked on an external dependency. It prevents silent model stops without inventing a
semantic completion judge.
_Avoid_: Progress update, background notification

**Intent map**:
A concise causal view of substantial human-facing work: objective, assumptions, decisions,
references, implementation, verification, risks, and superseded choices. It progressively
discloses evidence instead of reproducing prose, private reasoning, or raw diffs.
_Avoid_: Chain of thought, exhaustive dependency graph, separate recap artifact

**Human-owned application**:
A browser or desktop-app session the person is actively using or has configured. Agent
verification uses an isolated session and never closes or takes over the human-owned one.
_Avoid_: Browser automation session

**PR review binding**:
An opt-in, user-local association from a same-repository PR to its feature worktree,
provider, and exact native session UUID. Automated review arrival resumes that owner;
delivery is not proof that its findings were fixed.
_Avoid_: Fresh repair agent, latest session, automatic merge

**Trusted review trigger**:
A new or edited comment/review by an explicitly allowed GitHub login. It wakes the
owner to inspect all applicable feedback, not merely that author's findings.
_Avoid_: Every bot, applicability verdict

## Example dialogue

Dev: "CLI-only PR. Need visual review?"
Reviewer: "Yes, if CLI output is customer-facing surface. Use terminal evidence, not browser screenshots."

Developer: "Run Prime before starting on this branch."
Domain expert: "Prime is for current-state orientation. Use Handoff only to transfer decisions from one session to next."

**Review repair round**:
One automatic feedback dispatch to the bound feature session. A persisted budget pauses
repeated repair for explicit reassessment; dispatch is not finding resolution or a reviewer pass.
_Avoid_: Review accuracy, reviews-to-pass
