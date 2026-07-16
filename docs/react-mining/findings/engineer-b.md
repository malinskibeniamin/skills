# Engineer B (engineer-b) — design-system craft mining (weight 9)

> Lean single-pass (quota-constrained), done inline without subagents. Corpus verified locally; 4 diffs read in depth, the rest profiled from subjects/stats.

## Corpus

| Repo | Commits/PRs | Range | Nature |
|---|---|---|---|
| ui-registry (local) | 46 squash-merged PRs | 2026-04-16 → 2026-07-07 | his center of gravity — 48 of 66 org-wide merged PRs |
| console (local) | 12 squash-merged PRs | 2026-05-11 → 2026-07-10 | registry consumption: Base UI migration, RPCN template gallery, Select/tooltip polish |
| cloudv2 (local) | 8 commits | 2026-05-29 → 2026-07-06 | feature flags, Chakra-era fixups, separator alignment |

Recent hire (~April 2026). Domain: **the component registry itself** — micro-interaction correctness, semantic color, component API design, upstream-drift stewardship. Complementary to Engineer A's app-architecture layer; almost no overlap in theme.

## Taste principles extracted

### P1 — Floating UI must track its anchor's lifecycle — `hook`/`skill`
Tooltip lingered after its anchor scrolled out of view; fix: `data-anchor-hidden:pointer-events-none data-anchor-hidden:opacity-0` on the positioner (`15a17a9d`, UX-1291). Same class: "Remove tooltips when anchor is hidden", "Dropdown with nested dialogs fix" (`1f3bd649`), "Tabs improvements when opened in portals" (`5a47a484`). Rule: any floating/portal element (tooltip, dropdown, popover) must handle anchor-hidden, nested-portal, and scroll-away states.

### P2 — Overlays mount in portals for consistent layering — `skill`
Sonner Toaster moved into a portal "for more consistent consumer app mounting… and layering contexts" (`7f6976aa`). Registry components must not depend on where the consumer mounts them.

### P3 — Semantic color = dark-safe by construction, tone in the surface not the text — `skill`
Alert adopted the Badge subtle palette (`4914f21f`): tone-tinted surface + matching outline + colored icon, body text stays high-contrast neutral in both themes — "the tone is carried by the surface, border, and icon — not the body text". Ad-hoc raw palettes had broken dark mode ("warning rendered as a glaring near-white blob").

### P4 — Color ramps need perceptual weight parity across hues — `skill`
Same commit: added `--color-orange-950`/`--color-red-950` because those ramps bottomed out at a too-luminant `-900` while blue/green sat at `-900` comfortably — large tinted surfaces must sit at the same visual weight regardless of hue.

### P5 — Token renames must never silently fall back — `hook`
`--color-info` → `--color-informative` rename left `text-info` resolving to nothing; blue text silently inherited the parent color (`4914f21f`). Rule: on any design-token rename, keep a duplicate alias until callsites are migrated, and grep-verify no utility resolves to nothing. Mechanically checkable: scan for `text-*`/`bg-*` utilities referencing tokens absent from the theme.

### P6 — Variant APIs are small orthogonal axes, not flat strings — `skill`
Badge's 34 flat variant strings collapsed to `tone` (7 semantic colors) × `variant` (solid/subtle/outline) + `disabled` prop (`4914f21f`). Non-breaking: old strings kept as `@deprecated` aliases with a full migration map in docs. Deprecate-then-remove over break.

### P7 — Converge vendored registry toward upstream, ship codemods, delete shims — `skill`
"ShadCN drift convergence" (`d65e592c`, 720 files): periodically pull the vendored registry back toward shadcn base; the 517-line `base-ui-compat` shim was deleted once a tested codemod (`codemods/base-ui-migration.ts` + 123-line test) existed for consumers. Registry stewardship = automate the consumer migration, then remove the compat layer. Also `8bfe4d94f`/`5eb31eba` (console side: sync + "fixes from console migration work" fed back upstream).

### P8 — Changesets are design docs — `skill`/`exemplar`
Every registry change ships a changeset naming affected components, the user-visible before/after, and the rationale (see `.changeset/alert-badge-palette.md` in `4914f21f` — it explains perceptual reasoning, regression risk, and the migration path). This is the written-communication bar for design-system PRs.

### P9 — Component states nobody tests get dedicated fixes: stuck, indeterminate, disabled, drag — `skill`
Recurring subjects: "Checkbox fixes - Stuck & Indeterminate" (`87a58314`), "tab disabled states fix" (`0a81f362`), "Tabs scrollable via drag" (`d2d1a331`), "button loading state" (`f85df1db`), "multi-select fixes" (`fad71314`). The registry bar covers the full state matrix of a component, not the happy path.

### P10 — Animation is tuned, then removed when it fights usability — `skill`
"Tab animation improvements" (`aa7dcaad`) then "Remove tabs content animation" (`20c2fc88`); "toggle group animations" (`86b861e6`); "tabs active state not as rounded" (`f2e6e71f`). Motion serves state clarity; when it causes scroll-jumping (`6bf16344`) or lag, delete it.

### P11 — Support the consumer matrix explicitly (React 18 + 19) — `skill`
"Small typechange to better support React 18 consumers" (`fe686fbd`), "Fixing React 18 error in code-block-dynamic" (`f42b0fe8`). The registry is consumed by apps on different React majors (cloud-ui 18, adp-ui 19 per architecture-evolution.md) — types and runtime must tolerate both.

## Gaps (NOT MINED — future deeper pass)
- Remaining ~40 ui-registry diffs and all 12 console PR diffs unread (subject-level only).
- His PR review comments (taxonomy like Engineer A's pr-craft pass) — needs `gh` mining.
- Lookout Tool (`6e47e0ae`) — a registry tooling feature worth studying for the registry-workflow skill.
