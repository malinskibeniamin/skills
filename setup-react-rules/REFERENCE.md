# React Rules Reference

## react-rules-check.sh

> Script: [`scripts/react-rules-check.sh`](scripts/react-rules-check.sh)

## Escape Hatch for useEffect

When useEffect is genuinely needed (e.g., WebSocket cleanup, third-party library integration), add a comment on the line before:

```tsx
// allow: useEffect — WebSocket subscription cleanup required
useEffect(() => {
  const ws = new WebSocket(url)
  return () => ws.close()
}, [url])
```

The hook checks for `// allow: useEffect` anywhere in the file. A reason is required for code review. Legacy format `// allow-useEffect:` also works.

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

Note: `<form>` and `<a>` are allowed — `<form>` has no standard registry replacement, `<a>` can't always be replaced with TanStack Router Link.

## Auto-Generated Files

The following files are automatically skipped by all hooks:

| Pattern | Source |
|---------|--------|
| `*.gen.ts` / `*.gen.tsx` | TanStack Router (`routeTree.gen.ts`) |
| `*_pb.ts` / `*_pb.js` | Protobuf codegen |
| `*_connectquery.ts` | Connect Query codegen |
| Files with `@generated` / `auto-generated` / `DO NOT EDIT` in first 5 lines | Any codegen tool |

## Named useEffect Functions

When writing `useEffect`, always use a named function expression instead of an anonymous arrow:

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

- Named functions appear in stack traces and React DevTools (instead of `(anonymous)`)
- Forces you to articulate what the effect does — reveals split opportunities
- If you can't name it without "and" or "also", the effect does too much — split it
- If the name starts with "sync" or "update" followed by state, it's probably derived state — compute inline during render instead

### Naming conventions

| Verb | Use for |
|------|---------|
| `subscribe`/`listen` | Event-based effects |
| `connect`/`disconnect` | WebSocket, SSE, external services |
| `synchronize`/`apply` | Syncing React state with external systems |
| `initialize` | One-time setup |
| `poll` | Interval-based data fetching |

## Form-Level Validation (react-hook-form v7.72+)

For cross-field validation (e.g., "confirm password must match password", "end date must be after start date"), use the `validate` option on `useForm` instead of custom logic inside `onSubmit`:

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

This runs alongside field-level resolvers (zod, protovalidate) and surfaces errors through the standard `formState.errors` API.

## Resetting State on Prop Change — Use `key`

When you need to reset component state when a prop changes, don't use `useEffect`:

```tsx
// BAD — extra render pass, intermediate stale state visible
useEffect(() => {
  setComment('')
  setDraft(null)
}, [userId])

// GOOD — React unmounts and remounts, all state resets automatically
<UserProfile key={userId} />
```

The `key` prop works on any component, not just lists. When the key changes, React destroys the old instance and creates a new one with fresh state.

## Subscriptions — Prefer `useSyncExternalStore`

When subscribing to browser APIs (online status, media queries, scroll position, external stores), prefer `useSyncExternalStore` over manual `useEffect` + `addEventListener`:

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

Don't use it for: React state, zustand (already uses it internally), TanStack Query.

## Common Agent Excuses

| Excuse | Counter |
|---|---|
| "`as any` is fine just here" | It's never just here. Type erasure spreads. Fix the type. |
| "Temporary @ts-expect-error" | Temporary becomes permanent. Fix the type error now. |
| "`style={{}}` is simpler" | Tailwind classes are composable and cacheable. Inline styles aren't. |
| "Raw `<button>` is fine for this case" | Use `<Button>` — consistent styling, variant props, a11y baked in. |
| "I'll add accessibility later" | Later never comes. Add aria-label and keyboard handlers now. |
| "`eval()` is needed for dynamic code" | Use `JSON.parse()` for data, `new Function` is also banned. |
