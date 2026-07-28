# Frontend Skills Harness

Skills + hooks for agentic dev. Goal: safer, more reviewable, consistently high-quality AI-assisted work.

## Language

**Customer-facing surface**:
Any screen, command output, generated report, interface, or flow an end user sees or acts on. Includes web, mobile, CLI, TUI, desktop, rendered docs, reports.
_Avoid_: UI when not graphical; web page when non-web.

**Surface review**:
Multi-hat review of a customer-facing surface: product clarity, design quality, interaction quality, engineering resilience, backed by evidence. Broader than screenshot diff; narrower than code review.
_Avoid_: Visual QA, pixel check, vibe check.

**Prime**:
Session-start orientation brief that gives an agent enough current repo, branch, and collaboration context to begin a new chat in the right state without a handoff.
_Avoid_: Index, cache, memory, handoff

**Handoff**:
Continuation brief produced at the end of a session for another agent or fresh session.
_Avoid_: Prime, onboarding

**Semantic density**:
Code in which each construct carries required behavior or makes the domain
clearer. The smallest obvious solution, not the fewest characters.
_Avoid_: Terse code, code golf

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

**Deletion as delivery**:
Removing code, configuration, dependencies, or tests while preserving required
behavior and making the system clearer.
_Avoid_: Negative LOC as a goal

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

**Human-owned application**:
A browser or desktop-app session the person is actively using or has configured. Agent
verification uses an isolated session and never closes or takes over the human-owned one.
_Avoid_: Browser automation session

## Example dialogue

Dev: "CLI-only PR. Need visual review?"
Reviewer: "Yes, if CLI output is customer-facing surface. Use terminal evidence, not browser screenshots."

Developer: "Run Prime before starting on this branch."
Domain expert: "Prime is for current-state orientation. Use Handoff only to transfer decisions from one session to next."
