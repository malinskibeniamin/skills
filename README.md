# Agent Skills

**Give Claude the outcome, a way to verify it, and the endpoint. Let it work.**

Hooks protect deterministic boundaries; skills disclose specialist knowledge only when a
task enters that domain. The primary model owns planning and execution without surprise
delegation, browser takeover, background wakeups, or unrequested shipping.


## Install

Run inside [Claude Code](https://docs.anthropic.com/en/docs/claude-code) session (start with `claude` in terminal):

```bash
/plugin marketplace add malinskibeniamin/skills
```
```bash
/plugin install frontend-skills@skills
```
```bash
/reload-plugins
```

Three commands. Skills, hooks, agents activate immediately. Done.

**Recommended: rtk** (output-compression proxy, ~60-90% token savings on git/cargo/test/gh):

```bash
brew install rtk
rtk trust            # approve .rtk/filters.toml per project
```

Harness fail-open -- skip safe; SessionStart nudge remind if miss.

**Update** (refresh the catalog, then pull latest):

```bash
claude plugin marketplace update skills
claude plugin update frontend-skills@skills
```

Restart Claude Code session so hooks reload from new cache.

**Verify:**

```bash
CLAUDE_PLUGIN_ROOT="$(
  claude plugin list --json |
    jq -er '.[] | select(.id == "frontend-skills@skills" and .enabled) | .installPath'
)"
bash "$CLAUDE_PLUGIN_ROOT/scripts/verify-install.sh" --remote origin
```

**Codex (OpenAI)** -- install as a Codex plugin from the repo's marketplace manifest:

```bash
brew upgrade --cask codex
codex features enable plugins
codex features enable hooks
codex plugin marketplace add malinskibeniamin/skills --ref v4.37.0
codex plugin marketplace upgrade skills
codex plugin add frontend-skills@skills
```

Track `main` instead of the pin with `--ref main`. Restart Codex after adding or upgrading so the Plugins UI reloads metadata.

**Fallback: individual skills via skills.sh** -- when you want specific skills instead of the full plugin:

```bash
bunx skills@latest add malinskibeniamin/skills/frontend-starter-kit --agent claude-code -y
bunx skills@latest add malinskibeniamin/skills/development-lifecycle --agent claude-code -y
bunx skills@latest add malinskibeniamin/skills/work-automation-kit --agent claude-code -y
```

Want proof and examples? Demo scripts, featured skill moments, and starter prompts live in [docs/DEMOS.md](docs/DEMOS.md); comparisons, measurement methodology, and common questions live in [docs/FAQ.md](docs/FAQ.md).

## Browse the docs

The Blume site turns every canonical `SKILL.md` into a searchable page without a
second documentation copy. Skill names, descriptions, instructions, and new skills are
picked up automatically.

```bash
bun run docs:dev    # local site with hot reload
bun run docs:check  # content and Astro checks
bun run docs:build  # static output in docs-site/dist
```

## How it all connects

```
You: "Build feature X" or "Fix these 5 issues overnight"
  │
  ├── Interactive ──-> Claude Code + an outcome contract
  │                    └── inspect -> act -> verify -> repeat
  │
  └── Automated ───-> Routines (claude.ai/code/routines)
                      └── schedule, GitHub webhook, or API trigger
                          └── cloud session with hooks + CLAUDE.md active
                              └── PR review, triage, health checks, docs drift
```

### Outcome contract

Most work needs four fields, not a prescribed workflow:

```md
Objective: the high-level end state
Guardrails: non-inferable constraints and reserved decisions
Verification: tests, commands, or observable behavior that prove success
Stop: the requested endpoint and genuine blockers
```

The model then owns one evidence loop:

```mermaid
graph TD
    Contract([Outcome contract]) --> Inspect[Inspect evidence and hardest unknown]
    Inspect --> Act[Act with the smallest clear change]
    Act --> Verify[Verify through tests and the real entrypoint]
    Verify -->|Failed| Repair[Repair or revise the approach]
    Repair --> Verify
    Verify -->|Passed| Endpoint{Requested endpoint reached?}
    Endpoint -->|No| Inspect
    Endpoint -->|Yes| Done([Done with evidence])

    style Act fill:#16a34a,stroke:#14532d,stroke-width:3px,color:#fff
    style Verify fill:#2563eb,stroke:#1e3a8a,stroke-width:3px,color:#fff
```

**Four layers, one outcome:**

| Layer | What | How | Reliability |
|---|---|---|---|
| **Skills** | Specialist knowledge | Loaded only when the observed task enters that domain | Progressive |
| **Hooks** | Enforce quality | PostToolUse + Stop hooks, every edit | 100% automatic |
| **Agents** | Optional specialization | Explicit delegation or `/swarm` only | Never automatic |
| **Routines** | Automate | Cloud-hosted sessions on schedule/webhook/API | Unattended, 24/7 |

## Why this exists

| Problem | Without repo | With repo |
|---|---|---|
| Claude write `as any` | Ships to PR -> human catches -> feedback loop | Hook blocks immediately -> 50 tokens -> fixed |
| Claude misses meaningful behavior | Ships -> human finds regression | TDD + review require public-contract proof |
| Claude use wrong patterns | 3-5 human review cycles per PR | 0-1 human review cycles per PR |
| Forget ask accessibility | No a11y until manual audit | Every component checked automatically |
| Must babysit every step | Manual: "now write tests", "now check types" | Ordinary work plans briefly, then continues |

**How it works**: deterministic hooks guard mechanical boundaries without spending model
tokens. Skills disclose specialist knowledge when the observed task needs it. Outcome and
verification stay with one primary model.

**vs. [obra/superpowers](https://github.com/obra/superpowers)**: Superpowers give great workflow skills (TDD, debug, plan). We take their best patterns AND add what they lack: **mechanical enforcement via hooks**. Superpowers teach Claude what do. We teach AND enforce -- if Claude forget, hook catch.

## When not to use this

Honest scoping -- this harness is **opinionated**. Here's when to skip it or fork it:

| Don't use if | Why |
|---|---|
| Backend-only repo (Go/Python/Rust) | React/TypeScript hooks add no value; fork the lifecycle skills only |
| Non-React frontend (Vue, Svelte, Angular) | ~80% of checks are React-specific |
| Throwaway prototype / spike | Stop gate blocks commits without tests; kills exploration velocity (set `ORCHESTRATION_STRICT=0` if keeping the plugin) |
| Can't use Bun | `enforce-toolchain.sh` bans npm/npx/yarn by default (configurable, but friction) |
| No Claude Code / Codex access | Hooks are harness-specific; nothing to enforce |
| Stack: not (TanStack Router + ConnectRPC + Protobuf v2) | Many setup skills assume this; fork to strip them |
| Team rejects opinionation | Setup skills pin choices (Biome over ESLint, TypeScript 7 `tsc` over preview-era `tsgo`, Vitest over Jest) |

**Partial adoption works.** Install only the specialist skills or hook groups your tasks
and evals justify.

## Skills catalog

Most work needs no named skill. `/development-lifecycle` provides the compact execution
contract for frontend implementation. Everything else is optional specialist guidance or
an explicit artifact command.

| Category | What it covers | Representative skills |
|---|---|---|
| Workflow | Build, ship, review, debug | `/development-lifecycle`, `/go`, `/review`, `/diagnosing-bugs` |
| Kits | Bundles that install groups | `/frontend-starter-kit` (profiles: `full`, `minimal`, `redpanda`, per-tool), `/work-automation-kit`, `/codex-compat` |
| Guidance | Auto-load on matching files | `/accessibility`, `/tanstack-router`, `/connect-query`, `/e2e-testing`, `/registry-workflow`, `/ux-copy` |
| Infra | Slash-only setup | `/setup-routines` (cloud automation), `/setup-atlassian-workflow` (Jira via acli) |
| Agents | Optional, explicit delegation | `code-reviewer` (PR correctness), `verifier` (read-only verification) |

The generated authoritative catalog with every skill and its trigger lives in [ask-ben/SKILL.md](ask-ben/SKILL.md).

## How it works

Three layers automation run without manual invocation:

**Layer 1 -- Dynamic Context** (every prompt, ~30ms): Record the requested endpoint and inject only facts the model cannot know, such as current branch and explicit PR identity. It does not prescribe a workflow.

**Layer 2 -- Pattern Enforcement** (every Edit/Write, ~293ms): PostToolUse hooks catch violations real-time. Claude see error, fix, hook re-check -- cycle repeat until clean. Plus file-aware guidance: write test file -> async leak tips, write component -> accessibility checklist.

**Layer 3 -- Quality Gate** (when Claude finishes, <10s): Stop hooks verify local quality,
reject silent completion once, and enforce only the requested endpoint. Local implementation
never auto-commits or opens a PR.

**Auto-loading skills**: Skills with `paths:` frontmatter auto-load when Claude work on matching files. Write test -> TDD patterns load. Edit route -> TanStack Router patterns load. No `/skill-name` invocation needed.

Never see hook output directly. Claude just produce better code, with tests, accessible, secure, type-safe -- without asking each thing individually.

### Configuration

| Env var | Default | What does |
|---------|---------|--------------|
| `PROMPT_CONTEXT_LEVEL` | `standard` | How much state inject per prompt (`minimal`, `standard`, `full`) |
| `ORCHESTRATION_STRICT` | `1` | Set `0` during prototyping to disable "must have tests" gate |
| `REACT_COMPILER_MODE` | `infer` | Set `annotation` for brownfield codebases |
| `HOOK_VERBOSITY` | `normal` | `terse` = blocks only (suppress warns), `quiet` = all output suppressed |
| `HOOKS_FAIL_CLOSED` | `0` | Set `1` to block on hook script errors (catch misconfiguration) |
| `HOOK_SHADOW_RULES` | empty | Comma-separated non-strict rule labels to log without steering or blocking |

Use shadow mode for controlled model-release holdouts. Compare equivalent tasks with
version-qualified telemetry before retaining or deleting a rule. Strict blocks and
permission denials are never shadowed.

## Why hooks over skills over manual prompting

| Approach | Reliability | Token cost | Latency | Human effort |
|----------|-------------|------------|---------|--------------|
| Manual prompting | 0% (forgotten) | 0 extra | 0 | High (remember every rule) |
| Skills on-demand | ~70% (Claude may skip) | ~500 tokens/skill | ~0ms | Low |
| Skills with `paths:` | ~90% (auto-load on file match) | ~500 tokens/skill | ~0ms | None |
| PostToolUse hooks | 100% (always fires) | 0 (bash scripts) | ~293ms | None |
| UserPromptSubmit hooks | 100% (every prompt) | 0 (bash) + context | ~120ms | None |
| Stop hooks | 100% (every turn end) | 0 (bash) + test run | ~4-10s | None |

## Hook architecture

Hooks fire automatic at each stage of Claude Code session. PostToolUse hooks run concurrent for speed; Stop hooks run sequential as final quality gate.

```mermaid
graph TD
    SS["SessionStart\nsession-env.sh, llm-env.sh"]
    UP["UserPromptSubmit\nuser-prompt-context.sh\nintent-detect.sh"]
    PRE["PreToolUse -- Bash\nenforce-toolchain.sh\nllm-test-flags.sh\nconventional-commits-check.sh"]

    subgraph POST ["PostToolUse -- Edit|Write (~293ms, concurrent)"]
        direction LR
        P1["react-rules\ntailwind\naccessibility"]
        P2["zustand\ntanstack-router\nconnect-query"]
        P3["query-pattern\nform-mode\nerror-boundary"]
        P4["test-perf\nux-copy\norchestration-guidance"]
    end

    PB["PostToolUse -- Bash\nllm-truncate.sh"]

    subgraph STOP ["Stop (~5-13s, sequential)"]
        direction TB
        ST1["biome-autofix.sh\nlint:fix changed files"]
        ST2["typecheck-stop.sh\ntsgo + related tests"]
        ST3["react-doctor-stop.sh\ndiagnostic gate"]
        ST4["orchestration-stop.sh\nsecurity-sensitive changes"]
        ST5["completion-contract-stop.sh\nvisible terminal status"]
        ST1 --> ST2 --> ST3 --> ST4 --> ST5
    end

    SS --> UP --> PRE --> POST --> PB --> STOP

    style POST fill:#ffe,stroke:#cc0
    style STOP fill:#fee,stroke:#c00
```

The authoritative hook inventory (every lifecycle event and the scripts wired to it) lives in [skill-manifest.json](skill-manifest.json), the source of truth that generates the plugin hook configs. Non-JS/TS file edits (Go, Python, Markdown, and so on) get zero overhead -- all hooks exit immediately on non-matching file extensions.

## Toolchain enforcement

Bootstrap setup consolidated into **one skill** (4.27.0): `/frontend-starter-kit` with
profiles `full | minimal | redpanda | <tool>`. Each tool's install steps live in
`frontend-starter-kit/references/<tool>/` and load lazily -- toolchain (bun+TypeScript 7 `tsc`, destructive
command guards), biome (+Ultracite, auto-fix Stop hook), quality-gate, agent-config,
react-compiler, react-rules, zustand, env-validation (t3-env+zod), conventional-commits,
react-doctor, ci-pipeline, redpanda (registry workflow, `REDPANDA_KIT=1`).

Daily-work guidance formerly hidden behind `setup-` names is now directly model-invoked:
`/accessibility`, `/tanstack-router`, `/connect-query`, `/e2e-testing`, `/registry-workflow`,
`/ux-copy`. Optional infra stays slash-only: `/setup-routines` (cloud routines) and `/setup-atlassian-workflow` (Jira via acli).

```
bunx skills@latest add malinskibeniamin/skills/frontend-starter-kit --agent claude-code -y
```

## Codex compatibility

Codex = first-class harness. Supported equivalent hooks are mapped directly: SessionStart, UserPromptSubmit, PreToolUse, PostToolUse, Stop, plus Codex-only PermissionRequest through an adapter that reuses hard-deny Bash/MCP guardrails. Claude PostToolUseFailure maps to Codex PostToolUse because Codex post-tool hooks include failed Bash commands. Claude-only events without Codex equivalents (FileChanged, compact hooks, SessionEnd, Subagent hooks, WorktreeCreate) stay Claude-only until Codex adds matching lifecycle events. `AGENTS.md` at repo root replaces PostCompact context re-injection.

All hook paths use `$(git rev-parse --show-toplevel)` for resolution -- works from any CWD, silently skip in repos without hooks installed.

- **codex-compat** -- Install `.codex/hooks.json`, batch checker, `AGENTS.md`. Session state harness-agnostic (`CLAUDE_SESSION_ID` or `CODEX_SESSION_ID`).

  ```
  bunx skills@latest add malinskibeniamin/skills/codex-compat --agent claude-code -y
  ```

## Evals

Two layers testing prevent regressions:

**Script-level evals** -- verify hook scripts, file structure, content. Run locally in <5 seconds:

```
./evals/run.sh
```

**Agent-level evals** -- behavioral tests using [@vercel/agent-eval](https://github.com/vercel-labs/agent-eval) verify Claude Code actually follows rules when given adversarial prompts. Runs in Docker sandbox:

```
cd agent-evals && bun install --yarn && npx @vercel/agent-eval
```

Run only the adversarial AIP design review with `npx @vercel/agent-eval aip`.

## Credits and provenance

Everything this harness uses from [mattpocock/skills](https://github.com/mattpocock/skills) is vendored locally -- nothing needs installing from the upstream repo. Vendored: `ask-ben`, `tdd`, `triage`, `diagnosing-bugs`, `handoff`, `codebase-design`, `improve-codebase-architecture`, `domain-modeling`, `grilling`, `prototype`, `research` (v1.1.0 rewrite, restored on owner request), `teach` (slash-only, kept on owner request), `to-questionnaire`, `to-spec`, `to-tickets`, `wait-what`, `writing-for-agents`, `resolving-merge-conflicts`, `wayfinder`, `wizard`. Upstream skills judged dead, off-domain, superseded, or contradictory to this harness (obsidian-vault, scaffold-exercises, implement, loop-me, migrate-to-shoehorn, setup-pre-commit, git-guardrails-claude-code, edit-article, batch-grill-me, spawn) are not registered.

Several workflow skills are vendored from [Builder.io](https://www.builder.io) Agent-Native patterns (`/visual-plan`, `/visual-recap`, `/agent-watchdog`, `/plan-arbiter`, `/plow-ahead`, `/read-the-damn-docs`, `/efficient-frontier`) and from the Cursor Team Kit (`/what-did-i-get-done`).

TanStack packages ship version-matched guidance through TanStack Intent. `/tanstack-intent`
discovers and loads the installed framework's task-specific skills before any TanStack
answer or change; the full starter kit runs `bunx @tanstack/intent@latest install --map`
and installs the official Claude/Codex hooks. Lifecycle patterns (TDD red/green, grilling,
writing-for-agents) are inspired by or vendored from [obra/superpowers](https://github.com/obra/superpowers); this harness adds mechanical enforcement on top.

## Security review: intentionally absent

Model-driven security review (per-edit security-audit hook, the review security hat, auth-path adversarial triggers) was removed by owner decision on 2026-07-10 after persistent false-positive flagging of legitimate cybersecurity work. Deterministic scanning (`/snyk-ux-security`, Biome) remains. Do not assume security coverage from this harness; restore from git history when model precision improves.
