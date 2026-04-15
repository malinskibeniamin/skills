# React Rules Reference

## react-rules-check.sh

> Script: [`scripts/react-rules-check.sh`](scripts/react-rules-check.sh)

## Escape Hatch for useEffect

When `useEffect` genuinely needed (WebSocket cleanup, third-party lib integration), add comment on line before:

```tsx
// allow: useEffect — WebSocket subscription cleanup required
useEffect(() => {
  const ws = new WebSocket(url)
  return () => ws.close()
}, [url])
```

Hook checks for `// allow: useEffect` anywhere in file. Reason required for code review. Legacy format `// allow-useEffect:` also works.

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

`<form>` and `<a>` allowed — `<form>` no standard registry replacement, `<a>` can't always swap with TanStack Router Link.

## Auto-Generated Files

Following files auto-skipped by all hooks:

| Pattern | Source |
|---------|--------|
| `*.gen.ts` / `*.gen.tsx` | TanStack Router (`routeTree.gen.ts`) |
| `*_pb.ts` / `*_pb.js` | Protobuf codegen |
| `*_connectquery.ts` | Connect Query codegen |
| Files with `@generated` / `auto-generated` / `DO NOT EDIT` in first 5 lines | Any codegen tool |

## Named useEffect Functions

Always use named function expression in `useEffect`, not anonymous arrow:

```tsx
// BAD — anonymous arrow
useEffect(() => {
  const ws = new WebSocket(url)
  return () => ws.close()
}, [url])

// GOOD — named function with symmetrical cleanup
useEffect(function connectToWebSocket() {
  const ws = new WebSocket(url)
  return function disconnectWebSocket() {
    ws.close()
  }
}, [url])
```

### Why

- Named functions show in stack traces and React DevTools (not `(anonymous)`)
- Forces articulating what effect does — reveals split opportunities
- Can't name without "and"/"also" → effect does too much — split it
- Name starts with "sync"/"update" + state → probably derived state — compute inline during render

### Naming conventions

| Verb | Use for |
|------|---------|
| `subscribe`/`listen` | Event-based effects |
| `connect`/`disconnect` | WebSocket, SSE, external services |
| `synchronize`/`apply` | Syncing React state with external systems |
| `initialize` | One-time setup |
| `poll` | Interval-based data fetching |

## Form-Level Validation (react-hook-form v7.72+)

Cross-field validation (confirm password, end date after start date) — use `validate` on `useForm`, not custom logic in `onSubmit`:

```tsx
// BAD — validation logic buried in submit handler, errors not surfaced to UI
const onSubmit = (data) => {
  if (data.password !== data.confirmPassword) {
    setError('confirmPassword', { message: 'Passwords must match' })
    return
  }
  // ...
}

// GOOD — form-level validate, errors integrate with formState.errors
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

Runs alongside field-level resolvers (zod, protovalidate), surfaces errors through standard `formState.errors` API.

## Resetting State on Prop Change — Use `key`

Need reset component state when prop changes? Don't use `useEffect`:

```tsx
// BAD — extra render pass, intermediate stale state visible
useEffect(() => {
  setComment('')
  setDraft(null)
}, [userId])

// GOOD — React unmounts and remounts, all state resets automatically
<UserProfile key={userId} />
```

`key` prop works on any component, not just lists. Key change → React destroys old instance, creates new one with fresh state.

## Subscriptions — Prefer `useSyncExternalStore`

Subscribing to browser APIs (online status, media queries, scroll position, external stores)? Use `useSyncExternalStore` over manual `useEffect` + `addEventListener`:

```tsx
// BAD — verbose, prone to tearing in concurrent mode
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

// GOOD — concurrent-mode safe, no boilerplate
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
| DOM state | scroll position, element dimensions (with `ResizeObserver`) |

Don't use for: React state, zustand (already uses internally), TanStack Query.

## Functional Programming

Components = pure render functions. Props in, JSX out. Side effects in hooks only.

### Rules

| # | Rule | Violation | Fix |
|---|------|-----------|-----|
| 1 | Pure render — no side effects in component body | `localStorage.setItem()` in render | Move to `useEffect` or custom hook |
| 2 | Side effects in hooks only | Timer in render body | `useEffect`/`useCallback`/custom hook |
| 3 | Immutable state updates | `arr.push(x)`, `delete obj[k]`, `state.x = y` | `[...arr, x]`, `{ ...obj }`, spread |
| 4 | Derive, don't sync | `useState` + `useEffect` to mirror prop | `useMemo(() => compute(prop), [prop])` |
| 5 | `useReducer` for 3+ interrelated `useState` | 3+ `useState` where updating one reads another | Single `useReducer` with pure reducer fn |
| 6 | Extract data transforms | Inline `.filter().sort().map()` chains in JSX | Named pure function + `useMemo` |
| 7 | Stable refs for memoized children | Inline callback to `React.memo` child | `useCallback` (only when child is memoized) |

### Derive vs Sync — Key Pattern

```tsx
// BAD — extra render, race conditions
const [active, setActive] = useState<Item[]>([])
useEffect(() => { setActive(items.filter(i => i.active)) }, [items])

// GOOD — computed inline, no extra state
const active = useMemo(() => items.filter(i => i.active), [items])
```

### useReducer Consolidation

When 3+ `useState` interact (updating one requires reading another):

```tsx
// Pure reducer — defined OUTSIDE component
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

Type-safe reusable components:

```tsx
interface SelectProps<T> {
  value: T
  onChange: (value: T) => void
  options: { value: T; label: string }[]
}

function Select<T>({ value, onChange, options }: SelectProps<T>) { /* ... */ }
```

### ComponentProps Extension

Extend native elements properly:

```tsx
export interface InputProps extends React.ComponentProps<'input'> {
  error?: boolean
}
```

## Common Agent Excuses

| Excuse | Counter |
|---|---|
| "`as any` is fine just here" | Never just here. Type erasure spreads. Fix type. |
| "Temporary @ts-expect-error" | Temporary becomes permanent. Fix type error now. |
| "`style={{}}` is simpler" | Tailwind classes composable and cacheable. Inline styles aren't. |
| "Raw `<button>` is fine for this case" | Use `<Button>` — consistent styling, variant props, a11y baked in. |
| "I'll add accessibility later" | Later never comes. Add aria-label and keyboard handlers now. |
| "`eval()` is needed for dynamic code" | Use `JSON.parse()` for data, `new Function` also banned. |
| "useState + useEffect is fine here" | If computed from props/state, use useMemo. No sync state. |
| "Mutation is faster" | Immutable updates prevent bugs. Spread/filter/map. |
| "Don't need useReducer yet" | 3+ interrelated useState = useReducer. Don't wait for bugs. |