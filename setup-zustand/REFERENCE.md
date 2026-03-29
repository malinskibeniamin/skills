# Zustand Reference

## zustand-check.sh

> Script: [`scripts/zustand-check.sh`](scripts/zustand-check.sh)

## Best Practices (Reference)

### Selectors — Always Use `useShallow` for Multiple Values

```tsx
import { useShallow } from 'zustand/react/shallow'

// Single value — no useShallow needed
const count = useStore((s) => s.count)

// Multiple values — MUST use useShallow
const { count, name } = useStore(useShallow((s) => ({ count: s.count, name: s.name })))
```

### State Updates — Always Use Callback Form

```tsx
// BAD — stale state in async contexts
set({ count: state.count + 1 })

// GOOD — always has latest state
set((state) => ({ count: state.count + 1 }))
```

### Don't Use Zustand for Server State

Zustand is for client-side state (UI state, form state, local preferences). For server data, use TanStack Query / Connect Query:

- **Zustand**: theme, sidebar open/closed, selected tab, draft form data
- **TanStack Query**: API responses, entity lists, server-computed data

### Middleware Chaining

```tsx
import { create } from 'zustand'
import { persist, devtools } from 'zustand/middleware'
import { immer } from 'zustand/middleware/immer'

const useStore = create<State>()(
  devtools(
    persist(
      immer((set) => ({
        // store definition
      })),
      { name: 'store-key' }
    )
  )
)
```

### Separate State and Action Interfaces

```tsx
interface State {
  count: number
  name: string
}

interface Actions {
  increment: () => void
  setName: (name: string) => void
}

const useStore = create<State & Actions>()((set) => ({
  count: 0,
  name: '',
  increment: () => set((state) => ({ count: state.count + 1 })),
  setName: (name) => set({ name }),
}))
```
