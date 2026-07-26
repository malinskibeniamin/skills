---
name: deslop
description: "Fallback audit for removing unjustified code from an already-bloated diff or repository. Use on explicit deslop, ponytail, lazy mode, YAGNI, or bloat requests; never as a mandatory lifecycle pass."
license: MIT
vendored_from: https://github.com/DietrichGebert/ponytail (write mode)
---

# Deslop

Fallback, not lifecycle. Clean code should arrive clean; invoke this skill only
when a diff or repository already feels larger than its behavior.

## Advocate for less is more

Code is liability, but negative LOC is not the goal. Prefer **semantic density**:
the smallest obvious implementation in which each construct carries required
behavior or clarifies the domain. Gorgeous code needs little
explanation because its shape matches the problem. Never trade clarity for
fewer characters.

Design for demonstrated scale. Do not add indexes, virtualization, caching,
queues, retries, factories, flags, configuration, or extension points for a
merely imaginable future.

An addition earns its place by expressing required behavior, clarifying the domain, or addressing a credible risk. "Could happen" is not evidence.

## Write mode

Explicit only: `/deslop write`, "ponytail", or "lazy mode". Understand the full
flow first; the ladder shortens the solution, never the reading.

1. Delete or leave speculative scope unbuilt.
2. Reuse the codebase.
3. Use the language or standard library.
4. Use the native platform.
5. Use an already-installed dependency.
6. Write the smallest clear local expression.
7. Only then own custom machinery.

Fix root cause, not symptoms: grep every caller before changing a shared
function. Prefer direct code until an abstraction removes real repeated
complexity. Comments explain unavoidable why; code explains what.

Meaningful behavior keeps the smallest public-contract test. Do not manufacture
tests for trivial wiring or delete useful tests to shorten a diff.

**Intensity** (`/deslop lite|full|ultra`, default full): lite names the lazier
alternative; full applies the ladder; ultra challenges every requirement before
keeping code.

**Never cut:** explicit requirements, trust-boundary validation, security,
accessibility, or error handling that prevents data loss.

## Gate mode

Read the goal, nearby code, `git diff --stat`, and `git diff`. Tag only proven
excess:

- `delete:` dead or speculative code; replace with nothing.
- `stdlib:` custom code replaced by the language or standard library.
- `native:` code or dependency replaced by platform behavior.
- `yagni:` flexibility without a current requirement.
- `shrink:` equally clear behavior with less surface area.

Then delete, inline, and tighten. Skill or harness changes still need matching
RED -> GREEN eval evidence. Run the smallest relevant verification.

Return `NEEDS_CHANGES` when required behavior is buried under avoidable surface
area. Do not reward code golf or remove proven safety. Report what stayed, what
left, and why. For repository audits, rank the largest justified deletions;
otherwise end with `Lean already. Ship.`

See [REFERENCE.md](REFERENCE.md) for the compact review checklist.
