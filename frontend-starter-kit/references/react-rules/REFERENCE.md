# React Rules Reference

## react-rules-check.sh

> Script: [`scripts/react-rules-check.sh`](scripts/react-rules-check.sh)

## Escape Hatch for useEffect

`useEffect` truly needed (WebSocket cleanup, third-party lib) -> add comment before:

```tsx
// allow: useEffect -- WebSocket subscription cleanup required
useEffect(() => {
  const ws = new WebSocket(url)
  return () => ws.close()
}, [url])
```

Hook check `// allow: useEffect` anywhere in file * reason required * legacy `// allow-useEffect:` also work.

## Raw HTML -> Component Library Mapping

| Banned | Replacement | Import (shadcn/ui convention) |
|--------|-------------|-------------------------------|
| `<button>` | `<Button>` | `@/components/ui/button` |
| `<input>` | `<Input>` | `@/components/ui/input` |
| `<select>` | `<Select>` | `@/components/ui/select` |
| `<textarea>` | `<Textarea>` | `@/components/ui/textarea` |
| `<dialog>` | `<Dialog>` | `@/components/ui/dialog` |
| `<table>` | `<Table>` | `@/components/ui/table` |
| `<label>` | `<Label>` | `@/components/ui/label` |

`<form>` + `<a>` allowed -- no registry replacement for `<form>`, `<a>` can't always swap with TanStack Router Link.

## Motion Craft Checks

The Tailwind hook warns on deterministic motion smells. It should stay warn-only because motion quality needs context.

| Smell | Why | Better default |
|---|---|---|
| `transition-all` | Unrelated state changes animate and become hard to debug. | Transition only `transform`, `opacity`, or the specific property. |
| `scale(0)` / `scale-0` entries | Text and edges collapse unnaturally. | Start near final size and fade or translate. |
| Layout property animation | Width, height, position, margin, and padding can jank. | Use transform/opacity, clip-path for reveals, or instant change. |
| Long common UI duration | Slow motion hurts frequent actions. | Keep routine UI under 300ms unless distance or platform convention warrants more. |
| `ease-in` entry/exit | It feels sluggish at the start of interaction. | Use short ease-out for entry/exit, ease-in-out for morphing, ease for simple hover/color. |

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

- Named functions show in stack traces + React DevTools
- Force articulate what effect do -> reveal split chance
- Can't name without "and" -> effect do too much -> split
- Name start with "sync"/"update" + state -> likely derived state -> compute inline

### Naming conventions

| Verb | Use for |
|------|---------|
| `subscribe`/`listen` | Event-based effects |
| `connect`/`disconnect` | WebSocket, SSE, external services |
| `synchronize`/`apply` | Sync state with external systems |
| `initialize` | One-time setup |
| `poll` | Interval-based fetching |

## React Hook Form validation lifecycle

`mode` controls validation before submit; `reValidateMode` controls revalidation after submit. Select both from the product lifecycle instead of forcing every form to validate on change:

See the official [`mode` and `reValidateMode` contract](https://react-hook-form.com/docs/useform#mode).

| User experience | Configuration |
|---|---|
| Keep a new form quiet until submit, then clear errors as the user fixes them | `mode: 'onSubmit', reValidateMode: 'onChange'` |
| Validate a field after the user leaves it | `mode: 'onBlur'` |
| Validate after first blur, then on change | `mode: 'onTouched'` |
| Live feedback for cheap, synchronous constraints | `mode: 'onChange'` |

`onChange` and `all` can do validation work on every change. Do not use them to compensate for stale dependencies, and do not use `delayError` as a debounce. Async validation still needs debounce or cancellation.

`criteriaMode` selects how many rule failures RHF collects per field. Use `criteriaMode: 'all'` only when the UI renders every entry in `error.types`; otherwise keep the default first error and avoid collecting hidden work.

## Form-level validation (react-hook-form v7.72+)

Cross-field validation (confirm password, end date > start date) -> use `validate` on `useForm`, not custom logic in `onSubmit`:

```tsx
// BAD -- validation buried in submit handler
const onSubmit = (data) => {
  if (data.password !== data.confirmPassword) {
    setError('confirmPassword', { message: 'Passwords must match' })
    return
  }
}

// GOOD -- form-level validate, integrates with formState.errors
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

Run alongside field-level resolvers (zod, protovalidate) * surface errors via `formState.errors`.

### Dependent validation and cleanup

The [`deps` register option](https://react-hook-form.com/docs/useform/register) revalidates named dependent fields when the registered source changes; it does not clear a dependent value, error, touched state, or dirty state:

```tsx
<Input {...register('password', { deps: ['confirmPassword'] })} />
<Input
  {...register('confirmPassword', {
    validate: (value, formValues) =>
      value === formValues.password || 'Passwords must match',
  })}
/>
```

`deps` is limited to `register`; do not pair it with manual `trigger` for the same transition. When a parent choice invalidates a child selection, reset that child explicitly:

```tsx
function changeCountry(country: string) {
  setValue('country', country, { shouldDirty: true })
  resetField('region', { defaultValue: '' })
}
```

Use `unregister` or `shouldUnregister` when an unmounted branch must leave the payload. Revalidation and cleanup are separate contracts; test both.

### Read versus subscribe

[`getValues`](https://react-hook-form.com/docs/useform/getvalues) reads an event-time snapshot and does not subscribe or trigger a re-render. Use it in event handlers and imperative boundaries; use the validator's `formValues` argument inside validation. Rendered UI that reacts to values needs a localized `useWatch`.

Subscribe with [`useFormState`](https://react-hook-form.com/docs/useformstate) at the leaf that renders it. Destructure the needed property so RHF's proxy enables that subscription:

```tsx
function EndpointError({ control }: { control: Control<FormValues> }) {
  const { errors } = useFormState({ control, name: 'endpoint', exact: true })
  return <FormMessage>{errors.endpoint?.message}</FormMessage>
}
```

Inside a `FormField` render prop, prefer its `fieldState` over subscribing the form root to `form.formState`. Use `exact: true` when nested-name changes should not wake a leaf.

### Deterministic default values

Provide every registered field a defined, serializable baseline. `defaultValues` must not contain `undefined`; use empty strings, booleans, arrays, or an explicit nullable schema value. Avoid `Date`, Moment, Luxon, `Date.now()`, random IDs, and other prototype-bearing or nondeterministic values.

```tsx
const CREATE_DEFAULT_VALUES: CreateFormValues = {
  name: '',
  enabled: false,
  labels: [],
}

const form = useForm<CreateFormValues>({
  defaultValues: CREATE_DEFAULT_VALUES,
})
```

[`defaultValues`](https://react-hook-form.com/docs/useform#defaultValues) are cached at initialization. When server data or record identity changes, use `reset(nextValues)` or the reactive `values` option with deliberate reset options; do not expect a new object literal to replace the cached baseline. Async defaults must map the response to the complete deterministic shape and render `formState.isLoading`.

## Proto Forms (useProtoForm + ProtoField)

Proto-backed forms in this codebase use `useProtoForm` (wraps `useForm` with a proto-schema resolver via `protovalidate` + Standard Schema). Keep a single source of truth -- drift is how forms silently break.

### No parallel `useState` (hook: `proto-form-parallel-state-check.sh`)

```tsx
// BAD -- form-shape state beside useProtoForm
const form = useProtoForm({ schema: McpServerSchema })
const [authConfig, setAuthConfig] = useState<McpAuthConfig>({}) // drift
// ...custom validateAuthConfigFields + surfaceAuthFieldErrors...

// GOOD -- register on the proto form
const form = useProtoForm({ schema: McpServerSchema })
<FormField
  control={form.control}
  name="authConfig"
  render={({ field }) => <AuthConfigEditor {...field} />}
/>
```

Use `useFieldArray` for list fields. Transient UI state (open/closed dialog, active tab) can stay in `useState`; only form-shape state must live in the form.

### Select `setValue` state transitions (hook: `form-setvalue-options-check.sh`)

```tsx
// BAD in a user-edit handler -- state transition is ambiguous
form.setValue('providers', next)

// GOOD when this edit should become dirty and revalidate now
form.setValue('providers', next, { shouldDirty: true, shouldValidate: true })
```

`shouldDirty`, `shouldValidate`, and `shouldTouch` default to false. Choose only the transitions the caller owns. For hydration or a new baseline, prefer `reset(nextValues)` over a loop of `setValue` calls. The hook is an optional intent nudge; mark deliberate silent writes with `// allow: setvalue-options [reason]`.

### Delayed validation is exceptional (react-hook-form v7.82+)

Default to immediate errors. `delayError` changes when an error appears; it does not debounce validation or network work. Add it only to address observed error flicker. Debounce or abort expensive async validation instead.

The [shipped v7.82.0 `SetValueConfig` type](https://github.com/react-hook-form/react-hook-form/blob/v7.82.0/src/types/form.ts#L78-L84) is authoritative; the release-note snippet puts the numeric duration on the wrong option.

If delayed errors are justified, `useForm({ delayError: 500 })` owns the duration and `setValue.delayError` is the boolean opt-in for programmatic validation:

```tsx
form.setValue('endpoint', next, {
  shouldDirty: true,
  shouldValidate: true,
  delayError: true,
})
```

Omitting `setValue.delayError` is the normal immediate path and stays silent. The form-mode hook only nudges numeric values copied from the release note; it never recommends adding delayed validation.

`dirtyFields` is not uniformly object-shaped: a registered array leaf can be boolean `true`, while `useFieldArray` produces nested or sparse state. Test changed, reverted, disabled-form programmatic writes, and remove-all transitions; do not cast every dirty node to one container shape.

### FormErrorSummary for multi-field forms (hook: `form-error-summary-check.sh`)

```tsx
<form onSubmit={form.handleSubmit(onSubmit)}>
  <FormErrorSummary form={form} />   {/* role="alert" aria-live="polite" */}
  <ProtoField name="name" />
  <ProtoField name="endpoint" />
  {/* ... */}
</form>
```

Inline `FormMessage` alone isn't enough -- offscreen + long forms need a submit-time summary. Accept any equivalent: a shared `<FormErrorSummary>`, an `Alert` with `role="alert"`, or an `aria-live` status region.

The summary must enumerate every field error rather than indexing the first one. With `criteriaMode: 'all'`, the inline renderer must also enumerate every message in each field's `error.types`.

### Proto annotations -- hydrate, don't hardcode

Labels / descriptions / placeholders hardcoded in JSX duplicate the proto source of truth and drift when the schema changes. Populate `ProtoAnnotations` once per schema and hydrate via `getFieldDescription(schema, fieldName)`:

```tsx
<ProtoField
  name="endpoint"
  label={getFieldLabel(McpServerSchema, 'endpoint')}
  description={getFieldDescription(McpServerSchema, 'endpoint')}
/>
```

New protos ship with annotation registry entries in the same commit as the generated `_pb.ts` -- not opportunistically later.

### ConnectError -> form.setError per field

See [setup-connect-query/REFERENCE.md](../../../connect-query/REFERENCE.md#connecterror--formseterror-per-field) for the `BadRequestSchema.fieldViolations` -> `form.setError` pattern enforced by `connect-error-fieldmap-check.sh`.

## Resetting State on Prop Change -- Use `key`

```tsx
// BAD -- extra render, stale state visible
useEffect(() => {
  setComment('')
  setDraft(null)
}, [userId])

// GOOD -- unmount/remount, all state resets
<UserProfile key={userId} />
```

`key` work on any component * key change -> React destroy old instance, create new with fresh state.

## Subscriptions -- Prefer `useSyncExternalStore`

Browser APIs (online status, media queries, scroll position, external stores) -> `useSyncExternalStore` over manual `useEffect` + `addEventListener`:

```tsx
// BAD -- verbose, tearing in concurrent mode
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

// GOOD -- concurrent-safe, no boilerplate
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

Skip for: React state, zustand (use internally), TanStack Query.

## Functional Programming

Components = pure render functions * props in, JSX out * side effects in hooks only.

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
// BAD -- extra render, race conditions
const [active, setActive] = useState<Item[]>([])
useEffect(() => { setActive(items.filter(i => i.active)) }, [items])

// GOOD -- computed inline
const active = useMemo(() => items.filter(i => i.active), [items])
```

### useReducer Consolidation

3+ interrelated `useState` -> single `useReducer`:

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
| "`as any` is fine just here" | Type erasure spread. Fix type. |
| "Temporary @ts-expect-error" | Temporary -> permanent. Fix now. |
| "`style={{}}` is simpler" | Tailwind composable + cacheable. Inline style no. |
| "Raw `<button>` is fine" | `<Button>` -- consistent styling, variants, a11y baked in. |
| "Add accessibility later" | Later never come. Add now. |
| "`eval()` needed for dynamic code" | `JSON.parse()` for data. `new Function` also banned. |
| "useState + useEffect fine here" | Computed from props/state -> `useMemo`. No sync state. |
| "Mutation is faster" | Immutable prevent bugs. Spread/filter/map. |
| "Don't need useReducer yet" | 3+ interrelated useState = useReducer. Don't wait for bugs. |
