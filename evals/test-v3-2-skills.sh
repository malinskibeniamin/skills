# Evals for v3.2.0 additions:
#   - ETHOS.md
#   - agents/karpathy-failure-modes.md
#   - adversarial-reviewer trigger gate
#   - code-reviewer Codex wiring + karpathy required reading
#   - self-reviewer karpathy required reading
#   - cso, canary, benchmark, mux skills
#   - docs/rfc/browser-daemon.md

run_file_eval "$REPO_ROOT/ETHOS.md" "ETHOS.md exists"
for p in "Boil the Lake" "Grill Before Build" "TDD Or Bust" "Search Before Build" "No Type Escape Hatches" "Every Thread Resolved" "User Sovereignty"; do
  run_content_eval "$REPO_ROOT/ETHOS.md" "$p" "ETHOS.md has principle: $p"
done

run_file_eval "$REPO_ROOT/agents/karpathy-failure-modes.md" "karpathy-failure-modes.md exists"
run_content_eval "$REPO_ROOT/agents/karpathy-failure-modes.md" "Hallucinated APIs" "karpathy: hallucinated APIs"
run_content_eval "$REPO_ROOT/agents/karpathy-failure-modes.md" "Confident Wrong Types" "karpathy: confident wrong types"
run_content_eval "$REPO_ROOT/agents/karpathy-failure-modes.md" "Unvalidated LLM Shapes" "karpathy: unvalidated LLM shapes"
run_content_eval "$REPO_ROOT/agents/karpathy-failure-modes.md" "SSRF" "karpathy: SSRF"
run_content_eval "$REPO_ROOT/agents/karpathy-failure-modes.md" "Silent Fallbacks" "karpathy: silent fallbacks"
run_content_eval "$REPO_ROOT/agents/karpathy-failure-modes.md" "karpathy_checks" "karpathy: machine-readable checks"

run_content_eval "$REPO_ROOT/agents/adversarial-reviewer.md" "Trigger Gate" \
  "adversarial-reviewer has trigger gate"
run_content_eval "$REPO_ROOT/agents/adversarial-reviewer.md" "diff_lines > 200" \
  "adversarial-reviewer trigger: diff size"
run_content_eval "$REPO_ROOT/agents/adversarial-reviewer.md" "karpathy-failure-modes" \
  "adversarial-reviewer references karpathy checklist"
run_content_eval "$REPO_ROOT/agents/adversarial-reviewer.md" "SKIPPED" \
  "adversarial-reviewer has skip block"

run_content_eval "$REPO_ROOT/agents/code-reviewer.md" "codex exec" \
  "code-reviewer wires codex exec"
run_content_eval "$REPO_ROOT/agents/code-reviewer.md" "karpathy-failure-modes" \
  "code-reviewer references karpathy"
run_content_eval "$REPO_ROOT/agents/code-reviewer.md" "codex_status" \
  "code-reviewer handles codex-unavailable"
run_content_eval "$REPO_ROOT/agents/self-reviewer.md" "karpathy-failure-modes" \
  "self-reviewer references karpathy"

for skill in cso canary benchmark mux; do
  run_file_eval "$REPO_ROOT/$skill/SKILL.md" "$skill SKILL.md exists"
  run_content_eval "$REPO_ROOT/$skill/SKILL.md" "^name: $skill" "$skill has correct name frontmatter"
  run_content_eval "$REPO_ROOT/$skill/SKILL.md" "Use when" "$skill uses 'Use when' trigger"
done

run_file_eval "$REPO_ROOT/mux/REFERENCE.md" "mux REFERENCE.md exists"
run_content_eval "$REPO_ROOT/mux/REFERENCE.md" "session-hint" "mux REFERENCE documents session-hint"

# CSO specific
run_content_eval "$REPO_ROOT/cso/SKILL.md" "OWASP" "cso covers OWASP"
run_content_eval "$REPO_ROOT/cso/SKILL.md" "STRIDE" "cso covers STRIDE"
run_content_eval "$REPO_ROOT/cso/SKILL.md" "CRITICAL" "cso blocks on CRITICAL"

# Canary specific
run_content_eval "$REPO_ROOT/canary/SKILL.md" "15 min" "canary watches 15 min"
run_content_eval "$REPO_ROOT/canary/SKILL.md" "rollback" "canary files rollback issue"

# Benchmark specific
run_content_eval "$REPO_ROOT/benchmark/SKILL.md" "LCP" "benchmark captures LCP"
run_content_eval "$REPO_ROOT/benchmark/SKILL.md" "CLS" "benchmark captures CLS"
run_content_eval "$REPO_ROOT/benchmark/SKILL.md" "baseline" "benchmark stores baseline"

# Mux specific
run_content_eval "$REPO_ROOT/mux/SKILL.md" "git worktree add" "mux wraps git worktree add"
run_content_eval "$REPO_ROOT/mux/SKILL.md" "session-hint" "mux writes session-hint"
run_content_eval "$REPO_ROOT/mux/SKILL.md" "\\-\\-list" "mux supports --list"
run_content_eval "$REPO_ROOT/mux/SKILL.md" "clean" "mux supports clean"

# Skills registered in plugin manifest
for s in cso canary benchmark mux; do
  run_content_eval "$REPO_ROOT/.claude-plugin/plugin.json" "\"./$s/\"" \
    "plugin.json registers $s"
done

# Browser daemon RFC
run_file_eval "$REPO_ROOT/docs/rfc/browser-daemon.md" "browser-daemon RFC exists"
run_content_eval "$REPO_ROOT/docs/rfc/browser-daemon.md" "Migration Path" "RFC has migration path"
run_content_eval "$REPO_ROOT/docs/rfc/browser-daemon.md" "Non-Goals" "RFC has non-goals"
run_content_eval "$REPO_ROOT/docs/rfc/browser-daemon.md" "claude-in-chrome" "RFC references legacy MCP"
