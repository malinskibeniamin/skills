# HTML Report Format

The visual review can render a single self-contained HTML report in the OS temp directory. This mirrors `/improve-codebase-architecture`: the skill writes the file directly first; a renderer script can come later once the JSON contract stabilizes.

## File location

Resolve temp dir from `$TMPDIR`, falling back to `/tmp` (or `%TEMP%` on Windows). Write `<tmpdir>/visual-review-<timestamp>.html`, open it with `open`, `xdg-open`, or `start`, and return the absolute path.

Do not write reports into the repo unless the user explicitly asks to keep artifacts.

## Scaffold

```html
<!doctype html>
<html lang="en">
  <head>
    <meta charset="utf-8" />
    <title>Visual review -- {{repo name}}</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <style>
      .p0 { border-color: #dc2626; }
      .p1 { border-color: #f97316; }
      .p2 { border-color: #eab308; }
      .p3 { border-color: #94a3b8; }
      .surface-shot { aspect-ratio: 16 / 10; object-fit: contain; background: #f8fafc; }
    </style>
  </head>
  <body class="bg-stone-50 text-slate-900 font-sans">
    <main class="max-w-6xl mx-auto px-6 py-10 space-y-10">
      <header>...</header>
      <section id="scorecard">...</section>
      <section id="findings">...</section>
      <section id="evidence">...</section>
      <section id="automation">...</section>
    </main>
  </body>
</html>
```

## Header

Include repo, branch, PR if known, mode (`plan`, `implemented`, `regression`, `release`), changed customer-facing surfaces, and status: `ready`, `needs fixes`, or `blocked`.

No long intro. The report is for review, not storytelling.

## Scorecard

Four cards, each with a score and one sentence:

| Hat | What it judges |
|---|---|
| Product | user value, clarity, task success, friction, competitive quality |
| Design | hierarchy, spacing, affordance, copy, visual consistency, state quality |
| Engineering | resilience under async, slow network, platform risk, performance |
| QA | reproducibility, unhappy paths, regression risk, automation opportunity |

Use scores as decision support, not false precision: `strong`, `ok`, `weak`, `blocked`.

## Finding cards

Each finding is one compact card with left severity stripe:

- **Severity**: P0, P1, P2, P3/nit
- **Hat**: Product, Design, Engineering, QA
- **Surface**: route, component, command, screen, report, or flow
- **Evidence**: screenshot path, terminal capture, browser trace, console line, network condition, or explicit observation
- **Why it matters**: user/business impact in one sentence
- **Fix**: concrete next action
- **Automate?**: hook, eval, browser test, visual regression, fixture, or no

Sort P0 -> P3, then by surface.

## Evidence gallery

Show screenshots, terminal captures, traces, or output snippets. For web UI, include browser, viewport, DPR, color scheme, reduced motion, forced-colors, locale/direction, and network profile. For CLI/TUI, include terminal width, color mode, exit code, command, and stderr/stdout split.

Use local absolute file paths when screenshots are local. Mark paths as local-only if they are not uploaded or attachable to PR.

## State matrix

Render checked/skipped matrix:

| Surface | Happy | Loading | Empty | Error | Dense | Slow network | Mobile/narrow | Keyboard | Dark/high contrast |
|---|---|---|---|---|---|---|---|---|---|

Every skip gets a reason. `not reachable` is allowed; blank is not.

## Automation candidates

List repeatable misses as hook/eval/test ideas. Be strict about hook fit:

| Candidate | Best home | Why |
|---|---|---|
| Deterministic source smell | PostToolUse hook | Can inspect changed text without running app |
| Missing review evidence | Stop or commit-push-pr gate | Workflow enforcement, not skill prose |
| Browser behavior regression | Playwright/browser test | Needs runtime evidence |
| Screenshot diff | Visual regression tool | Needs baseline comparison |
| Subjective taste issue | Skill rubric/eval example | Requires judgement, not deterministic hook |
| Report rendering | Script | Deterministic transformation from JSON to HTML |

## Style guidance

- Editorial, concise, high-signal.
- Use generous whitespace and clear severity color.
- Prefer screenshots and small annotated callouts over long prose.
- Use house terms: customer-facing surface, surface review, evidence, finding, automation candidate.
- Do not hide uncertainty. Mark inferred findings as lower confidence.
