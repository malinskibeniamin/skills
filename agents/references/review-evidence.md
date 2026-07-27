# Review evidence requirements

Shared by code-reviewer and self-reviewer.

## Resilience Review Evidence

Require `/resilience-review` evidence only when credible failure could cause data
loss, security or privacy harm, irreversible action, broken external contracts,
or a likely user dead end. Missing evidence on that surface is a P1 testing gap.
Do not require a resilience artifact for ordinary forms, async code, or state by
category alone.

## Visual Review Evidence

If the diff touches rendered frontend UI (`*.tsx`, CSS, routes, components, forms, dialogs, media, animations, browser/platform branches) or another customer-facing surface (CLI/TUI output, mobile/desktop screen, generated report, onboarding/setup flow), check whether `/visual-review` evidence exists in the session or PR body. If absent, add a P1 testing gap recommending `/visual-review` or an explicit skip reason. Do not treat static hook success or unit tests as a substitute for browser screenshot/state/a11y review or equivalent surface evidence.
