# Project rules

This project has React Compiler enabled. Prefer compiler-owned memoization for ordinary
React values. One narrow exception is authorized here: the third-party
`useLegacyDatasetSubscription(options, listener)` hook keys its subscription by the
options object's identity. Its cleanup and re-subscription behavior is correct whenever
that identity changes, but rebuilding equal options causes expensive unnecessary work.
`doctor.config.json` already contains a file-scoped manual-memoization exception for the
requested path.

- Use `useMemo` only for that options object.
- Import `useMemo` directly from `react`; do not use a hook re-export or wrapper.
- Keep React Compiler enabled. Do not add `'use no memo'`.
- Add a short comment naming the external identity contract.
- The subscription must remain correct if React discards the cache: the third-party hook
  cleans up and may safely subscribe again.

# Task

Create `src/useDatasetSubscription.ts`. Export these types and hook:

```ts
type DatasetListener = (points: number[]) => void;

function useDatasetSubscription(
  datasetId: string,
  listener: DatasetListener,
): void;
```

Import `useLegacyDatasetSubscription` from `@legacy/datasets`. Memoize `{ datasetId }`
for that external identity boundary, then pass the options and listener to the legacy
hook.
