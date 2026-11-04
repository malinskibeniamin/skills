# Verifiability over readability

Use when designing, reviewing, refactoring or assessing code health. Judge a module
by how reliably its behavior can be verified, not how quickly its implementation
can be read. Agents should gather executable evidence: run focused tests, probe the
public interface and inspect observed results instead of relying on source fluency.

## Keep humans connected

Use the human's domain language in interfaces, types, tests and diagnostics; follow
`GLOSSARY.md` and settled ADRs. Keep the contract, state owner, important invariants
and verification entrypoint discoverable so a human can jump in for observability,
incident diagnosis or consequential PR spot-checks. Optimize for that intervention,
not making every implementation small or immediately familiar.

## Design independently verifiable modules

- Test behavior through the same stable interface callers use. A focused command
  and representative fixture should exercise a module without booting unrelated
  application layers or reaching into private implementation details.
- Control relevant dependencies, state, time and randomness at existing seams.
  Keep setup/reset repeatable; expose outcomes and actionable failure diagnostics.
  Test doubles isolate the module; integration checks still verify real dependency
  contracts. Add a seam for a concrete verification need, not hypothetical testing.
- Use an independent oracle: specified outcomes, worked examples, production-shaped
  fixtures, or a trusted reference implementation. Prove a plausible wrong behavior
  fails; test credible failure/recovery paths, not just the happy path.
- Keep the smallest rerunnable proof and name what it misses. Even 100% line or
  branch coverage cannot establish assertion quality, correct requirements or real
  integration behavior; passing tests do not replace source, security or impact review.

## Trade-offs need evidence

Function/file size, nesting depth and cyclomatic complexity are not standalone
quality scores, refactor triggers or review findings. Split by independently
verifiable responsibilities and state ownership, not arbitrary thresholds. Simplify
when it improves verification, removes a concrete failure mode or lowers change
coordination; a smaller diff or more helpers is not proof of improvement.

Keep a less readable implementation when a representative benchmark proves a
worthwhile performance gain and contract tests preserve behavior. Retain the
invariant, trade-off and rerunnable benchmark for human inspection. A large optimized
module with strong independent checks need not be split; a short elegant module
whose behavior cannot be exercised needs a better verification seam. Unmeasured
cleverness earns no performance exemption.
