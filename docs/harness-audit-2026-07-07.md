# Harness audit — 2026-07-07

Five-agent audit of every skill (95), wired hook (98 / 108 scripts), and agent definition (9) in the
frontend-skills plugin. Verdicts: 76 keep, 36 trim, 16 rewrite, 53 merge, 26 delete, 4 demote across
211 items. Wave 1 was applied in the same session (see `x-changelog` 4.27.0); waves 2–4 below are the
remaining roadmap. The per-item verdict table is at the bottom.

## The thesis

The harness's enforcement architecture is genuinely good — severity tiers, payload-diff added-lines,
session-scoped Stop gating, escape hatches, JSONL telemetry, and a generated-config drift guard are
better engineering than most published harnesses. The problem is **accretion without a retention
policy**: three vendored skill packs were merged on top of the original harness without pruning, every
rule got restated in 3–4 places (CLAUDE.md, hook nudges, skill bodies, README), and one-shot setup
actions occupy permanent context slots. The fix is not more content — it is deletion, merging, and
moving static text out of the per-session/per-prompt hot path.

## Cost model (why this matters for any model)

1. **System-prompt tax**: every model-invoked skill's description is injected into *every* session.
   At 95 skills that was ~17KB (≈4–5k tokens) before the first user message. Target: <60 model-invoked
   descriptions. `disable-model-invocation: true` keeps a slash command working at zero context cost —
   it is the single cheapest lever in the repo.
2. **Per-prompt injection tax**: `intent-detect` + `user-prompt-context` fired ~350 tokens of
   CLAUDE.md restatement on nearly every implementation prompt (~2–4k tokens per 20-turn session).
   Rule of thumb now encoded in the hook: *inject only what the model cannot already know* —
   branch state, PR numbers, installed tools, once-per-session markers.
3. **Per-edit latency tax**: 56 sequential PostToolUse processes per Edit/Write, each sourcing a 27KB
   lib that spawned python3 *at source time* (~30–60ms × 56 before any check ran) — multi-second wall
   clock per edit. Wave 1 removed the interpreter spawn; wave 2 collapses the 56 scripts into ~8
   family dispatchers (parse stdin once, gate by path once, run rule functions in-process).
4. **Skill-chaining tax**: a full `/work` run mandated 15–25 skill-load round trips
   (work → ponytail → development-lifecycle → grill-with-docs → grilling → domain-modeling → tdd →
   go → simplify → ponytail-review → deslop → visual-review → visual-recap → make-pr-easy-to-review →
   commit-push-pr → quick-recap …). Each hop is a tool call plus a SKILL.md load. Composition should
   be *advisory routing*, with only two hard gates (approval before code, grill before implementation)
   plus hook-enforced ship checks.

## Good / Bad / Ugly

### Good (patterns to keep and extend)

- **Progressive disclosure done right**: `triage`, `visual-plan`, `codebase-design`, `commit-push-pr`
  keep SKILL.md as routing + mandatory workflow and push bulk into reference files loaded on demand.
- **Hook-backed enforcement instead of prose**: `resolve-pr-feedback` + `pr-feedback-completeness-stop`
  + `pr-unresolved-count.sh` — the skill stays short because the hook carries the guarantee.
- **Institutional knowledge the model cannot rederive**: GraphQL-only `reviewThreads.isResolved`,
  tree-identity verification after history rewrite, the AIP proto suite, TanStack loader/Query cache
  ownership split.
- **`skill-manifest.json` as generated single source of truth** with a lefthook `--check` drift guard.
  Under-applied: it should also generate the README catalog, the ask-ben table, AGENTS.md, and count
  strings.
- **ETHOS.md maps each principle to the hooks that enforce it** — values with receipts.
- **Gated expensive agents**: `adversarial-reviewer` computes diff size and security-path match before
  doing any work and emits a structured SKIPPED block.
- **`bash-verbose-guard`'s self-pruning comment** documenting nudges removed after ROI measurement —
  the retention discipline the whole harness needs.

### Bad (systemic anti-patterns)

- **The same rule in 3–4 places**: CLAUDE.md ∩ hook nudge ∩ skill body ∩ README. Every restatement is
  paid per session and drifts independently. One rule, one enforcement point.
- **Skills mandating other skills**: `review` decreed an 8-hat fan-out on every diff ("never skip due
  to token budget") and thermo-nuclear itself invokes `/review` — circular ceremony. `snyk` mandated 5
  internal skill gates per path; `improve` routes through 11 skills.
- **Near-duplicate pairs paying two description slots**: commit-push/commit-push-pr (~80% shared, both
  carried the same copy-paste bug), handoff/claude-handoff, efficient-fable/efficient-frontier,
  weekly-review/what-did-i-get-done, research/read-the-damn-docs, three grill variants, four ponytails.
- **21 one-time `setup-*` skills each holding a permanent description slot**, several of which hide
  daily-work runtime guidance behind a "setup" trigger the model will never fire during daily work.
- **Catalog hand-maintained in three places** (descriptions, README, ask-ben) — already showing
  drift and copy-paste corruption.
- **93 eval files with zero CI wiring** — they project confidence they do not earn and rot silently.

### Ugly (defects fixed or flagged)

- `test-warning-check.sh` **hard-blocked the audit itself twice**: `*lint*`/`*tsc*` substring command
  matching fired on file reads, then grepped arbitrary output for the word "warning", with a
  deliberately removed escape hatch. A misfiring, un-overridable block is the most corrosive artifact
  a harness can ship — it trains the model to distrust and route around hooks. *Fixed in wave 1*
  (command-word gating, 21-case regression test in the fix commit).
- `perf-regression-stop.sh` **booted a dev server and ran Lighthouse inside a Stop hook** — minutes of
  wall clock at the moment the session should end. *Deleted; perf budgets live in CI.*
- `obsidian-vault` hardcoded a WSL mount (`/mnt/d/…`) on a darwin machine; `scaffold-exercises` ran
  `pnpm ai-hero-cli`, which the harness's own toolchain hook blocks; `setup-pre-commit` installed
  Husky+Prettier while `setup-conventional-commits` advertises "Replaces commitlint + husky entirely";
  `git-guardrails-claude-code` blocked `git push`, breaking the flagship commit skills. *All deleted.*
- The `/deslop` preamble stamped into **94 of 95 SKILL.md files** — ~95 copies of one hook-enforced
  rule, violating the repo's own `writing-great-skills` single-source-of-truth principle. *Stripped.*
- **MCP self-contradiction**: CLAUDE.md bans MCP ("MCP banned → CLI") while `visual-plan`/`visual-recap`
  hard-require the Builder.io Plan MCP server, whose injected tool schemas are the largest MCP payload
  in the session. *Unresolved — owner decision required (see wave 2).*
- `lifecycle-stop` blocks session termination until a PR exists **and a reviewer is assigned**,
  prescribing `gh pr create --fill NOW` — the harness forcing junk PRs into existence so you can stop
  working. *Flagged, not changed: deliberate ETHOS design; recommend demoting steps 2–5 to warn.*

### Rejected findings (verified false)

- "tdd/REFERENCE.md is corrupted" — inspected: 56 balanced code fences, 15 well-formed sections. The
  auditor misread dense code blocks. No repair needed.

## Wave 1 — applied (v4.27.0)

- Deleted 12 skills: `obsidian-vault`, `scaffold-exercises`, `setup-pre-commit`,
  `git-guardrails-claude-code`, `teach`, `migrate-to-shoehorn`, `implement`, `loop-me`, `research`,
  `weekly-review`, `efficient-fable`, `quick-recap` — after porting unique content into
  `what-did-i-get-done` (weekly mode), `read-the-damn-docs` (durable-artifact path), `go` (status
  line), `efficient-frontier` (Fable trigger).
- Stripped the `/deslop` preamble from all SKILL.md files; deleted the eval that enforced it.
- `work`, `writing-beats`, `writing-fragments`, `writing-shape`, `edit-article` →
  `disable-model-invocation: true` (slash commands keep working; zero context tax).
- Unwired + deleted 3 Stop hooks: `architecture-review-stop` (third pass over territory owned by
  per-edit hooks), `perf-regression-stop` (Lighthouse in a Stop hook), `cache-telemetry-stop`
  (answered a one-time cache-policy question).
- Fixed `test-warning-check` command gating (command-word matching; verified against 21 cases).
- Replaced the python3-at-source-time timer in both hook-lib copies with `EPOCHREALTIME`
  (removes ~56 interpreter spawns per edit).
- Rewrote `intent-detect.sh` to dynamic-context-only; rewrote `orchestration-guidance.sh` to
  tracking-only (its guidance strings duplicated CLAUDE.md; its 13 REDPANDA_KIT nudges cat+grepped the
  whole file ~15× per edit).
- Purged stale references: `/ultraplan`, `/codex:rescue`, `/goal`, duplicated
  `improve-codebase-architecture` review rows, all references to deleted skills across skills, evals,
  README, and manifests. Counts regenerated: 83 skills, 95 wired hooks, 104 scripts.

## Wave 2 — consolidation (largely applied in the same PR)

Applied in this PR: 11 low-value per-edit pattern hooks deleted (partial item 1 — the
family-dispatcher packaging rewrite itself remains); review stack collapsed (thermo-nuclear →
`/review --deep`, mandatory 8-hat fan-out → evidence-triggered lanes, recursion forbidden);
ponytail 4 → 1 (debt ledger into ponytail, complexity tags into deslop); stay-within-limits →
efficient-frontier; claude-handoff → handoff; frontend-skills-stats → hook-audit; commit-push →
zero-context alias of commit-push-pr; karpathy-failure-modes split into ~6KB core + lazy MAST
reference; findings-schema.md moved to agents/references/; shared review-evidence reference
extracted; hardcoded `git diff HEAD~1` base replaced with `${REVIEW_BASE:-merge-base}` in all
reviewer agents. Surface after wave 2: 76 skills, 84 wired hooks, 93 scripts, 7 registered agents.

Remaining (original wave-2 list; unapplied items are 1's dispatcher packaging, 4, 5, 7, 8, 10):

1. **Hook dispatcher rewrite (highest ROI)**: collapse the 56 Edit/Write PostToolUse scripts into ~8
   family passes (react-ui, router, forms, connect/query, tests, styling/copy, ts-escape-hatches,
   security/meta): parse stdin once, compute added_lines once, gate by path at the top, run rule
   functions in-process. Target <100ms per edit. The lib's severity tiers/telemetry already support
   this — only the packaging is wrong. Fold in the per-script merge verdicts from the table below
   (for example the 4 connect-error scripts → connect-query family, 5 form scripts → forms family) and
   delete the low-value pattern hooks (`tdd-prompt-check`, `url-state-check`, `unhappy-path-check`,
   `resilience-review-nudge`, `magic-number-check`, `duplicate-function-check`,
   `zustand-subscription-check`, `mutation-naming-check`, `structural-test-nudge-check`,
   `route-sibling-test-check`, `route-visual-test-check`).
2. **Review stack collapse**: one entry point. `/review` gets evidence-triggered optional lanes;
   thermo-nuclear becomes its `--deep` mode; built-in `/code-review` + `/security-review` own generic
   passes. Remove "never skip due to token budget" decrees. Fix the hardcoded `git diff HEAD~1` base
   in all reviewer agents (accept a base ref; default merge-base with main).
3. **Ponytail family 4 → 1–2**: keep `ponytail` (absorb debt harvest); fold review/audit tag taxonomy
   into `deslop`.
4. **Grill family 3 → 1**: `grilling` is the primitive; fold grill-with-docs' domain-awareness in as a
   mode; move grill-me's 3-hat fan-out spec into development-lifecycle's 2b section. One owner for the
   Phase 2b gate.
5. **Setup consolidation 21 → ~6**: pure installers (toolchain, biome, quality-gate, agent-config,
   conventional-commits, env-validation, react-compiler, react-doctor, zustand, redpanda-frontend-kit)
   fold into `frontend-starter-kit` taking a profile argument, each tool's SETUP.md read lazily.
   The six hybrids whose real value is runtime guidance (accessibility, tanstack-router,
   connect-query, e2e-testing, registry-workflow, ux-copy) drop the `setup-` prefix and get
   daily-work trigger descriptions (path triggers already point there).
6. **commit-push → commit-push-pr** (one skill, no-PR path), **claude-handoff → handoff**,
   **stay-within-limits → efficient-frontier**, **frontend-skills-stats → hook-audit**.
7. **Resolve the MCP contradiction**: either write a documented, token-measured exemption for the
   Plan MCP server into CLAUDE.md, or drop visual-plan/visual-recap. Do not leave both.
8. **development-lifecycle rewrite**: sub-skill invocations become advisory one-liners except the two
   real gates; inline the phase table; drop the ceremony a senior engineer bypasses.
9. **karpathy-failure-modes.md**: split into a ~4KB required core + lazy MAST reference; move
   `findings-schema.md` out of `agents/` (it is a schema, not a dispatchable agent); extract the
   duplicated Resilience/Visual evidence paragraphs from code-reviewer/self-reviewer into one shared
   reference.
10. **lifecycle-stop**: keep steps 0–1 (test/coverage gate, uncommitted-session-files gate); demote
    PR-exists/CI/reviewer-assigned steps to warn. Move network-calling Stop hooks
    (`pr-feedback-completeness-stop`, `ci-warning-audit`) into `/go` or env-gate them.

## Wave 3 — generation & CI

- Extend `generate-hook-configs.sh` to emit the README skills catalog, the ask-ben routing table
  (only `disable-model-invocation` skills — the model routes the rest), AGENTS.md, and plugin count
  strings from one source. Kill all hand-maintained catalog copies.
- Wire `evals/run.sh` into a GitHub Actions PR workflow; delete evals that cannot pass today; add a CI
  check that every `/skill-name` mentioned in any SKILL.md resolves to an existing skill dir.
- Rule-retention policy via existing telemetry: any warn/nudge rule with zero fires (or >90%
  escape-hatch rate) over 30 days gets auto-flagged for deletion by `hook-audit`.
- One hook-lib copy, one sourcing convention (retire the `source-hook-lib.sh` dangling-symlink shim
  and the `shared/` + `.claude/hooks/` manual mirroring).

## Wave 4 — distribution hygiene

- README 1460 → ~300 lines: install, architecture, when-not-to-use; demo/FAQ/marketing move to docs/;
  catalog becomes generated.
- Move `docs/screenshots` (31MB) out of git history (filter-repo + release assets or LFS) while the
  consumer base is small — every plugin install clones it.
- Deduplicate the rule sources: one canonical rule pack generating project CLAUDE.md (repo deltas
  only), the global CLAUDE.md, and AGENTS.md — in this repo the near-identical global and project
  files are both injected, paying most rules twice per session, and AGENTS.md has already drifted.
- Split personal skills (writing family) out of the published marketplace listing into a personal
  skills layer.

## Per-item verdicts

Full reasoning per item, from the five audit agents (verdicts on deleted items are retained for the
record; wave-1 items are marked by the changelog).

### Core workflow skills

| Item | Verdict | Confidence | Reasoning |
|---|---|---|---|
| `work` | **delete** | high | Pure alias wrapper. Its entire body is 'run /ponytail full, then /development-lifecycle' -- two extra skill-load round trips before any real content. |
| `development-lifecycle` | **rewrite** | high | The spine concept is sound (understand -> plan -> grill -> TDD -> ship) and phases align with hook enforcement, but execution is bloated with mandatory sub-skill fan-out: a full run mandates or suggests /ponytail, /resilience-review, /prototype, /grill-with-do… |
| `go` | **trim** | high | The ship tail earns its slot: verify commands are concrete, hook integration (pr-feedback-completeness-stop) is real, entry gate and CI-monitor discipline are genuinely useful. |
| `tdd` | **trim** | high | Strongest skill in the partition: iron law, seams, tautological-test and horizontal-slice anti-patterns, tracer bullets, Monitor-driven watch loop -- this is content a frontier model actually drifts on without enforcement, and the paths: frontmatter targets it… |
| `implement` | **delete** | high | 19 lines that say: use /tdd, run /read-the-damn-docs if the spec cites APIs, run typechecks, use /review, commit. Every sentence is already covered by development-lifecycle phase 3 and tdd itself. |
| `grill-me` | **merge → `development-lifecycle`** | high | Its only unique content is the three-hat fan-out (product/engineering/design reviewer agents) and the plan-arbiter escalation. |
| `grilling` | **keep** | high | The core primitive, 14 lines, near-perfect: one question at a time, recommended answer each, look up facts yourself but put decisions to the user, no enactment until shared understanding. This is exactly what a compact behavioral skill should look like. |
| `grill-with-docs` | **merge → `grilling`** | high | It is /grilling plus 'run /domain-modeling inline' plus CONTEXT.md/ADR housekeeping guidance. The glossary-challenge and ADR-sparingly sections are good content but they are a mode of grilling, not a separate skill -- and domain-modeling already owns the CONTE… |
| `brainstorming` | **trim** | medium | Compact and useful: design mode (propose 2-3 approaches) is distinct from grilling (interview the user), and the gate is real. |
| `prime` | **keep** | high | Genuinely valuable session-bootstrap behavior: untrusted-seed discipline, read-only-highest-signal-files rule, explicit 'no full CLAUDE.md/README dumps' -- this fights real context waste and the model does not do it natively. |
| `commit-push` | **merge → `commit-push-pr`** | high | ~80% identical to commit-push-pr: same context gathering, same phase 0 review-gate, same branch strategy, same categorized-commit procedure, same safety rules. The only delta is stopping before PR creation. |
| `commit-push-pr` | **trim** | high | The canonical ship command and the right survivor of the merge. Categorized conventional commits, explicit-path staging, --fill-verbose PR, auto-labels, mandatory CI watch via Monitor -- all real value wired to the user's actual workflow. |
| `resolve-pr-feedback` | **keep** | high | Earns its slot completely: the GraphQL reviewThreads gotcha (REST cannot see isResolved) is non-obvious institutional knowledge, the triage table prevents re-answering addressed threads, the completeness hook + pr-unresolved-count.sh wiring makes 'address ALL … |
| `resolving-merge-conflicts` | **keep** | high | 17 lines of high-leverage discipline: find primary sources per conflict (commits/PRs/issues), preserve both intents, never --abort, run project checks, finish the rebase. |
| `make-pr-easy-to-review` | **keep** | high | Cursor kit vendored, and it is good: the tree-identity verification pattern (ORIGINAL_TREE vs post-rewrite tree) for safe history rewriting is a concrete technique the model will not invent reliably, dependency-ordered commit grouping is sound, and the 'recomm… |
| `handoff` | **keep** | high | The file-based handoff with template, redaction rules, and 'reference artifacts by path, do not restate' discipline is a real workflow the model otherwise fumbles (it dumps whole transcripts). Compact, human-invoked, no reference-file bloat. |
| `claude-handoff` | **merge → `handoff`** | high | Same skill with a different sink: instead of writing a file, it launches `claude --bg` seeded with the summary. The summary-authoring rules (redact, reference-not-restate, suggested skills) are copy-pasted from handoff. |
| `loop-me` | **delete** | high | Mattpocock's personal life-automation tool: grill the user about recurring 'loops' in their life and write workflow specs to a workflows/*.md workspace. |
| `plow-ahead` | **trim** | high | The autonomy contract is genuinely useful -- crisp decision rules and a correct true-blocker list that stops the model from either over-asking or bulldozing irreversible actions. |
| `swarm` | **rewrite** | high | The description is embarrassing ('parallel executor. Use /swarm.') -- worthless for model-side selection. The Position section references /goal, a skill that does not exist. |
| `wizard` | **keep** | high | One of the best-designed skills in the harness: the 8.7KB template.sh carries all the UX machinery (progress, secret entry, .env upserts, gh secret writes, WSL-aware URL opening) so the SKILL.md is pure scoping process, and the 'never invent dashboard steps --… |
| `quick-recap` | **merge → `go`** | high | An entire skill -- with a references/ dir -- to say 'end with a 🟢/🟡/🔴 status line under 100 chars'. The convention is fine; the packaging is absurd. |
| `prototype` | **keep** | high | Well-factored: the branch decision (logic vs UI) sits in a 35-line SKILL.md and the heavy per-branch guidance loads lazily from LOGIC.md/UI.md. |
| `plan-arbiter` | **trim** | medium | The skill itself is compact and the Adopt/Hybrid/Revise-first verdict plus tie-breaker ordering gives structure a raw model comparison lacks. |

### Review & quality skills + agents

| Item | Verdict | Confidence | Reasoning |
|---|---|---|---|
| `review` | **rewrite** | high | The Standards/Spec axis split, PR-comment discipline, and priority mapping are genuinely good. But the mandatory 8-hat fan-out on EVERY review (ponytail, thermo-nuclear, resilience, regular, adversarial, visual, test-perf, security) with 'never skip due to tok… |
| `deslop` | **trim** | high | The owner's signature gate, wired into CLAUDE.md lifecycle and every hook — it stays. But its Inputs section tells you to run /simplify, /ponytail-review, /ponytail-audit, AND /ponytail-debt before doing its own job: four skill invocations of indirection for w… |
| `ponytail` | **keep** | high | Distinct persistent authoring mode (writes less code), not a review — no built-in covers a sticky YAGNI persona with intensity levels and the ponytail: shortcut-marker convention. Terse, well-written, cheap, vendored with provenance. |
| `ponytail-review` | **merge → `deslop`** | high | Pure overlap: deslop already invokes it as step 2, built-in /simplify covers the same 'shrink/inline/stdlib' ground, and /review runs it as a mandatory hat. |
| `ponytail-audit` | **merge → `deslop`** | high | It is literally described as 'repo-wide /ponytail-review' — a scope flag, not a skill. /improve already owns repo-wide audits and invokes this too. Fold as a repo-wide mode of deslop (or an /improve focus) and reclaim the context slot. |
| `ponytail-debt` | **merge → `ponytail`** | high | It is a grep for 'ponytail:' comments plus an output format — a frontier model does this from a one-line ask. The marker convention belongs to ponytail, which defines it; put the ledger-harvest paragraph there. |
| `resilience-review` | **trim** | high | The unhappy-path lens (probes for input/timing/system/UX failure, failure matrix output) is real value that built-in /code-review does not systematize, and half the harness references it. |
| `thermo-nuclear-code-quality-review` | **merge → `review`** | high | A mega-wrapper that fans out to /review, /resilience-review, /visual-review, /steelman, /agent-watchdog, /visual-recap, /stay-within-limits, and /read-the-damn-docs — while /review simultaneously runs thermo-nuclear as one of its hats. |
| `steelman` | **keep** | high | Best-written skill in the partition. Anti-sycophancy with a real procedure: classify claim type, decline preference steelmans, gather repo evidence before arguing, surface-don't-block. |
| `visual-review` | **trim** | high | Genuinely earns a slot: browser-evidence-first UI review with lifecycle tracing (idle->pending->success->error), keyboard matrix, and design-language handles — none of which built-ins do, and it matches the owner's daily frontend work. |
| `improve` | **trim** | medium | The advisor-not-implementer contract, plans/ handoff artifact, and reconcile loop are distinct from built-in Explore/Plan and worth keeping for a senior engineer dispatching work. |
| `improve-codebase-architecture` | **merge → `improve`** | medium | An architecture-focused audit that overlaps /improve's job with extra ceremony: a self-contained Tailwind-CDN + Mermaid-CDN HTML report is a demo gimmick, and the grilling loop re-invokes /codebase-design and /domain-modeling. |
| `agent-watchdog` | **keep** | high | Distinct, increasingly relevant job in 2026: reconstruct another agent's contract and audit its claims against evidence. Tight at 1.9KB, clear modes, defaults to audit-only, lazy upstream reference. |
| `diagnosing-bugs` | **keep** | high | The strongest engineering content in the partition: feedback-loop-first debugging ('build the loop, bug 90% fixed'), falsifiable ranked hypotheses, tagged debug logs, regression-test seam analysis, non-determinism handling. |
| `snyk-ux-security` | **trim** | high | A real, load-bearing Redpanda workflow (Snyk sweeps across JS/Go/Bazel with exploitability triage, .snyk hygiene, existing-project monitor gate) — the domain knowledge is irreplaceable. |
| `upgrade-dependency` | **trim** | high | Distinct, useful workflow (version-hop path research, safe/risky gate, supply-chain preflight) that complements snyk-ux-security and covers Go too. |
| `migrate-to-shoehorn` | **delete** | high | An 899-byte codemod recipe for one niche library that a frontier model executes correctly from the prompt 'migrate test as-casts to shoehorn'. One-time migration, not a recurring behavior; only reference is ask-ben trivia. |
| `agent:adversarial-reviewer` | **keep** | high | Model of how to write an expensive agent: explicit trigger gate computed BEFORE any work (diff>200 lines, prior CRITICAL, or security paths), clear failure-class taxonomy, explicit non-goals, structured skip output. |
| `agent:code-reviewer` | **trim** | high | The spec-compliance stage, JSON findings, and pre_existing filter earn the orchestration slot even with built-in /code-review existing. |
| `agent:findings-schema` | **demote-to-reference** | high | It is not an agent — it is a JSON schema document that seven other files cite. Sitting in agents/ risks it being registered/listed as a dispatchable agent, which is pure confusion. |
| `agent:karpathy-failure-modes` | **trim** | high | Three reviewer agents mark this 18KB file as required reading on every run. The first tier (7 single-agent failure modes with verify commands) is excellent and earns the read. |
| `agent:plan-design-hat` | **keep** | high | Tight 2.2KB, sonnet, clear passes (flow, WCAG floor, craft), explicit non-goals deferring to sibling hats, structured output, gated inside /grill-me rather than free-floating. Exactly the right size for a parallel review persona. |
| `agent:plan-engineering-hat` | **keep** | high | Same quality bar as design-hat: architecture/non-functional/delivery passes, test_first output feeding TDD, non-goals stated, gated in grill-me. Cheap and well-scoped. |
| `agent:plan-product-hat` | **keep** | high | Best of the three hats — MISSING_PERSONA, ONE_WAY_DOOR, SOLUTION_IN_SEARCH_OF_PROBLEM flags plus the prior-art git-log check give a real PM lens the model does not apply unprompted. must_answer capped at 3-5 shows restraint. Keep as-is. |
| `agent:self-reviewer` | **trim** | high | The code-liability gate, pre-existing filter via dirty baseline, and honest-confidence rule are good phase-4b machinery. But it duplicates the Resilience/Visual evidence blocks verbatim with code-reviewer (extract to shared reference), inherits the 18KB karpat… |
| `agent:verifier` | **keep** | medium | 1KB, haiku-priced, gives the lifecycle a cheap delegation target that runs related tests, typecheck, agent-browser visual check, and lint outside the main context. |

### Setup skills & kits

| Item | Verdict | Confidence | Reasoning |
|---|---|---|---|
| `setup-accessibility` | **rewrite** | high | Identity mismatch: name/description say one-time a11y-enforcement setup, but the body is durable runtime guidance (nested-pressables patterns, 17-item visual checklist) path-triggered on component edits. |
| `setup-agent-config` | **merge → `frontend-starter-kit`** | high | Pure one-time installer: copy 3 scripts, wire 3 hooks. The plugin already ships llm-env.sh/llm-test-flags.sh/llm-truncate.sh in .claude/hooks and wires them in hooks/hooks.json, so for plugin users this skill does nothing. |
| `setup-atlassian-workflow` | **merge → `work-automation-kit`** | medium | Tiny opt-in installer (install acli, set two env vars). CLAUDE.md already mandates 'Jira acli' and the actual command patterns live in a 2.5K REFERENCE.md. |
| `setup-biome` | **merge → `frontend-starter-kit`** | high | One-time installer whose hook (biome-autofix.sh) the plugin already ships and wires. The biome.jsonc template and scripts block belong in the starter kit's per-tool SETUP/REFERENCE files, read lazily during bootstrap. |
| `setup-ci-pipeline` | **demote-to-reference** | medium | One-time GH Actions scaffolding. The real value is the REFERENCE.md conventions (Blacksmith workers, coverage diff, bundle budgets), not the 1.2K SKILL.md which is a table of contents. |
| `setup-connect-query` | **rewrite** | high | Same identity mismatch as setup-accessibility: path-triggered on *_pb*/gen/** files, and the useful payload is runtime rules plus REFERENCE.md protobuf gotchas (Timestamp, Any, cache patterns) that matter every time proto-generated code is touched. |
| `setup-conventional-commits` | **merge → `frontend-starter-kit`** | high | Pure installer for a hook the plugin already ships (conventional-commits-check.sh in .claude/hooks). The format spec is duplicated in CLAUDE.md's Commits section AND inside the commit-push/commit-push-pr skills. |
| `setup-e2e-testing` | **rewrite** | medium | Half runtime guidance (selector priority, spec naming, agent-browser vs Playwright decision table, axe-on-every-page pattern) path-triggered on e2e/**, half installer (correctly pushed to SETUP.md). |
| `setup-env-validation` | **merge → `frontend-starter-kit`** | high | Installer for one hook (shipped by plugin as env-validation-check.sh) plus a t3-env snippet any frontier model writes from memory. CLAUDE.md already has a dedicated Env Vars section mandating @/env with t3-env+zod. |
| `setup-pre-commit` | **delete** | high | Directly contradicts the harness three ways: installs Husky+Prettier+lint-staged when the toolchain is Biome (setup-biome) and Claude hooks; defaults to npm when setup-toolchain BLOCKS npm; and setup-conventional-commits explicitly advertises 'Replaces commitl… |
| `setup-quality-gate` | **merge → `frontend-starter-kit`** | high | Installer whose three hooks (typecheck-stop, bundle-guard, test-perf-stop) the plugin already ships and wires. The package.json scripts block and assets.d.ts are bootstrap artifacts; the GH Actions workflow overlaps setup-ci-pipeline (two skills both writing q… |
| `setup-react-compiler` | **merge → `frontend-starter-kit`** | medium | One-time installer (bun add, rsbuild config, sprinkle 'use no memo'). Hook shipped by plugin; compiler-memoization rules already in CLAUDE.md Quick Ref and React section, enforced by react-rules hooks. |
| `setup-react-doctor` | **merge → `frontend-starter-kit`** | medium | 977 bytes to run 'bun add -D react-doctor', add one script, one config, one Stop hook (shipped by plugin as react-doctor-stop presumably). Thinnest installer in the set; a single line in the starter kit sequence covers it. |
| `setup-react-rules` | **demote-to-reference** | high | This is the canonical rule catalog for the react-rules/fp/tailwind hooks — but the hooks already enforce every hard rule mechanically, and CLAUDE.md's React section duplicates roughly 80% of the list verbatim, so the model already carries the content twice per… |
| `setup-registry-workflow` | **rewrite** | high | Mislabeled: two of its three sections are recurring runtime workflows, not setup. The component taxonomy (atom/molecule/organism with test-depth heuristics) and especially the consumer drift analysis (git diff --no-index, filter rules, business-logic red flags… |
| `setup-routines` | **demote-to-reference** | medium | 4K walkthrough of the claude.ai/code routines web UI plus a template table. The built-in /schedule skill now handles CLI-side routine creation (the skill itself says 'CLI = scheduled routines only... |
| `setup-sandcastle` | **delete** | medium | Setup doc for a third-party orchestrator whose job — parallel sandboxed agents, HITL review, branch strategies — is now covered by built-ins: Workflow tool, EnterWorktree, background agents, agent teams, plus the plugin's own swarm skill. |
| `setup-tanstack-router` | **rewrite** | high | Strongest hybrid in the partition: the Router-loader-primes/Query-owns-cache ownership split, per-field suspense policy, useLoaderData pitfall, and nuqs pattern are real senior-level guidance the model benefits from at route-writing time, path-triggered on rou… |
| `setup-toolchain` | **merge → `frontend-starter-kit`** | high | Installer for enforce-toolchain.sh + session-env.sh, both shipped and wired by the plugin. CLAUDE.md's Toolchain section carries the policy. Copy-two-files-and-chmod does not earn a permanent description; it is step 1 of the starter kit and nothing more. |
| `setup-ux-copy` | **trim** | medium | The largest setup skill (4.8K) and the rule enumeration duplicates exactly what ux-copy-check.sh and prose-style-check.sh already enforce mechanically — the model learns those rules from hook error messages, not from reading a ban list. |
| `setup-zustand` | **merge → `frontend-starter-kit`** | medium | 1K skill whose every rule (create<T>()(), useShallow, persist, client-state-only) appears verbatim in CLAUDE.md's Quick Ref and Zustand sections AND is hook-enforced. |
| `frontend-starter-kit` | **rewrite** | high | Keep the concept — this should become THE single setup entry point absorbing the 10+ pure-installer skills above, which is the whole consolidation play. |
| `redpanda-frontend-kit` | **merge → `frontend-starter-kit`** | medium | A 1.6K delta over frontend-starter-kit: two env vars, one extra setup skill, and inline bash to hand-patch react-rules-check.sh with a Chakra ban (fragile — editing a shipped hook script instead of an env-driven rule). |
| `work-automation-kit` | **rewrite** | medium | Half of it is another redundant skill-installer block (installs brainstorming/triage/etc. that the plugin already provides; has a literal duplicated '# Owned' comment and two identical grill-with-docs mentions across sections; references nonexistent 'codex-plu… |
| `git-guardrails-claude-code` | **delete** | high | Vendored mattpocock installer that is both redundant and hostile in this harness: setup-toolchain's enforce-toolchain.sh already guards reset --hard, checkout ., restore ., force push, and the plugin ships branch-safety-check.sh — while this hook additionally … |
| `codex-compat` | **keep** | high | Distinctive, non-duplicated capability: translating the plugin's 98-hook harness into Codex hooks.json + AGENTS.md with a direct/shim/fallback compatibility matrix. |
| `aip` | **keep** | high | The best skill in the partition and arguably the plugin: dense, opinionated Google-AIP resource-API design rules path-triggered on *.proto, with compatibility-exception policy (legacy id paths, custom operations), implementation rules for handlers/storage, and… |

### Hook harness

| Item | Verdict | Confidence | Reasoning |
|---|---|---|---|
| `_hook-lib.sh` | **rewrite** | high | Genuinely good engineering (payload-diff added_lines, session/worktree binding, severity tiers, JSONL telemetry, escape hatches) but it is the per-edit tax multiplier: every one of 56 Edit/Write hooks sources this 27KB file, and line 528 spawns python3 AT SOUR… |
| `react-rules-check.sh` | **trim** | high | 424 lines, ~30 checks. This IS the dispatcher pattern the other 55 hooks should follow — one parse, many rules. Keep the hard blocks (eval/innerHTML/dangerouslySetInnerHTML, outline removal, passive listeners, class components, setTimeout string, ===NaN, raw H… |
| `tailwind-check.sh` | **trim** | high | The design-token blocks (raw hex/rgb, hardcoded palette utilities, !important, user-scalable=no, 100vh) are high-value hard rules with escape hatches. |
| `accessibility-check.sh` | **keep** | high | Hard WCAG blocks (img alt, clickable div needs role+tabIndex+kbd, combobox aria) that models still genuinely miss under pressure, cheap greps, escape hatch present. One of the few Edit/Write hooks that earns a block tier. |
| `zustand-check.sh` | **keep** | high | Three real footguns (create<T>()() curried form, useShallow for object selectors, persist vs raw localStorage) — the middleware-typing one especially is a silent type-rot bug models reproduce from stale training data. Small, import-gated, blocks are correct. |
| `zustand-subscription-check.sh` | **delete** | high | Heuristic guesses that any `api.foo` property read is an un-subscribed store access — wildly false-positive-prone (any object named api trips it), and it warns based on absent useApiStore in the file. |
| `tanstack-router-check.sh` | **trim** | high | 224 lines. Strong core: react-router-dom ban, window.location nav ban, URLSearchParams-in-client block, strict:false ban, empty-args useParams/useSearch block, validateSearch requirement — real repo conventions with teeth. |
| `tanstack-router-gen.sh` | **trim** | high | Auto-runs `bun run generate:routes` on EVERY edit to any file under /routes/ — useful automation but unbounded: a 10-edit route session runs codegen 10 times synchronously in the hook path. Debounce via session marker or move to a Stop-time single run. |
| `connect-query-check.sh` | **keep** | high | Repo-critical conventions (connect-query imports over raw @tanstack/react-query, no empty invalidateQueries, proto v2 create() over new Message(), no raw fetch in ConnectRPC files). These are Redpanda-stack-specific and not in any model's priors. |
| `query-pattern-check.sh` | **keep** | high | The sharpest of the query hooks: unstable QueryClient block, query-result-in-deps-array block, rest-destructure warn, await-invalidateQueries warn — real correctness bugs models still write. Merge target for the mutation-* singletons. |
| `mutation-onerror-check.sh` | **merge → `query-pattern-check.sh`** | high | Single rule (mutate without onError → block) that re-parses stdin, re-cats the file, and re-sources the 27KB lib for one grep. Rule is good; the standalone process is not. Fold into query-pattern pass. |
| `mutation-naming-check.sh` | **delete** | high | *Mutation suffix naming warn. Pure style, already one line in CLAUDE.md, model follows it; a naming nit does not earn a process spawn on every edit. |
| `mutation-side-effect-check.sh` | **merge → `query-pattern-check.sh`** | medium | Raw DELETE/POST fetch without useMutation — decent heuristic with sensible count-based gating, but same single-rule-single-process waste. Fold in. |
| `connect-error-check.sh` | **merge → `connect-query-check.sh`** | high | ConnectError.from() over new Error() in data-fetching code — legit Redpanda rule, but it walks the directory tree to find package.json per invocation and shares 80% of its gating logic with connect-error-format-check. |
| `connect-error-format-check.sh` | **merge → `connect-query-check.sh`** | high | formatToastErrorMessageGRPC + ConnectError.from in catch — duplicates connect-error-check's gating (identical package.json tree walk copy-pasted). Textbook merge candidate. |
| `connect-error-fieldmap-check.sh` | **merge → `connect-query-check.sh`** | high | FieldViolation→form.setError rule is valuable domain knowledge, but it is a whole-file grep chain that belongs in the same connect pass as its two siblings. |
| `aip-proto-check.sh` | **keep** | high | Only fires on .proto edits (perfect gating), encodes Google AIP conventions (resource pattern, IDENTIFIER, full-name over bare id) that pair with the aip skill. Cheap, precise, Redpanda-relevant. |
| `form-mode-check.sh` | **trim** | medium | onChange-mode warn + no-validation warn + no-inline-error-display warn. The mode warn is fine; the 'form has no validation' file-level heuristic fires on partially-built forms mid-session (you get warned while still writing the resolver). |
| `form-watch-check.sh` | **merge → `form-mode-check.sh`** | high | One rule (useWatch over form.watch, correct for React Compiler), one process. Fold into forms pass. |
| `form-setvalue-options-check.sh` | **merge → `form-mode-check.sh`** | high | setValue shouldDirty/shouldValidate warn — legit RHF footgun, single grep, fold in. |
| `form-error-summary-check.sh` | **merge → `form-mode-check.sh`** | high | FormErrorSummary/aria-live on multi-field forms — good a11y rule with sensible ≥2-field gate, but whole-file cat + single rule. Fold in. |
| `proto-form-parallel-state-check.sh` | **merge → `form-mode-check.sh`** | high | useState<*Config> beside useProtoForm drift warn — Redpanda-specific and worth keeping, as one function in the forms pass, not a process. |
| `field-mask-check.sh` | **merge → `form-mode-check.sh`** | medium | Hardcoded FieldMask paths → dirtyFields warn. Real rule from real incidents by the look of it; single-purpose process though. Fold in. |
| `env-validation-check.sh` | **keep** | high | Hard block on raw process.env outside env/config files with a thorough exemption list. Repo convention with teeth, cheap, precisely gated. Earns its slot. |
| `ux-copy-check.sh` | **trim** | high | 242 lines, 30 checks. The blocks are defensible house style (no '!', no 'successfully', inclusive terms, no click-here, Redpanda capitalization). |
| `security-audit-check.sh` | **trim** | high | Hardcoded-secret, SQL template injection, MD5-on-password blocks are keepers. But eval/new Function/innerHTML are ALSO blocked by react-rules-check — the same edit gets scanned twice for the same sins by two processes. |
| `llm-failure-mode-check.sh` | **keep** | high | Hallucinated-import detection (import not in package.json deps) is one of the few checks aimed at an actual LLM failure mode rather than a style preference, and grep genuinely can verify it. Keep, fold into dispatcher. |
| `as-cast-check.sh` | **merge → `ts-no-escape-hatches-check.sh`** | medium | as-any/@ts-ignore ban split out of react-rules into its own process; ts-no-escape-hatches covers the same territory. Two processes enforcing one CLAUDE.md line ('no as any / no ts-ignore') is exactly the fragmentation problem. One escape-hatch pass. |
| `ts-no-escape-hatches-check.sh` | **keep** | medium | Type-escape-hatch bans are the highest-ROI hard blocks in the harness (models under pressure reach for `as any` constantly). Keep as the anchor for the escape-hatch family (absorb as-cast, biome-ignore, legacy-linter). |
| `biome-ignore-check.sh` | **merge → `ts-no-escape-hatches-check.sh`** | high | biome-ignore suppression ban — correct rule ('every biome-ignore gets copied by LLMs' is true), single grep, same family as ts-ignore. Fold in. |
| `legacy-linter-check.sh` | **merge → `ts-no-escape-hatches-check.sh`** | high | eslint-disable/prettier-ignore ban in a Biome repo — three greps, same suppression-comment family. Fold in. |
| `tsconfig-strict-check.sh` | **keep** | medium | Only fires on tsconfig*.json edits (perfect file gating), guards strictness flags with perl comment-stripping. Cheap, precise, real regression vector. |
| `test-convention-check.sh` | **keep** | high | test() over it(), vi over jest, toBeVisible over toBeInTheDocument, no waitForTimeout, no test.skip in e2e — all repo conventions on test files only. Correct gating, all warns not blocks. Anchor for tests family. |
| `test-perf-check.sh` | **merge → `test-convention-check.sh`** | high | await-import-in-test, userEvent.type keystroke cost, setInterval leak — same file gate (test files) as test-convention, same tier. One test-file pass. |
| `tdd-prompt-check.sh` | **delete** | high | Once-per-session 'remember to run /tdd' warn on first new source file. Pure reminder — lifecycle-stop already HARD-enforces tests at Stop with far better logic (adjacent-test scan, branch scoping, coverage). A nag that duplicates an enforcer is noise. |
| `structural-test-nudge-check.sh` | **delete** | medium | Another 'new component should have a test' nudge — third overlapping test-presence mechanism (with route-sibling-test-check and lifecycle-stop step 0). lifecycle-stop's version is session-scoped, branch-aware, and blocking. Delete the nudge tier duplicates. |
| `route-sibling-test-check.sh` | **delete** | medium | Route-file-needs-sibling-test nudge, overlapping lifecycle-stop's enforced version and structural-test-nudge. Three hooks policing test presence per edit is two too many; the Stop-time enforcement is the right altitude (tests are per-feature, not per-keystroke… |
| `route-visual-test-check.sh` | **delete** | medium | Fourth test-presence variant (browser tests for new routes), with a package.json tree walk per edit. Same argument: Stop-time enforcement already owns this; a per-edit nudge about a test you have not written YET (because you are mid-TDD) is anti-signal. |
| `error-boundary-check.sh` | **merge → `tanstack-router-check.sh`** | high | Route-with-loader-needs-errorComponent, with parent-boundary globbing. Good rule, router-scoped, belongs in the router pass not its own process. |
| `hook-location-check.sh` | **merge → `tanstack-router-check.sh`** | high | use* hook defined in route file → move to /hooks/. One grep, route-gated, router family. |
| `file-size-check.sh` | **merge → `tanstack-router-check.sh`** | high | Route >300 LOC warn. One wc -l, route-gated. Fine rule, wrong packaging. |
| `split-file-convention-check.sh` | **merge → `tanstack-router-check.sh`** | medium | *.page.tsx layout convention block — Redpanda-specific and real, but route-gated single rule. Router pass. |
| `url-state-check.sh` | **delete** | high | 'Consider URL state for pagination/sort' suggestion keyed on variable names in useState. Low-precision architecture advice; the model weighs this fine in context, and it is already a CLAUDE.md-adjacent preference not a rule. |
| `unhappy-path-check.sh` | **delete** | high | grep -A5 around catch blocks guessing at silent-swallow — fragile multi-line heuristics of exactly the kind extend-harness's own section 4 says not to fake with regex. |
| `resilience-review-nudge.sh` | **delete** | high | Scores files on regexes so broad ('create\|update\|delete\|submit\|save', 'loading\|empty\|error\|success\|disabled') that virtually every product file scores ≥2 and gets a per-file nudge to run /resilience-review. |
| `magic-number-check.sh` | **delete** | medium | Inline staleTime warn duplicates a CLAUDE.md line; the proto-enum-vs-number heuristic (any comparison against 3-9 in a file importing proto) is guesswork with an exclusion list that admits it. Neither earns a process. |
| `duplicate-function-check.sh` | **delete** | high | git-greps the repo for every new function name >8 chars on every edit — expensive, name-collision-based (same name ≠ duplicate logic), once-per-session dedup admits it is noisy. /simplify and code review find real duplication with semantics. |
| `copyright-check.sh` | **keep** | medium | New-file copyright header warn, once per session, git-show gated to new files only. Corporate requirement, cheap, correctly throttled. Fine as a dispatcher rule. |
| `disabled-button-tooltip-check.sh` | **merge → `react-rules-check.sh`** | high | disabled Button needs Tooltip — legit a11y house rule, one grep, react family. Fold in. |
| `react-compiler-check.sh` | **keep** | high | useMemo/useCallback/React.memo ban gated on actual compiler presence in package.json plus 'use no memo' opt-out. Correct, compiler-aware, and models absolutely still emit manual memoization from priors. Keep. |
| `bundle-guard.sh` | **keep** | high | moment/lodash/jquery/core-js/classnames blocks, fires only on package.json edits and verifies the dep actually landed in dependencies. Precise gating, real bundle value, near-zero cost. |
| `vendor-file-check.sh` | **keep** | high | Hard block on editing vendor/registry/@generated files — one of the highest-value guards in the harness (models happily 'fix' generated files). Make it the single owner of registry warnings (see ui-registry-warn). |
| `ui-registry-warn.sh` | **merge → `vendor-file-check.sh`** | high | Registry-sourced-component warning is emitted THREE times by the harness: here, in vendor-file-check, and inside _hook-lib.sh's hook_skip_ui_dirs. Same message, three code paths. Consolidate into vendor-file-check and delete the lib copy. |
| `legacy-import-check.sh` | **trim** | medium | @redpanda-data/ui and lucide-react-direct warns are real Redpanda migration rules, but the icons check walks the directory tree to / looking for components/icons on every edit. Cache the lookup or resolve once from repo root. Keep rules, fix cost. |
| `lockfile-sync-check.sh` | **keep** | medium | bun.lock/yarn.lock sync + package-lock ban supporting the Snyk workflow — fires only on lockfile paths, encodes genuinely obscure repo process knowledge grep can verify. Cheap and niche in the good way. |
| `edit-loop-check.sh` | **keep** | high | 12/20-edit thrash detector with per-file counters. Tiny, tool-agnostic, targets a real agent failure mode (edit-loop death spirals) that the model cannot see from inside. One of the few behavioral hooks that earns its slot. |
| `orchestration-guidance.sh` | **rewrite** | high | 253 lines doing two unrelated jobs: (1) file-category tracking that orchestration-stop consumes — keep, it is 5 lines of appends; (2) once-per-category guidance strings plus a 13-nudge REDPANDA_KIT pile that cats the whole file and greps it ~15 times per edit … |
| `intent-detect.sh` | **trim** | high | Keyword→directive injection on every prompt. The useful parts: PR-number auto-context (gh pr checkout hint), scope-lock on feature branches, browser-tools-exist reminder. |
| `user-prompt-context.sh` | **keep** | high | Turn-aware design is right: full context first turn only, then git-state delta (~30-50 tokens/turn) which the model would otherwise burn a tool call to get. The violations line closes the loop on suppressed hook output. |
| `session-env.sh` | **keep** | high | Real session infrastructure: DISABLE_FRONTEND_HOOKS detection for non-React repos, worktree binding, dirty-files baseline (the thing that stops Stop hooks hostage-holding pre-existing mess), background typecheck baseline. |
| `llm-env.sh` | **merge → `session-env.sh`** | medium | 364 bytes of env exports as a separate SessionStart process. Three lines in session-env. |
| `post-compact-context.sh` | **keep** | medium | Re-injecting project state after compaction is exactly what hooks are for — the model provably loses this. Cheap, event-gated. |
| `pre-compact.sh` | **keep** | low | Small pre-compaction state stash. Event-gated, cheap. |
| `post-tool-failure.sh` | **merge → `consecutive-failure-check.sh`** | medium | Bash-failure guidance and consecutive-failure counting are the same concern (failure-loop detection) split across two processes on overlapping events. One failure-tracking hook. |
| `consecutive-failure-check.sh` | **keep** | medium | Repeated-failing-command detector — like edit-loop-check, targets a real agent death spiral invisible from inside. Keep as the failure-family anchor. |
| `file-changed-schema.sh` | **keep** | low | Fires only on .proto/.graphql changes to nudge regeneration. Precise event gating is the model for how the whole harness should work. |
| `file-changed-config.sh` | **keep** | low | biome/tsconfig/vitest config change notification, path-gated. Cheap. |
| `file-changed-env.sh` | **keep** | low | 744 bytes, fires only on src/env.ts. Fine. |
| `file-changed-manifest.sh` | **keep** | medium | Nudges regenerating hook configs when skill-manifest.json changes — directly guards the drift invariant. Keep. |
| `file-changed-deps.sh` | **keep** | low | Dependency-change nudge on lockfile/package.json/go.mod, path-gated. Cheap and useful. |
| `worktree-create.sh` | **keep** | low | Small worktree setup on an event that fires rarely. No concerns. |
| `session-end.sh` | **keep** | medium | Session cleanup + metrics summary write that hook-audit/stats depend on. Keep while telemetry exists. |
| `violation-nudge.sh` | **merge → `user-prompt-context.sh`** | medium | PreToolUse on every Edit/Write/Bash to remind about repeat violations — but user-prompt-context already injects the violation summary every turn. Same information, extra process on the hottest path. |
| `enforce-toolchain.sh` | **keep** | high | The flagship deny hook: npm/npx/tsc→bun/bunx/tsgo with the exact rewritten command in the message, rm -rf allowlist, --force vs --force-with-lease, --no-verify ban, git reset --hard ban. |
| `mcp-ban.sh` | **keep** | high | 162 lines of per-tool deny messages with the EXACT acli/gog/gh/bk/box/m365 replacement syntax, justified by measured char counts (23k MCP vs ~1k CLI). Every deny teaches. High-value, precisely gated on mcp__ matcher so it costs nothing on normal tool use. |
| `llm-test-flags.sh` | **keep** | low | Test-command flag optimization for token-lean output (reporter flags, related-file targeting) on the Bash pre-path. Consistent with the measured-drain philosophy of the bash family. |
| `conventional-commits-check.sh` | **keep** | medium | Pre-exec commit-message validation replacing commitlint+husky entirely — deterministic format check is the canonical good hook. Keep. |
| `branch-safety-check.sh` | **keep** | low | Small guard (commits to main/protected branches). Deterministic, cheap, real footgun. |
| `snyk-project-create-guard.sh` | **keep** | low | Prevents accidental Snyk project creation during sweeps — encodes a costly-to-undo org-level side effect. Niche but only fires on snyk commands. Keep. |
| `bash-verbose-guard.sh` | **keep** | high | Already self-pruned (comment documents removing four nudges that duplicated CLAUDE.md — exactly the right discipline). Remaining nudges are measured drains (lefthook commit spam, gh --json without --jq, repeat-command detection) with drain logging for ROI meas… |
| `rtk-rewrite.sh` | **keep** | medium | 796-byte auto-prefix of output-heavy commands with rtk. Tiny, measurable win, fails open. |
| `llm-truncate.sh` | **keep** | high | 4KB output cap with head/tail view and full log stashed to /tmp for re-read. Direct, measurable token savings with a recovery path. Keep. |
| `test-warning-check.sh` | **rewrite** | high | Right idea (green-but-warning runs are not clean), catastrophically wrong gating — it hard-blocked THIS AUDIT twice: the command gate is naive substring match (`*lint*` matched a for-loop listing 'legacy-linter-check.sh'; `*test*` matches any path containing '… |
| `subagent-start.sh` | **keep** | low | Context injection for spawned subagents so they inherit harness rules. Event-gated, sensible. |
| `subagent-stop.sh` | **keep** | low | Gated to reviewer-type subagents only (good matcher discipline). Keep. |
| `architecture-review-stop.sh` | **delete** | medium | Stop-time grep for structural issues (route file checks, testable-file heuristics) that duplicate the per-edit file-size/route/test hooks AND lifecycle-stop's test gate. Third pass over the same territory with the weakest signal. |
| `biome-autofix.sh` | **keep** | high | Auto-runs lint:fix on session-changed files at Stop, excluding UI dirs. Deterministic remediation (not nagging) at the right lifecycle point. One of the top-3 Stop hooks. |
| `typecheck-stop.sh` | **keep** | high | The best Stop hook: type:check with session-file filtering AND the SessionStart baseline diff so pre-existing errors never hostage-hold the session, shares test results with sibling hooks to avoid re-runs. Keep exactly this. |
| `react-doctor-stop.sh` | **trim** | medium | Score-gated react-doctor run with special-casing for the tool's own crashes ('is not iterable' handling) — the hook is compensating for a flaky tool. Gated on a doctor script existing so it is dormant elsewhere. |
| `registry-check.sh` | **keep** | high | registry.json rebuild + changeset reminder, gated on registry repos only, reports via the quality-gate findings file instead of blocking independently. Correct pattern, near-zero cost elsewhere. |
| `orchestration-stop.sh` | **merge → `lifecycle-stop.sh`** | medium | Runs vitest (with --detectAsyncLeaks) at Stop and checks test presence — overlapping lifecycle-stop's coverage/test gate and typecheck-stop's shared test results. Three Stop hooks arbitrate 'were tests run'; consolidate the test-execution gate into one. |
| `test-perf-stop.sh` | **delete** | medium | Compares per-test timings against an opt-in (CAPTURE_TEST_BASELINE=1) SessionStart full-suite baseline. Double vitest runs for timing-regression detection nobody asked for per-session — CI is where test-perf tracking belongs. |
| `quality-gate-stop.sh` | **keep** | high | The aggregator that turns N independent Stop blocks into ONE consolidated block with all findings — the architectural keystone that makes a multi-hook Stop pile tolerable. Keep and route more Stop hooks through it. |
| `lifecycle-stop.sh` | **trim** | high | 328 lines enforcing tested→committed→pushed→PR→CI→reviewer. The test/coverage gate (step 0) and uncommitted-session-files gate are excellent, with visibly battle-hardened false-positive defenses (branch-scoping, adjacent-test scan, worktree filtering). |
| `pr-feedback-completeness-stop.sh` | **delete** | medium | GraphQL-queries unresolved review threads on EVERY Stop of any branch with a PR — a per-stop network tax to enforce something only relevant during a resolve-pr-feedback session, and that skill already owns thread completeness. |
| `ci-warning-audit.sh` | **trim** | medium | Downloads CI logs (45s timeout) on green CI at Stop to grep for warnings — the Stop-tier sibling of test-warning-check with the same pattern-matching fragility (its own regex list literally tripped test-warning-check during this audit). |
| `perf-regression-stop.sh` | **delete** | high | Boots the dev server (nohup bun run dev, 30s readiness poll) and runs Lighthouse INSIDE A STOP HOOK. Even gated behind lhci being installed, this is a category error — minutes of wall-clock and a spawned server at the moment the user wants the session to end. |
| `violation-summary-stop.sh` | **keep** | high | 20 lines: injects the session violation tally once at Stop then clears. Cheap, closes the telemetry loop for the user. Keep. |
| `cache-telemetry-stop.sh` | **delete** | medium | Python-parses the full transcript on every Stop to compute cache-token telemetry — measurement infrastructure for harness development, not something every consumer session should pay for. Move to an on-demand script invoked by hook-audit. |
| `extend-harness` | **keep** | high | Concise, correct, load-bearing: documents the manifest→generate-hook-configs single-source-of-truth flow (which works — --check passed, lefthook runs it pre-push), the severity-tier table, synthetic-event testing, and honestly states when grep is not enough. |
| `hook-audit` | **keep** | high | The data-driven prune/soften/harden loop is the only honest defense of a hook harness this size, and the retro analytics section adds session-flow metrics stats lacks. Keep as the single analytics skill and absorb frontend-skills-stats. |
| `frontend-skills-stats` | **merge → `hook-audit`** | high | Near-clone of hook-audit: same metrics dir, same silent-hooks/over-aggressive/under-enforced sections, same 'prioritized action list (max 5)' output contract. |

### Vendored & misc skills + repo meta

| Item | Verdict | Confidence | Reasoning |
|---|---|---|---|
| `visual-plan` | **trim** | medium | Well-engineered progressive disclosure (1.5KB SKILL.md, 92KB lazily-read references) but it hard-depends on the Builder.io hosted Plan MCP server in a repo whose own CLAUDE.md says 'MCP banned -> CLI' -- and the plan MCP tool schemas injected per session (crea… |
| `visual-recap` | **trim** | medium | Same Builder.io Plan MCP contradiction as visual-plan. Worse: its 'Local harness overlay' wires recap creation into /commit-push-pr and /go, making the core ship path soft-depend on a hosted SaaS for every review-worthy diff. |
| `efficient-fable` | **merge → `efficient-frontier`** | high | Confirmed near-duplicate: efficient-frontier's own upstream reference opens with 'Apply the same orchestration as /efficient-fable to any high-cost frontier model'. |
| `efficient-frontier` | **trim** | medium | Keep exactly one orchestration skill after absorbing efficient-fable, but be honest about no-op risk: CLAUDE.md already carries a 'Subagent model choice (cost)' section, and 2026 frontier models with built-in Explore agents and the Workflow tool delegate bound… |
| `stay-within-limits` | **merge → `efficient-frontier`** | medium | The only concrete content is 'run bunx ccusage, stop at 95%, report on pause' -- one guardrail bullet, not a skill. It only matters during parallel agent waves, which is exactly when efficient-frontier is active, and wayfinder already invokes it in that contex… |
| `read-the-damn-docs` | **trim** | high | One of the highest-value model-invoked behaviors in the pack: 'do not guess where authoritative docs answer it' genuinely changes frontier-model behavior on API drift, auth, and migrations, and the strong-triggers list is well chosen. |
| `research` | **merge → `read-the-damn-docs`** | medium | Its entire delta over read-the-damn-docs is 'save the findings as a cited Markdown file where the repo keeps such notes' -- and its delta over the built-in deep-research skill (which already fan-outs searches, adversarially verifies, and synthesizes a cited re… |
| `wayfinder` | **keep** | medium | The one mattpocock planning skill with no built-in equivalent: multi-session, issue-tracker-backed planning with claim discipline, fog-of-war scoping, and one-ticket-per-session -- built-in Plan agents are single-session, so this fills a real gap for genuinely… |
| `to-spec` | **keep** | high | User-invoked (disable-model-invocation: true), so zero context tax -- the correct trade for a deliberate command. Content is solid: synthesis-not-interview, seam-first thinking wired to codebase-design vocabulary, sensible template, clean handoff to /to-ticket… |
| `to-tickets` | **keep** | high | User-invoked, zero context tax, and the tracer-bullet vertical-slice + blocking-edges model is genuinely good ticket discipline that models do not do by default. Templates for both local tickets.md and real trackers are practical. |
| `triage` | **keep** | high | User-invoked with textbook progressive disclosure: 4.7KB SKILL.md routing to tracker-github/tracker-jira/AGENT-BRIEF/OUT-OF-SCOPE/REFERENCE files loaded on demand. |
| `teach` | **delete** | high | A personal stateful learning-workspace system (missions, spaced-repetition lessons, learning records) -- competent writing, but it has nothing to do with a published React/TS+Go enforcement harness. |
| `ask-ben` | **rewrite** | medium | A router for user-invoked skills is legitimate (writing-great-skills argues exactly this), but the execution is a hand-maintained 95-row table that duplicates the skill catalog for the third time (after system-prompt descriptions and README) and is already sho… |
| `codebase-design` | **keep** | high | Ousterhout deep-module vocabulary as a shared glossary other skills (tdd, to-spec, improve) genuinely reference -- this is infrastructure, not ceremony. |
| `domain-modeling` | **keep** | high | CONTEXT.md glossary + ADR discipline with a sharp activation boundary ('reading CONTEXT.md is not this skill'), lazy file creation, and a genuinely good three-condition ADR gate that prevents ADR spam. Referenced by wayfinder and grill-with-docs. |
| `edit-article` | **merge → `writing-shape`** | medium | Six lines of editing procedure. It is the 'edit' phase of the same personal article pipeline as writing-fragments/shape/beats -- four always-on descriptions in every frontend session for a hobby-writing workflow. |
| `writing-beats` | **merge → `writing-shape`** | medium | writing-beats and writing-shape are two drafting variants of the same loop (offer candidates, user picks, append one block, re-read before write). |
| `writing-fragments` | **merge → `writing-shape`** | medium | The capture phase of the same pipeline -- interview, append fragments with --- separators. Good micro-discipline (re-read before write, no imposed outline) worth preserving verbatim as the 'fragments' mode of one consolidated user-invoked writing skill. |
| `writing-shape` | **rewrite** | medium | Becomes the survivor: rewrite into a single user-invoked /writing skill with fragments/shape/beats/edit modes absorbing the other three, set disable-model-invocation: true, and ideally move the whole thing to a personal skills dir out of the published plugin -… |
| `writing-great-skills` | **keep** | high | The best document in the repo: a genuinely original theory of skill authorship (context load vs cognitive load, leading words, information hierarchy, no-op test, negation trap) with a proper glossary disclosed to GLOSSARY.md, and correctly user-invoked so it c… |
| `obsidian-vault` | **delete** | high | Hardcodes vault path /mnt/d/Obsidian Vault/AI Research/ -- a WSL Windows mount, on the owner's current darwin machine, so it is provably dead on the machine it ships from. |
| `scaffold-exercises` | **delete** | high | Scaffolding for Matt Pocock's ai-hero course repo: runs 'pnpm ai-hero-cli internal lint' -- tooling the owner does not have, in a package manager (pnpm) the harness's own enforce-toolchain hook would block. |
| `weekly-review` | **merge → `what-did-i-get-done`** | high | Cursor Team Kit near-duplicate of what-did-i-get-done: both resolve git user email, collect authored commits, exclude merges, and emit a concise summary. |
| `what-did-i-get-done` | **keep** | high | The better half of the pair: parameterized time range, sharp guardrails (no intent inference, omit cosmetic changes, state the real date range), genuinely useful for standup/status writing and cheap to run. |
| `meta:README.md` | **trim** | high | 1460 lines / 73.5KB is a landing page, not a README. The good: install matrix, 'When NOT to use this' honesty, real-numbers table with methodology pointers. |
| `meta:CLAUDE.md` | **trim** | medium | Dense compressed rule-pack, mostly justified -- but the user's global ~/.claude/CLAUDE.md is a near-identical copy of the project file, so in this repo both are injected and nearly every rule is paid for twice per session. |
| `meta:AGENTS.md` | **trim** | medium | 4.8KB Codex mirror of CLAUDE.md with drift already visible (Lifecycle phrasing differs, 'Effort: high (Understand) -> xhigh (Plan)' vs CLAUDE.md's table; unhappy-paths section exists only here). |
| `meta:ETHOS.md` | **keep** | high | 2.7KB, nine principles, each explicitly mapped to the hook scripts that enforce it -- this is the rare meta doc that is neither marketing nor duplication: it is the index from values to enforcement, useful for auditing hooks (this audit used it) and for onboar… |
| `meta:CONTEXT.md` | **keep** | medium | 1.3KB domain glossary (customer-facing surface, surface review, prime vs handoff) that dogfoods the domain-modeling skill and demonstrably resolves real term collisions the skills trade in. Small enough to cost nothing. |
| `meta:skill-manifest.json/plugin.json` | **keep** | high | The manifest-as-source-of-truth pattern is solid: skill-manifest.json generates settings.json, hooks.json, both plugin.jsons and marketplaces via generate-hook-configs.sh, with a lefthook pre-push --check guard against drift. |
| `meta:evals/` | **rewrite** | high | 93 eval scripts with a real runner (evals/run.sh) but zero CI wiring -- the only GitHub workflow is update-agent-native-plan-skills.yml, and lefthook runs typecheck/lint/manifest-sync only. |
| `meta:docs/` | **trim** | high | 31MB, almost all docs/screenshots, permanently baked into the git history of a plugin repo that every consumer clones on install. The written content (rfc/, evaluation notes, harness-orchestration-learnings.md) is a few hundred KB of genuine value. |
