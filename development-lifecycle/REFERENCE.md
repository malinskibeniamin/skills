# Development lifecycle reference

Use this only when the compact execution loop needs a concrete branch. The primary model
owns the work inline. Agents, recursive model calls, and persistent background processes
require explicit user authorization.

## Outcome evidence by task

| Task | First useful evidence | Completion evidence |
|---|---|---|
| Feature | Existing public seam and nearest example | Requested behavior at the real entrypoint plus repository checks |
| Bug | Reproduction and root-cause hypothesis | Regression test fails before the fix, passes after, original path works |
| Refactor | Preserved public contract | Existing contract remains green and complexity demonstrably drops |
| Test-only | Missing behavior proof | New test fails against the faulty behavior and passes against the intended behavior |
| Docs/config | Consumer or validator for the artifact | Render, parser, generator check, or representative invocation |
| PR/ship | Diff and requested endpoint | Delivery evidence in the endpoint table below |

Do not invent a test solely because a file changed. Static wiring, copy, styles, and
behavior-preserving deletion may be better verified by an existing parser, renderer,
type checker, or representative invocation.

## Choosing the next action

Resolve the unknown most likely to invalidate the approach:

- **Lookup**: inspect source, current docs, generated types, logs, or history.
- **Executable probe**: run the smallest command that distinguishes competing causes.
- **Disposable prototype**: build only enough to answer an unresolved behavior or visual
  question, then discard or deliberately adopt it.
- **Reversible assumption**: state it briefly and proceed.
- **Pause trigger**: ask only for a material product, architecture, legal/privacy,
  destructive, high-security, or other user-reserved decision.

When assumptions conflict, name the conflict and the consequence. Do not convert routine
implementation detail into a user decision.

## Bug branch

1. Reproduce the full failure at the narrowest public seam.
2. Trace the faulty value or behavior to its source; compare a working path.
3. State one falsifiable hypothesis and run a discriminating check.
4. Add the smallest regression test for the public contract.
5. Fix at the source. Keep defense in depth only at real trust boundaries.
6. Replay both the reproduction and one adjacent recovery path.

If a feedback loop is slow or noisy, improve it before expanding the fix.

## Meaningful behavior branch

Use RED -> GREEN -> REFACTOR:

1. Add one test that fails for the intended reason.
2. Make the smallest behavior change that passes it.
3. Preserve test integrity; never weaken the assertion to reach green.
4. Refactor only while the public proof stays green.
5. Exercise the increment through the interface a real consumer uses.

Test suffixes follow repository convention:

| Suffix | Purpose |
|---|---|
| `.test.ts` | Unit behavior without DOM |
| `.test.tsx` | Integrated component behavior |
| `.browser.test.tsx` | Rendered visual or browser behavior |
| `e2e/*.spec.ts` | End-to-end workflow |

## Review depth

Review the complete diff once after applicable checks pass. Add depth only when evidence
demands it:

- Trust boundary, data loss, privacy, irreversible action, or broken contract: inspect the
  failure path and add the smallest guard with contract evidence.
- Customer-facing surface: inspect rendered output, interaction states, accessibility,
  and console behavior.
- New dependency or external API: verify current primary documentation and compatibility.
- Security-sensitive change: run the repository's SAST/SCA checks and inspect secrets,
  injection, unsafe HTML, and permission boundaries.

Classify findings by consequence, fix actionable issues, then rerun affected checks. Do not
schedule fixed review rounds or invoke other skills just to satisfy ceremony.

## Endpoint evidence

| Requested endpoint | Required evidence before stopping |
|---|---|
| Answer/plan/review | Requested artifact only; no edits |
| Build/fix/implement | Verified changes committed and pushed unless an explicit local/no-delivery stop wins |
| Commit | Verified requested changes committed |
| Push | Verified changes committed and pushed |
| PR | Verified, committed, pushed, PR opened, one CI snapshot |
| Ship | PR opened, CI and requested feedback loop clean, human handoff |

Use `../commit-push-pr/REFERENCE.md` for exact Git delivery commands. Commit, push, rebase,
and use `--force-with-lease` when needed on the current user-owned feature branch without
another permission prompt. Never merge, use plain `--force`, or rewrite default, shared,
foreign, or concurrently owned branches without explicit permission. A normal PR request
takes one CI snapshot; only `ship`, an explicit `/go`, or explicit babysitting authorizes
active CI remediation.

## Isolation and long runs

- On `main`, `master`, or `develop` before code, create an isolated worktree with
  `scripts/mux-worktree.sh <type>/<branch-name>`.
- Use isolated browser automation; never take over a human-owned browser or desktop.
- Stream a long-running check only while actively supervising it. Stop it before handoff
  unless persistence was explicitly requested.
- Keep deviations, current evidence, and pause triggers in
  `.context/implementation-notes.md` only for long or high-unknown work.

## Durable learning

Add a path-scoped rule or regression eval only for a recurring, repository-specific
failure that is not already inferable or mechanically enforced. One-off fixes and generic
knowledge do not justify more ambient context.
