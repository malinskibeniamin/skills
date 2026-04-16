---
name: setup-registry-workflow
description: Registry hooks + component taxonomy + consumer drift analysis. Use when maintaining a shadcn component registry, design system, or analyzing drift between consumer repos and registry.
---

# Setup Registry Workflow

## Hooks

- **PostToolUse** (`ui-registry-warn.sh`): warns once/session when editing UI component dirs · prompts upstream PR
- **Stop** (`registry-check.sh`): blocks if redpanda-ui modified without updating `registry.json` + adding changeset

## Component Taxonomy (Atomic Design)

Classify every registry component into one level. Drives test depth.

| Level | useState | Registry imports | Custom kbd handlers | Portal | Test count |
|-------|----------|-----------------|-------------------|--------|------------|
| **Atom** | 0-1 | 0 | 0 | No | 3-4 |
| **Molecule** | 2 | 1-2 | 1-10 lines | Maybe | 5-8 |
| **Organism** | 3+ | 3+ | 10+ lines | Often | 8-15 |

Tiebreaker: highest-scoring signal wins. Radix-provided kbd nav doesn't count.

**Atom**: Single-responsibility primitives · one semantic HTML element/Radix primitive · zero or one controlled/uncontrolled toggle.
Examples: Button, Badge, Input, Label, Separator, Spinner, Skeleton, Checkbox, Switch

**Molecule**: Combines 2-3 atoms · limited local state (open/closed, selected index) · simple portals.
Examples: CopyButton, InputGroup, ButtonGroup, Field, Accordion, Breadcrumb, Card, Tabs

**Organism**: Multiple molecules+atoms · significant state (3+ vars or useReducer) · custom kbd nav · portal rendering.
Examples: Combobox, MultiSelect, DataTable, Dialog, DropdownMenu, Sheet, Sidebar, AutoForm

Component evolves between levels → verify heuristics · expand tests to new minimum · review FP compliance.

## Consumer Drift Analysis

Compare consumer repo components against registry source. Run when upstream syncing.

### Process

1. **Discovery** — scan `packages/registry/src/components/` · match against consumer dirs
2. **Comparison** — `git diff --no-index --ignore-all-space` per component · skip empty diffs
3. **Filtering** — apply rules below to each non-empty diff
4. **Categorization** — assign exactly one status per component

### Filter Rules

| Rule | Detect | Action |
|------|--------|--------|
| **Import noise** | Only `@/`→`../` path changes, `'use client'` directives, biome comments | **Skip-Import-Only** |
| **Staleness** | Registry changelog newer than consumer file | **Skip-Outdated** — consumer should sync FROM registry |
| **Business logic** | String equality (`=== 'admin'`), feature flags, API endpoints, route logic, analytics, env checks | **Skip-Business-Logic** — never upstream app-specific code |

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
| **Upstream** | Real functional diff, safe to merge into registry |
| **Skip-Import-Only** | Only import path/directive noise |
| **Skip-Outdated** | Registry newer — consumer should pull, not push |
| **Skip-Business-Logic** | App-specific logic — re-implement cleanly if needed |

## Steps

1. Copy `scripts/ui-registry-warn.sh` + `scripts/registry-check.sh` → `.claude/hooks/` · `chmod +x`
2. Configure in `.claude/settings.json`:
   - PostToolUse (Edit|Write): `ui-registry-warn.sh`
   - Stop: `registry-check.sh`

## Verify
- [ ] Both hooks executable
- [ ] Editing `components/ui/` or `redpanda-ui/` triggers warning
- [ ] Modifying `redpanda-ui/` without `registry.json` update → Stop block
- [ ] Modifying `redpanda-ui/` with `registry.json` but no changeset → Stop block
