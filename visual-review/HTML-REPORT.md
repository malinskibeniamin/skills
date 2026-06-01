# HTML Report Format

Visual review can render single self-contained HTML report in OS temp dir. This mirrors `/improve-codebase-architecture`: skill writes file first; renderer script later once JSON contract stable.

## Location

Resolve temp dir from `$TMPDIR`, fallback `/tmp` or `%TEMP%`. Write `<tmpdir>/visual-review-<timestamp>.html`, open via `open`, `xdg-open`, or `start`, return abs path. Do not write repo artifacts unless user asks.

## Scaffold

```html
<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8" />
  <title>Visual review -- {{repo name}}</title>
  <script src="https://cdn.tailwindcss.com"></script>
  <style>
    .p0{border-color:#dc2626}.p1{border-color:#f97316}.p2{border-color:#eab308}.p3{border-color:#94a3b8}
    .surface-shot{aspect-ratio:16/10;object-fit:contain;background:#f8fafc}
  </style>
</head>
<body class="bg-stone-50 text-slate-900 font-sans">
  <main class="max-w-6xl mx-auto px-6 py-10 space-y-10">
    <header>...</header><section id="scorecard">...</section><section id="findings">...</section><section id="evidence">...</section><section id="automation">...</section>
  </main>
</body>
</html>
```

## Header

Repo, branch, PR if known, mode (`plan`, `implemented`, `regression`, `release`), changed customer-facing surfaces, status: `ready`, `needs fixes`, `blocked`. No intro.

## Scorecard

Product, Design, Engineering, QA. Four cards: score + one sentence. Scores = `strong`, `ok`, `weak`, `blocked`; decision support, not false precision.

| Hat | Judges |
|---|---|
| Product | user value, clarity, task success, friction, competitive quality |
| Design | hierarchy, spacing, affordance, copy, visual consistency, state quality |
| Engineering | async/slow-network resilience, platform risk, performance |
| QA | repro, unhappy paths, regression risk, automation opportunity |

## Finding cards

One compact card per finding. Sort P0 -> P3, then surface.

- Severity: P0, P1, P2, P3/nit
- Hat: Product, Design, Engineering, QA
- Surface: route, component, command, screen, report, flow
- Evidence: screenshot path, terminal capture, trace, console line, network condition, observation
- Why it matters: user/business impact, one sentence
- Fix: concrete next action
- Automate?: hook, eval, browser test, visual regression, fixture, or no

## Evidence gallery

Show screenshots, terminal captures, traces, snippets. Web evidence includes browser, viewport, DPR, color scheme, reduced motion, forced-colors, locale/direction, network. CLI/TUI evidence includes terminal width, color mode, exit code, command, stdout/stderr split. Local paths must be marked local-only unless uploaded/attached.

## State matrix

| Surface | Happy | Loading | Empty | Error | Dense | Slow network | Mobile/narrow | Keyboard | Dark/high contrast |
|---|---|---|---|---|---|---|---|---|---|

Every skip gets reason. `not reachable` ok; blank not ok.

## Automation candidates

| Candidate | Best home | Why |
|---|---|---|
| Deterministic source smell | PostToolUse hook | inspect changed text |
| Missing review evidence | Stop or commit-push-pr gate | workflow enforcement |
| Browser behavior regression | Playwright/browser test | runtime evidence |
| Screenshot diff | Visual regression tool | baseline compare |
| Subjective taste issue | Skill rubric/eval example | judgement required |
| Report rendering | Script | JSON -> HTML transform |

## Style

Editorial, terse, high-signal. Whitespace. Severity color. Screenshots + small callouts > prose. Use terms: customer-facing surface, surface review, evidence, finding, automation candidate. Mark low-confidence inferred findings.
