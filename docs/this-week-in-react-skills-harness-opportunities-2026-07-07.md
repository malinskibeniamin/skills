# This Week in React skills harness opportunities

Date: 2026-07-07
Scope: Issues 280-288, with special check for newer releases after 285.

## Newer newsletters after 285

Found three newer issues after the provided 280-285 set:

- #286, 2026-06-17: React Compiler Rust rollout, React Native 0.86, Biome 2.5, pnpm 11.7, Playwright 1.61.
- #287, 2026-06-24: Fragment refs, React Compiler updates, React Router 8, actions/checkout v7 security.
- #288, 2026-07-01: Next.js 16.3 preview AI improvements, React Router 8.1 agent skills, pnpm 11.8/11.9, TypeScript 7 notes.

I found no published #289 on thisweekinreact.com as of 2026-07-07.

## Decision-ready findings

### 1. Add supply-chain workflow/release hardening to the harness

Priority: P0

Evidence:

- TWiR repeatedly flags supply-chain incidents and mitigations: the TanStack npm compromise, Mini Shai-Hulud follow-on compromises, staged publishing, npm v12 script blocking, actions/checkout v7, and pnpm SBOM/integrity work.
- GitHub says `actions/checkout` v7 refuses common `pull_request_target`/`workflow_run` pwn-request patterns; SHA/minor pins do not receive the floating-major backport.
- GitHub says npm v12 will default `allowScripts` off and `--allow-git` / `--allow-remote` to `none`.
- pnpm 11.8 adds install dry-run and package-map generation; pnpm 11.9 adds missing tarball-integrity computation and SBOM peer exclusion.
- Current repo already has dependency-upgrade guidance for min release age, script disabling, git/tarball blocking, and lockfile review, but no deterministic workflow scanner or release-publish staged-publishing workflow.
- Current repo workflow `.github/workflows/update-agent-native-plan-skills.yml` uses pinned `actions/checkout` v4 SHA twice, so it will not automatically inherit the v7/backported protection.

Recommended harness change:

- Add a focused supply-chain/workflow audit skill or extend `setup-ci-pipeline` plus `upgrade-dependency`.
- Add eval-backed checks for:
  - `pull_request_target` or privileged `workflow_run` combined with fork PR checkout.
  - `actions/checkout` pinned below v7 without explicit risk comment or upgrade plan.
  - npm release flows that do not mention staged publishing or `allowScripts` review.
  - pnpm repos that do not use dry-run/SBOM/integrity checks during dependency changes.
- Keep as audit/nudge first, not broad blocking, to avoid false positives.

Sources:

- https://thisweekinreact.com/newsletter/281
- https://thisweekinreact.com/newsletter/282
- https://thisweekinreact.com/newsletter/283
- https://thisweekinreact.com/newsletter/285
- https://thisweekinreact.com/newsletter/287
- https://thisweekinreact.com/newsletter/288
- https://github.blog/changelog/2026-06-18-safer-pull_request_target-defaults-for-github-actions-checkout/
- https://github.blog/changelog/2026-05-22-staged-publishing-and-new-install-time-controls-for-npm/
- https://github.blog/changelog/2026-06-09-upcoming-breaking-changes-for-npm-v12/
- https://pnpm.io/blog/releases/11.8
- https://pnpm.io/blog/releases/11.9

### 2. Prefer first-party framework skills/local docs instead of static local clones

Priority: P0/P1

Evidence:

- Next.js 16.3 auto-manages AGENTS.md pointers to version-matched docs, adds first-party workflow skills, agent-browser React introspection, structured agent-readable errors, and markdown docs endpoints.
- React Router 8.1 makes the official React Router Agent Skill default-on in `create-react-router --yes` / non-interactive setup, with `--no-agent-skills` opt-out.
- Current repo has no `setup-nextjs` or `setup-react-router` skill, and `setup-tanstack-router` intentionally bans `react-router-dom` only when installing TanStack Router.

Recommended harness change:

- Add a tiny framework-skill router, not a big new wrapper:
  - If Next.js detected, tell agent to read local `node_modules/next/dist/docs/`, respect managed AGENTS.md blocks, and optionally install/use first-party `next-dev-loop`, `next-cache-components-adoption`, or `next-cache-components-optimizer`.
  - If React Router detected, install/use official `remix-run/agent-skills` or generated project skills rather than inventing local docs.
  - If TanStack Router detected, keep using our existing stricter `setup-tanstack-router` rules.
- Add this as routing text in `ask-ben`, `frontend-starter-kit`, and `read-the-damn-docs`; avoid new public setup wrappers unless the evals show a real gap.

Sources:

- https://nextjs.org/blog/next-16-3-ai-improvements
- https://reactrouter.com/changelog
- https://github.com/remix-run/agent-skills
- Local: `setup-tanstack-router/SKILL.md`

### 3. Modernize React Compiler setup around Rust/lint-first integrations

Priority: P1

Evidence:

- TWiR 285-288 tracks React Compiler Rust moving from PR to real tool integrations.
- Oxlint now has an experimental `react/react-compiler` rule that runs React Compiler analysis in lint-only mode and reports the same diagnostics as `eslint-plugin-react-compiler`.
- Rspack 2.1 supports React Compiler through built-in SWC loader with claimed 7-13x speedup versus Babel in their benchmark.
- Current `setup-react-compiler` is Babel/Rsbuild-centric and its hook activates mainly from `babel-plugin-react-compiler` or generic config grep.

Recommended harness change:

- Update `setup-react-compiler` to split:
  - Compiler-friendly coding rules: current hooks remain useful.
  - Lint-only diagnostics: recommend Oxlint `react/react-compiler` where projects can tolerate an extra linter.
  - Build transform: choose per bundler; include Rspack/SWC/Oxc/Bun/Next detection, but mark non-Babel integrations experimental until docs stabilize.
- Add evals proving the hook detects React Compiler when enabled via Rspack/SWC/Oxc/Next/Bun, not only `babel-plugin-react-compiler`.

Sources:

- https://thisweekinreact.com/newsletter/285
- https://thisweekinreact.com/newsletter/286
- https://thisweekinreact.com/newsletter/287
- https://thisweekinreact.com/newsletter/288
- https://oxc.rs/docs/guide/usage/linter/rules/react/react-compiler.html
- https://rspack.rs/blog/announcing-2-1
- Local: `setup-react-compiler/SKILL.md`

### 4. Refresh Biome setup for agent output and cross-language checks

Priority: P1

Evidence:

- Biome 2.5 adds cross-language CSS class rules, plugin code fixes, watch mode, `linter.rules.preset`, and a `concise` reporter explicitly positioned for coding agents to save tokens.
- Current `setup-biome` already uses Ultracite, import organization, restricted imports/elements, and several nursery/project rules, but does not mention `--reporter=concise`, `linter.rules.preset`, or opt-in cross-language CSS rules.

Recommended harness change:

- Add `--reporter=concise` to agent-facing lint commands where Biome >= 2.5 is installed.
- Update the reference config from deprecated `recommended` shape to `linter.rules.preset` when relevant.
- Consider opt-in `noUndeclaredClasses` / `noUnusedClasses` only for projects with static CSS imports; avoid defaulting it on Tailwind-heavy codebases because dynamic utility classes may create noise.

Sources:

- https://thisweekinreact.com/newsletter/286
- https://biomejs.dev/blog/biome-v2-5/
- Local: `setup-biome/REFERENCE.md`

### 5. Add optional Playwright Test Agents path to E2E setup

Priority: P2

Evidence:

- Playwright official docs now include planner, generator, and healer Test Agents, regenerated with `init-agents` whenever Playwright is updated.
- Current `setup-e2e-testing` already has strong Playwright conventions, axe fixtures, route sibling tests, and agent-browser guidance, but does not mention official Test Agents.

Recommended harness change:

- Add an optional section to `setup-e2e-testing`: when user asks to generate or heal Playwright coverage, run `bunx playwright init-agents --loop=codex` or `--loop=claude` according to the agent, then use planner -> generator -> healer.
- Keep it opt-in, not default CI surface. The current minimal E2E setup is still the right default.

Sources:

- https://playwright.dev/docs/test-agents
- Local: `setup-e2e-testing/SKILL.md`

## Explicit non-recommendations

- Do not vendor the full Next.js or React Router skill bodies into this repo right now. Their point is version-coupled, first-party context.
- Do not add Meticulous/Drizz/AI-visual-test SaaS flows to the core harness from newsletter sponsor links alone. Our existing visual-review plus browser-test hooks already cover the principle without adding a paid dependency.
- Do not switch the project from Bun to pnpm just because pnpm has new package-map/SBOM features. Use pnpm-specific guidance only when the target repo already uses pnpm.
- Do not enable React Compiler build transforms globally. Use lint-first checks and per-bundler docs until Rust integrations stabilize.

## Suggested implementation order

1. Supply-chain workflow audit + release hardening evals.
2. Framework skill router for Next.js and React Router first-party skills/local docs.
3. React Compiler Rust/lint-first setup refresh.
4. Biome 2.5 concise reporter and opt-in cross-language rules.
5. Optional Playwright Test Agents setup note.

## Open grill question

Do we want this as one small PR containing only guidance/evals, or split supply-chain hardening into its own PR before the framework-skill-router work?
