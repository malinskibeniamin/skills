# Registry Workflow Reference

## registry-check.sh

> Script: [`scripts/registry-check.sh`](scripts/registry-check.sh)

## How It Works

The Stop hook runs when Claude finishes a turn. It checks:

1. Were any files in `redpanda-ui/` or `src/redpanda-ui/` modified? (`git diff --name-only HEAD`)
2. If yes — was `registry.json` also modified in the same diff?
3. If `registry.json` was NOT updated → **blocks** with a reminder

If no `redpanda-ui/` directory exists in the repo, the hook exits immediately (zero overhead).

## When It Triggers

| Changed files | registry.json updated? | Result |
|---|---|---|
| `redpanda-ui/button.tsx` | Yes | Pass |
| `redpanda-ui/button.tsx` | No | **Block** — rebuild registry |
| `src/components/UserTable.tsx` | N/A | Pass (not a registry file) |
| No files changed | N/A | Pass |

## Registry Rebuild Steps

When blocked:

1. Run the registry build command: `bun run build:registry`
2. Update `CHANGELOG.md` with the component changes
3. Let Claude finish the turn — the hook will re-check

## Skipping in Non-Registry Repos

The hook auto-detects: if neither `redpanda-ui/` nor `src/redpanda-ui/` exists at the repo root, it exits 0 immediately. No configuration needed to disable it in non-registry projects.

## Component Taxonomy — Detailed Classification

### Atom Examples

Single-responsibility. One semantic element. No composition from registry.

```tsx
// Button — atom. One element, variant props, no internal state.
export const Button = ({ variant = 'default', size = 'md', ...props }: ButtonProps) => (
  <button className={cn(buttonVariants({ variant, size }))} {...props} />
)
```

Test checklist (3-4 tests): callbacks fire, disabled state, `data-testid` pass-through, `asChild` renders custom element.

### Molecule Examples

Combines 2-3 atoms. Limited state.

```tsx
// CopyButton — molecule. Composes Button + uses clipboard state.
export function CopyButton({ text }: { text: string }) {
  const [copied, setCopied] = useState(false)
  // ...
}
```

Test checklist (5-8 tests): atom tests + composition renders, internal state transitions, edge cases (empty text, rapid clicks).

### Organism Examples

Multiple molecules+atoms. Significant state. Keyboard nav. Portals.

```tsx
// Combobox — organism. useReducer, keyboard nav, portal.
export function Combobox<T>({ options, onChange }: ComboboxProps<T>) {
  const [state, dispatch] = useReducer(comboboxReducer, initialState)
  // keyboard handler, portal rendering, filtering...
}
```

Test checklist (8-15 tests): molecule tests + keyboard nav (arrow keys, Escape, Enter), portal open/close, async filtering, controlled/uncontrolled modes.

## Consumer Drift Analysis — Workflow

### Running Drift Analysis

```bash
# Phase 1-2: Discovery + Comparison
mkdir -p .upstreaming/diffs
for component in packages/registry/src/components/*/; do
  name=$(basename "$component")
  consumer_file="<consumer-path>/$name.tsx"
  [ -f "$consumer_file" ] || continue
  git diff --no-index --ignore-all-space \
    "$component/index.tsx" "$consumer_file" \
    > ".upstreaming/diffs/${name}.diff" 2>/dev/null || true
done

# Phase 3: Remove empty diffs
find .upstreaming/diffs -empty -delete
```

### Import Normalization — What to Ignore

| Registry (source) | Consumer (installed) |
|---|---|
| `@/components/button` | `../components/button` or `./button` |
| `@/lib/utils` | `../lib/utils` |
| `@/hooks/use-toast` | `../hooks/use-toast` |

Also ignore: `'use client'` directive changes, biome-ignore comments, trailing whitespace.

If ONLY these differences exist → **Skip-Import-Only**.

### Staleness Detection

Before upstreaming, check `CHANGELOG.md` for recent registry updates:

| Registry newer? | Action |
|---|---|
| Yes (changelog > consumer file date) | **Skip-Outdated** — sync FROM registry |
| No or no changelog entry | Proceed with analysis |

### Business Logic Detection — Safe vs Unsafe

```tsx
// SAFE — prop-based (component API)
if (variant === 'destructive') { /* ... */ }
if (size === 'lg') { /* ... */ }

// UNSAFE — business data (app-specific)
if (status === 'premium') { /* ... */ }
if (userRole === 'admin') { /* ... */ }
if (pathname.includes('/dashboard')) { /* ... */ }
```

When business logic mixed with legitimate fixes: classify as **Skip-Business-Logic**. Re-implement fix cleanly in registry.
