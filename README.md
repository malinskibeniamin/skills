# Agent Skills

A collection of agent skills and Claude Code hooks that enforce frontend best practices, automate quality checks, and reduce wasted tokens in AI-assisted development.

## TLDR — Full Setup for a New Repo

One command to install everything (15 setup skills + diagnostics + 13 community workflow skills):

```bash
bunx skills@latest add malinskibeniamin/skills/frontend-starter-kit --agent claude-code -y
```

**Optional extras:**

```bash
# TanStack official reference skills (28 soft-guidance skills from docs)
npx @tanstack/intent@latest install

# Codex compatibility (if team uses both Claude Code and Codex)
bunx skills@latest add malinskibeniamin/skills/codex-compat --agent claude-code -y

# Redpanda-specific (Chakra/legacy bans, registry workflow)
bunx skills@latest add malinskibeniamin/skills/redpanda-frontend-kit --agent claude-code -y
```

Or install individual skills if you don't want the full kit — see sections below.

## Migrating an Existing Codebase

After installing, paste this prompt into a new Claude Code session to migrate existing code to comply with the new hooks:

<details>
<summary>Migration prompt (click to expand)</summary>

```
I just installed the frontend-starter-kit skills. Run all setup skills now, then migrate existing code to comply with the new hooks.

## Phase 1: Run setup skills

Execute the frontend-starter-kit skill. This will:
- Install all 15 setup skills (toolchain, biome, quality-gate, etc.)
- Create all hook scripts in .claude/hooks/
- Set up src/env.ts, biome.jsonc, .github/workflows/quality-gate.yml
- Install community workflow skills
- Set REACT_RULES_BAN_USEEFFECT=1 in session env

## Phase 2: Migrate existing code

After hooks are installed, fix all existing violations. Work through these in order:

### 2a. Lint + format
Run bun run lint:fix to auto-fix everything Biome can handle.

### 2b. Type checking
Run bun run type:check and fix all errors.

### 2c. Filename convention
Rename any non-kebab-case files to kebab-case. Use git mv to preserve history.

### 2d. Environment variables
Find all process.env. usage outside of src/env.ts and move each env var into src/env.ts with a zod schema. Replace process.env.X with import { env } from "@/env".

### 2e. React patterns
Fix these in order (each may affect many files):

1. Class components → functional components
2. useEffect for data fetching → TanStack Query / route loaders
3. Raw HTML elements (<button>, <input>, etc.) → @/components/ui/ components
4. as any, @ts-ignore, @ts-expect-error → proper types, type guards, or zod validation
5. dangerouslySetInnerHTML → DOMPurify or safe rendering
6. Inline style={{}} → Tailwind utility classes
7. Raw hex/rgb in className → design tokens
8. !important → fix specificity
9. useMemo/useCallback/React.memo → remove (React Compiler handles it)
10. outline: none → focus-visible:outline-2

### 2f. Zustand stores
Fix create<T>() → create<T>()(), inline selectors → useShallow, direct localStorage → persist.

### 2g. Routing
Fix window.location navigation → TanStack Router, react-router-dom → @tanstack/react-router, URLSearchParams → nuqs, untyped hooks → { from } param.

## Phase 3: Verify

Run bun run quality:gate — should pass with zero errors.
Run bun run doctor — score should be 80+.
Commit everything as: refactor(webui): migrate to frontend-starter-kit patterns
```

</details>

The migration is ordered from least disruptive (auto-fixable lint) to most disruptive (React pattern rewrites) — commit incrementally after each phase.

---

## Starter Kits

Meta-skills that install everything you need in one go.

- **frontend-starter-kit** — Complete frontend stack in one command: 15 setup skills (toolchain, Biome, quality gate, LLM optimization, React Compiler, zustand, accessibility, React rules, env validation, conventional commits, react-doctor, TanStack Router, Connect Query, e2e testing) + test-guardian diagnostics + 13 community workflow skills (TDD, triage, architecture, refactoring, design, PRD, QA, DDD glossary). `console.*` is fully covered by Biome's `noConsole`.

  ```
  bunx skills@latest add malinskibeniamin/skills/frontend-starter-kit --agent claude-code -y
  ```

- **redpanda-frontend-kit** — Everything in the frontend starter kit, plus Redpanda-specific rules: Chakra/legacy import bans, TanStack Router, Connect Query + Protobuf enforcement, react-doctor, and registry workflow.

  ```
  bunx skills@latest add malinskibeniamin/skills/redpanda-frontend-kit --agent claude-code -y
  ```

- **work-automation-kit** — Project planning and management workflow skills: PRD creation, implementation planning, issue breakdown, and bug triage.

  ```
  bunx skills@latest add malinskibeniamin/skills/work-automation-kit --agent claude-code -y
  ```

## Toolchain Enforcement

Claude Code hooks that enforce tooling standards via `PreToolUse` and `SessionStart` hooks.

- **setup-toolchain** — Ban npm/npx/tsc/eslint/prettier, enforce bun as package manager with `--yarn` flag, tsgo as TypeScript compiler, block global installs, and guard against destructive commands (`rm -rf`, `git push --force`, `git reset --hard`, `git checkout .`). Sets `PKG_MANAGER`, `LINTER`, `TEST_RUNNER` env vars.

  ```
  bunx skills@latest add malinskibeniamin/skills/setup-toolchain --agent claude-code -y
  ```

## Code Quality

Linting, formatting, and quality gate automation.

- **setup-biome** — Install Biome + Ultracite, create `biome.jsonc` with strict overrides (noConsole, cognitive complexity 15, kebab-case filenames, useExhaustiveSwitchCases, restricted imports for moment/lodash/classnames/mobx/yup). Stop hook auto-fixes all changed JS/TS files before Claude finishes.

  ```
  bunx skills@latest add malinskibeniamin/skills/setup-biome --agent claude-code -y
  ```

- **setup-quality-gate** — Add `quality:gate` package.json script (biome + tsgo + related tests in <5s), GitHub Actions CI workflow with formatting integrity check (`git diff --exit-code`), Stop hook for tsgo type checking, and bundle guard PostToolUse hook that warns on heavy dependencies (moment, lodash, jquery, core-js, classnames).

  ```
  bunx skills@latest add malinskibeniamin/skills/setup-quality-gate --agent claude-code -y
  ```

## React Rules

PostToolUse hooks that enforce React patterns on every Edit/Write. All checks skip non-JS/TS files (zero overhead for backend devs) and auto-detect component library directories (`components/ui/`, `redpanda-ui/`, `src/ui/`, `packages/ui/` — configurable via `UI_LIB_DIRS`).

- **setup-react-rules** — React/TS/security/Tailwind checks in a single hook script:
  - Ban raw HTML elements (`<button>`, `<input>`, `<select>`, etc.) — suggest shadcn/ui components (`<form>` allowed)
  - Ban `as any`, `as Record<string, any>`, `as Record<string, unknown>`, `@ts-ignore`, `@ts-expect-error`
  - Ban visual style overrides on registry components (use variant prop)
  - Ban `onClick + navigate()` (use `<Button asChild><Link>`)
  - Require handler on buttons (onClick, asChild, type=submit, disabled)
  - Ban icon inside AlertTitle (use icon prop)
  - Enforce `create()` wrapper for protobuf spreads (v2 only)
  - Icon-only buttons must have `aria-label`
  - Ban `outline: none` (breaks keyboard navigation)
  - React Compiler: ban manual `useMemo`/`useCallback`/`React.memo`
  - Ban `dangerouslySetInnerHTML` (XSS — escape hatch: `// allow-dangerouslySetInnerHTML: [reason]`)
  - Ban `eval()` / `new Function()` (code injection)
  - Ban `.innerHTML =` assignment (XSS)
  - Ban inline `style={{}}` — use Tailwind utility classes
  - Ban raw hex/rgb in className — use design tokens
  - Ban `!important` — breaks Tailwind cascade
  - Ban barrel imports (re-exports from index files) — suggest direct path imports
  - Ban `addEventListener('scroll'|'touchstart'|'wheel')` without `{ passive: true }`
  - Warn on static imports of heavy deps (`chart.js`, `d3`, `three.js`, `pdf-lib`) — suggest dynamic import
  - Opt-in: ban `useEffect` via `REACT_RULES_BAN_USEEFFECT=1` (best for greenfield with TanStack Query + zustand)

  ```
  bunx skills@latest add malinskibeniamin/skills/setup-react-rules --agent claude-code -y
  ```

- **setup-react-compiler** — Install `babel-plugin-react-compiler` with rsbuild config. `'use no memo'` directive for escape hatch. Component library directories auto-excluded from compiler.

  ```
  bunx skills@latest add malinskibeniamin/skills/setup-react-compiler --agent claude-code -y
  ```

## Health & Diagnostics

Stop hooks and manual diagnostic skills.

- **setup-react-doctor** — Install react-doctor, add `doctor` package.json script, Stop hook running health check on changed files. Fails on score regression.

  ```
  bunx skills@latest add malinskibeniamin/skills/setup-react-doctor --agent claude-code -y
  ```

- **test-guardian** — Manual diagnostic skill for test health across frameworks (Vitest, Jest, Bun, Rstest). Detect async leaks, profile performance, find slow/flaky tests. Not a hook — invoke when debugging test issues.

  ```
  bunx skills@latest add malinskibeniamin/skills/test-guardian --agent claude-code -y
  ```

## LLM Optimization

Reduce token usage and context waste.

- **setup-llm-optimization** — SessionStart sets `AI_AGENT=1` and `CLAUDECODE=1` for LLM-friendly test output. PreToolUse blocks `--verbose` on test runners. PostToolUse truncates bash output >200 lines.

  ```
  bunx skills@latest add malinskibeniamin/skills/setup-llm-optimization --agent claude-code -y
  ```

## Accessibility

- **setup-accessibility** — PostToolUse hook enforcing ARIA accessibility patterns: ban `<img>` without `alt`, ban mouse-only `onClick` on `<div>`/`<span>` (require `role` + `tabIndex` + keyboard handler), enforce required ARIA attributes on `role="combobox"` / `role="tablist"` / `role="dialog"`. Includes Playwright AXE test helper for WCAG 2.1 AA scanning and ARIA patterns reference (combobox, tabs, dialog, accordion, alert, listbox, switch, slider, radio group). Escape hatch: `// allow-a11y-skip: [reason]`.

  ```
  bunx skills@latest add malinskibeniamin/skills/setup-accessibility --agent claude-code -y
  ```

## State Management

- **setup-zustand** — PostToolUse hook enforcing zustand best practices: ban single-parens `create<T>()` (must be `create<T>()()`), ban inline object selectors (suggest `useShallow`), ban direct localStorage in stores (suggest persist middleware).

  ```
  bunx skills@latest add malinskibeniamin/skills/setup-zustand --agent claude-code -y
  ```

## Routing & Registry

- **setup-tanstack-router** — Auto-regenerate TanStack Router route tree when route files change, plus anti-pattern enforcement: ban react-router-dom, window.location navigation, `strict: false`, untyped hooks (`useParams()`/`useSearch()` without `{ from }`), URLSearchParams (suggest nuqs), warn on exported components from route files (code splitting), and require `validateSearch` when using `useSearch`. Warns on `window.location.reload()` and `window.location` reads. Optional: install TanStack's 28 official reference skills via `npx @tanstack/intent@latest install`.

  ```
  bunx skills@latest add malinskibeniamin/skills/setup-tanstack-router --agent claude-code -y
  ```

- **setup-registry-workflow** — Stop hook that reminds about `registry.json` rebuild and changelog update when redpanda-ui components are modified.

  ```
  bunx skills@latest add malinskibeniamin/skills/setup-registry-workflow --agent claude-code -y
  ```

## Data Fetching

- **setup-connect-query** — PostToolUse hook enforcing ConnectRPC + Connect Query + Protobuf best practices: ban raw `useQuery`/`useMutation` from `@tanstack/react-query` when ConnectRPC is available (allows `useTransport`/`callUnaryMethod` pattern), ban `invalidateQueries()` with no args, warn on axios/fetch. Protobuf v2 projects also get: ban `new Message()` construction (use `create(Schema)`), ban `PlainMessage`/`PartialMessage` (use `MessageShape`/`MessageInitShape`), ban manual `$typeName` object literals. Promotes Standard Schema + protovalidate for form validation. Version detected at install time.

  ```
  bunx skills@latest add malinskibeniamin/skills/setup-connect-query --agent claude-code -y
  ```

## E2E Testing

- **setup-e2e-testing** — Playwright for end-to-end testing with Testcontainers for backend infrastructure, axe-core for automated WCAG 2.1 AA accessibility audits. Includes test patterns for forms, tables, multi-step workflows, and debugging strategies.

  ```
  bunx skills@latest add malinskibeniamin/skills/setup-e2e-testing --agent claude-code -y
  ```

## Environment & Configuration

- **setup-env-validation** — PostToolUse hook banning raw `process.env.X` access. Enforces t3-env with zod validation — all env vars must be declared in `src/env.ts` and imported as a validated object. Skips env files and test files.

  ```
  bunx skills@latest add malinskibeniamin/skills/setup-env-validation --agent claude-code -y
  ```

## Commit Format

- **setup-conventional-commits** — PreToolUse hook enforcing `type(scope): description` format on `git commit` commands. Replaces commitlint + husky with zero dependencies. Validates type, scope (required), lowercase description, no trailing period, 5-72 character length.

  ```
  bunx skills@latest add malinskibeniamin/skills/setup-conventional-commits --agent claude-code -y
  ```

## Community Skills (Optional)

### mattpocock/skills — Workflow automation

Already included in the starter kits. Install individually if needed:

```bash
bunx skills@latest add mattpocock/skills/tdd --agent claude-code -y              # TDD red-green-refactor
bunx skills@latest add mattpocock/skills/triage-issue --agent claude-code -y      # Bug investigation → GitHub issue
bunx skills@latest add mattpocock/skills/improve-codebase-architecture --agent claude-code -y  # Architecture improvements
bunx skills@latest add mattpocock/skills/request-refactor-plan --agent claude-code -y  # Refactor plans as GitHub issues
bunx skills@latest add mattpocock/skills/design-an-interface --agent claude-code -y    # Multiple interface designs
bunx skills@latest add mattpocock/skills/write-a-prd --agent claude-code -y       # PRD via interview
bunx skills@latest add mattpocock/skills/prd-to-plan --agent claude-code -y       # PRD → implementation plan
bunx skills@latest add mattpocock/skills/prd-to-issues --agent claude-code -y     # PRD → GitHub issues
bunx skills@latest add mattpocock/skills/write-a-skill --agent claude-code -y     # Create new skills
bunx skills@latest add mattpocock/skills/grill-me --agent claude-code -y          # Stress-test your design
bunx skills@latest add mattpocock/skills/git-guardrails-claude-code --agent claude-code -y  # Branch protection
bunx skills@latest add mattpocock/skills/qa --agent claude-code -y                # Interactive QA → auto-file GitHub issues
bunx skills@latest add mattpocock/skills/ubiquitous-language --agent claude-code -y  # Domain glossary (DDD)
```

**Note:** `setup-pre-commit` (husky/lint-staged) is intentionally omitted. Claude Code hooks already enforce linting, formatting, and type checking deterministically on every edit — pre-commit hooks are redundant and add friction for human developers who may prefer different workflows.

### TanStack Official Skills — Framework reference (optional)

TanStack packages ship their own reference skills via `@tanstack/intent`. These are soft guidance (patterns, examples, API docs) — no hooks, no enforcement. Install only if you want Claude to have deep TanStack knowledge in context:

```bash
# Install all TanStack skills from your node_modules (Router, DB, DevTools, etc.)
npx @tanstack/intent@latest install
```

**Available packages with skills:**
- **TanStack Router** — 28 skills: search params, data loading, auth guards, error handling, code splitting, type safety, navigation, SSR
- **TanStack DB** — 14 skills: collections, live queries, optimistic mutations, persistence, offline transactions
- **TanStack DevTools** — 9 skills: plugin panels, production devtools, instrumentation
- **TanStack CLI** — 5 skills: scaffolding, addons, ecosystem integrations

Note: TanStack Query, Table, Form, Virtual do not have published skills yet.

## Evals

Two layers of testing to prevent regressions:

**Script-level evals** — verify hook scripts, file structure, and content. Run locally in <5 seconds:

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
├── enforce-toolchain.sh            — block npm/npx/tsc/eslint/prettier, enforce --yarn, guard destructive commands
├── llm-test-flags.sh               — block --verbose on test runners
└── conventional-commits-check.sh   — enforce type(scope): description format

PostToolUse (Edit|Write)                          All use shared/hook-lib.sh
├── react-rules-check.sh      — React/TS/security checks (skips non-JS/TS)
├── tailwind-check.sh          — !important + raw hex ban (CSS/SCSS/TSX/JSX)
├── accessibility-check.sh     — ARIA/WCAG enforcement (~30ms, skips non-TSX/JSX)
├── zustand-check.sh           — zustand anti-patterns (~20ms, skips non-zustand files)
├── tanstack-router-check.sh   — 9 routing anti-patterns (skips non-router files)
├── connect-query-check.sh     — ConnectRPC/protobuf patterns (skips non-connect files)
├── react-compiler-check.sh    — ban manual memoization (skips 'use no memo' files)
├── env-validation-check.sh    — ban raw process.env (skips env.ts, test files)
└── bundle-guard.sh            — heavy dependency warnings (~10ms, skips non-package.json)

PostToolUse (Bash)
└── llm-truncate.sh      — truncate output >200 lines

Stop
├── biome-autofix.sh     — lint:fix all changed JS/TS files
├── typecheck-stop.sh    — tsgo type check + related tests (vitest/jest/bun auto-detect)
├── react-doctor-stop.sh — health check on changed files (--diff mode)
└── registry-check.sh    — remind about registry.json rebuild
```

Non-JS/TS file edits (Go, Python, Markdown, etc.) get zero overhead — all hooks exit immediately on non-matching file extensions.

## Performance

PostToolUse hooks run **concurrently** — wall-clock time is the slowest hook, not the sum.

### Per Edit/Write (PostToolUse)

| Scenario | Wall-clock | What happens |
|----------|-----------|--------------|
| Edit a `.go` / `.md` / `.css` file | **~80ms** | All 10 hooks exit immediately on extension check |
| Edit a `.tsx` file (clean code) | **~293ms** | Slowest hook (react-rules) runs full diff + 19 grep checks |
| Edit a `package.json` | **~80ms** | Only bundle-guard runs, rest exit |

The ~80ms floor is bash process spawn + `jq` parse — fixed cost regardless of hook count. Adding more hooks doesn't increase wall-clock time since they run in parallel.

### Per Bash Command (PreToolUse)

| Hook | Time | Notes |
|------|------|-------|
| enforce-toolchain.sh | ~166ms | Grep chain on command string |
| conventional-commits-check.sh | ~91ms | Only does real work on `git commit -m` |
| **Total** | **~257ms** | Sequential, runs before every Bash call |

### Per Turn (Stop)

| Hook | Time | Notes |
|------|------|-------|
| biome-autofix.sh | 1-3s | Only changed files, skips UI library dirs |
| typecheck-stop.sh | 2-5s | tsgo (incremental) + related tests only |
| react-doctor-stop.sh | 1-2s | `--diff` mode, changed files only |
| **Total** | **~4-10s** | Runs once when Claude finishes, not per edit |

### Context

A typical Claude Code tool call takes 3-8 seconds (network + LLM inference). PostToolUse overhead of ~293ms is **3-8%** of that — imperceptible. The Stop hooks at 4-10s replace what you'd run manually (lint, type check, tests) and only target changed/related files.

The ~80ms per-hook floor is dominated by process spawning and `jq`. This is the cost of using bash — a compiled hook runner would cut it to <5ms, but bash is portable, readable, and easy to customize.

## Codex Compatibility (Experimental)

> Codex supports only the `Bash` matcher for PostToolUse — not `Edit|Write`. This skill bridges that gap by wrapping Edit|Write hooks into a Stop-based batch checker.

- **codex-compat** — Generates `.codex/hooks.json` and `AGENTS.md` from existing Claude Code hooks. Translates PostToolUse Edit|Write hooks into a Stop-based batch checker. PreToolUse, SessionStart, and Stop hooks work identically on both platforms.

  ```
  bunx skills@latest add malinskibeniamin/skills/codex-compat --agent claude-code -y
  ```

  **Not included in starter kits.** Install separately for repos where Codex users need hook enforcement.
