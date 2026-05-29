# Visual Review Examples

## Web feature

Input: `/visual-review /settings/billing`

Output should include browser screenshots, mobile viewport, keyboard path, loading/error states, console/network scan, P0-P3 findings, and HTML report path.

Example finding:

| Severity | Hat | Surface | Evidence | Why it matters | Fix | Automate? |
|---|---|---|---|---|---|---|
| P1 | Design | `/settings/billing` empty state | mobile screenshot shows primary action below fold | new users cannot recover from no-payment-method state | move action into empty-state card | browser visual test for empty state |

## CLI command

Input: `/visual-review mycli deploy --dry-run`

Check narrow and wide terminal widths, color and no-color output, success/error/empty output, exit code, stderr/stdout separation, and whether next action is obvious.

Example finding:

| Severity | Hat | Surface | Evidence | Why it matters | Fix | Automate? |
|---|---|---|---|---|---|---|
| P2 | Product | `deploy --dry-run` output | terminal capture lacks next command | user knows result but not what to do next | add one-line next step | CLI snapshot fixture |

## TUI or desktop app

Capture screenshots or terminal frames for focused, hovered, loading, error, and narrow layouts. Verify keyboard navigation, Escape/back behavior, focus return, and high-contrast/readable color mode.

## Bug regression

Input: `/visual-review regression for broken checkout submit`

Compare before/after if available. Confirm the fix resolves the reported pain without creating worse state handling, duplicate submissions, race conditions, or unreachable errors.
