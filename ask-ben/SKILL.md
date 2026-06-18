---
name: ask-ben
description: Router for Ben's frontend-skills harness and every local skill.
disable-model-invocation: true
---

# Ask Ben

Repo/code changes: run `/deslop` before commit, push, PR, or merge.
Use this when you forget which local skill fits Ben's work. Default lens: ship frontend/React/TypeScript/Go changes and skills repo releases with enforced TDD, review, resilience, visual proof, PR, CI, and installable plugin surfaces.

## Fast routes

- Building or fixing product code -> `/development-lifecycle` or `/work`.
- Implementation done -> `/go`.
- Hard bug -> `/diagnosing-bugs` first, then `/tdd`.
- Plan unclear -> `/grill-with-docs`; no repo/docs needed -> `/grill-me`.
- Architecture cleanup -> `/improve-codebase-architecture`; broad advisor scan -> `/improve`.
- PR or diff review -> `/review`; high stakes -> `/thermo-nuclear-code-quality-review`.
- UI/customer-facing -> `/visual-review`; edge cases/errors -> `/resilience-review`.
- Too much code -> `/deslop`, `/ponytail-review`, `/ponytail-audit`, `/ponytail-debt`, `/ponytail`.
- Issue/PRD flow -> `/to-prd`, `/to-issues`, `/triage`, `/resolve-pr-feedback`.
- Setup a frontend repo -> `/frontend-starter-kit`; Redpanda repo -> `/redpanda-frontend-kit`.
- Need exact repo state -> `/prime`; hand off context -> `/handoff`; parallelize -> `/swarm`.

| Skill | What Ben uses it for |
|---|---|
| `/aip` | Google AIP-style protobuf/resource API design. |
| `/ask-ben` | This router: explains all local skills and routes work. |
| `/brainstorming` | Explore/challenge design options before code. |
| `/codebase-design` | Deep-module vocabulary: interface, seam, adapter, depth. |
| `/codex-compat` | Generate Codex hooks/AGENTS parity from Claude hooks. |
| `/commit-push` | Conventional commit plus push, no PR. |
| `/commit-push-pr` | Commit, push, draft/ready PR, watch CI. |
| `/design-an-interface` | Deprecated interface-design flow; prefer `/prototype`. |
| `/deslop` | Liability gate: delete, inline, justify, verify. |
| `/development-lifecycle` | Main frontend work loop: understand -> plan -> grill -> TDD -> ship. |
| `/diagnosing-bugs` | Feedback-loop-first bug/perf diagnosis. |
| `/domain-model` | Legacy DDD grill; prefer `/grill-with-docs`. |
| `/domain-modeling` | Maintain CONTEXT.md terms and ADRs. |
| `/edit-article` | Tighten article drafts. |
| `/extend-harness` | Add/tune hook-harness rules and severity. |
| `/frontend-skills-stats` | Inspect hook latency, violations, zero-fire rules. |
| `/frontend-starter-kit` | Install complete generic frontend harness. |
| `/git-guardrails-claude-code` | Install dangerous-git command blockers. |
| `/go` | Ship tail: verify, review, deslop, PR, CI. |
| `/grill-me` | Stateless relentless plan/design interview. |
| `/grill-with-docs` | Plan grill plus domain docs and ADR updates. |
| `/grilling` | Reusable model-invoked interview loop. |
| `/handoff` | Compact context into a continuation file. |
| `/hook-audit` | Audit hook usefulness and session telemetry. |
| `/implement` | Execute a PRD/issue with `/tdd` where possible. |
| `/improve` | Senior advisor scan and implementation plans. |
| `/improve-codebase-architecture` | Visual deepening report plus architecture grill. |
| `/migrate-to-shoehorn` | Replace test casts with `@total-typescript/shoehorn`. |
| `/obsidian-vault` | Search/create/organize Obsidian notes. |
| `/ponytail` | Build least-code solution via reuse-first ladder. |
| `/ponytail-audit` | Whole-repo overengineering audit. |
| `/ponytail-debt` | Harvest `ponytail:` shortcut debt. |
| `/ponytail-review` | Diff review for delete/stdlib/native/YAGNI only. |
| `/prime` | Repo startup/resume brief. |
| `/prototype` | Throwaway logic/UI prototype to answer design risk. |
| `/qa` | Deprecated bug intake; prefer `/triage`. |
| `/redpanda-frontend-kit` | Frontend starter kit plus Redpanda registry workflow. |
| `/request-refactor-plan` | Deprecated refactor planner; prefer architecture + issues. |
| `/resilience-review` | Edge cases, errors, fallback, recovery, polish. |
| `/resolve-pr-feedback` | Fetch, fix, reply, resolve PR review threads. |
| `/resolving-merge-conflicts` | Resolve merge/rebase conflicts from primary sources. |
| `/review` | Multi-hat diff/PR review across standards/spec/risk. |
| `/scaffold-exercises` | Course exercise directories and stubs. |
| `/setup-accessibility` | ARIA/a11y hooks and tests. |
| `/setup-agent-config` | Token-saving agent env, flags, truncation. |
| `/setup-atlassian-workflow` | Jira/acli workflow integration. |
| `/setup-biome` | Biome/Ultracite lint-format setup. |
| `/setup-ci-pipeline` | GitHub Actions quality/coverage/visual CI. |
| `/setup-connect-query` | ConnectRPC, Connect Query, protobuf v2 enforcement. |
| `/setup-conventional-commits` | Conventional commit hook setup. |
| `/setup-e2e-testing` | Playwright/Testcontainers/axe e2e setup. |
| `/setup-env-validation` | t3-env/zod env validation. |
| `/setup-matt-pocock-skills` | Configure tracker/labels/domain docs for Matt-derived flows. |
| `/setup-pre-commit` | Husky/lint-staged/pre-commit setup. |
| `/setup-quality-gate` | Local/CI quality:gate and Stop typecheck. |
| `/setup-react-compiler` | React Compiler setup and anti-manual-memo rules. |
| `/setup-react-doctor` | React health score Stop gate. |
| `/setup-react-rules` | React/TS/security component rules. |
| `/setup-registry-workflow` | Component registry drift and taxonomy workflow. |
| `/setup-routines` | Claude cloud routines for recurring automation. |
| `/setup-sandcastle` | Sandcastle parallel/headless agent delegation. |
| `/setup-tanstack-router` | TanStack Router generation and enforcement. |
| `/setup-toolchain` | Bun/tsgo toolchain and destructive-command guardrails. |
| `/setup-ux-copy` | UX copy, inclusive language, docs prose style. |
| `/setup-zustand` | Zustand create/useShallow/persist enforcement. |
| `/snyk-ux-security` | JS/Go/Bazel Snyk sweep with reachability gates. |
| `/steelman` | Evidence-backed strongest counterargument. |
| `/swarm` | Parallel executor with coordinator-owned merge. |
| `/tdd` | Red-green-refactor one vertical slice at a time. |
| `/teach` | Stateful teaching workspace. |
| `/thermo-nuclear-code-quality-review` | Release-blocking cold audit. |
| `/to-issues` | Turn PRD/plan into vertical-slice tracker issues. |
| `/to-prd` | Turn conversation into PRD. |
| `/triage` | Move incoming issues through readiness states. |
| `/ubiquitous-language` | Deprecated domain-language skill; prefer `/grill-with-docs`. |
| `/upgrade-dependency` | Safe dependency upgrade plan and PR/issue path. |
| `/visual-review` | Customer-facing UX review with evidence. |
| `/work` | Alias for `/development-lifecycle`. |
| `/work-automation-kit` | Install planning/PRD/triage workflow skills. |
| `/writing-beats` | Draft article beat by beat. |
| `/writing-fragments` | Mine conversation into writing fragments. |
| `/writing-great-skills` | Write/edit predictable low-no-op skills. |
| `/writing-shape` | Shape raw markdown into an article. |
