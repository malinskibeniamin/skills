# Deslop Reference

## Surface-area budget

Treat each addition as production liability:

- Runtime path: can fail, slow down, leak, or confuse.
- API/export: becomes a contract to support.
- Dependency/config: expands upgrade and outage surface.
- Test helper/mock: can hide real behavior or harden implementation details.
- Hook/rule: can block good work or create noisy false positives.

`/deslop` is an explicit fallback for work that is already bloated. Normal
authoring should apply these principles from the first design and need no
cleanup skill.

## Keep rules

Keep when the addition does at least one:

1. **Required behavior** -- implements an explicit user or caller contract.
2. **Domain clarity** -- makes the real concepts and invariants easier to see.
3. **Credible risk** -- prevents a failure supported by evidence, not imagination.

If none apply, delete it. If unsure, ask for the value claim or split the diff.

## Reuse-first ladder

Before accepting new code, stop at the first rung that solves the behavior:

1. Delete it or skip speculative scope.
2. Use the standard library.
3. Use a native platform feature.
4. Use an already-installed dependency.
5. Use the smallest clear local expression.
6. Only then own the smallest custom implementation.

Never remove trust-boundary validation, visible error handling, security, accessibility, or explicitly requested behavior.

## Review passes

1. **Scope** -- Does every changed file trace to the ask?
2. **Shape** -- Can a branch, option, abstraction, helper, or file disappear?
3. **Reuse** -- Does extraction remove real repeated complexity? If not, inline.
4. **State** -- Can one source of truth replace mirrored state or flags?
5. **Errors** -- Does each guard address a credible failure?
6. **Tests** -- Does each test protect a meaningful public contract?
7. **Cost** -- Would you be comfortable owning this during an incident?

## Repository slop audits

Audit requests report candidates; explicit cleanup requests may apply verified cuts.
Rank maintenance cost and confidence, not deletion volume. Inspect callers, public
exports, dynamic registration, and history before calling a wrapper unused. A one-use
function can still own a useful domain boundary.

For each test candidate, name the public failure it catches. Delete duplicate coverage
only after showing the retained test catches that same failure, using a temporary fault
or an existing regression reproduction. A test that survives a representative fault may
need repair, not deletion. Keep the fault out of the final diff. Mock count, age, green
CI, and short implementation are not proof of uselessness.

For each applied cut, record the removed responsibility, replacement or retained
coverage, and focused checks. Verify the behavior before and after; preserve unique
error, security, accessibility, and compatibility coverage.

## Block examples

- New wrapper component only changes names around an existing component.
- Utility used once with no clear semantic boundary.
- Behavior change without a meaningful contract test.
- Broad config/dependency change to solve a one-line local problem.
- Defensive-looking fallback for an unsubstantiated failure.

## Output template

```markdown
Verdict: APPROVED | NEEDS_CHANGES

Kept
- `<path>`: value/defense/test reason.

Delete or inline
- `<path:line>`: reason, smallest replacement.

Verification
- `<command>`: pass/fail summary.
```
