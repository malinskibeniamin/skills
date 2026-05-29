# Visual Review Reference

Use this reference when `/visual-review` runs standalone or as part of `/development-lifecycle`, `/go`, `/commit-push`, `/commit-push-pr`, `/prototype`, `/triage`, `self-reviewer`, or `code-reviewer`.

A visual review is a surface review for customer-facing surfaces: web UI, mobile screens, CLI/TUI output, desktop apps, generated reports, onboarding flows, forms, or any user-visible behavior. Browser screenshot review is the common adapter, not the whole skill.

## Customer-facing surface detection

Treat a diff as customer-facing when it changes anything a user sees, reads, or interacts with.

Frontend/browser-related signals:

- `*.tsx`, `*.jsx`, `*.css`, `*.scss`, `*.html`, `*.mdx`
- `src/routes/`, `src/pages/`, `src/app/`, `src/components/`, `components/ui/`
- design tokens, Tailwind/theme files, registry components, typography, icons
- form, dialog, popover, table, notification/toast, media, navigation, animation, scroll code
- browser/platform branches using user agent, viewport, media queries, feature detection, or `window`/`document`

Non-web signals:

- CLI command output, help text, errors, progress spinners, tables, JSON shown to users
- TUI layout, terminal colors, focus/keyboard behavior, resize behavior
- mobile or desktop screens, Electron windows, native controls, notifications
- generated reports, exported HTML/PDF, rendered docs, onboarding or setup flows

Not visual by default: docs-only source edits with no rendered output, test-only, generated files, type-only edits with no rendered behaviour.


## Review hats

| Hat | Primary question | Typical P1/P2 issues |
|---|---|---|
| Product | Does this surface make the user more successful? | unclear value, missing next step, poor task flow, confusing default |
| Design | Does it look and feel intentional? | weak hierarchy, spacing drift, poor affordance, inconsistent copy, bad states |
| Engineering | Will the experience stay stable under stress? | slow-network gaps, race conditions, crashes, platform/browser risk, perf regressions |
| QA | Can we reproduce and prevent regressions? | missing evidence, untested states, no before/after, no automation candidate |

Design taste is not treated as objective truth. Findings need evidence and a user-impact sentence.

## Environment fingerprint

Capture enough context to reproduce visual/browser-specific behaviour:

| Field | How | Why |
|---|---|---|
| Browser | Playwright project, browser name/version, or browser UI | rendering/layout/native controls differ |
| User agent | `navigator.userAgent` | diagnose UA branches and in-app browser quirks |
| Platform | `navigator.platform`, `navigator.userAgentData?.platform` | macOS/Windows/Linux/iOS/Android control/font differences |
| Viewport | `window.innerWidth`, `innerHeight`, `visualViewport?.width/height/scale` | mobile keyboard, zoom, dynamic viewport units |
| DPR | `window.devicePixelRatio` | image sharpness and canvas/SVG issues |
| Color scheme | `matchMedia('(prefers-color-scheme: dark)')` | dark/light token bugs |
| Reduced motion | `matchMedia('(prefers-reduced-motion: reduce)')` | transition and animation safety |
| Contrast/forced colors | `matchMedia('(forced-colors: active)')` | high-contrast accessibility |
| Locale/direction | `navigator.language`, `document.dir` | long strings, RTL, quotes, formatting |
| Network | Playwright route/throttle or DevTools profile | lazy media/loading and skeleton states |

Useful browser snippet:

```js
JSON.stringify({
  userAgent: navigator.userAgent,
  platform: navigator.userAgentData?.platform ?? navigator.platform,
  language: navigator.language,
  viewport: {
    innerWidth,
    innerHeight,
    visualWidth: visualViewport?.width,
    visualHeight: visualViewport?.height,
    scale: visualViewport?.scale,
    dpr: devicePixelRatio,
  },
  media: {
    dark: matchMedia('(prefers-color-scheme: dark)').matches,
    reducedMotion: matchMedia('(prefers-reduced-motion: reduce)').matches,
    forcedColors: matchMedia('(forced-colors: active)').matches,
  },
  dir: document.dir,
}, null, 2)
```

## Platform risk map

| Change area | Platform/browser risks to inspect |
|---|---|
| Sticky/fixed UI | iOS safe area, Android browser chrome, `visualViewport`, `100vh` vs `100dvh` |
| Forms | mobile keyboard resize, Enter submit, autofill/password managers, input type keyboards |
| Dialog/popover/select | Safari/Firefox native-control differences, Escape/back gesture, focus return |
| Tables/dense data | horizontal overflow, headers/captions, zoom, scrollbar-gutter |
| Animations/transitions | reduced motion, interaction blocking, transform order, INP |
| Scroll UI | smooth scroll side effects, scroll snapping, `scrollIntoView`, overscroll chaining |
| Images/video/media | LCP, CLS, DPR sharpness, lazy/preload, captions/controls, aspect ratio |
| Typography/icons | system font fallback, custom font shift, text zoom, SVG accessible names |
| Dark/high contrast | token coverage, `forced-colors`, color-only state, focus visibility |
| Feature-detected APIs | Baseline/browser support, fallback path, no UA sniff when feature detect works |
| In-app browsers/WebViews | UA quirks, blocked APIs, viewport differences, navigation limitations |

## Visual-review-specific checks

These belong in visual review even when hooks already exist:

- Screenshot comparison for changed views and important states.
- Browser matrix evidence: Chromium plus Firefox/WebKit when feasible.
- Mobile viewport and virtual-keyboard behaviour.
- Real focus order and keyboard interaction, including Escape/close paths.
- Accessible names matching visible intent, not merely presence of ARIA.
- Toast/notification announcement and persistence.
- Dense/empty/error/loading states that require mocked or seeded data.
- Overflow, clipping, z-index, portal, sticky/fixed, and safe-area bugs.
- Scroll behaviour and transition/motion interaction bugs.
- Core Web Vitals risks visible to users: LCP, CLS, INP.
- Platform-specific branches based on user agent, viewport, media queries, or feature detection.
- CLI/TUI output readability across terminal width, color/no-color, stdout/stderr split, exit codes, and error recovery.
- Generated reports/docs have scannable hierarchy, durable links, accessible tables, and clear next actions.

## Ecosystem wiring

- `/visual-review` can run standalone any time the user asks.
- `/development-lifecycle` uses `plan` mode for customer-facing feature plans, then `/go` handles implemented/release review.
- `/go` runs it automatically for frontend diffs and other customer-facing surface diffs before PR creation.
- `/commit-push-pr` requires its result or an explicit skip reason for frontend PRs and customer-facing surface PRs.
- `/commit-push` requires it before pushing frontend or customer-facing surface changes, unless skipped with reason.
- `/prototype` can use it to compare alternatives before implementation hardens.
- `/triage` can use `regression` mode when a bug affects user-visible behavior.
- `self-reviewer` and `code-reviewer` should flag missing `/visual-review` evidence when reviewing frontend diffs or customer-facing surface diffs.
- `route-visual-test-check.sh`, browser/e2e tests, CLI snapshots, and visual regression tools remain complementary; passing tests do not replace surface review for customer-facing changes.


## Scripts vs hooks

Use scripts for deterministic work the skill repeats: diff-to-surface inference, environment fingerprint capture, evidence JSON creation, and HTML rendering. Use hooks for workflow enforcement or static source smells.

| Potential script | Could become hook? | Recommended home |
|---|---|---|
| `visual-review-targets` diff -> surfaces | Partly | script first; hook can warn when surface diff lacks evidence |
| `visual-review-evidence` writes report marker | No | script/session artifact |
| `visual-review-html` renders HTML | No | script; deterministic artifact generation |
| missing review evidence before PR | Yes | Stop or `/commit-push-pr` gate, warn first then block later |
| unresolved P0/P1 in report | Yes | Stop or ship gate once report schema exists |
| source-level CSS/Tailwind gotchas | Yes | PostToolUse hook when deterministic |
| slow network/mobile/browser behavior | No | Playwright/browser test or manual evidence in skill |
| subjective product/design taste | No | rubric/eval examples, not hooks |

Start warn-only. Hard-block only after false positives are low and report schema is stable.

## PR evidence contract

Every frontend or customer-facing surface PR should carry or link this `/visual-review` evidence:

- Environment fingerprint: browser, user agent, platform, viewport, visualViewport, DPR, media prefs, locale/direction.
- Checked matrix: browsers, viewports, states, keyboard path, console/network scan, a11y checks.
- Screenshots: changed views/states, with path or attachment reference.
- Findings: P0/P1 fixed or explicitly accepted; P2/P3 noted.
- Skip reasons: every unrun matrix item gets a concrete reason.
- HTML report: absolute temp path, uploaded artifact, or explicit skip reason.
- Automation candidates: repeatable misses worth hook/eval/docs follow-up.
