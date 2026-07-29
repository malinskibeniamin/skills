# Visual Review Reference

## House taste

- Rendering stays honest: show machine truth beside human labels; preserve zero values;
  name degraded causes and offer retry.
- Create flows stay shallow; the detail page carries depth. Empty states get one primary
  action and cover no-data, no-match, error, and no-permission.
- Tables earn columns, truncate with recovery, and keep headers/captions meaningful.
- Semantic color uses background, border, icon, and readable text in both themes.
- Loading reserves layout. Parents own spacing. Destructive copy names the subject.
- Buttons act; links navigate. Motion clarifies state and respects reduced motion.

## Surface stress checklist

Check safe areas, virtual keyboards, writing modes, clipping, sticky elements, viewport
units, CLS, dense data, table semantics, complex CSS, accessible names, label association,
native semantics, ARIA restraint, password managers, autofill, disabled semantics, focus
trap/return, autofocus, nested controls, `requestSubmit`, toast persistence, side-effect
confirmation, strikethrough/emoji/generated content, SVG/icons/images, Firefox, Safari,
WebView, bfcache, smooth scrolling, scroll snapping, `scrollIntoView`, interaction
blocking, native-control behaviour, feature detection, responsive images/video, stable
aspect ratio, LCP/CLS/INP, font loading, and third-party embeds.

Minimum evidence names the Chromium mobile viewport and keyboard path: Tab, Shift+Tab, Enter, Space, Escape.
Exercise the notification/toast path. Confirm captions/headers still explain tables.
Require no surprise autofocus, and ensure buttons/links do not nest. Critical actions keep
information persistent; toasts are not sole carrier for critical actions. Stress
strikethrough, emoji, generated content; responsive video/media; stable aspect ratio; and
third-party embeds/scripts.

Use when `/visual-review` runs standalone, or via `/development-lifecycle`, `/go`, `/commit-push-pr`, `/prototype`, `/triage`, `self-reviewer`, `code-reviewer`.

Visual review = surface review for customer-facing surfaces: web UI, mobile screens, CLI/TUI output, desktop apps, generated reports, onboarding, forms, any user-visible behavior. Browser screenshot review = one adapter.

## Visual artifacts

`/visual-review` judges the surface from evidence. Builder.io artifacts help people inspect that evidence: use `/visual-plan` for planned UI/product/API surfaces before implementation, `/visual-recap` for review-worthy implemented diffs before or during PR handoff, and `/plan-arbiter` when visual plans, design directions, detector findings, or reviewer reports conflict. Do not substitute a hosted plan/recap for browser, terminal, accessibility, or state evidence.

## Customer-facing surface detection

User sees/reads/acts on it -> surface. Frontend/browser signals:

- `*.tsx`, `*.jsx`, `*.css`, `*.scss`, `*.html`, `*.mdx`
- `src/routes/`, `src/pages/`, `src/app/`, `src/components/`, `components/ui/`, shadcn/ui, `@/components/ui`
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

## Design context bootstrap

Read existing tokens/theme and at least one representative component or page before judging. Check design tokens, Tailwind config/theme, shadcn/ui or `@/components/ui` components, registry components, shared typography, Button variants, form controls, layout shell, and neighboring surfaces. Preserve system intent when it works; call out drift when local choices break the system or user task.

## Review lanes

Critique lane = what the surface communicates: first read, hierarchy, scan path, copy, emotional fit. Audit lane = whether it holds under runtime constraints: accessibility, performance, responsive behavior, browser/platform risk. Polish lane = whether it is ready to ship: design-system alignment, states, microcopy, visual consistency, rough edges.

## Surface register

Classify the surface before judging design quality:

| Register | Standard | Failure mode |
|---|---|---|
| Product | Familiar, trustworthy, consistent, task-first | decoration, strange affordances, weak states, broken density |
| Brand | Distinctive, memorable, art-directed, audience-specific | safe template, no focal point, generic aesthetic lane |
| Report or CLI/TUI | Scannable, aligned, legible, next action clear | noisy output, no hierarchy, hidden status, no recovery path |

If register is ambiguous, state the assumption in the report. Product UI can be intentionally familiar; brand UI needs a stronger point of view. Do not punish product UI for being familiar. Do not praise brand UI for being safe.

## Design language protocol

Use this section during design-hat review.

1. Run the squint test: identify primary, secondary, and ignored elements.
2. Name the handle before the fix: hierarchy, density, rhythm, anchor, negative space, leading, measure, visual weight, affordance, scan path.
3. Write current read and desired read. Current read is what the surface communicates now; desired read is what the user should notice or do.
4. Tie every subjective note to evidence: screenshot, viewport, state, browser, terminal width, or numbered callouts.
5. Translate the adjustment into implementation knobs: design tokens, `gap-*`, padding, line-height, max-width, Button variant, grid, copy, state, or component prop.
6. Choose magnitude: nudge, step, or system change. If the same issue appears twice, prefer a system change and automation candidate.

Bad: "Spacing feels off." Good: "Density is too tight in the billing card; helper text and action read as one group. Move the action row one spacing step away from supporting text."

## Index articulation pass

Use [Index /to/articulate](https://index.how/to/articulate) as a vocabulary source, not a rulebook. Before proposing a taste fix, classify the issue by lane: typography, color, iconography, layout, interaction, motion, accessibility, information architecture, copywriting, components.

The goal is precise language. Replace "make it better" with "the CTA loses hierarchy because the icon stroke weight and button label have mismatched visual weight" or "the empty state fails wayfinding because the signpost and next action are missing."

| Lane | Terms to reach for | Review questions |
|---|---|---|
| Typography | type scale, weight, leading, measure, line length, font stack, tabular nums, text overflow | Is text readable, aligned, and stable under fallback fonts, long labels, and data changes? |
| Color | semantic token, contrast ratio, tinted neutral, chroma, OKLCH, alpha, dark mode | Does color carry purpose, contrast, and hierarchy without vibrating or going grey? |
| Iconography | stroke weight, optical centre, filled vs outlined, meaning collision, breathing room, unified weight | Does the icon read as intended, align optically, and match nearby text weight? |
| Layout | gap, negative space, border radius, max-width, breakpoint, safe area, z-index, layout shift | Does space group related content, reserve size, and survive viewport changes? |
| Interaction | affordance, hover state, focus state, active state, disabled state, cursor, touch target | Does each state communicate what can happen and what just happened? |
| Motion | easing, duration, transition property, reduced motion, choreography, motion as feedback | Does motion guide attention without jank, delay, or vestibular risk? |
| Accessibility | accessible names, DOM order, label association, color-only state, tab order, focus trap, semantic HTML | Does the screen reader and keyboard experience match what sighted pointer users see? |
| Information architecture | progressive disclosure, mental model, hierarchy, empty state, wayfinding, signpost, labelling | Does the user know where they are, what matters, and what to do next? |
| Copywriting | microcopy, CTA, error message, placeholder, sentence case, front-loading, contextual help, truncation strategy | Do the words guide scanning, recovery, and trust at the point of action? |
| Components | button, input, modal/dialog, toast, badge/tag, tabs, data table, skeleton, empty state | Does the component behave according to its native pattern and product system? |

Copywriting lens: front-loading, CTA, contextual help, success message, destructive language, numeric formatting, and truncation strategy are visual-review concerns because words affect hierarchy, trust, and task completion.

Accessibility lens: accessible names, DOM order, label association, color-only state, tab order, focus trap, and semantic HTML are visual-review concerns because visual polish that does not survive assistive tech is not shippable polish.

## Research-backed operating loop

Use Impeccable-style taste work as an operating loop, not as a replacement for evidence:

1. **Context before taste**: read existing tokens, components, `PRODUCT.md`, `DESIGN.md`, voice notes, and anti-references before judging. If those files do not exist, infer the product register and say the assumption.
2. **Named dimension pass**: pick one lane at a time, such as typeset, colorize, layout, animate, clarify, harden, onboard, optimize, polish. Do not run conflicting taste directions at once.
3. **pre-ship gauntlet**: audit, clarify, harden. Score accessibility, performance, theming, responsive behavior, platform risk, state quality, and anti-patterns before calling a surface ready.
4. **Reality stress**: use long names, localized labels, German titles, huge numbers, dense data, 500s, offline states, slow network, text zoom, reduced motion, dark mode, and mobile keyboard states.
5. **System maintenance**: if a pattern appears twice, extract a token, component variant, fixture, hook warning, or docs rule. Taste that cannot be repeated is a one-off opinion.

## Motion decision framework

For every animation, ask frequency, purpose, easing, duration before implementation. High-frequency or keyboard-triggered actions should often be instant. Motion needs a job: spatial continuity, state feedback, attention guidance, explanation, or rare delight. Default to ease-out for entry/exit, ease-in-out for morphing or movement, ease for simple hover/color transitions, and linear for progress. Keep common UI motion under 300ms unless distance, platform convention, or large surface size justifies more.

Implementation rules:

- Animate `transform` and `opacity` first. Avoid layout property animation such as width, height, top, left, margin, and padding.
- Prefer transitions for dynamic, interruptible UI. Use keyframes for predetermined sequences only.
- Avoid `transition-all`; name the property so unrelated state changes do not animate.
- Do not animate from `scale(0)`. Start near the final size so text and edges stay credible.
- Active press feedback should be subtle, often around `scale(0.97)`, and immediate.
- Popovers, menus, and sheets should animate from their trigger or natural edge through `transform-origin`.
- Reduced motion should remove movement and large transforms while preserving essential opacity, color, or instant state feedback.
- Debug motion with slow motion, frame-by-frame, physical device or simulator evidence, and next-day fresh eyes for non-trivial polish.

When reviewing UI code, include a design-engineering patch table for concrete motion/component fixes:

| Before | After | Why |
|---|---|---|
| `transition-all duration-500` | `transition-transform duration-200 ease-out` | Exact property, shorter duration, faster perceived response |
| `scale(0)` entry | `scale(0.95) + opacity` | Entry keeps physical continuity |
| Center-origin popover | Trigger-origin popover | Motion follows the user's mental model |

Advanced motion checks:

- Spring motion belongs on interruptible gesture work, drag momentum, and decorative living surfaces; avoid springs on dense functional dashboards where movement hides data.
- `@starting-style` is the preferred CSS entry pattern when supported; use mounted data attributes only as fallback.
- CSS variables are inheritable, so changing a parent variable during drag can recalculate all children. Update `transform` on the moving element instead.
- WAAPI is useful when programmatic control needs CSS-level animation performance.
- Stagger can help multi-item entry, but keep stagger 30-80ms and never block interaction while items finish.
- Use asymmetric enter/exit timing: deliberate holds can be slow, but release and cancellation should be snappy.

## Component craft heuristics

Toast, Drawer, Hold-to-delete, and clip-path components need interaction review, not screenshot review:

| Component | Review heuristics |
|---|---|
| Toast | Loading, success, and error states exist; timers pause when the tab is hidden; swipe dismissal uses pointer capture plus velocity threshold; stacked toasts keep stable height/gaps; hover gaps do not dismiss accidentally; critical errors are also persistent inline or page context. |
| Drawer | Mobile drawers use dialog-grade focus trap, focus return, background inertness, scroll-at-top drag rules, damped momentum, snap points, multitouch guard, `visualViewport` keyboard handling, safe-area spacing, and physical phone or simulator checks. |
| Hold-to-delete | Destructive copy says what will be deleted; release cancels; hold progress is visible and linear; release animation is quick; duplicate overlay content is `aria-hidden`; focus and keyboard alternative are present. |
| Clip-path reveal | Use for reveals, tabs, comparisons, and theme transitions when it prevents layout shift; duplicate visual overlays are `aria-hidden` and `tabIndex={-1}`; scroll-triggered reveals do not replay distractingly; View Transitions API is an optional platform path, not a requirement. |

Gesture details: confirm swipe dismissal has a velocity threshold, boundary damping, pointer capture after drag starts, and multi-touch protection so the component does not jump when fingers change.

## Slop catalog expansion

Priority catalog: flat type hierarchy, AI color palette, layout property animation, gradient text, glassmorphism, side-stripe accent borders, ghost-card border plus large shadow, extreme radius, repeated icon tiles, repeated section kickers, fake metric heroes, nested cards, too-long measure, bounce easing, overlong duration, marketing buzzwords, aphoristic cadence, and placeholder imagery.

Use the catalog as a detector. Still write the finding as evidence:

| Lane | Slop smell | Better review language |
|---|---|---|
| Typography | Flat type hierarchy, crushed tracking, oversized hero type, repeated eyebrow chips | "Hierarchy is flat; primary heading and body compete. Step the scale or weight so the CTA path wins first read." |
| Color | AI color palette, grey text on colored surface, dark glow, cream palette with weak contrast | "Color is decorative rather than semantic. Move emphasis into tokens that preserve contrast and state meaning." |
| Layout | Nested cards, identical grids, fake metrics, too-long line length, viewport-edge body text | "Grouping is doing decoration work. Flatten containers and use spacing or dividers to show relationships." |
| Motion | Bounce easing, layout property animation, image hover zoom, delayed frequent tooltip | "Motion steals attention or costs interaction time. Remove it, shorten it, or move it to transform/opacity with reduced-motion coverage." |
| Copy | Buzzword CTA, theater framing, generic empty state, em dash rhythm | "Copy hides the concrete task. Name the action, object, cause, or recovery path." |

## Design language handles

Design review needs shared handles, not vibes.

| Handle | Meaning | Look for | Implementation knobs |
|---|---|---|---|
| Density | How packed or airy a surface feels | Crowded cards, buried actions, sparse pages with weak grouping | `gap-*`, padding, row height, line-height, container width |
| Hierarchy | What reads first, second, third | Primary action lost, headings similar to body, too many accents | type scale, weight, contrast, order, placement, whitespace |
| Rhythm | Repeated spatial beat across a surface | Equal spacing everywhere, random jumps, no section cadence | spacing tokens, `gap`, section padding, grid rhythm, dividers |
| Anchor | Stable visual starting point | Floating content, unclear alignment edge, weak header/action relationship | grid columns, left edge, baseline, sticky header, action alignment |
| Negative space | Space that groups, separates, or emphasizes | Cramped groups, hollow empty regions, unrelated content stuck together | margin, padding, max-width, section breaks, grouping containers |
| Leading | Vertical space inside text lines | Paragraphs feel compressed, dark text feels heavy, long copy tires the eye | `leading-*`, font size, weight, max-width, paragraph spacing |
| Measure | Width of readable text blocks | Lines too long, headings break awkwardly, metadata wraps noisily | `max-w-*`, `ch` widths, grid columns, copy length |
| Visual weight | Perceived emphasis of an element | Secondary items overpower primary, borders/shadows compete with content | font weight, fill, border, shadow, opacity, color contrast |
| Affordance | Whether an element looks actionable | Ghost buttons, link-like text that is not a link, disabled ambiguity | Button variant, hover/focus/active states, cursor, icon, label |
| Scan path | Eye movement through the task | User must hunt, cards have no obvious reading order, CTA appears too late | layout order, alignment, focal point, progressive disclosure |

Design finding anatomy: Current read, Desired read, User-impact sentence, Evidence, Magnitude, Adjustment, Implementation knobs.

Current read and Desired read are the core pair: first name what the surface communicates now, then name what the user should notice or do after the adjustment. User-impact sentence explains why that read delta matters for task success, trust, comprehension, or conversion.

Design finding format:

```markdown
Vocabulary lane: <typography | color | iconography | layout | interaction | motion | accessibility | information architecture | copywriting | components>
Handle: <hierarchy | density | rhythm | anchor | negative space | leading | measure | visual weight | affordance | scan path>
Current read: <what dominates or feels unclear now>
Desired read: <what should dominate or feel clear>
User-impact sentence: <why this blocks comprehension, trust, task success, or conversion>
Evidence: <screenshot path, viewport, state, numbered callout>
Magnitude: <nudge | step | system>
Adjustment: <direction and scope>
Implementation knobs: <tokens, components, Tailwind utilities, layout props, copy, state>
```

Calibration:

| Weak note | Better note |
|---|---|
| Spacing feels off. | Density is too tight in the billing card. Metadata, helper text, and action read as one group, so the primary action loses hierarchy. Move the action row one spacing step away from supporting text. |
| Make it pop. | The primary action lacks visual weight. Increase contrast or use the primary button variant so it wins the first-read hierarchy. |
| Let it breathe. | Negative space is not separating groups. Add section-level space between filters and results while keeping each filter label/input pair tight. |
| Text is hard to read. | Leading and measure are fighting readability. Keep body copy near 65 to 75 characters and loosen line-height one step. |

Guardrails:

- Jargon is not evidence. Every handle needs observed evidence and user impact.
- Prefer token-level direction over exact pixels unless the system uses fixed values.
- Do not inflate whitespace everywhere. Whitespace should group, separate, or emphasize.
- Do not fix one screen by breaking design-system rhythm elsewhere.
- Do not confuse accessibility contrast with visual hierarchy.

Reviewer prompts:

- What should the user see first?
- Where does the eye land after a two-second squint test?
- Where does the scan path break?
- Which element anchors the composition?
- Is whitespace grouping related content or just making holes?
- Is the action weak because of hierarchy, affordance, copy, or placement?
- Is density appropriate for the task and user expertise?

Adjustment magnitude: Nudge, Step, System.

| Magnitude | Use when | Example direction |
|---|---|---|
| Nudge | One element is optically off | Align icon to text baseline, reduce secondary label weight |
| Step | One region needs a clearer read | Increase card padding one token, separate body from action row |
| System | The same issue repeats | Define spacing rhythm for all cards, standardize button hierarchy |

## Anti-pattern matrix

Use this as a detector-backed checklist, not a taste shortcut. If a pattern appears, name the visible symptom, the register mismatch, user impact, and fix knob.

| Pattern | Symptom | Fix knob |
|---|---|---|
| overused fonts | interface relies on Inter/Roboto/system defaults where brand voice matters | preserve existing identity or choose type from product/brand register |
| gray text on colored backgrounds | body/helper text looks washed out even when layout is sound | use darker shade of bg hue, increase contrast token, or simplify surface color |
| nested cards | cards inside cards create noisy depth and weak grouping | flatten with spacing, dividers, headings, or one container |
| bounce or elastic easing | motion feels dated or steals attention from state change | use short ease-out motion, instant reduced-motion path |
| gradient text | heading emphasis becomes decoration, not hierarchy | use solid text color, weight, scale, spacing, or layout isolation |
| purple/cyan SaaS default | palette reads generated instead of chosen | derive palette from product context, brand token, or existing system |
| icon tile stack | repeated rounded icon tile above every card heading | inline icon with heading, remove tile, or vary content structure |
| fake metric hero | decorative stats imply proof without real data | use real evidence, testimonial, product screenshot, or remove stats |

## Optional detector contract

If the detector is available and network/tooling policy allows it, run it as evidence input:

```bash
bunx impeccable detect <target>
bunx impeccable detect --fast --json <target>
```

Detector output is supporting evidence, not final judgment. Map each hit to the Anti-pattern matrix, then confirm visually in the relevant state/viewport. Detector unavailable is non-blocking: report `Detector unavailable: <reason>` and continue manual visual review. Do not vendor detector code or copy rule text; keep this skill's wording and evals local.

## Screenshot callouts

When screenshots exist, annotate or describe numbered callouts:

1. Assign callout numbers to visible issues.
2. Reference those numbers in findings.
3. Include viewport, state, and browser.
4. Use the squint test: name what remains dominant when details blur.

If image annotation is unavailable, write text callouts: "Callout 2: right side of pricing card, mobile 390x844".

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
- `/commit-push-pr --no-pr`: require before push unless skipped with reason.
- `/prototype`: compare alternatives pre-implementation.
- `/triage`: use `regression` mode for user-visible bugs.
- `self-reviewer` and `code-reviewer`: flag missing evidence for frontend/customer-facing surface diffs.
- Browser/e2e tests, CLI snapshots, and visual regression tools complement the review;
  passing tests do not replace rendered evidence.

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
- Design handles: hierarchy/density/rhythm findings include current read, desired read, and numbered callouts when screenshots exist.
- Findings: P0/P1 fixed or accepted; P2/P3 noted.
- Skip reasons: every unrun matrix item has reason.
- HTML report: absolute temp path, uploaded artifact, or skip reason.
- Automation candidates: repeatable misses worth hook/eval/docs.

## HTML report format

Visual review can render a single self-contained HTML report in OS temp dir. This mirrors `/improve architecture`: write the file first; add a renderer script later only if the JSON contract stabilizes.

Location: resolve temp dir from `$TMPDIR`, fallback `/tmp` or `%TEMP%`. Write `<tmpdir>/visual-review-<timestamp>.html`, open via `open`, `xdg-open`, or `start`, return absolute path. Do not write repo artifacts unless user asks.

### Scorecard

Product, Design, Engineering, QA. Four cards: score + one sentence. Scores = `strong`, `ok`, `weak`, `blocked`; decision support, not false precision.

| Hat | Judges |
|---|---|
| Product | user value, clarity, task success, friction, competitive quality |
| Design | hierarchy, spacing, affordance, copy, visual consistency, state quality |
| Engineering | async/slow-network resilience, platform risk, performance |
| QA | repro, unhappy paths, regression risk, automation opportunity |

### Design handles

Add a compact design-language strip:

| Vocabulary lane | Handle | Current read | Desired read | Magnitude | Implementation knobs |
|---|---|---|---|---|---|
| copywriting | hierarchy | secondary metadata dominates action | primary action wins first read | step | Button variant, weight, gap |

### Callouts

Screenshots can include numbered callouts. Each finding references callout number, screenshot path, viewport, browser, and state. If image annotation is unavailable, describe callouts in text.

### Finding cards

One compact card per finding. Sort P0 -> P3, then surface.

- Severity: P0, P1, P2, P3/nit
- Hat: Product, Design, Engineering, QA
- Surface: route, component, command, screen, report, flow
- Evidence: screenshot path, terminal capture, trace, console line, network condition, observation
- Why it matters: user/business impact, one sentence
- Fix: concrete next action
- Automate?: hook, eval, browser test, visual regression, fixture, or no

### State matrix

| Surface | Happy | Loading | Empty | Error | Dense | Slow network | Mobile/narrow | Keyboard | Dark/high contrast |
|---|---|---|---|---|---|---|---|---|---|

Every skip gets reason. `not reachable` ok; blank not ok.

### Automation candidates

| Candidate | Best home | Why |
|---|---|---|
| Deterministic source smell | PostToolUse hook | inspect changed text |
| Missing review evidence | Stop or commit-push-pr gate | workflow enforcement |
| Browser behavior regression | Playwright/browser test | runtime evidence |
| Screenshot diff | Visual regression tool | baseline compare |
| Subjective taste issue | Skill rubric/eval example | judgement required |
| Report rendering | Script | JSON -> HTML transform |
