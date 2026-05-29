# Visual Review Examples

## Web

Input: `/visual-review /settings/billing`

Check screenshots, mobile viewport, keyboard path, loading/error/empty states, console/network, P0-P3, HTML report.

| Severity | Hat | Surface | Evidence | Why it matters | Fix | Automate? |
|---|---|---|---|---|---|---|
| P1 | Design | `/settings/billing` empty state | mobile screenshot: primary action below fold | new user stuck with no payment method | move action into empty-state card | browser visual test |

## CLI

Input: `/visual-review mycli deploy --dry-run`

Check narrow/wide terminal, color/no-color, success/error/empty output, exit code, stdout/stderr split, obvious next action.

| Severity | Hat | Surface | Evidence | Why it matters | Fix | Automate? |
|---|---|---|---|---|---|---|
| P2 | Product | `deploy --dry-run` output | terminal capture lacks next command | user sees result, not next step | add one-line next step | CLI snapshot fixture |

## TUI/desktop

Capture focused, hovered, loading, error, narrow layouts. Verify keyboard nav, Escape/back, focus return, contrast/readability.

## Regression

Input: `/visual-review regression for broken checkout submit`

Compare before/after if possible. Confirm fix solves pain without worse states, duplicate submits, races, unreachable errors.
