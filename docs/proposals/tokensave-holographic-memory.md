# Tokensave holographic memory integration plan

## Status

Draft proposal.

## Context

The frontend skills harness already reduces agent waste with lifecycle hooks, prompt context, quality gates, and LLM-optimized command output. The next opportunity is reducing repeated codebase exploration and preserving verified decisions across sessions.

[Tokensave](https://github.com/ScriptedAlchemy/tokensave) provides a local semantic code graph, MCP tools, token accounting, and a fact-store style memory layer. It can support the harness if used as an advisory exploration and memory substrate, not as a source of truth or primary editor.

## Recommendation

Integrate tokensave as an opt-in experiment first.

Use it for:

- Semantic orientation before broad search.
- Subagent exploration guidance.
- Impact analysis and review surface selection.
- Trust-scored, branch-aware decision memory.
- Token and exploration telemetry.

Do not initially use it for:

- Automatic file editing.
- Blocking all grep/read behavior.
- Unverified architectural conclusions.
- Global installation through default starter kits.

## Fit analysis

### Strengths

- Local-first index and memory storage.
- Tree-sitter based symbol graph across many languages.
- MCP interface designed for coding agents.
- Tools for search, context, callers, callees, impact, health, and test risk.
- Holographic memory primitives through fact storage, entity relationships, trust, and feedback.
- Codex-aware installation path and lifecycle hooks.

### Risks

- Large MCP surface can increase tool-choice noise.
- Stale indexes are possible because agent hooks cannot observe every external file or git operation.
- Persisted memory can become stale or wrong.
- Semantic graph results may miss framework-specific meaning, especially TanStack Router, connect-query, generated files, and UI registry conventions.
- Tokensave edit tools bypass the harness's normal test-driven `apply_patch` workflow.

## Design principles

1. Memory is advisory, never source of truth.
2. Exact source files must be read before editing.
3. Tokensave should reduce exploration, not replace verification.
4. Durable facts require source, date, branch, category, and trust.
5. Hooks fail open.
6. Advanced tools stay hidden until there is evidence they help.

## Default tool profile

Allow these tools first:

- `tokensave_status`
- `tokensave_context`
- `tokensave_search`
- `tokensave_outline`
- `tokensave_callers`
- `tokensave_callees`
- `tokensave_impact`
- `tokensave_files`
- `tokensave_message_search`
- `tokensave_fact_store`
- `tokensave_memory_status`

Hold these back for the MVP:

- `tokensave_str_replace`
- `tokensave_multi_str_replace`
- `tokensave_insert_at`
- `tokensave_replace_symbol`
- `tokensave_ast_grep_rewrite`

## Memory policy

Durable memory may be written only for:

- Explicit user decisions.
- Accepted plan decisions.
- ADR or docs-backed architecture decisions.
- Final handoff summaries.
- Repeated user preferences.
- Confirmed code-area ownership or invariants.

Do not persist:

- Guesses.
- Failed hypotheses.
- Transient debug observations.
- Raw test output unless linked to a fix.

Recommended trust defaults:

| Source | Trust |
| --- | ---: |
| Explicit user decision | 0.9 |
| Merged ADR or docs decision | 0.8 |
| Agent handoff | 0.6 |
| Inferred code area | 0.4 |

Every memory fact should include:

- category
- entities
- source
- repo path
- branch
- date
- related files
- `verify_before_use: true`

## Implementation phases

### Phase 0: Baseline measurement

Add a baseline script that measures recent transcript exploration cost:

- `grep`, `rg`, `find`, `sed`, and `cat` counts.
- File read volume.
- Bash output bytes.
- Subagent exploration count.
- Time to first useful edit when detectable.

Success metric: at least 25 percent fewer exploration tool calls on comparable tasks with no increase in stale-context mistakes.

### Phase 1: Optional setup skill

Create `setup-tokensave` with scripts to:

1. Detect the `tokensave` binary.
2. Install through Homebrew or Cargo when missing.
3. Run `tokensave install --local --agent codex`.
4. Run `tokensave init`.
5. Run `tokensave sync`.
6. Verify MCP config and hook installation.
7. Remind the user to trust new Codex hooks through `/hooks` when needed.

Do not add this to `frontend-starter-kit` until the experiment passes.

### Phase 2: Harness hooks

Add fail-open hooks through `skill-manifest.json`.

#### SessionStart

Create `shared/tokensave-session-start.sh`.

Behavior:

- No-op when `.tokensave/` is absent.
- Run a cheap status check.
- Inject short context with freshness and branch state.
- Remind agents to prefer tokensave context/search before broad grep.

#### UserPromptSubmit

Create `shared/tokensave-prompt-context.sh`.

Behavior:

- Inject tokensave guidance only for code exploration, review, refactor, diagnose, or architecture intents.
- Avoid repeated large context.

#### SubagentStart

Extend `shared/subagent-start.sh`.

Behavior:

- For explore, research, code-review, and adversarial-review subagents, instruct first use of tokensave context/search/impact before broad scanning.

#### PostToolUse

Create `shared/tokensave-sync-after-edit.sh`.

Behavior:

- On file edits, sync touched files only when possible.
- On branch-changing git commands, maintain branch tracking or sync.
- Fail open on all errors.

### Phase 3: Memory helpers

Create `docs/tokensave-memory-policy.md` and `shared/tokensave-record-decision.sh`.

The helper should write structured `decision`, `project`, `tool`, and `code_area` facts with required metadata and trust defaults.

### Phase 4: Skill updates

Update these skills to prefer tokensave for initial exploration when initialized:

- `prime`
- `development-lifecycle`
- `diagnose`
- `review`
- `improve-codebase-architecture`
- `grill-with-docs`
- `handoff`

Each skill must still require exact source verification before edits.

### Phase 5: Evaluation

Add eval cases under `evals/tokensave/`:

- auth refactor
- route state change
- zustand store review
- connect-query migration
- form validation bug

Run each in control and treatment modes.

Compare:

- Tool calls.
- Exploration calls.
- Files read.
- Wrong files opened.
- Time to first useful edit.
- Review finding quality.
- Final verification result.

Adopt by default only if:

- Exploration calls drop by at least 25 percent.
- Final correctness is not worse.
- No stale-memory incidents occur in the eval set.
- Setup takes less than 5 minutes.

## MVP scope

Ship first:

1. `setup-tokensave` skill.
2. Session, prompt, and subagent nudges.
3. Post-edit targeted sync.
4. Memory policy doc.
5. Five-task eval harness.

Skip first:

- Automatic memory writes at every Stop.
- Tokensave edit tools.
- Blocking grep/read.
- Global installation.
- Inclusion in `frontend-starter-kit`.
