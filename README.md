# Agent Skills

**Tell Claude what to build. Get a PR that's ready to merge.**

25 hooks enforce patterns in real-time, skills guide the workflow, and the orchestration layer ensures nothing ships without tests, accessibility, type safety, and code review — zero babysitting required.

## How It All Connects

```
You: "Build feature X" or "Fix these 5 issues overnight"
  │
  ├── Interactive ──→ Claude Code + /development-lifecycle
  │                    └── understand → plan → TDD → verify → review → compound
  │
  └── AFK batch ───→ Sandcastle (.sandcastle/main.ts)
                      └── picks issues → spawns N agents in Docker
                          └── each agent runs development-lifecycle
                              └── hooks enforce 69+ checks per edit
                                  └── code-reviewer agent reviews
                                      └── PRs ready to merge
```

**Four layers, one outcome:**

| Layer | What | How | Reliability |
|---|---|---|---|
| **Skills** | What to do | development-lifecycle (6 phases) | Loaded on demand |
| **Hooks** | Enforce quality | 25 hooks, 69+ checks, every edit | 100% automatic |
| **Agents** | Specialize | code-reviewer + verifier | Dispatched by skills |
| **Sandcastle** | Delegate | N parallel agents in Docker worktrees | AFK batch mode |

## Why This Exists

| Problem | Without this repo | With this repo |
|---|---|---|
| Claude writes `as any` | Ships to PR → human catches → feedback loop | Hook blocks immediately → 50 tokens → fixed |
| Claude skips tests | Ships → human requests → another round | Stop gate blocks → tests added automatically |
| Claude uses wrong patterns | 3-5 human review cycles per PR | 0-1 human review cycles per PR |
| You forget to ask for accessibility | No a11y until manual audit | Every component checked automatically |
| You have to babysit every step | Manual: "now write tests", "now check types" | Full lifecycle runs without prompting |

**How it works**: 25 hooks fire automatically with 100% reliability and zero LLM tokens. Skills add workflow guidance when needed. The combination eliminates 80-90% of human review cycles.

**vs. [obra/superpowers](https://github.com/obra/superpowers)**: Superpowers provides excellent workflow skills (TDD, debugging, planning). We incorporate their best patterns AND add what they don't have: **mechanical enforcement via hooks**. Superpowers teaches Claude what to do. We teach AND enforce — if Claude forgets, the hook catches it.

## Skills You Need to Know

You only need to remember **one skill**: `/development-lifecycle`. It covers the full flow.

| What you're doing | What to invoke | What happens |
|---|---|---|
| Building a feature | Just describe it | Hooks detect → understand → plan → TDD → review |
| Fixing a bug | Describe the bug | Hooks detect → reproduce → root cause → TDD fix → review |
| Writing tests | Just write them | Hooks enforce TDD patterns, detect async leaks |
| Creating a PR | "Create a PR" | Hooks verify CI, suggest review, conventional commits |
| Any code change | Just code | 25 hooks enforce patterns in real-time |

**Advanced** (optional, for specific needs):
- `/brainstorming` — deep design exploration with challenge mode
- `/grill-me` — stress-test a specific decision

Everything else happens automatically via hooks. You don't need to invoke skills.

## TLDR — Full Setup for a New Repo

**Option A: Plugin marketplace (recommended — installs everything in one command):**

```
/plugin marketplace add malinskibeniamin/skills
/plugin install frontend-skills@skills
/reload-plugins
```

Three commands: register the marketplace, install everything, activate in current session.

**Option B: Individual skills (if you prefer granular control):**

```bash
bunx skills@latest add malinskibeniamin/skills/frontend-starter-kit --agent claude-code -y
bunx skills@latest add malinskibeniamin/skills/development-lifecycle --agent claude-code -y
```

**Project management + workflow skills:**

```bash
bunx skills@latest add malinskibeniamin/skills/work-automation-kit --agent claude-code -y
```

**Optional extras:**

```bash
# TanStack official reference skills (28 soft-guidance skills from docs)
npx @tanstack/intent@latest install

# Codex compatibility (if team uses both Claude Code and Codex)
bunx skills@latest add malinskibeniamin/skills/codex-compat --agent claude-code -y

# Atlassian/Jira integration (requires acli installed)
bunx skills@latest add malinskibeniamin/skills/setup-atlassian-workflow --agent claude-code -y

# Codex cross-model review plugin (requires OpenAI API key)
# /plugin marketplace add openai/codex-plugin-cc
# /plugin install codex@openai-codex

# Redpanda-specific (Chakra/legacy bans, registry workflow)
bunx skills@latest add malinskibeniamin/skills/redpanda-frontend-kit --agent claude-code -y
```

Or install individual skills if you don't want the full kit — see sections below.

**Verify installation health:**

```bash
# If installed via plugin marketplace:
bash ~/.claude/plugins/cache/skills/frontend-skills/*/scripts/verify-install.sh

# If installed via bunx skills:
bash scripts/verify-install.sh

# Options:
bash scripts/verify-install.sh --remote     # also check for updates
bash scripts/verify-install.sh --json       # machine-readable output
```

## Quick Start

New to AI-assisted development? Start here.

**Day 1 (30 min):**
1. Add the marketplace: `/plugin marketplace add malinskibeniamin/skills`
2. Install the plugin: `/plugin install frontend-skills@skills`
3. Activate: `/reload-plugins`
4. Run `bash ~/.claude/plugins/cache/skills/frontend-skills/*/scripts/verify-install.sh` to confirm everything is wired
3. Pick a real ticket from your backlog — not a toy problem

**Your first prompt:**
```
Read [relevant files]. I want to [goal from your ticket].
Before writing any code, produce a plan with what you'll do, files you'll change,
edge cases, and how you'll verify. Wait for my approval before starting.
```

**What happens automatically:** 25 hooks enforce patterns on every edit. Intent detection injects workflow guidance. Stop hooks run type checking, linting, and related tests before Claude finishes. You don't need to ask for any of this.

**Day 2+:** Work real tickets. Let the hooks catch mistakes. Focus on **clarifying the problem** and **reviewing the output** — not writing code yourself. Post wins and failures to your team channel.

**Tips that matter:**
- Plan before you execute (`/plan`). Engineers who skip this spend the day untangling misdirected work
- Use `/clear` between unrelated tasks. Long sessions degrade output quality
- If Claude starts deleting tests to make CI green — stop immediately. That's a red flag
- Use `HOOK_VERBOSITY=terse` for long sessions to reduce token overhead
- Run `verify-install.sh --remote` weekly to check for updates (see Verify section above for path)

## How It Works

Three layers of automation run without any manual invocation:

**Layer 1 — Intent Detection** (every prompt, ~30ms): Detects what you're doing from your prompt keywords and injects workflow directives. "Write a test" → TDD workflow. "Fix a bug" → triage pattern. "Create component" → accessibility + design system checklist. "Create PR" → CI verify + review.

**Layer 2 — Pattern Enforcement** (every Edit/Write, ~293ms): 10 PostToolUse hooks catch violations in real-time. Claude sees the error, fixes it, hook re-checks — cycle repeats until clean. Plus file-aware guidance: writing a test file → async leak tips, writing a component → accessibility checklist.

**Layer 3 — Quality Gate** (when Claude finishes, <10s): 6 Stop hooks verify the work is production-ready. Type check, lint autofix, health score, PLUS the orchestration gate that blocks on missing tests, async leaks, and security issues. Claude doesn't stop until the PR is ready to merge.

**Auto-loading skills**: Skills with `paths:` frontmatter auto-load when Claude works on matching files. Write a test → TDD patterns load. Edit a route → TanStack Router patterns load. No `/skill-name` invocation needed.

You never see hook output directly. Claude just produces better code, with tests, accessible, secure, and type-safe — without you asking for each thing individually.

### Configuration

| Env var | Default | What it does |
|---------|---------|--------------|
| `PROMPT_CONTEXT_LEVEL` | `standard` | How much state to inject per prompt (`minimal`, `standard`, `full`) |
| `ORCHESTRATION_STRICT` | `1` | Set to `0` during prototyping to disable "must have tests" gate |
| `REACT_COMPILER_MODE` | `infer` | Set to `annotation` for brownfield codebases |
| `HOOK_VERBOSITY` | `normal` | `terse` = blocks only (suppresses warns), `quiet` = all output suppressed |
| `HOOKS_FAIL_CLOSED` | `0` | Set to `1` to block on hook script errors (catches misconfiguration) |

## Why Hooks > Skills > Manual

| Approach | Reliability | Token cost | Latency | Human effort |
|----------|-------------|------------|---------|--------------|
| Manual prompting | 0% (forgotten) | 0 extra | 0 | High (remember every rule) |
| Skills on-demand | ~70% (Claude may skip) | ~500 tokens/skill | ~0ms | Low |
| Skills with `paths:` | ~90% (auto-load on file match) | ~500 tokens/skill | ~0ms | None |
| PostToolUse hooks | 100% (always fires) | 0 (bash scripts) | ~293ms | None |
| UserPromptSubmit hooks | 100% (every prompt) | 0 (bash) + context | ~120ms | None |
| Stop hooks | 100% (every turn end) | 0 (bash) + test run | ~4-10s | None |

### Token Impact

| Without hooks/skills | With hooks+skills |
|---|---|
| `as any` → ships → human catches → feedback loop (3000+ tokens) | Hook blocks → 50 tokens → fixed |
| No tests → ships → human requests → another round (5000+ tokens) | Stop gate blocks → 100 tokens → tests added |
| Wrong import → review → fix (2000+ tokens) | Rules line prevents → 0 extra tokens |
| **3-5 human review cycles per PR** | **0-1 human review cycles per PR** |
| **~15,000-30,000 tokens wasted on violations** | **~500-2,000 tokens in hook messages** |

## Greenfield vs Brownfield

**New project:** Use `infer` mode (default). All hooks enforce maximum strictness.

**Existing codebase:** Set `REACT_COMPILER_MODE=annotation` in your session env. This lets you migrate file-by-file — add `"use memo"` to files as you adopt the compiler, and hooks only enforce compiler patterns in opted-in files.

```bash
# In .claude/hooks/session-env.sh, add:
echo "export REACT_COMPILER_MODE=annotation" >> "$CLAUDE_ENV_FILE"
```

## Example Prompts

After installing, try these prompts to see the skills in action:

<details>
<summary>Feature development workflow</summary>

```
/write-a-prd for a new user settings page with theme, language, and notification preferences.
```

Then:

```
/prd-to-plan
```

Then:

```
/prd-to-issues
```

If using Jira: the issues will also be created as Jira work items when `ISSUE_TRACKER=both`.

</details>

<details>
<summary>Code review workflow</summary>

```
Create a PR for these changes. After creating it, comment @claude review on the PR for an automated review.
```

Or for a local second opinion:

```
/codex:review
```

For design challenges:

```
/codex:adversarial-review
```

</details>

<details>
<summary>Test health check</summary>

```
Run test health diagnostics on this project. Identify flaky tests, async leaks, and slow queries.
```

</details>

<details>
<summary>E2E test scaffolding</summary>

```
Use agent-browser to inspect http://localhost:3000/topics and generate Playwright e2e tests from the accessibility tree.
```

</details>

<details>
<summary>Architecture review</summary>

```
/improve-codebase-architecture — focus on module boundaries and testability
```

Or stress-test a design:

```
/grill-me on the data fetching strategy for the new dashboard feature
```

</details>

<details>
<summary>Daily workflow (start of session)</summary>

```
Check git status. Run bun run quality:gate to verify the codebase is clean. Then let's work on [your task].
```

Before creating a PR:

```
Run quality:gate. If it passes, create a PR. After creating, comment @claude review on it.
```

</details>

<details>
<summary>Bug triage</summary>

```
/triage-issue — investigate why [describe the bug]. Check logs, reproduce, identify root cause, and file a GitHub issue with a fix plan.
```

If using Jira:

```
/triage-issue — investigate [bug]. File findings as a Jira work item via acli.
```

</details>

## Migrating an Existing Codebase

After installing, paste this prompt into a new Claude Code session to migrate existing code to comply with the new hooks:

<details>
<summary>Migration prompt (click to expand)</summary>

```
I just installed the frontend-starter-kit skills. Run all setup skills now, then migrate existing code to comply with the new hooks.

## Phase 1: Run setup skills

Execute the frontend-starter-kit skill. This will:
- Install all 14 setup skills (toolchain, biome, quality-gate, etc.)
- Install development-lifecycle skill (the one skill for the full workflow)
- Create all hook scripts in .claude/hooks/ (25 hooks, 69+ checks)
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
4. as any, as Record<string, any>, @ts-ignore, @ts-expect-error → proper types, type guards, or zod validation
5. dangerouslySetInnerHTML → DOMPurify or safe rendering
6. Inline style={{}} → Tailwind utility classes
7. Raw hex/rgb in className → design tokens
8. !important → fix specificity
9. useMemo/useCallback/React.memo → remove (React Compiler handles it, or add "use memo" in annotation mode)
10. outline: none → focus-visible:outline-2
11. Barrel imports (import from index files) → direct path imports
12. addEventListener('scroll') → add { passive: true }
13. Static imports of chart.js/d3/three → dynamic import() or React.lazy()
14. React.FC / React.FunctionComponent → plain function declarations
15. cloneElement → Context-based composition
16. biome-ignore comments → fix the lint issue instead
17. import * as Foo → import { specific } (tree-shaking)
18. export * from → export specific items (tree-shaking)
19. handleSubmit(onSubmit) → handleSubmit(onSubmit, onError)
20. navigate(-1) / history.back() → explicit route path
21. react-beautiful-dnd → @dnd-kit/core (archived by Atlassian)
22. framer-motion → motion (renamed package)
23. plotly.js / recharts → lazy load (heavy bundles)

### 2e-2. Protobuf v2 patterns (if applicable)
1. new Message() → create(MessageSchema, { ... })
2. PlainMessage/PartialMessage → MessageShape/MessageInitShape
3. Manual $typeName object literals → create()
4. Protobuf spreads without create() wrapper → wrap with create(Schema, { ...msg })

### 2e-3. Connect Query patterns (if applicable)
1. Raw useQuery/useMutation with ConnectRPC → use Connect Query hooks
2. invalidateQueries() with no args → specify query key
3. Duplicate Zod schemas for protobuf messages → Standard Schema + protovalidate

### 2e-4. Accessibility patterns
1. All `<img>` must have `alt` attribute
2. Clickable `<div>`/`<span>` must have role + tabIndex + keyboard handler
3. Icon-only buttons → add `aria-label`
4. Interactive elements → add `data-track` or semantic identifiers for observability

### 2e-5. Protobuf well-known types (if applicable)
1. Timestamp as { seconds, nanos } → timestampFromDate() from @bufbuild/protobuf/wkt
2. Any without typeUrl → anyPack() from @bufbuild/protobuf/wkt

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

- **frontend-starter-kit** — Complete frontend stack in one command: 14 setup skills (toolchain, Biome, quality gate, LLM optimization, React Compiler, zustand, accessibility, React rules, env validation, conventional commits, react-doctor, TanStack Router, Connect Query, e2e testing) + test-driven-development (TDD + diagnostics) + 10 community workflow skills (TDD, triage, architecture, refactoring, design, PRD, QA, DDD glossary). `console.*` is fully covered by Biome's `noConsole`.

  ```
  bunx skills@latest add malinskibeniamin/skills/frontend-starter-kit --agent claude-code -y
  ```

- **redpanda-frontend-kit** — Everything in the frontend starter kit, plus Redpanda-specific rules: Chakra/legacy import bans, TanStack Router, Connect Query + Protobuf enforcement, react-doctor, and registry workflow.

  ```
  bunx skills@latest add malinskibeniamin/skills/redpanda-frontend-kit --agent claude-code -y
  ```

- **work-automation-kit** — Project planning and management workflow skills: PRD creation, implementation planning, issue breakdown, bug triage. Optional: Atlassian/Jira integration via acli, Codex cross-model review via codex-plugin-cc.

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

- **setup-quality-gate** — Add `quality:gate` package.json script (biome + tsgo + related tests in <5s), GitHub Actions CI workflow with formatting integrity check (`git diff --exit-code`), Stop hook for tsgo type checking, bundle guard PostToolUse hook, `gh` CLI CI status checks, `@claude review` trigger pattern, and optional Codex cross-model review.

  ```
  bunx skills@latest add malinskibeniamin/skills/setup-quality-gate --agent claude-code -y
  ```

## React Rules

PostToolUse hooks that enforce React patterns on every Edit/Write. All checks skip non-JS/TS files (zero overhead for backend devs) and auto-detect component library directories (`components/ui/`, `redpanda-ui/`, `src/ui/`, `packages/ui/` — configurable via `UI_LIB_DIRS`).

- **setup-react-rules** — 34 React/TS/security/a11y checks in two hook scripts (`react-rules-check.sh` + `tailwind-check.sh`). All messages are compressed for token efficiency — keeps the fix, drops the explanation. Key checks:
  - Ban raw HTML elements, `as any`, `@ts-ignore`, `@ts-expect-error`, class components
  - Ban `dangerouslySetInnerHTML`, `eval()`, `.innerHTML`, `setTimeout("string")`, `=== NaN`
  - Ban `onClick + navigate()`, barrel imports, `!important`, `outline: none`
  - Suggest `structuredClone()` over JSON roundtrip, `.requestSubmit()` over `.submit()`
  - Suggest `100dvh` over `100vh`, `100%` over `100vw`, block `user-scalable=no`
  - Use `<Button>` over `<div role="button">`, `Number()` over unradixed `parseInt()`
  - React Compiler: ban manual `useMemo`/`useCallback`/`React.memo`
  - Opt-in: ban `useEffect` via `REACT_RULES_BAN_USEEFFECT=1`

  ```
  bunx skills@latest add malinskibeniamin/skills/setup-react-rules --agent claude-code -y
  ```

- **setup-react-compiler** — Install `babel-plugin-react-compiler` with rsbuild config. Default `annotation` mode for brownfield codebases (opt-in per file with `"use memo"`), `infer` for greenfield. `'use no memo'` for escape hatch. Compiler modes reference, derived-state detection, named useEffect heuristic. Component library directories auto-excluded.

  ```
  bunx skills@latest add malinskibeniamin/skills/setup-react-compiler --agent claude-code -y
  ```

## Health & Diagnostics

Stop hooks and manual diagnostic skills.

- **setup-react-doctor** — Install react-doctor, add `doctor` package.json script, Stop hook running health check on changed files. Fails on score regression.

  ```
  bunx skills@latest add malinskibeniamin/skills/setup-react-doctor --agent claude-code -y
  ```

Test health diagnostics (async leaks, slow queries, flaky tests) are now part of `/test-driven-development` and the `orchestration-stop` quality gate.

## LLM Optimization

Reduce token usage and context waste.

- **setup-agent-config** — SessionStart sets `AI_AGENT=1`, `CLAUDECODE=1`, `NODE_OPTIONS=--max-old-space-size=8192`. UserPromptSubmit injects project state (3 context levels) + condensed rules line + intent detection (TDD/component/bug/PR/refactor/e2e). PreToolUse strips `--verbose`, suggests `--pool=forks`/`--bail=1`. PostToolUse truncates output >200 lines + file-aware orchestration guidance. Stop: violation summary + comprehensive quality gate.

  ```
  bunx skills@latest add malinskibeniamin/skills/setup-agent-config --agent claude-code -y
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

- **setup-connect-query** — PostToolUse hook enforcing ConnectRPC + Connect Query + Protobuf best practices: ban raw `useQuery`/`useMutation` when ConnectRPC is available (allows `useTransport`/`callUnaryMethod`), ban `invalidateQueries()` with no args, warn on axios/fetch. Protobuf v2: ban `new Message()`, `PlainMessage`/`PartialMessage`, manual `$typeName` literals. Well-known types: warn on `Any` without `@type`, `Timestamp` as plain object (use `timestampFromDate`/`anyPack` from `@bufbuild/protobuf/wkt`). Promotes Standard Schema + protovalidate. Auto-loads on `*_pb*`/`*_connectquery*` files via `paths:`.

  ```
  bunx skills@latest add malinskibeniamin/skills/setup-connect-query --agent claude-code -y
  ```

## E2E Testing

- **setup-e2e-testing** — Playwright for end-to-end testing with Testcontainers for backend infrastructure, axe-core for automated WCAG 2.1 AA accessibility audits. Optional agent-browser integration for AI-driven test scaffolding and visual verification. Includes test patterns for forms, tables, multi-step workflows, and debugging strategies.

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

## Atlassian / Jira (Optional)

- **setup-atlassian-workflow** — Opt-in Jira integration via `acli` (Atlassian CLI). Mirrors gh-based workflow skills for Jira users — create work items, transition status, comment, link PRs. Works alongside `gh` (`ISSUE_TRACKER=both`) or standalone (`ISSUE_TRACKER=acli`). Requires `acli` installed and authenticated.

  ```
  bunx skills@latest add malinskibeniamin/skills/setup-atlassian-workflow --agent claude-code -y
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
- **TanStack Router** — 25 skills: search params, data loading, auth guards, error handling, code splitting, type safety, navigation, SSR
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

**Agent-level evals** — 14 behavioral tests using [@vercel/agent-eval](https://github.com/vercel-labs/agent-eval) that verify Claude Code actually follows the rules when given adversarial prompts. Runs in Docker sandbox:

```
cd agent-evals && bun install --yarn && npx @vercel/agent-eval
```

## Hook Architecture

```
SessionStart
├── session-env.sh      — PKG_MANAGER=bun, LINTER=biome, TEST_RUNNER=vitest, NODE_OPTIONS=8GB
└── llm-env.sh          — AI_AGENT=1, CLAUDECODE=1

UserPromptSubmit
├── user-prompt-context.sh — inject git state, scripts, violations, rules, config (3 levels)
└── intent-detect.sh       — detect TDD/component/bug/PR/refactor/e2e intent, inject directives

PreToolUse (Bash)
├── enforce-toolchain.sh            — block npm/npx/tsc/eslint/prettier, enforce --yarn, guard destructive commands
├── llm-test-flags.sh               — strip --verbose (updatedInput rewrite), suggest --pool=forks/--bail
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
├── bundle-guard.sh            — heavy dependency warnings (~10ms, skips non-package.json)
└── orchestration-guidance.sh  — file-aware guidance (test patterns, a11y, security) + category tracking

PostToolUse (Bash)
└── llm-truncate.sh      — truncate output >200 lines

Stop
├── biome-autofix.sh     — lint:fix all changed JS/TS files
├── typecheck-stop.sh    — tsgo type check + related tests (vitest/jest/bun auto-detect)
├── react-doctor-stop.sh — health check on changed files (--diff mode)
├── registry-check.sh        — remind about registry.json rebuild (skips if no redpanda-ui dir)
├── orchestration-stop.sh    — quality gate: missing tests, async leaks, security, co-located tests
└── violation-summary-stop.sh — session violation aggregator
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

### Token Efficiency

Hook messages are compressed (inspired by [Caveman](https://github.com/JuliusBrussee/caveman) and [arxiv:2604.00025](https://arxiv.org/abs/2604.00025)). The LLM already knows the rules from SKILL.md — hooks are reminders, not tutorials.

| Optimization | Savings |
|---|---|
| Compressed systemMessage strings | ~40% fewer tokens per violation |
| Guidance deduplication (once per category per session) | ~50-70% fewer orchestration tokens |
| `HOOK_VERBOSITY=terse` (blocks only) | Suppresses all warns |
| REFERENCE.md trimmed to essentials | -21% input tokens on skill loads |

Combined: **~6,700 fewer tokens per session** vs. unoptimized hooks. For long sessions or multi-agent (Sandcastle), use `HOOK_VERBOSITY=terse` and `PROMPT_CONTEXT_LEVEL=minimal` to minimize overhead.

### Context

A typical Claude Code tool call takes 3-8 seconds (network + LLM inference). PostToolUse overhead of ~293ms is **3-8%** of that — imperceptible. The Stop hooks at 4-10s replace what you'd run manually (lint, type check, tests) and only target changed/related files.

## Codex Compatibility

Codex is a first-class harness. 15 of 25 hooks port directly (SessionStart, UserPromptSubmit, PreToolUse/Bash, PostToolUse/Bash, Stop). The 10 Edit|Write PostToolUse hooks are consolidated into a single Stop-phase batch checker. `AGENTS.md` at repo root replaces PostCompact context re-injection.

All hook paths use `$(git rev-parse --show-toplevel)` for resolution — works from any CWD, silently skips in repos without hooks installed.

- **codex-compat** — Installs `.codex/hooks.json`, batch checker, and `AGENTS.md`. Session state is harness-agnostic (`CLAUDE_SESSION_ID` or `CODEX_SESSION_ID`).

  ```
  bunx skills@latest add malinskibeniamin/skills/codex-compat --agent claude-code -y
  ```
