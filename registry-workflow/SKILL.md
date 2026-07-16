---
name: registry-workflow
description: Component registry maintenance -- taxonomy, consumer drift analysis, sync discipline. Use when maintaining the shadcn registry or design system, syncing registry components, or analyzing consumer-repo drift.
---

# Setup Registry Workflow
## Hooks

- **PostToolUse** (`ui-registry-warn.sh`): warn once/session when edit UI component dirs | prompt upstream PR
- **PostToolUse** (`split-file-convention-check.sh`): split-file convention -- route pages are `*.page.tsx`; reusable pieces live under `components/`; reject `-parts`/`.dialogs`/`.checklist` mixes
- **Stop** (`registry-check.sh`): block if redpanda-ui modified without update `registry.json` + add changeset

## Component Taxonomy (Atomic Design)

Classify every registry component one level. Drive test depth.

| Level | useState | Registry imports | Custom kbd handlers | Portal | Test count |
|-------|----------|-----------------|-------------------|--------|------------|
| **Atom** | 0-1 | 0 | 0 | No | 3-4 |
| **Molecule** | 2 | 1-2 | 1-10 lines | Maybe | 5-8 |
| **Organism** | 3+ | 3+ | 10+ lines | Often | 8-15 |

Tiebreaker: highest-scoring signal win. Radix-provided kbd nav no count.

**Atom**: Single-responsibility primitives | one semantic HTML element/Radix primitive | zero or one controlled/uncontrolled toggle.
Examples: Button, Badge, Input, Label, Separator, Spinner, Skeleton, Checkbox, Switch

**Molecule**: Combine 2-3 atoms | limited local state (open/closed, selected index) | simple portals.
Examples: CopyButton, InputGroup, ButtonGroup, Field, Accordion, Breadcrumb, Card, Tabs

**Organism**: Multiple molecules+atoms | significant state (3+ vars or useReducer) | custom kbd nav | portal rendering.
Examples: Combobox, MultiSelect, DataTable, Dialog, DropdownMenu, Sheet, Sidebar, AutoForm

Component evolve between levels -> verify heuristics | expand tests new minimum | review FP compliance.

## Consumer Drift Analysis

Compare consumer repo components against registry source. Run on upstream sync.

### Process

1. **Discovery** -- scan `packages/registry/src/components/` | match against consumer dirs
2. **Comparison** -- `git diff --no-index --ignore-all-space` per component | skip empty diffs
3. **Filtering** -- apply rules below each non-empty diff
4. **Categorization** -- assign one status per component

### Filter Rules

| Rule | Detect | Action |
|------|--------|--------|
| **Import noise** | Only `@/`->`../` path changes, `'use client'` directives, biome comments | **Skip-Import-Only** |
| **Staleness** | Registry changelog newer than consumer file | **Skip-Outdated** -- consumer sync FROM registry |
| **Business logic** | String equality (`=== 'admin'`), feature flags, API endpoints, route logic, analytics, env checks | **Skip-Business-Logic** -- never upstream app-specific code |

### Business Logic Red Flags

| Pattern | Example |
|---------|---------|
| String equality checks | `title === 'Users'` |
| Hard-coded business data | `tier === 'enterprise'` |
| Feature flags | `featureFlagEnabled` |
| API endpoints | `fetch('/api/console/users')` |
| Route-specific logic | `pathname.includes('/dashboard')` |
| Analytics/tracking | `analytics.track(...)` |

Safe: prop-based logic (`variant === 'destructive'`, `size === 'lg'`).

### Output Statuses

| Status | Meaning |
|--------|---------|
| **Upstream** | Real functional diff, safe merge into registry |
| **Skip-Import-Only** | Only import path/directive noise |
| **Skip-Outdated** | Registry newer -- consumer pull, not push |
| **Skip-Business-Logic** | App-specific logic -- re-implement cleanly if needed |

## Governance rules (mined from the registry's own review history)

- **Registry sync is its own PR** -- never mixed with feature work; a registry update inside a feature diff hides accidental component regressions.
- **Consumers never hand-edit managed files** -- local edits get blasted away by the next upstream sync; consumer-specific code lives in a sibling file, never inside the managed one.
- **Breaking changes ship a codemod + a changelog entry with a migration example.** Manual white-gloving of consumers does not scale ("agents never seem to find them all"). After the codemod exists, delete the compat shim.
- **Consumer smoke tests on destructive flows after every registry upgrade** -- the canonical incident: a primitive renamed `onSelect`->`onClick` and every delete-confirmation dialog silently stopped opening. Visual baselines don't catch dead handlers.
- **Framework-agnostic invariant**: the registry never imports a router or app framework; consumers span routers and React majors.
- **API shape**: composition (children) over render-props/items arrays; variant axes are small and orthogonal (`tone` x `variant`), `default` maps to a named variant; deprecate-then-remove, never break.
- **Fix consumer misuse structurally**: when consumers repeatedly misuse an API (icon sizes, spacing), encode the correction in the component (selectors, stricter props) instead of repeating review comments.
- **Changesets are design docs**: each states affected components, user-visible before/after, and reasoning -- good enough that a consumer can decide to upgrade from the changeset alone.
- **Every animation honors `prefers-reduced-motion`; restrained motion is the default.** Documented tradeoffs (e.g. an extra lockfile for a scanner) carry a written why + external reference so they aren't re-litigated.

## Steps

1. Copy `scripts/ui-registry-warn.sh` + `scripts/registry-check.sh` -> `.claude/hooks/` | `chmod +x`
2. Configure `.claude/settings.json`:
   - PostToolUse (Edit|Write): `ui-registry-warn.sh`
   - Stop: `registry-check.sh`

## Verify
- [ ] Both hooks executable
- [ ] Edit `components/ui/` or `redpanda-ui/` trigger warning
- [ ] Modify `redpanda-ui/` without `registry.json` update -> Stop block
- [ ] Modify `redpanda-ui/` with `registry.json` but no changeset -> Stop block
