# Writable derived state

Use for editors that start with server defaults and let the user override them.
Keep server truth in the query cache, user intent in local state, and derive the
displayed value during render. Without an override, refresh updates the displayed
value; an existing override survives it. This is guidance, not an automatic lint guarantee.

## Choose the editing contract

- **Whole-value override:** the first edit owns the entire value until discard or
  accepted save. Suitable for replacing a list or editing an intentional snapshot.
- **Field overrides:** untouched fields continue to follow server updates. Track
  field presence explicitly; a whole-object override would freeze untouched fields.
- **Snapshot form:** when a form library intentionally captures initial values,
  use its dirty/reset APIs and define when to accept newer server data. Do not
  replace a working form abstraction just to use this pattern.

Derivation replaces redundant state-copying Effects, not Effects that synchronize
external systems. Keep focus/reconnect refresh enabled unless the product's
freshness contract independently requires otherwise.

## Represent absence, not truthiness

Inside an editor with `serverTodos: Todo[] | undefined`:

```tsx
const [draftTodos, setDraftTodos] = useState<Todo[] | undefined>(undefined);
const todos = draftTodos ?? serverTodos;
```

`undefined` means no override; `[]` means the user deliberately emptied the list.
Use immutable, functional updates when an edit depends on the previous draft;
fall back to the current server value only when no draft exists. Never mutate
query data through the fallback reference.

Preserve `false`, `0`, and `""` as edits; use `??`, not `||`. If `null` is a valid
edit, represent override presence separately rather than using nullish fallback:

```tsx
type Override<T> = { value: T } | undefined;
const [titleOverride, setTitleOverride] = useState<Override<string | null>>(undefined);
const title = titleOverride === undefined ? serverTitle : titleOverride.value;
```

This wrapper is client-only; it does not change Protobuf optional-field semantics.
Use field-presence checks for patch objects too. Do not convert missing/error data
to an apparently loaded empty list. Keep loading, background refresh, empty, and
error states explicit; gate editing/saving until required server data is available.
Retain an existing draft and expose recovery if a background read fails.

## Scope, reset, and save

- Scope both queries and drafts to environment, tenant/org, user, and record.
  Use a keyed editor or identity-tagged draft; never render one record's edits over
  another. Keys reset local state, not shared cache entries or pending callbacks.
  Preserve the product's unsaved-change policy on navigation.
- **Discard/reset** removes the override, revealing the latest server data. It
  does not copy a possibly stale snapshot back into local state. Restoring the
  original editing snapshot is a separate product action.
- **Save** captures the submitted identity, payload, and draft revision. A successful
  write alone does not make the cache authoritative: update the matching cache from
  a canonical mutation response, or await and verify the required server refresh.
  Follow [Connect Query discipline](../connect-query/SKILL.md) for RPCs; keep the
  existing query/form library instead of hand-rolling fetching or a duplicate store.
- Clear only the submitted override after that handoff, and only if its identity
  and revision still match. Edits, discard/reset, and identity changes must invalidate
  older save completions. Either prevent edits/reset/navigation for the full save
  and refresh window, or guard completions with revision/identity checks. Disabling
  only the Save button does not prevent later edits from being erased.
- A resolved invalidation promise is not proof that the required query returned
  fresh data: inactive/disabled queries may not refetch, and refetch failures need
  explicit handling. On write failure or unconfirmed refresh, retain the draft and
  show the actual outcome, distinguishing "saved, refresh failed" from "save failed".
- For overlapping writes, serialize saves or use server version/conflict checks;
  ignoring an old callback or aborting a request does not undo an accepted write.
  Preserving a draft does not itself prevent overwriting another user's changes.

## Regression scenarios

When implementing or repairing an editor, start with a failing public-contract test
for the reported loss. Cover applicable sequences through the real component/query
boundary with controlled responses and condition-based waits:

- Untouched editor follows a successful server refresh; an edited value survives it.
- Empty list, empty string, zero, false, and valid null remain deliberate overrides.
- Discard reveals the newest server value; switching identities never leaks edits.
- Successful save hands off to canonical data; edits made during save/refetch survive
  an older completion. A completion after discard/navigation cannot reset a new draft.
- Write failure or refresh failure preserves input and exposes the right recovery.
- Field-level editing accepts remote changes to untouched fields; snapshot editing
  follows its intentional reset contract.

## Sources

- [React: You might not need an Effect](https://react.dev/learn/you-might-not-need-an-effect): derive renderable values; retain external synchronization Effects.
- [React: Resetting a form with a key](https://react.dev/learn/preserving-and-resetting-state#resetting-a-form-with-a-key): identity-scoped local state.
- [TanStack Query: Invalidations from mutations](https://tanstack.com/query/latest/docs/framework/react/guides/invalidations-from-mutations): await the mutation's cache handoff.
- [TanStack Query: QueryClient](https://tanstack.com/query/latest/docs/framework/react/reference/classes/QueryClient): invalidation/refetch behavior and error handling; check the consuming project's installed version.
