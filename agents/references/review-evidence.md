# Review evidence requirements

Shared by code-reviewer and self-reviewer.

## Resilience Review Evidence

If diff adds/changes non-trivial feature behavior (forms, async/data flows, mutations, state transitions, config/resource choices, destructive actions, or user-visible error states), check whether `/resilience-review` evidence exists in session or PR body. Evidence should include Failure matrix, Finding queue, diagnosing-bugs/TDD status, and visual review when UI. If absent, add P1 testing gap recommending Resilience Review or explicit skip reason. Happy-path tests/type checks do not prove resilience.

## Visual Review Evidence

If the diff touches rendered frontend UI (`*.tsx`, CSS, routes, components, forms, dialogs, media, animations, browser/platform branches) or another customer-facing surface (CLI/TUI output, mobile/desktop screen, generated report, onboarding/setup flow), check whether `/visual-review` evidence exists in the session or PR body. If absent, add a P1 testing gap recommending `/visual-review` or an explicit skip reason. Do not treat static hook success or unit tests as a substitute for browser screenshot/state/a11y review or equivalent surface evidence.
