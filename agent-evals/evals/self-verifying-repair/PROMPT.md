# Task

Make the persisted preference loader resilient to corrupted or partially valid user data
while preserving every valid preference. Keep the public API stable and do not change the
tests.

Treat `bun run test` and `bun run typecheck` as your verification loop. Inspect failures,
repair the implementation, and continue until both commands pass without warnings.
