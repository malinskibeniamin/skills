# This Week in React skills harness opportunities

Date: 2026-07-07
Scope: Issues 280-289, with special check for newer releases after 285. Updated 2026-07-09 with #289 and owner descoping (supply-chain folded into existing skills; framework router dropped).

## Newer newsletters after 285

Found three newer issues after the provided 280-285 set:

- #286, 2026-06-17: React Compiler Rust rollout, React Native 0.86, Biome 2.5, pnpm 11.7, Playwright 1.61.
- #287, 2026-06-24: Fragment refs, React Compiler updates, React Router 8, actions/checkout v7 security.
- #288, 2026-07-01: Next.js 16.3 preview AI improvements, React Router 8.1 agent skills, pnpm 11.8/11.9, TypeScript 7 notes.
- #289, 2026-07-08 (checked on owner request): shadcn/ui defaults to Base UI over Radix, TypeScript 7.0 Go port (10x type-check, `strict: true` default), React Navigation 8.0, React Native 0.87 RC, pnpm 11.10 (CI auth, self-update to Rust v12), ES2026 ratified, HTTP QUERY proposed standard, nuqs adopting npm staged publishing. Nothing in #289 changes the recommendations below: the supply-chain items reinforce finding 1, and the shadcn/Base UI switch is worth a registry-workflow note only when we actually bump shadcn.

## Decision-ready findings

### 1. Supply-chain hardening: fold into existing skills, no new skill

Priority: P1 (descoped per owner feedback -- security-scan territory, not a standing harness concern)

Owner call: no dedicated supply-chain audit skill and no standing workflow scanner. This belongs in the security scan we already run (`/snyk-ux-security`) and in touch-time guidance: when a change touches `.github/workflows/`, bump action versions as part of that change.

Evidence worth keeping:

- `actions/checkout` v7 refuses common `pull_request_target`/`workflow_run` pwn-request patterns; SHA/minor pins do not inherit the floating-major backport. This repo's `.github/workflows/update-agent-native-plan-skills.yml` pins a v4 SHA twice.
- npm v12 will default `allowScripts` off; pnpm 11.8/11.9 add dry-run, tarball integrity, and SBOM support; nuqs (#289) shows staged publishing being adopted in the ecosystem.

Recommended harness change (small):

- Add one paragraph to `/snyk-ux-security`: include GitHub Actions workflow risk (fork-PR checkout under `pull_request_target`, stale action majors) in the sweep.
- Add one line to `/upgrade-dependency`: when a PR touches workflow files, upgrade `actions/*` majors in the same PR unless pinned with a risk comment.
- Bump this repo's own `actions/checkout` pins to v7 next time those workflows change. No `refresh-ci` skill -- overkill for two files.

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

### Dropped: first-party framework skills router (Next.js / React Router)

Cut per owner feedback: this harness does not use Next.js, and a framework-skill router is too specific to hypothetical stacks. TanStack Router remains the enforced router; `read-the-damn-docs` already covers "use the framework's own current docs" generically.

### 2. Modernize React Compiler setup around Rust/lint-first integrations

Priority: P1

Evidence:

- TWiR 285-288 tracks React Compiler Rust moving from PR to real tool integrations.
- Oxlint now has an experimental `react/react-compiler` rule that runs React Compiler analysis in lint-only mode and reports the same diagnostics as `eslint-plugin-react-compiler`.
- Rspack 2.1 supports React Compiler through built-in SWC loader with claimed 7-13x speedup versus Babel in their benchmark.
- Current `setup-react-compiler` is Babel/Rsbuild-centric and its hook activates mainly from `babel-plugin-react-compiler` or generic config grep.

Recommended harness change:

- Update `setup-react-compiler` to split (revised 2026-07-10 for the settled toolchain -- Biome/Ultracite + React Doctor, no standalone Oxlint/ESLint/Prettier):
  - Compiler-friendly coding rules: owned by React Doctor (react-compiler-no-manual-memoization + state-and-effects family); the per-edit react-compiler hook was retired.
  - Lint-only diagnostics: covered by React Doctor's bundled engine -- do not add a second linter.
  - Build transform: choose per bundler; include Rspack/SWC/Bun detection, but mark non-Babel integrations experimental until docs stabilize.

Sources:

- https://thisweekinreact.com/newsletter/285
- https://thisweekinreact.com/newsletter/286
- https://thisweekinreact.com/newsletter/287
- https://thisweekinreact.com/newsletter/288
- https://oxc.rs/docs/guide/usage/linter/rules/react/react-compiler.html
- https://rspack.rs/blog/announcing-2-1
- Local: `setup-react-compiler/SKILL.md`

### 3. Refresh Biome setup for agent output and cross-language checks

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

### 4. Add optional Playwright Test Agents path to E2E setup

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

1. Supply-chain paragraphs in `/snyk-ux-security` and `/upgrade-dependency` (descoped scope above).
2. React Compiler Rust/lint-first setup refresh.
3. Biome 2.5 concise reporter and opt-in cross-language rules.
4. Optional Playwright Test Agents setup note.

## Open grill question

Resolved 2026-07-09: no separate supply-chain PR and no framework-skill router. The remaining items are small enough for one guidance/evals PR.
