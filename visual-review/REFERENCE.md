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

## UI lifecycle rubric

Treat each changed surface as a small state machine. Review the transition, not just the final screenshot.

| State | Must communicate | Common failure |
|---|---|---|
| Idle/unrequested | What the user can do next; default values; constraints | ambiguous affordance, surprising default, hidden prerequisite |
| Pending/loading | Something is happening; content may change; layout stays stable | blank screen, skeleton lies about shape, cumulative layout shift |
| Pending/submitting | Form stays visible; duplicate submit prevented; current values preserved | premature close/navigation, enabled double-submit, lost input |
| Success | New data or completed action is visible; pending indicator gone | stale UI, no confirmation for side effect, user unsure what happened |
| Error | Error is near cause; all errors visible; recovery path obvious | toast-only critical error, first-error-only, disabled controls stay disabled |
| Settled/dismissed | Temporary UI disappears; important context persists until user resolves/dismisses | persistent noise, disappearing debug context, ghost state |

Form submit contract:
- Keep the form on screen while submitting.
- Disable submit and fields that would corrupt the request; keep safe cancellation if available.
- Close, reset, or navigate only after success.
- On error, remove pending indicators, re-enable inputs, show all errors inline, and keep critical errors non-dismissible.

Side-effect contract:
- User-visible writes/destructive actions need confirmation that the action happened.
- Failed side effects need persistent, actionable error context; a toast can duplicate but not replace it.
- Long-running work needs progress text. Add time estimates when functionally possible; otherwise show current step and persistence rules.
- Decide whether progress/errors are local to the resource view or global enough to survive navigation.

Transition contract:
- Motion directs attention to the thing that changed.
- Hover, focus, active, selected, and disabled states move in a consistent visual direction across related controls.
- Interactive micro-transitions should be short; longer motion must have a reason and respect reduced motion.
- Motion must not block interaction, hide state changes, or imply loading when nothing is loading.

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
- UI lifecycle trace: idle, pending, success, error, settled/dismissed.
- Form submit lifecycle: visible form while pending, disabled duplicate submit, success-only close/reset/navigation, inline errors.
- Side-effect lifecycle: success confirmation, persistent failed side effects, progress for long work.
- Transition consistency: hover/focus/active/selected/disabled direction, duration, reduced motion.
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

Scripts = deterministic repeated work: diff->surface inference, env fingerprint, evidence JSON, HTML render. Hooks = workflow enforcement plus deterministic source/workflow smells.

| Candidate | Could become hook? | Best home | Notes |
|---|---|---|---|
| `visual-review-targets` diff -> surfaces | Partly | script first; hook warns missing evidence | Map changed files to routes/stories/commands. |
| `visual-review-evidence` marker/schema | No | script/session artifact | Generate checked matrix, state trace, screenshot list. |
| `visual-review-html` render | No | script | JSON or markdown -> HTML report. |
| Missing visual review before PR for surface diffs | Yes | Stop or `/commit-push-pr` gate | Hard-block only after skip reasons and evidence schema are stable. |
| Unresolved P0/P1 in report | Yes | Stop/ship gate | Block after stable report markers; allow explicit user override. |
| `100vh`, fixed/sticky, safe-area risk | Yes | PostToolUse hook | Warn to verify mobile browser chrome, virtual keyboard, `100dvh`. |
| Long transition/animation on interactive state | Yes | PostToolUse hook | Warn on long durations; require reduced-motion check. |
| Smooth scroll, scroll snap, `scrollIntoView` | Yes | PostToolUse hook | Warn to verify reduced motion, focus, and interaction blocking. |
| Async form submit without pending/disabled/error state nearby | Warn only | PostToolUse hook | Source smell; avoid hard-block because patterns vary. |
| Toast-only failure for submit/write/destructive action | Warn only | PostToolUse hook | Critical errors need persistent inline or page context. |
| Success side effect without user-visible confirmation | Warn only | PostToolUse hook | Confirmation can be toast, inline update, navigation, or changed data. |
| Media without size/aspect-ratio hints | Yes | PostToolUse hook | CLS/LCP risk for images/video/iframes. |
| `autoFocus`, surprise focus movement | Yes | PostToolUse hook | Warn unless dialog/opening flow intentionally focuses first useful control. |
| ARIA on static/generic elements, nested button/link | Yes | PostToolUse hook | Deterministic accessibility source smells. |
| Slow network/mobile/browser behavior | No | Playwright/browser test or skill evidence | Runtime evidence, not source text. |
| Subjective product/design taste | No | rubric/eval | Needs judgement and user-impact evidence. |

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
