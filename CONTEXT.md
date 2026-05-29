# Frontend Skills Harness

Skills + hooks for agentic dev. Goal: safer, more reviewable, consistently high-quality AI-assisted work.

## Language

**Customer-facing surface**:
Any screen, command output, generated report, interface, or flow an end user sees or acts on. Includes web, mobile, CLI, TUI, desktop, rendered docs, reports.
_Avoid_: UI when not graphical; web page when non-web.

**Surface review**:
Multi-hat review of a customer-facing surface: product clarity, design quality, interaction quality, engineering resilience, backed by evidence. Broader than screenshot diff; narrower than code review.
_Avoid_: Visual QA, pixel check, vibe check.

## Example dialogue

Dev: "CLI-only PR. Need visual review?"
Reviewer: "Yes, if CLI output is customer-facing surface. Use terminal evidence, not browser screenshots."
