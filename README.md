# Agent Skills

A collection of agent skills and Claude Code hooks that enforce frontend best practices, automate quality checks, and reduce wasted tokens in AI-assisted development.

## Starter Kits

Meta-skills that install everything you need in one go.

- **frontend-starter-kit** — Set up all generic frontend skills: toolchain enforcement, Biome + Ultracite, quality gate, LLM optimization, React Compiler, zustand, plus community workflow skills (TDD, triage, architecture, refactoring, design).

  ```
  bunx skills@latest add malinskibeniamin/skills/frontend-starter-kit
  ```

- **redpanda-frontend-kit** — Everything in the frontend starter kit, plus Redpanda-specific rules: useEffect ban, raw HTML enforcement, Chakra migration, TanStack Router (with anti-pattern checks), Connect Query + Protobuf enforcement, and react-doctor.

  ```
  bunx skills@latest add malinskibeniamin/skills/redpanda-frontend-kit
  ```

- **work-automation-kit** — Project planning and management workflow skills: PRD creation, implementation planning, issue breakdown, and bug triage.

  ```
  bunx skills@latest add malinskibeniamin/skills/work-automation-kit
  ```

## Toolchain Enforcement

Claude Code hooks that enforce tooling standards via `PreToolUse` and `SessionStart` hooks.

- **setup-toolchain** — Ban npm/npx/tsc/eslint/prettier, enforce bun as package manager with `--yarn` flag, tsgo as TypeScript compiler, and block global installs. Sets `PKG_MANAGER`, `LINTER`, `TEST_RUNNER` env vars.

  ```
  bunx skills@latest add malinskibeniamin/skills/setup-toolchain
  ```

## Code Quality

Linting, formatting, and quality gate automation.

- **setup-biome** — Install Biome + Ultracite, create `biome.jsonc` with strict overrides (noConsole, cognitive complexity 15, noClassComponent, useExhaustiveSwitchCases, restricted imports for moment/lodash/classnames/mobx/yup). Stop hook auto-fixes all changed JS/TS files before Claude finishes.

  ```
  bunx skills@latest add malinskibeniamin/skills/setup-biome
  ```

- **setup-quality-gate** — Add `quality:gate` package.json script (biome + tsgo + related tests in <5s), GitHub Actions CI workflow with formatting integrity check (`git diff --exit-code`), and Stop hook for tsgo type checking.

  ```
  bunx skills@latest add malinskibeniamin/skills/setup-quality-gate
  ```

## React Rules

PostToolUse hooks that enforce React patterns on every Edit/Write. All checks skip non-JS/TS files (zero overhead for backend devs) and exclude `redpanda-ui/` directory.

- **setup-react-rules** — 13 checks in a single hook script:
  - Ban `useEffect`/`useLayoutEffect`/`useInsertionEffect` (suggest React Query, zustand, event handlers)
  - Ban raw HTML elements (`<button>`, `<input>`, `<form>`, etc.) — suggest redpanda-ui components
  - Ban `@chakra-ui/react` and `@redpanda-data/ui` imports (legacy)
  - Ban `as any`, `@ts-ignore`, `@ts-expect-error`
  - Ban visual style overrides on registry components (use variant prop)
  - Ban `onClick + navigate()` (use `<Button asChild><Link>`)
  - Require handler on buttons (onClick, asChild, type=submit, disabled)
  - Ban icon inside AlertTitle (use icon prop)
  - Enforce `create()` wrapper for protobuf spreads (v2 only)
  - Icon-only buttons must have `aria-label`
  - Ban `outline: none` (breaks keyboard navigation)
  - React Compiler: ban manual `useMemo`/`useCallback`/`React.memo`

  ```
  bunx skills@latest add malinskibeniamin/skills/setup-react-rules
  ```

- **setup-react-compiler** — Install `babel-plugin-react-compiler` with rsbuild config. `'use no memo'` directive for escape hatch. redpanda-ui directory excluded from compiler.

  ```
  bunx skills@latest add malinskibeniamin/skills/setup-react-compiler
  ```

## Health & Diagnostics

Stop hooks and manual diagnostic skills.

- **setup-react-doctor** — Install react-doctor, add `doctor` package.json script, Stop hook running health check on changed files. Fails on score regression.

  ```
  bunx skills@latest add malinskibeniamin/skills/setup-react-doctor
  ```

- **test-guardian** — Manual diagnostic skill for test health across frameworks (Vitest, Jest, Bun, Rstest). Detect async leaks, profile performance, find slow/flaky tests. Not a hook — invoke when debugging test issues.

  ```
  bunx skills@latest add malinskibeniamin/skills/test-guardian
  ```

## LLM Optimization

Reduce token usage and context waste.

- **setup-llm-optimization** — SessionStart sets `AI_AGENT=1` and `CLAUDECODE=1` for LLM-friendly test output. PreToolUse blocks `--verbose` on test runners. PostToolUse truncates bash output >200 lines.

  ```
  bunx skills@latest add malinskibeniamin/skills/setup-llm-optimization
  ```

## State Management

- **setup-zustand** — PostToolUse hook enforcing zustand best practices: ban single-parens `create<T>()` (must be `create<T>()()`), ban inline object selectors (suggest `useShallow`), ban direct localStorage in stores (suggest persist middleware).

  ```
  bunx skills@latest add malinskibeniamin/skills/setup-zustand
  ```

## Routing & Registry

- **setup-tanstack-router** — Auto-regenerate TanStack Router route tree when route files change, plus anti-pattern enforcement: ban react-router-dom, window.location navigation, `strict: false`, untyped hooks (`useParams()`/`useSearch()` without `{ from }`), URLSearchParams (suggest nuqs), and require `validateSearch` when using `useSearch` in route files. Warns on `window.location.reload()` and `window.location` reads.

  ```
  bunx skills@latest add malinskibeniamin/skills/setup-tanstack-router
  ```

- **setup-registry-workflow** — Stop hook that reminds about `registry.json` rebuild and changelog update when redpanda-ui components are modified.

  ```
  bunx skills@latest add malinskibeniamin/skills/setup-registry-workflow
  ```

## Data Fetching

- **setup-connect-query** — PostToolUse hook enforcing ConnectRPC + Connect Query + Protobuf best practices: ban raw `useQuery`/`useMutation` from `@tanstack/react-query` when ConnectRPC is available, ban `invalidateQueries()` with no args, warn on axios/fetch. Protobuf v2 projects also get: ban `new Message()` construction (use `create(Schema)`), ban `PlainMessage`/`PartialMessage` (use `MessageShape`/`MessageInitShape`). Version detected at install time.

  ```
  bunx skills@latest add malinskibeniamin/skills/setup-connect-query
  ```

## Evals

Two layers of testing to prevent regressions:

**Script-level evals** — 292 tests that verify hook scripts, file structure, and content. Run locally in <5 seconds:

```
./evals/run.sh
```

**Agent-level evals** — 9 behavioral tests using [@vercel/agent-eval](https://github.com/vercel-labs/agent-eval) that verify Claude Code actually follows the rules when given adversarial prompts. Runs in Docker sandbox:

```
cd agent-evals && bun install --yarn && npx @vercel/agent-eval
```

## Hook Architecture

```
SessionStart
├── session-env.sh      — PKG_MANAGER=bun, LINTER=biome, TEST_RUNNER=vitest
└── llm-env.sh          — AI_AGENT=1, CLAUDECODE=1

PreToolUse (Bash)
├── enforce-toolchain.sh — block npm/npx/tsc/eslint/prettier, enforce --yarn
└── llm-test-flags.sh    — block --verbose on test runners

PostToolUse (Edit|Write)
├── react-rules-check.sh      — 13 React/TS/a11y checks (~50ms, skips non-JS/TS)
├── zustand-check.sh           — zustand anti-patterns (skips non-zustand files)
├── tanstack-router-check.sh   — routing anti-patterns (skips non-router files)
└── connect-query-check.sh     — ConnectRPC/protobuf patterns (skips non-connect files)

PostToolUse (Bash)
└── llm-truncate.sh      — truncate output >200 lines

Stop
├── biome-autofix.sh     — lint:fix all changed JS/TS files
├── typecheck-stop.sh    — bun run type:check (skips if no JS/TS changes)
├── react-doctor-stop.sh — health check on changed files
└── registry-check.sh    — remind about registry.json rebuild
```

Non-JS/TS file edits (Go, Python, Markdown, etc.) get zero overhead — all hooks exit immediately on non-matching file extensions.
