# Review evidence requirements

Shared by code-reviewer and self-reviewer. Apply the conditional axes in
[the reviewer catalogue](../../review/REVIEWERS.md) inline unless delegation was
explicitly authorized. The verifier supplies execution evidence; specialists judge
their assigned lens. Do not infer independent coverage from a role definition.

## Specialist routing

Load applicable owners from [change evidence](../../shared/change-evidence.md) before
forming findings. Its protobuf route covers schemas, generation and runtime/descriptor
consumers even without an AIP-style API or review-gate opt-in. Keep capability
opportunities in `simplification_opportunities`, separate from defects and testing gaps.
Loading a specialist does not authorize delegation or start another review workflow.

## Resilience Review Evidence

Require `/resilience-review` evidence only when credible failure could cause data
loss, security or privacy harm, irreversible action, broken external contracts,
or a likely user dead end. Missing evidence on that surface is a P1 testing gap.
Do not require a resilience artifact for ordinary forms, async code, or state by
category alone.

## Visual Review Evidence

If the diff touches rendered frontend UI (`*.tsx`, CSS, routes, components, forms, dialogs, media, animations, browser/platform branches) or another customer-facing surface (CLI/TUI output, mobile/desktop screen, generated report, onboarding/setup flow), check whether `/visual-review` evidence exists in the session or PR body. If absent, add a P1 testing gap recommending `/visual-review` or an explicit skip reason. Do not treat static hook success or unit tests as a substitute for browser screenshot/state/a11y review or equivalent surface evidence.
