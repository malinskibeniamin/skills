# Demos and example prompts

Real prompts, demo scripts, and recorded moments from this harness. Everything here is copy-pasteable into a Claude Code session with the plugin installed.

## Starter prompts

**Try it yourself** -- copy-paste into a Claude Code session:

<details>
<summary>Real starter prompts (pick one)</summary>

**Feature work:**
```
/development-lifecycle -- add dark mode toggle to settings page.
Read src/routes/settings.tsx first. Propose approach, wait for my approval.
```

**Bug fix (skip plan phase):**
```
/development-lifecycle -- users report form submits twice on double-click.
Reproduce, find root cause, fix with test.
/visual-review -- review changed customer-facing surfaces before opening a PR.
/review --deep -- release-blocking cold PR audit across code quality, frontend harness, resilience, visual UX, security, tests, perf, and steelman axes.
```

**Swarm execution:**
```
/swarm improve URL parameter handling fast. Split tests, implementation, resilience review, and docs across subagents; stay on this branch.
```

**Address PR review:**
```
/resolve-pr-feedback
```
Auto-detects current branch PR, triages, fixes, replies to threads.

</details>

## See it in motion

**Three big wins** -- autoplay teaser, real moments from the last 30 days:

<p align="center">
</p>

**Hero GIF** -- hook blocking a banned cast at write time (~293ms, every edit):

<p align="center">
</p>

**2-minute highlight reel** -- skill wins extracted from real transcripts (ADP UI + ui-registry + skills repo):

<p align="center">
  </video>
</p>

Featured skill moments -- each from an actual session:
- **`/grilling`** -- 100+ rapid-fire questions on autoform proto-schema coupling. Surfaced 3 weeks of wasted work before a line of code was written.
- **`/development-lifecycle`** -- adp-ui-llm-provider-cards: 4 waves, 13 phases, shipped end-to-end. No scope creep.
- **`/tdd`** -- applied to `codex/autoform-v2-foundation` refactor. RED -> GREEN -> REFACTOR across the full PR surface.
- **`/simplify`** -- three iterative passes on MCP marketplace PR. Caught 15% redundant code reviewers missed.
- **`/grilling`** -- stress-tested plans, updated CONTEXT.md + ADRs inline. Institutional memory captured mid-design.
- **`/resilience-review`** -- Murphy-law pass for edge cases, error handling, fallback, observability, and feature polish before PR.
- **Force-push to main blocked** -- hook redirected to feature branch + PR flow every time.
- **Dogfooding** -- 12 skills + 60 hooks + 263 unit tests + 9 agent evals shipped using the harness itself.
- **Skill auto-load on file match** -- `/tdd` on `*.test.ts`, `/tanstack-router` on `route.tsx`, `/connect-query` on `*_pb.ts`. Zero invocation needed.

<details>
<summary>More videos -- 60s explainer, 50s comparison, 70s announcement</summary>

**60-second explainer** -- pain -> fix -> install -> proof:

<p align="center">
  </video>
</p>

**50-second comparison** -- prompt-packs vs obra/superpowers vs this harness:

<p align="center">
  </video>
</p>

**70-second announcement** -- launch version for Slack / social:

<p align="center">
  </video>
</p>

</details>

## 5-minute proof (run it yourself)

The fastest way to believe it: reproduce the core claim in your terminal.

<details>
<summary>Five-minute hook demo -- step by step</summary>

**Prereq:** Claude Code installed, fresh repo.

**1. Install the plugin**
```bash
/plugin marketplace add malinskibeniamin/skills
/plugin install frontend-skills@skills
/reload-plugins
```

**2. Ask Claude to write a banned pattern**
```
Create src/bad.ts with: export function parseUser(data: unknown) { return data as any; }
```

**3. Watch the hook fire** -- ~293ms after the Edit, `react-rules-check.sh` blocks with:
> `as any` banned. Use type guards or zod.

**4. Compare token cost**
- Without hooks: `as any` ships -> human review catches -> 3-5 comment rounds -> ~3,000 tokens
- With hooks: blocked at write time -> Claude fixes in same turn -> ~50 tokens

**5. Try to bypass it**
```
Use // biome-ignore noExplicitAny to silence
```
Hook still fires -- all `biome-ignore` comments are blocked. Fix the underlying type, lint, or style issue at source. Generated files are skipped automatically; source files get no suppression escape hatch.

**6. Try the Stop gate** -- ask Claude to skip tests:
```
Write src/math.ts with an add() function. Skip tests.
```
Watch the Stop hook block: "orchestration-stop.sh: missing co-located test for src/math.ts".

Five tests, five deterministic blocks. Everything a human reviewer would catch, caught in <1 second by bash scripts with zero LLM tokens.

</details>

## Prompt examples for each workflow skill

<details>
<summary>Prompt examples for each workflow skill</summary>

**`/development-lifecycle`** -- default for all dev work:
```
/development-lifecycle -- I need to add a user settings page with theme, language,
and notification preferences. Read src/routes/ to understand the routing structure first.
```

**`/brainstorming`** -- explore options before commit:
```
/brainstorming design -- I need to add real-time collaboration to our editor.
Compare WebSocket, SSE, and CRDT approaches. Focus on latency and offline support.
```

**`/prime`** -- startup brief:
```
/prime -- summarize repo state before I start the URL params work.
```

**`/tdd`** -- strict test-first:
```
/tdd -- add input validation to the signup form. Email format, password strength,
and matching confirm password. Start with the failing tests.
```

**`/grilling`** -- docs-first grill with inline doc updates:
```
/grilling -- stress-test the data fetching strategy for the new dashboard feature.
We're planning to use TanStack Query with a 5-minute stale time.
```

**`/triage`** -- triage incoming issues (GitHub or Jira):
```
/triage -- show me anything that needs my attention
```

**`/diagnosing-bugs`** -- debug a hard bug:
```
/diagnosing-bugs -- the export button intermittently throws on Firefox but not Chrome.
Build the feedback loop first.
```

**`/grilling`** -- light stress-test (no DDD docs):
```
/grilling on the data fetching strategy for the new dashboard feature.
```

**`/triage`** -- investigate a bug and file a ticket with a TDD fix plan:
```
/triage -- users report the sidebar flickers on navigation.
It started after the last release. Check rendering and route transitions.
```

**`/resolve-pr-feedback`** -- address review comments:
```
/resolve-pr-feedback 123
```
or just `/resolve-pr-feedback` to auto-detect PR from current branch.

**`/improve-codebase-architecture`** -- find opportunities:
```
/improve-codebase-architecture -- focus on module boundaries and testability
in src/features/. Look for tightly coupled modules that should be split.
```

**`/aip`** -- protobuf API design:
```
/aip -- review the Book resource API for standard methods, names, etags, and pagination.
```

**`/handoff`** -- transfer context to another session:
```
/handoff -- next session should prototype the URL-state approach without touching the main implementation branch.
```

**`/writing-great-skills`** -- improve skill quality:
```
/writing-great-skills review this new design-system-token skill draft.
It should check that components use --color-* CSS variables instead of raw hex values.
```

</details>

## Quick start

New to AI-assisted dev? Start here.

**Day 1 (30 min):**
1. Install (see [Install](#install) above)
2. Run `bash "$(ls -d ~/.claude/plugins/cache/skills/frontend-skills/*/ | tail -1)scripts/verify-install.sh"` confirm all wired
3. Pick real ticket from backlog -- not toy problem

**First prompt:**
```
Read [relevant files]. I want to [goal from your ticket].
Before writing any code, produce a plan with what you'll do, files you'll change,
edge cases, and how you'll verify. Wait for my approval before starting.
```

**What happens automatic:** Hooks enforce patterns every edit. Intent detection inject workflow guidance. Stop hooks run type checking, linting, related tests before Claude finish. No need ask.

**Day 2+:** Work real tickets. Let hooks catch mistakes. Focus on **clarifying problem** + **reviewing output** -- not writing code yourself. Post wins + failures to team channel.

**Tips that matter:**
- Plan before execute (`/plan`). Engineers who skip spend day untangling misdirected work
- Use `/clear` between unrelated tasks. Long sessions degrade output quality
- If Claude start deleting tests to make CI green -- stop immediately. Red flag
- Use `HOOK_VERBOSITY=terse` for long sessions to reduce token overhead
- Run `verify-install.sh --remote` weekly to check updates (see Verify section above for path)

## Migrating an existing codebase

After install, paste prompt into new Claude Code session to migrate existing code comply with new hooks:

<details>
<summary>Migration prompt (click to expand)</summary>

```
I just installed the frontend-starter-kit skills. Run all setup skills now, then migrate existing code to comply with the new hooks.

## Phase 1: Run setup skills

Execute the frontend-starter-kit skill. This will:
- Install all setup skills (toolchain, biome, quality-gate, etc.)
- Install development-lifecycle skill (the one skill for the full workflow)
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

1. Class components -> functional components
2. useEffect for data fetching -> TanStack Query / route loaders
3. Raw HTML elements (<button>, <input>, etc.) -> @/components/ui/ components
4. as any, as never, as Record<string, any>, @ts-ignore, @ts-expect-error -> proper types, type guards, or zod validation
5. dangerouslySetInnerHTML -> DOMPurify or safe rendering
6. Inline style={{}} -> Tailwind utility classes
7. Raw hex/rgb in className -> design tokens
8. !important -> fix specificity
9. useMemo/useCallback/React.memo -> remove (React Compiler handles it, or add "use memo" in annotation mode)
10. outline: none -> focus-visible:outline-2
11. Barrel imports (import from index files) -> direct path imports
12. addEventListener('scroll') -> add { passive: true }
13. Static imports of chart.js/d3/three -> dynamic import() or React.lazy()
14. React.FC / React.FunctionComponent -> plain function declarations
15. cloneElement -> Context-based composition
16. biome-ignore comments -> fix the lint issue instead
17. import * as Foo -> import { specific } (tree-shaking)
18. export * from -> export specific items (tree-shaking)
19. handleSubmit(onSubmit) -> handleSubmit(onSubmit, onError)
20. navigate(-1) / history.back() -> explicit route path
21. react-beautiful-dnd -> @dnd-kit/core (archived by Atlassian)
22. framer-motion -> motion (renamed package)
23. plotly.js / recharts -> lazy load (heavy bundles)
24. JSON.parse(JSON.stringify(x)) -> structuredClone(x)
25. form.submit() -> form.requestSubmit() (fires validation + submit event)
26. Bare parseInt(s) -> parseInt(s, 10) or Number(s)
27. Global isNaN() -> Number.isNaN() (no coercion)
28. splice/direct mutation to remove -> .filter() or Array.prototype.with()
29. Unnamed useEffect(() => {...}) -> useEffect(function syncX() {...}, [deps]) (named for devtools)
30. 100vh -> 100dvh (mobile safe area), 100vw -> 100%, user-scalable=no -> remove (WCAG 1.4.4)
31. React.lazy() missing for heavy deps (chart.js, three, d3) -> wrap in Suspense + lazy import
32. Hooks defined inside route files -> extract to /hooks/ (route files stay thin)

### 2e-2. Protobuf v2 patterns (if applicable)
1. new Message() -> create(MessageSchema, { ... })
2. PlainMessage/PartialMessage -> MessageShape/MessageInitShape
3. Manual $typeName object literals -> create()
4. Protobuf spreads without create() wrapper -> wrap with create(Schema, { ...msg })

### 2e-3. Connect Query patterns (if applicable)
1. Raw useQuery/useMutation with ConnectRPC -> use Connect Query hooks
2. invalidateQueries() with no args -> specify query key
3. Duplicate Zod schemas for protobuf messages -> Standard Schema + protovalidate
4. Inline staleTime/gcTime numeric literals -> named constants (STALE_TIME_5_MIN, etc.)
5. useMutation without onError -> add onError with ConnectError.from() + toast
6. Mutation hooks missing *Mutation suffix -> rename (useCreateUser -> useCreateUserMutation)
7. refetchQueries -> await invalidateQueries (reactive, deduped)

### 2e-4. Accessibility patterns
1. All `<img>` must have `alt` attribute
2. Clickable `<div>`/`<span>` must have role + tabIndex + keyboard handler
3. Icon-only buttons -> add `aria-label`
4. Interactive elements -> add `data-track` or semantic identifiers for observability
5. `aria-invalid` field -> add `aria-describedby` pointing to error message id
6. Disabled `<Button>` -> wrap in `<Tooltip>` explaining why (blind users need context)
7. `outline: none` / `outline: 0` -> `focus-visible:ring-2 focus-visible:ring-*` (keep keyboard focus visible)
8. Nested interactives (Button inside Link, etc.) -> flatten to single interactive + aria-label

### 2e-5. Protobuf well-known types (if applicable)
1. Timestamp as { seconds, nanos } -> timestampFromDate() from @bufbuild/protobuf/wkt
2. Any without typeUrl -> anyPack() from @bufbuild/protobuf/wkt

### 2f. Zustand stores
Fix create<T>() -> create<T>()(), inline selectors -> useShallow, direct localStorage -> persist.

### 2g. Routing
Fix window.location navigation -> TanStack Router, react-router-dom -> @tanstack/react-router, URLSearchParams -> nuqs, untyped hooks -> { from } param.

### 2h. Testing (vitest + React Testing Library + Playwright)
1. it() -> test() (consistent naming, Biome rule enforces)
2. jest.fn() / jest.mock() / jest.spyOn() -> vi.fn() / vi.mock() / vi.spyOn()
3. .toBeInTheDocument() -> .toBeVisible() (also catches display:none, opacity:0)
4. fireEvent -> userEvent.setup() + user.click() / user.keyboard() (simulates real user)
5. setTimeout / waitForTimeout -> await waitFor(() => expect(...)) (deterministic)
6. Missing data-testid on interactive elements -> add stable test identifiers
7. ConnectRPC calls in tests: raw mocks -> createRouterTransport for typed mocking
8. test.skip in E2E -> test.fixme() (explicit known bug, not silent skip)
9. Co-located .test.ts(x) next to source; visual tests .browser.test.tsx; E2E under e2e/*.spec.ts

### 2i. Forms (react-hook-form)
1. form.watch() in render body -> useWatch({ control, name }) (fewer re-renders)
2. <input {...register("x")} /> losing ref -> spread ...field from Controller
3. handleSubmit(onSubmit) -> handleSubmit(onSubmit, onError) (surfaces validation errors)
4. Async onChange without abort -> AbortController, cancel stale request on next change
5. Form mode undefined -> mode: "onChange" + per-field validation + <FormMessage /> inline
6. FieldMask paths hardcoded -> Object.keys(dirtyFields) (only send what user touched)
7. Oneof protobuf fields: leftover value after branch switch -> clear prev branch explicitly
8. URL input type="text" -> type="url" (native validation + mobile keyboard)

### 2j. ConnectRPC error handling
1. throw new Error("...") in ConnectRPC handlers -> ConnectError.from(error, Code.Internal)
2. Magic numbers for proto enum cases -> import enum, compare by name
3. Error toasts with raw message -> formatToastErrorMessageGRPC(error) (code + message + trace)
4. Catch block with only console.log -> set error state, show inline UI, or re-throw
5. Silent fallbacks on parse failure -> early return <ErrorState /> with retry action
6. Exhaustive switch on enum: missing default -> add `default: never satisfies never` (compile error on new variant)

## Phase 3: Verify

Run bun run quality:gate -- should pass with zero errors.
Run bun run doctor -- score should be 80+.
Commit everything as: refactor(webui): migrate to frontend-starter-kit patterns
```

</details>

Migration ordered from least disruptive (auto-fixable lint) to most disruptive (React pattern rewrites) -- commit incrementally after each phase.

