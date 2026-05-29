# Frontend Skills Harness

A skills and hook harness for agentic software development. It exists to make AI-assisted work safer, more reviewable, and more consistently high quality.

## Language

**Customer-facing surface**:
Any screen, command output, generated report, interface, or interactive flow that an end user sees or acts on. A surface can be web, mobile, CLI, TUI, desktop, docs-rendered, or report-based.
_Avoid_: UI when the surface may not be graphical; web page when the surface may be non-web.

**Surface review**:
A multi-hat review of a customer-facing surface that judges product clarity, design quality, interaction quality, and engineering resilience using concrete evidence. It is broader than screenshot comparison and narrower than general code review.
_Avoid_: Visual QA, pixel check, vibe check.

## Example dialogue

Developer: "This PR only changes a CLI command. Do we need visual review?"
Reviewer: "Yes, if the CLI output is a customer-facing surface. Run surface review with terminal output evidence instead of browser screenshots."
