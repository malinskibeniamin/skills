# TanStack Router Reference

## tanstack-router-gen.sh

> Script: [`scripts/tanstack-router-gen.sh`](scripts/tanstack-router-gen.sh)

## tanstack-router-check.sh

> Script: [`scripts/tanstack-router-check.sh`](scripts/tanstack-router-check.sh)

## Customization

The routes directory pattern defaults to `/routes/`. If your project uses a different convention, update the grep pattern in both hook scripts:

```bash
# Examples:
if ! echo "$file_path" | grep -qE '/routes/'; then    # default
if ! echo "$file_path" | grep -qE '/pages/'; then     # pages-based
if ! echo "$file_path" | grep -qE '/app/routes/'; then # nested
```

## Type-Safe Search Params with nuqs

For complex URL query state, use [nuqs](https://nuqs.47ng.com/) with TanStack Router:

```tsx
import { useQueryState, parseAsInteger, parseAsString } from 'nuqs'

function UsersPage() {
  const [page, setPage] = useQueryState('page', parseAsInteger.withDefault(1))
  const [filter, setFilter] = useQueryState('filter', parseAsString)

  return (
    <div>
      <input value={filter ?? ''} onChange={(e) => setFilter(e.target.value)} />
      <button onClick={() => setPage(page + 1)}>Next</button>
    </div>
  )
}
```
