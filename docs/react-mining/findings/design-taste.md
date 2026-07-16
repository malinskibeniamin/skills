# Design taste mining — UI architecture + visual/UX judgment

Corpus: 4,050 Engineer A frontend commits, 2022-08 → 2026-07, in ~/Documents/git/cloudv2 (apps/cloud-ui, adp-ui, admin-ui, adp-console). Weighted toward 2025-2026 adp-ui (the most refined app).

## Design-system evolution (context for everything below)

1. **2022-08→09**: cloud-ui bootstrapped with homegrown components, immediately migrated to Chakra UI — `b58da95d` (2022-09-06, Card→Chakra Box), `915ffbd8` (Chakra Modal), `c332711d` (Breadcrumb→Chakra).
2. **2023**: shared Chakra-based `the legacy UI library` library, versions 2.x-3.x — `a153f7b5` (2023-05-19), `a518d8c2` (2023-07-28).
3. **2025-08-22**: `d9e5c3eb` "cloud-ui: set up design system" — the vendored registry theme.css lands (shadcn/Tailwind v4 tokens).
4. **2026-01→04**: registry rollout — `093110fa` (2026-01-19 admin-ui registry), `df535da4` (2026-01-19 react-icons→lucide-react, centralized `components/icons` hub, title→aria-label), `dd4ac1df` (2026-03-30 adp-console adopts StatusBadge/CopyButton/Alert), `a9164d27` (2026-04-17 adp-ui "migrate to registry patterns" — filtered-table, header idiom, form-footer, BadgeGroup).
5. **2026-06**: vendored-shadcn discipline hardens: base kit treated as upstream, never forked (see P8).

**Important**: the repo already codifies much of this in `apps/adp-ui/.claude/skills/{form-ux,design-audit,ui-development,molecules,organisms}` and `apps/adp-ui/docs/design/*.md` (numbered ADRs with design sign-off quotes). The berlin skill should align with/import these, not re-derive.

---

## P1 — Two-click create; the detail page is the wizard

Create forms collapse to the minimum viable decision (name + one choice); everything optional is defaulted and moved to post-create. No success dialog — redirect straight to the detail page, where each config area is its own editable tab/section ("continue the wizard from there"). Resources are created enabled when an empty config is pass-through-safe. Rationale (ADR 0005 sign-off quotes): "I would like to create a guardrail in two clicks… the form is way more complicated than it needs to be"; "Let's make everything that's optional happen at the update stage"; "I don't want a 'Guardrail created' dialog."

- **Anti-pattern**: multi-step create wizard/stepper front-loading every optional field, ending in a success modal.
- **Evidence**: `beee163245` (2026-06-11, guardrails create+details redesign, ships ADR `docs/design/0005-guardrails-create-details-redesign.md`); `3a11e78aa` (2026-06-11, one-card create flow — deletes `guardrail-create-wizard.tsx` +481-line wizard test); `ff7fcc0ea` (2026-04-21, drops CallbackUrlCallout from create — the callback URL belongs on the detail page, when the user actually needs it); `35da805e5` (2026-06-23, Users rework: detail page mirrors the OAuth/guardrail loader-prefetch + Suspense + not-found Empty pattern).
- **Enforcement**: `skill` — "Create = name + the one identity-defining choice, defaults for the rest, straight redirect to detail. Detail page = editable sections, no separate /edit page." `exemplar`: `apps/adp-ui/src/routes/_authenticated/guardrails/$name.details-parts.tsx`, ADR 0005.

## P2 — Flatten nesting; move hand-holding into helper drawers

Primary surfaces show only the inputs; deep guidance (token-by-token regex explanation, cron breakdowns, next-runs, quick references, CLI setup) lives in an on-demand right-side Sheet that echoes live field state so it stays usable even when a modal hides the inline field. Nested cards flatten to divider-separated rows with segmented controls, inline switches, and info tooltips.

- **Anti-pattern**: 4-deep nested cards; always-open three-tab explainer panels next to a fresh field; repeated help paragraphs inline.
- **Evidence**: `b4c35bb8b` (2026-06-09, flattens 4-deep policy cards → flat layout, None/Low/Medium/High segmented control, help→tooltips, labelled slider ticks, pre-filled safe defaults so rows are "never enabled-but-empty"); `14c31fd22` (2026-06-19, RegexField declutter: "a fresh field now reads as just two inputs instead of an always-open three-tab panel"); `f0bfb5cbd` (2026-06-29, cron helper drawer + live per-field part blobs graded valid/invalid as you type); `f82e84bb7` (2026-07-14, contextual rpk-ai setup drawer reused across 5 detail pages).
- **Enforcement**: `skill` + `exemplar`: `apps/adp-ui/src/components/rpk-ai/rpk-ai-guide-drawer.tsx`, `apps/adp-ui/src/components/cron-field/`.

## P3 — Card-grid pickers for choose-one-of-N with identity

When options have identity (a provider, a transport, an auth method), pick via a searchable card grid — icon, name, one-line description, key stat — not tabs or a dropdown. Custom/escape-hatch card first. Clamped descriptions measure overflow and only then add a tooltip with the full text ("short descriptions render the plain div without tooltip noise").

- **Anti-pattern**: preset tabs; a bare Select for choices that carry branding and consequences; tooltips on everything whether or not content is clipped.
- **Evidence**: `4c2086135` (2026-04-15, preset tabs → card-grid provider selection, "Custom card first per a teammate feedback"); `067b825ed` (2026-04-18, card picker for Transport/Auth/Token-Endpoint-Auth); `4c9cb3dc5` (2026-04-20, tooltip only when line-clamp actually truncates — measured scrollHeight vs clientHeight); `6f8925a58` (2026-04-20, CSS-columns masonry for the picker).
- **Enforcement**: `exemplar`: `apps/adp-ui/src/components/molecules/picker-card-grid.tsx`. `skill` for the measured-clamp-tooltip rule.

## P4 — Empty states: one unambiguous CTA; four states, one component

Every list handles loading / error / no-data / no-filter-match through the same Empty component. First-run empty state offers a single primary action — alternates and shortcuts are removed even when convenient ("Remove them so the empty state offers a single, unambiguous 'Create guardrail' CTA"). Filtered-empty offers "clear filters", not "create".

- **Anti-pattern**: empty state with 3 preset shortcut buttons competing with the primary CTA; hand-rolled per-page empty divs; missing filtered-empty distinct from no-data.
- **Evidence**: `8baefc6c8` (2026-06-14, drops preset shortcuts from guardrails empty state); `87f5f614d` (2026-04-20, PickerEmptyState → Empty with clear-filters action); `c63471ca0` (2026-03-30, "Empty component consistently for all empty states: loading, error, no data, no matching filter"); `870ff9f33` (2026-06-12, Empty adopted in inspector history/notifications/tool-runner); lineage back to `371f4007d`/`5daaa2d71` (2024, PaymentMethods empty state).
- **Enforcement**: `skill` — "List page = exactly four states via Empty; no-data gets ONE CTA; filtered-empty gets clear-filters." `exemplar`: `apps/adp-ui/src/components/molecules/resource-list-content.tsx` (embeds ResourceEmptyState/ListLoading/ErrorState).

## P5 — Tables earn their columns; width is a budget

A column must justify itself at a glance; anything recoverable elsewhere (detail page, row-action copy) is dropped before it forces horizontal scroll. Columns declare responsive rules against **container** width (not viewport — the app runs inside a module-federation frame with a sidebar) and auto-hide by tier; the phone tier keeps name + status + actions. Fluid tables get a min-width floor so overflow scrolls rather than crushing cells to "Di…".

- **Anti-pattern**: URL columns pushing tables past the viewport, clipping the actions column; columns crushed to one character; viewport-based breakpoints that break inside embedded frames.
- **Evidence**: `20cfd320b` (2026-04-20, drops API URL column — "Models is the more useful at-a-glance column, and the URL is still surfaced on the detail page plus the row's Copy action"); `afaa4e824` (2026-04-20, ResizeObserver column-visibility hook, per-column px breakpoints on wrapper width); `c61003a5b` (2026-07-03, phone tier: llm-providers drops models+spend, ~800px floor → ~440); `1138eb9a8` (2026-06-29, min-width floor = sum of column sizes so wrappers scroll instead of crushing).
- **Enforcement**: `skill` + `exemplar`: `apps/adp-ui/src/hooks/use-responsive-column-visibility.ts`, `resource-list-content.tsx` fluidColumns.

## P6 — Truncate with a recovery path; be honest about what's cut

Every truncation surfaces the full value: `block truncate` + `title`, tooltip on clamp, or a copy action in the row menu. When the system itself truncates data (CSV export, client-side-filtered lists), the UI discloses it truthfully rather than hiding the note.

- **Anti-pattern**: `overflow-hidden` cells clipping emails mid-character with no hover recovery; "Showing first 250" notes that are inaccurate; silent export truncation.
- **Evidence**: `0f6b4f793` (2026-07-09, members name/email `truncate` + title, "matching the agents-list pattern"); `a189fe520` (2026-04-19, API URL tooltip on truncate + copy in row dropdown); `b7f0956cc` (2026-06-19, "make Users truncation note honest about client-side filter"); `80fa66b8` (2026-06-24, CSV export "fail loud on truncation"); `15b357f54` (2026-06-23, disclose truncation on Cost & Usage CSV); `35da805e5` (fetch-all pagination removes the truncation note "as genuinely unnecessary rather than just hiding it").
- **Enforcement**: `skill` — "truncate ⇒ title/tooltip/copy; never hide a limitation, remove the limitation or state it accurately."

## P7 — Dark mode is a first-class theme, tested, fixed via semantic tokens

Every visual regression test captures light AND dark. Dark bugs are fixed by pointing at theme-aware semantic tokens ("No bespoke tokens"), choosing tokens one neutral step off the surface, never hardcoded palettes. Third-party surfaces (Sonner) are re-pointed at app tokens.

- **Anti-pattern**: light-only visual suites; `--muted` track invisible on `--card` in dark; bright light-palette toasts on a near-black page; light-mode-only alert variants.
- **Evidence**: `77c8e3561` (2026-06-14, dark variant reuses the entire light browser config, `-dark` baseline infix — dark regressions "went uncaught"); `b3e74eaf9` (2026-06-24, Sonner variables → semantic tokens, kept regression test asserting toast luminance < 0.5); `f8f475aa5` (2026-06-14, progress track dark:bg-border — "one neutral step off any dark surface"); `205a0c646` (2026-04-19, dark-mode-safe brand icons); `0f64014b2` (2026-06-24, cross-mode contrast fixes verified by reading Playwright screenshots).
- **Enforcement**: `hook`/CI — dark-mode browser variant is mechanical (test:browser:dark job exists). `skill` for the token-selection guidance.

## P8 — Never fork the base kit; scope overrides to call sites, upstream the rest

Vendored shadcn/registry components stay pristine. A surface-specific need is met with a call-site className override (tailwind-merge beats the base class), never a new variant in the vendored cva, never a new theme token when an existing semantic token works. Genuine base-kit gaps are upstreamed to ui-registry and the local edit is a tracked temporary referencing the upstream PR. (Refines the already-encoded "fix specificity at source" with mechanics.)

- **Anti-pattern**: adding a global `screen` height variant to the vendored dialog; minting an orange-alpha token scale for one badge; sizing rules living in globals.css instead of consumers.
- **Evidence**: `07d203760` (2026-06-25, reverts dialog cva variant, applies h-[90dvh] at the one call site); `ceb1e3047` (2026-06-25, reverts shadcn dropdown edit; `w-auto max-w-xs` on row-action call sites); `19c4d3b1b` (2026-06-19, reverts new tokens, uses existing bg-warning/10; Alert fix "upstreamed to ui-registry PR #216; the vendored edit is now a tracked temporary"); `0c6b9071d` (2026-07-03, moves drawer/kv-grid sizing off globals.css into consumers).
- **Enforcement**: `hook` — mechanical: diff touching `components/shadcn/`/`components/registry-ui/` requires an `UPSTREAM:` comment/PR ref; diff adding tokens to theme.css blocked without registry reference. Repo already has this rule in prose (`apps/adp-ui/.claude/skills/ui-development/SKILL.md`).

## P9 — Spacing is layout rhythm, not per-element margins

Pages are gap-columns (list pages = a gap-6 flex column); dialogs use DialogBody (standard p-4 + scroll); registry components never carry margins — wrappers own spacing. Deviations from the rhythm are treated as bugs and tests assert the rhythm structurally ("row gap equals a reference gap-6 element… robust to root font-size change").

- **Anti-pattern**: pagination glued to the table inside a scroll wrapper; form grids touching dialog edges; redundant px-0 py-0 utility noise; margins on registry components.
- **Evidence**: `425ae540e` (2026-06-19, matches Users table-to-pagination gap to "the gap-6 list rhythm" every other page uses); `ea35584d9` (2026-06-15, pricing dialog: wrap in DialogBody, "room to breathe"); `e2a77376c` (2026-06-26, collapse px-0 py-0 → p-0); `5569e1232` (2026-06-10, agent card dialog body padding so JSON doesn't crowd the modal).
- **Enforcement**: `skill` — "space via container gap tokens; one rhythm per page type; never margin registry components."

## P10 — Dialog viewport contract: body scrolls, footer reachable, no nested dialogs

Dialog content = header + scrollable flex-1 body + pinned footer; server-controlled content can never push actions out of reach. Maximized views fill the real viewport (dvh). Dialogs/sheets portal into the shared content root so popovers stack correctly. A flow too big for a dialog links out to the full page — dialogs never nest dialogs.

- **Anti-pattern**: field lists pushing Send/Cancel past an 85vh cap with no scroll; a maximized chart capped at 880px on a large monitor; a create-provider dialog opening a second dialog with unclickable cards inside.
- **Evidence**: `91e6bda0d` (2026-07-09, DialogBody flex-1 so elicitation footer "stays pinned and reachable"); `1881849` + `07d203760` (2026-06-24/25, maximize dialog → 90dvh, test: content ≥88% viewport, chart ≥70% of body); `ff7fcc0ea` (2026-04-21, deletes nested CreateProviderDialog — links to the full 2-step page flow instead); `baf1d252b` (2026-06-25, portal dialogs/sheets into shared content root); `ea8db21c8` (2026-06-25, frame maximized chart so sparse data isn't stretched into "wide slabs" — cap plot width by bucket count, centre it).
- **Enforcement**: `skill` + `exemplar`: registry DialogBody usage; `apps/adp-ui/src/components/cost-and-usage/maximized-chart-frame.tsx`.

## P11 — Dashboards rank attention; stats are true numbers from one call

The home rework organized around "attention, stats, budget, usage": greeting kept, decorative badges/cluster-ids dropped, stat strip trimmed to exactly three metrics, per-card create CTAs removed (View all only), whole sections (Quickstarts, Updates) deleted. Headline stats come from a purpose-built RPC with server-side distinct counts — never a page-capped row-count proxy. Detail pages get sparklines/metric breakdowns rather than big charts in rows.

- **Anti-pattern**: dashboards as feature grids with a CTA per card; stat tiles computed from the first page of a list (undercounts fleets); header noise (badges, ids) competing with the one number that matters.
- **Evidence**: `e08927069` (2026-06-09, home rework — full rationale in commit body); `8de3feeca` (2026-06-08, InsightsService stat strip, "removes the row-count proxy that under-counted"); `0ff915224` (2026-06-22, metric breakdowns + sparkline on LLM provider detail); `3260c1c56` (2026-06-19, align budget watchlist progress bars).
- **Enforcement**: `skill` — "stat strip = ≤3 headline metrics, real aggregates; resource cards navigate, they don't all create."

## P12 — Icons are real brand marks, legible in both themes, drift-tested; icon-only affordances must earn discoverability

Brand icons are real SVG logos (not mono-tinted approximations), dark-safe, centralized; a CI drift test fails when a provider lacks an icon. When an icon-only control is missed by users, it becomes a labeled or hover-expanding pill — subtlety loses to discoverability.

- **Anti-pattern**: simple-icons mono+tint stand-ins; PNG logos; a "faint borderless book glyph that was easy to miss" as the docs entry point; low-contrast `secondary` badges; hairline checkbox ticks.
- **Evidence**: `56c9426f4` (2026-06-04, real brand SVGs replace mono+tint); `9fed87b79` (2026-04-29, icon coverage drift test in CI); `c6c5eaca2` (2026-06-25, icon-only DocsBadge → prominent hover-expanding "Documentation" pill, accessible name unchanged); `0f64014b2` (2026-06-24, neutral-outline badge over secondary, stroke-[3] tick); `df535da48` (2026-01-19, centralized icon hub + aria-label).
- **Enforcement**: `hook` (drift test pattern — mechanical, already exists: `apps/adp-ui/src/components/brand-icons.tsx` + coverage test); `skill` for the discoverability rule. `exemplar`: `apps/adp-ui/src/components/molecules/docs-badge.tsx`.

## P13 — Loading reserves layout; no flash, no shift

Skeletons exist "to avoid layout shift" (verbatim, 2023) and match the surface's shape; routes prefetch in loaders and render under Suspense with RouteErrorComponent; viewport-dependent chrome reads state synchronously so there's no desktop-sidebar flash on mobile. Removed skeletons/loading states get restored as regressions.

- **Anti-pattern**: content popping in and reflowing the page; spinner-only pages; sidebar flashing desktop layout before collapsing.
- **Evidence**: `6f876a6b5` (2023-06-19, SkeletonLoadingSection "to avoid layout shift"); `9f5d23a73` (2026-05-21, restore sidebar loading skeleton); `d7536012b` (2026-05-28, restore empty loading state); `1138eb9a8` (2026-06-29, useIsMobile reads viewport synchronously — "no desktop-sidebar flash"); `35da805e5` (loader-prefetch + Suspense + not-found Empty as the standard detail pattern).
- **Enforcement**: `skill` + `exemplar`: `apps/adp-ui/src/components/molecules/list-loading.tsx`.

## P14 — Humanize copy, but keep machine truth beside it

Validation errors are humanized ("must be at least 1 characters" → "This field is required"), labels/help hydrate from proto annotations, but raw machine identifiers stay visible next to human labels when operators need them: a deliberate revert kept both the raw `server_error` badge and the humanized "Server error" — "the duplication IS the mapping" for cross-referencing logs and specs.

- **Anti-pattern**: deduplicating away the raw enum/code; hardcoding label strings that proto annotations already provide; leaking raw validation messages to users.
- **Evidence**: `6f2daf3ed` (2026-04-21, revert commit: "keep both errorType badges — the duplication is the mapping"); `b4c35bb8b` (2026-06-09, humanized nested repeated-field errors); `d371e74ec` + `d3a32ec70` (2026-06-03/12, proto-driven help/tooltip annotations feed the UI).
- **Enforcement**: `skill`.

## P15 — Mark required, never say "optional"; help is a tooltip icon, not a paragraph

One canonical red `*` (`RequiredIndicator`, aria-label="required" so SRs don't announce "star"), shown before submit, ordered asterisk-before-help-icon, consistent across every create form. Optional fields carry no marker at all (ADR sign-off: "if a field is optional, don't say 'optional'"). Inline FieldDescriptions give way to help tooltip icons.

- **Anti-pattern**: three forms with three requirement conventions (none / bespoke `*` markup / proto-driven only); screen readers announcing the glyph; requirement only discoverable via submit-time error summary.
- **Evidence**: `6cea4032d` (2026-04-20, RequiredIndicator + RequiredProtoField, full rationale in body — "users see the requirement before clicking"); `d92537450` (2026-07-14, standardize requirement indicators repo-wide); `e7bbfda3d` (2026-06-04, asterisk-before-help order); ADR 0005 help-to-tooltip deviation.
- **Enforcement**: `exemplar`: `RequiredIndicator` component; `skill` for ordering + no-"optional" rule.

---

## Exemplar files (current house style, adp-ui)

- `apps/adp-ui/src/components/molecules/resource-list-content.tsx` — the list-table molecule: fluid/flex column sizing, empty/loading/error states, pagination rhythm.
- `apps/adp-ui/src/components/organisms/crud-form-section.tsx` + `apps/adp-ui/src/components/molecules/crud-page-layout.tsx` — form/detail architecture (one RHF instance per section, FieldMask-scoped saves).
- `apps/adp-ui/src/components/rpk-ai/rpk-ai-guide-drawer.tsx` — contextual helper drawer.
- `apps/adp-ui/src/components/molecules/docs-badge.tsx` — in-context docs affordance.
- `apps/adp-ui/src/routes/_authenticated/guardrails/$name.details-parts.tsx` — detail-page-as-wizard.
- `apps/adp-ui/.claude/skills/form-ux/SKILL.md` — the codified CRUD pipeline (phased, HALT gates, "compose, don't re-implement", "never add fixed widths to pages or forms").
- `apps/adp-ui/docs/design/0005-guardrails-create-details-redesign.md` — ADR format: sign-off quotes per deviation, deliberate non-implementations recorded.
