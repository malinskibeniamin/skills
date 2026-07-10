# React Doctor Reference

## react-doctor-stop.sh

> Script: [`scripts/react-doctor-stop.sh`](scripts/react-doctor-stop.sh)

React Doctor runs on its own bundled oxlint engine -- that is an internal implementation detail, not a linter we adopt or configure. The project toolchain stays Biome/Ultracite for lint/format; React Doctor is the React-pattern layer on top. Pin the react-doctor version in package.json (current pin: 2.2.6) -- it moves fast and the stop hook already works around known internal bugs.

## Rule ownership

React Doctor ships 22 rule categories (~200 rules): a11y, architecture, bundle-size, client, correctness, design, js-performance, performance, react-builtins, react-ui, security, security-scan, server, state-and-effects, tanstack-query, zod, plus framework-specific sets (nextjs, preact, react-native, tanstack-start, jotai, view-transitions).

Per-edit hooks retired into React Doctor (do not re-add -- one owner per rule):

| Former hook rule | React Doctor rule |
|---|---|
| react-compiler-check (all 3 rules) | `architecture/react-compiler-no-manual-memoization`, `state-and-effects/no-derived-state-effect`, `rerender-lazy-ref-init` |
| react-rules blanket no-useEffect | `state-and-effects/*` (no-fetch-in-effect, no-effect-chain, no-mirror-prop-effect, ...) |
| react-rules outline removal | `design/no-outline-none` |
| react-rules reset-state-on-prop-change | `state-and-effects/no-reset-all-state-on-prop-change` |
| tailwind user-scalable=no | `design/no-disabled-zoom` |
| a11y dialog name / nested interactive / name wording / placeholder label | `a11y/dialog-has-accessible-name`, `correctness/html-no-nested-interactive`, `a11y/img-redundant-alt`, `a11y/label-has-associated-control` |
| query-pattern stable-client / rest-destructure / unstable-deps / void queryFn | `tanstack-query/query-stable-query-client`, `query-no-rest-destructuring`, `query-destructure-result`, `query-no-void-query-fn` |

Disabled in react-doctor config (Biome/Ultracite owns): hook dependencies, nested component definitions, and any rule duplicating `noRestrictedImports`/`noRestrictedElements`/`noProcessEnv`.

## Score ratchet

The Stop hook keeps a per-repo baseline (best score achieved, `~/.claude/hook-metrics/doctor-baseline-<repo>`). Scores below the baseline block the session; scores above it raise it. 80 remains the absolute floor; the ratchet makes gradual decline impossible. Lowering the baseline is a deliberate act: edit the file and justify it in the commit.

## CLI Flags

| Flag | Purpose |
|------|---------|
| `--diff` | Scan changed files only |
| `--verbose` | Show file-level details |
| `--score` | Output numeric score only |
| `--no-lint` | Skip lint (keep dead code) |
| `--no-dead-code` | Skip dead code (keep lint) |
| `--fix` | Auto-fix with AI |
