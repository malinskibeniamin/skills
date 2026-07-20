---
name: hook-audit
description: Analyze hook effectiveness + session retro from collected metrics. Use when auditing hooks, inspecting hook latency, top violations, zero-fire rules, manifest drift, session trends, or running a retro across recent sessions.
---

# Hook audit
## Step 0: Gather context

Run Bash commands before proceed:

- `ls "$(git rev-parse --show-toplevel 2>/dev/null)/.claude/hooks/"*.sh 2>/dev/null | wc -l` -- installed hook scripts
- `ls ~/.claude/hook-metrics/*.json 2>/dev/null | wc -l` -- session summaries collected
- `ls ~/.claude/hook-metrics/*.json 2>/dev/null | head -1 | xargs -I{} jq -r '.date' {}` -- earliest date
- `ls ~/.claude/hook-metrics/*.json 2>/dev/null | tail -1 | xargs -I{} jq -r '.date' {}` -- latest date

Metrics dir: `~/.claude/hook-metrics/`

Codex sessions appear twice in the dir: per-turn records in
`codex-turns.jsonl` (written by codex-notify.sh on agent-turn-complete) and
schema-v2 summaries named `*-codex-*.json` (source: "codex", turn counts, no
per-hook metrics -- Codex emits no SessionEnd). Include them in session
counts and retro flow; do not report their empty hook maps as silent hooks.

Use `/visual-plan` for large action plans, `/plan-arbiter` for contradictory recommendations, and `/agent-watchdog` when auditing routine/agent-generated reports.

## Your task

Analyze hook effectiveness across all session metrics. Read every JSON in `~/.claude/hook-metrics/`. Produce report:

### 1. Hook activity

Each hook fired >=1 across sessions:
- Total blocks, warns, nudges, denies
- Avg fires per session
- Trend: up or down over time?

### 1b. Latency profile

Parse `perf_ms` per hook from session summaries: P50, P95, invocations, total wall-clock.
Flag P95 > 100ms (perf budget breach), P95 > 500ms (critical).

### 2. Silent hooks

List hook scripts in `.claude/hooks/` with **zero entries** in any metrics file. Prune candidates -- never trigger or not wired to logging.

### 3. Over-aggressive hooks

High block counts hurt productivity:
- Blocks-per-session ratio > 3 -> flag too strict
- Same rule blocked repeat in one session -> agent retry and fail

### 4. Enforcement gaps

Cross-ref CLAUDE.md rules vs hook activity:
- Rules with hook but zero fires -> followed perfect or untested
- Rules with no hook -> advisory, no enforce

### 5. Recommendations

From data:
- **Prune**: hooks never fire (remove or merge)
- **Soften**: hooks block too much (demote to warn)
- **Harden**: warns fire often (promote to block)
- **Add**: CLAUDE.md rules with no hook enforce

### 6. Retro analytics (session flow)

Broader than hook-level. Pull from session JSONL + git log same window as metrics.

- **Sessions -> PR lag**: median time from first edit to PR open. High lag = planning thrash.
- **CI first-try pass rate**: PRs green on first CI run / total PRs. Low = hooks missed pre-commit catches.
- **Phases skipped in `/development-lifecycle`**: sessions wrote code without prior grill step (infer from session-touched-files + absence of grill markers). High skip = gate ineffective.
- **Review-round distribution**: how often hit 0/1/2/3 AI self-review rounds? Bulk at 3 = reviewer too picky or code quality trending down.
- **Human-review resolution latency**: time from human review comment -> resolved thread. High = bottleneck.
- **Worktree sprawl**: count active worktrees per repo. >4 sustained -> investigate with `/mux --list` candidates for prune.

Output per-metric: current value, 7-day trend (up/down/flat), actionable next step.

### 6a. Skill-fire audit

Read `~/.claude/hook-metrics/skill-fires.jsonl` (written by skill-fire-log.sh).
Model-invoked skills with zero fires over the window are either dead weight or have
bad trigger descriptions -- both actionable: propose delete/merge or a description
rewrite per writing-great-skills. Report top-fired skills too (candidates for
further polish). Run on demand only -- no schedule.

### 6b. Manifest drift check

```
bash scripts/generate-hook-configs.sh --check
```

Drift between `skill-manifest.json` and generated configs: RED FLAG -- regression. Run without `--check` to fix.

### Mode flags

`$ARGUMENTS`:
- empty / `--hooks` -> run sections 1-5 only (default).
- `--retro` -> run sections 1-6 with emphasis on section 6.
- `--all` -> all sections (including latency + drift), no emphasis.

### Output format

Structured report. Tables where data fit. End with prioritized action list (max 5). If <5 session files, note data limited, recs preliminary.