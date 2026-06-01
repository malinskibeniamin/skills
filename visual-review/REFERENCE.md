# Visual Review Reference

Use when `/visual-review` runs standalone, or via `/development-lifecycle`, `/go`, `/commit-push`, `/commit-push-pr`, `/prototype`, `/triage`, `self-reviewer`, `code-reviewer`.

Visual review = surface review for customer-facing surfaces: web UI, mobile screens, CLI/TUI output, desktop apps, generated reports, onboarding, forms, any user-visible behavior. Browser screenshot review = one adapter.

## Customer-facing surface detection

User sees/reads/acts on it -> surface. Frontend/browser signals:

- `*.tsx`, `*.jsx`, `*.css`, `*.scss`, `*.html`, `*.mdx`
- `src/routes/`, `src/pages/`, `src/app/`, `src/components/`, `components/ui/`
- design tokens, Tailwind/theme, registry components, typography, icons
- form, dialog, popover, table, toast, media, nav, animation, scroll code
- browser/platform branches: UA branches, user agent, viewport, media queries, feature detection, `window`/`document`

Non-web signals:
- CLI command output, help text, errors, progress, tables, user-visible JSON
- TUI layout, terminal color, focus/keyboard, resize
- mobile/desktop screens, Electron, native controls, notifications
- generated reports, exported HTML/PDF, rendered docs, onboarding/setup flows

Not visual by default: docs source with no rendered output, test-only, generated files, type-only edits with no rendered behaviour.

## Review hats

| Hat | Question | Common miss |
|---|---|---|
| Product | User more successful? | unclear value, missing next step, confusing default |
| Design | Looks intentional? | weak hierarchy, spacing drift, poor affordance, inconsistent copy/states |
| Engineering | Stable under stress? | slow network, race, crash, platform/browser risk, perf regression |
| QA | Reproducible/preventable? | weak evidence, untested states, no automation candidate |

subjective product/design taste -> No hook. Need evidence + user-impact sentence.

## Environment fingerprint

| Field | How | Why |
|---|---|---|
| Browser | Playwright/browser name + version | rendering/native controls differ |
| User agent | `navigator.userAgent` | UA branches, WebView quirks |
| Platform | `navigator.platform`, `navigator.userAgentData?.platform` | OS fonts/controls |
| Viewport | `innerWidth`, `innerHeight`, `visualViewport` | zoom, virtual keyboard, viewport units |
| DPR | `devicePixelRatio` | image sharpness/canvas/SVG |
| Color scheme | `prefers-color-scheme` | dark/light tokens |
| Reduced motion | `prefers-reduced-motion` | motion safety |
| Contrast/forced colors | `forced-colors` | high contrast |
| Locale/direction | `navigator.language`, `document.dir` | long strings, RTL |
| Network | Playwright throttle/DevTools | lazy media/loading |

Snippet:

```js
JSON.stringify({
  userAgent: navigator.userAgent,
  platform: navigator.userAgentData?.platform ?? navigator.platform,
  language: navigator.language,
  viewport: { innerWidth, innerHeight, visualWidth: visualViewport?.width, visualHeight: visualViewport?.height, scale: visualViewport?.scale, dpr: devicePixelRatio },
  media: { dark: matchMedia('(prefers-color-scheme: dark)').matches, reducedMotion: matchMedia('(prefers-reduced-motion: reduce)').matches, forcedColors: matchMedia('(forced-colors: active)').matches },
  dir: document.dir,
}, null, 2)
```

## Platform risk map

| Change area | Risk |
|---|---|
| Sticky/fixed UI | iOS safe area, Android browser chrome, `visualViewport`, `100vh` vs `100dvh` |
| Forms | mobile keyboard, Enter submit, autofill/password managers, input keyboards |
| Dialog/popover/select | Safari/Firefox native-control differences, Escape/back, focus return |
| Tables/dense data | overflow, headers/captions, zoom, scrollbar-gutter |
| Animations/transitions | reduced motion, interaction blocking, transform order, INP |
| Scroll UI | smooth scrolling, scroll snapping, `scrollIntoView`, overscroll |
| Images/video/media | LCP, CLS, DPR, lazy/preload, captions/controls, aspect ratio |
| Typography/icons | font fallback, shift, text zoom, SVG accessible names |
| Dark/high contrast | token coverage, `forced-colors`, color-only state, focus visibility |
| Feature-detected APIs | Baseline/browser support, fallback, no UA sniff if feature detect works |
| In-app browsers/WebViews | UA quirks, blocked APIs, viewport/navigation limits |

## Visual-review-specific checks

These belong here even when hooks exist:
- Screenshot comparison for changed views/states.
- Browser matrix evidence: Chromium plus Firefox/WebKit when feasible.
- Mobile viewport + virtual-keyboard behaviour.
- Real focus order, keyboard interaction, Escape/close.
- Accessible names match visible intent, not just ARIA presence.
- Toast announcement/persistence.
- Dense/empty/error/loading states.
- Overflow, clipping, z-index, portal, sticky/fixed, safe-area.
- Scroll/motion interaction bugs.
- Core Web Vitals risks: LCP, CLS, INP.
- Platform-specific branches based on user agent, viewport, media queries, feature detection.
- CLI/TUI output readability: terminal width, color/no-color, stdout/stderr, exit codes, error recovery.
- Generated reports/docs: hierarchy, links, accessible tables, next actions.

## Ecosystem wiring

- `/visual-review` can run standalone.
- `/development-lifecycle`: `plan` mode for customer-facing plans; `/go` handles implemented/release.
- `/go`: auto-run for frontend diffs + customer-facing surface diffs before PR.
- `/commit-push-pr`: require result or explicit skip reason for frontend/customer-facing surface PRs.
- `/commit-push`: require before push unless skipped with reason.
- `/prototype`: compare alternatives pre-implementation.
- `/triage`: use `regression` mode for user-visible bugs.
- `self-reviewer` and `code-reviewer`: flag missing evidence for frontend/customer-facing surface diffs.
- `route-visual-test-check.sh`, browser/e2e tests, CLI snapshots, visual regression tools complement; passing tests do not replace review.

## Scripts vs hooks

Scripts = deterministic repeated work: diff->surface inference, env fingerprint, evidence JSON, HTML render. Hooks = workflow enforcement/static source smells.

| Potential script | Could become hook? | Best home |
|---|---|---|
| `visual-review-targets` diff -> surfaces | Partly | script first; hook warns missing evidence |
| `visual-review-evidence` marker | No | script/session artifact |
| `visual-review-html` render | No | script |
| missing review evidence before PR | Yes | Stop or `/commit-push-pr` gate |
| unresolved P0/P1 in report | Yes | Stop/ship gate after schema stable |
| CSS/Tailwind source gotchas | Yes | PostToolUse hook if deterministic |
| slow network/mobile/browser behavior | No | Playwright/browser test or skill evidence |
| subjective product/design taste | No | rubric/eval examples |

Start warn-only. Hard-block after low false positives + stable schema.

## PR evidence contract

Every frontend or customer-facing surface PR carries/links:
- Environment fingerprint: browser, User agent, Platform, Viewport, visualViewport, DPR, media prefs, Locale/direction.
- Checked matrix: browsers, viewports, states, keyboard path, console/network scan, a11y checks.
- Screenshots/terminal captures: changed views/states, path or attachment.
- Findings: P0/P1 fixed or accepted; P2/P3 noted.
- Skip reasons: every unrun matrix item has reason.
- HTML report: absolute temp path, uploaded artifact, or skip reason.
- Automation candidates: repeatable misses worth hook/eval/docs.
