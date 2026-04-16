# React Rules Reference

## react-rules-check.sh

> Script: [`scripts/react-rules-check.sh`](scripts/react-rules-check.sh)

## Escape Hatch for useEffect

When `useEffect` genuinely needed (WebSocket cleanup, third-party lib), add comment before:

```tsx
// allow: useEffect — WebSocket subscription cleanup required
useEffect(() => {
  const ws = new WebSocket(url)
  return () => ws.close()
}, [url])
```

Hook checks for `// allow: useEffect` anywhere in file · reason required · legacy `// allow-useEffect:` also works.

## Raw HTML → Component Library Mapping

| Banned | Replacement | Import (shadcn/ui convention) |
|--------|-------------|-------------------------------|
| `<button>` | `<Button>` | `@/components/ui/button` |
| `<input>` | `<Input>` | `@/components/ui/input` |
| `<select>` | `<Select>` | `@/components/ui/select` |
| `<textarea>` | `<Textarea>` | `@/components/ui/textarea` |
| `<dialog>` | `<Dialog>` | `@/components/ui/dialog` |
| `<table>` | `<Table>` | `@/components/ui/table` |
| `<label>` | `<Label>` | `@/components/ui/label` |

`<form>` and `<a>` allowed — no registry replacement for `<form>`, `<a>` can't always swap with TanStack Router Link.

## Auto-Generated Files

All hooks auto-skip:

| Pattern | Source |
|---------|--------|
| `*.gen.ts` / `*.gen.tsx` | TanStack Router |
| `*_pb.ts` / `*_pb.js` | Protobuf codegen |
| `*_connectquery.ts` | Connect Query codegen |
| `@generated` / `auto-generated` / `DO NOT EDIT` in first 5 lines | Any codegen |

## Named useEffect Functions

Use named function expression, not anonymous arrow:

```tsx
// BAD
useEffect(() => {
  const ws = new WebSocket(url)
  return () => ws.close()
}, [url])

// GOOD
useEffect(function connectToWebSocket() {
  const ws = new WebSocket(url)
  return function disconnectWebSocket() {
    ws.close()
  }
}, [url])
```

### Why

- Named functions show in stack traces and React DevTools
- Forces articulating what effect does → reveals split opportunities
- Can't name without "and" → effect does too much → split
- Name starts with "sync"/"update" + state → probably derived state → compute inline

### Naming conventions

| Verb | Use for |
|------|---------|
| `subscribe`/`listen` | Event-based effects |
| `connect`/`disconnect` | WebSocket, SSE, external services |
| `synchronize`/`apply` | Syncing state with external systems |
| `initialize` | One-time setup |
| `poll` | Interval-based fetching |

## Form-Level Validation (react-hook-form v7.72+)

Cross-field validation (confirm password, end date > start date) — use `validate` on `useForm`, not custom logic in `onSubmit`:

```tsx
// BAD — validation buried in submit handler
const onSubmit = (data) => {
  if (data.password !== data.confirmPassword) {
    setError('confirmPassword', { message: 'Passwords must match' })
    return
  }
}

// GOOD — form-level validate, integrates with formState.errors
const form = useForm({
  validate: async ({ formValues }) => {
    if (formValues.password !== formValues.confirmPassword) {
      return {
        confirmPassword: { type: 'formError', message: 'Passwords must match' },
      }
    }
  },
})
```

Runs alongside field-level resolvers (zod, protovalidate) · surfaces errors through `formState.errors`.

## Resetting State on Prop Change — Use `key`

```tsx
// BAD — extra render, stale state visible
useEffect(() => {
  setComment('')
  setDraft(null)
}, [userId])

// GOOD — unmount/remount, all state resets
<UserProfile key={userId} />
```

`key` works on any component · key change → React destroys old instance, creates new with fresh state.

## Subscriptions — Prefer `useSyncExternalStore`

Browser APIs (online status, media queries, scroll position, external stores) → `useSyncExternalStore` over manual `useEffect` + `addEventListener`:

```tsx
// BAD — verbose, tearing in concurrent mode
const [isOnline, setIsOnline] = useState(navigator.onLine)
useEffect(function subscribeToOnlineStatus() {
  const handle = () => setIsOnline(navigator.onLine)
  window.addEventListener('online', handle)
  window.addEventListener('offline', handle)
  return () => {
    window.removeEventListener('online', handle)
    window.removeEventListener('offline', handle)
  }
}, [])

// GOOD — concurrent-safe, no boilerplate
const isOnline = useSyncExternalStore(
  (cb) => {
    window.addEventListener('online', cb)
    window.addEventListener('offline', cb)
    return () => {
      window.removeEventListener('online', cb)
      window.removeEventListener('offline', cb)
    }
  },
  () => navigator.onLine,
  () => true // server snapshot
)
```

### When to use `useSyncExternalStore`

| Use case | Example |
|----------|---------|
| Browser APIs | `navigator.onLine`, `matchMedia`, `document.visibilityState` |
| External stores | Redux, MobX, vanilla stores without React bindings |
| DOM state | scroll position, element dimensions (`ResizeObserver`) |

Skip for: React state, zustand (uses internally), TanStack Query.

## Functional Programming

Components = pure render functions · props in, JSX out · side effects in hooks only.

### Rules

| # | Rule | Violation | Fix |
|---|------|-----------|-----|
| 1 | Pure render | `localStorage.setItem()` in render | `useEffect` or custom hook |
| 2 | Side effects in hooks only | Timer in render body | `useEffect`/`useCallback`/custom hook |
| 3 | Immutable state updates | `arr.push(x)`, `state.x = y` | `[...arr, x]`, spread |
| 4 | Derive, don't sync | `useState` + `useEffect` to mirror prop | `useMemo(() => compute(prop), [prop])` |
| 5 | `useReducer` for 3+ interrelated `useState` | 3+ `useState` reading each other | Single `useReducer` with pure reducer |
| 6 | Extract data transforms | Inline `.filter().sort().map()` in JSX | Named pure function + `useMemo` |
| 7 | Stable refs for memoized children | Inline callback to `React.memo` child | `useCallback` (only if child memoized) |

### Derive vs Sync

```tsx
// BAD — extra render, race conditions
const [active, setActive] = useState<Item[]>([])
useEffect(() => { setActive(items.filter(i => i.active)) }, [items])

// GOOD — computed inline
const active = useMemo(() => items.filter(i => i.active), [items])
```

### useReducer Consolidation

3+ interrelated `useState` → single `useReducer`:

```tsx
type State = { open: boolean; query: string; highlighted: number }
type Action = { type: 'open' } | { type: 'close' } | { type: 'search'; value: string }

const reducer = (state: State, action: Action): State => {
  switch (action.type) {
    case 'open': return { ...state, open: true, highlighted: 0 }
    case 'close': return { ...state, open: false, query: '' }
    case 'search': return { ...state, query: action.value, highlighted: 0 }
  }
}
```

## Type Safety Patterns

### Discriminated Unions

Enforce valid prop combos at type level:

```tsx
type AlertProps =
  | { variant: 'info'; icon?: never }
  | { variant: 'warning'; icon: ReactNode }
  | { variant: 'error'; icon: ReactNode; onRetry?: () => void }
```

### Generic Components

```tsx
interface SelectProps<T> {
  value: T
  onChange: (value: T) => void
  options: { value: T; label: string }[]
}

function Select<T>({ value, onChange, options }: SelectProps<T>) { /* ... */ }
```

### ComponentProps Extension

```tsx
export interface InputProps extends React.ComponentProps<'input'> {
  error?: boolean
}
```

## Common Agent Excuses

| Excuse | Counter |
|---|---|
| "`as any` is fine just here" | Type erasure spreads. Fix type. |
| "Temporary @ts-expect-error" | Temporary → permanent. Fix now. |
| "`style={{}}` is simpler" | Tailwind composable + cacheable. Inline styles aren't. |
| "Raw `<button>` is fine" | `<Button>` — consistent styling, variants, a11y baked in. |
| "Add accessibility later" | Later never comes. Add now. |
| "`eval()` needed for dynamic code" | `JSON.parse()` for data. `new Function` also banned. |
| "useState + useEffect fine here" | Computed from props/state → `useMemo`. No sync state. |
| "Mutation is faster" | Immutable prevents bugs. Spread/filter/map. |
| "Don't need useReducer yet" | 3+ interrelated useState = useReducer. Don't wait for bugs. |
