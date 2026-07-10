# Evals for the model-routing policy and /codex delegation skill (2026-07).

run_file_eval "$REPO_ROOT/codex/SKILL.md" "codex skill exists"
run_content_eval "$REPO_ROOT/codex/SKILL.md" "codex exec" "codex skill uses codex exec"
run_content_eval "$REPO_ROOT/codex/SKILL.md" "-s read-only" "codex skill documents read-only investigation"
run_content_eval "$REPO_ROOT/codex/SKILL.md" "self-contained" "codex skill requires self-contained prompts"
run_content_eval "$REPO_ROOT/codex/SKILL.md" "GPT-5\.6:" "codex skill mandates GPT-5.6 wrapper labels"
run_content_eval "$REPO_ROOT/codex/SKILL.md" "isolation.*worktree" "codex skill requires worktree isolation for parallel implementation"
run_content_eval "$REPO_ROOT/codex/SKILL.md" "budget" "codex skill notes codex work is invisible to workflow budgets"
run_content_eval "$REPO_ROOT/codex/SKILL.md" "timeout" "codex skill covers the bash timeout problem"
run_content_eval "$REPO_ROOT/codex/SKILL.md" "model: sonnet.*effort: low|sonnet.*effort. low" "codex wrapper is sonnet effort low"

run_content_eval "$REPO_ROOT/CLAUDE.md" "model routing" "CLAUDE.md has model routing section"
run_content_eval "$REPO_ROOT/CLAUDE.md" "NEVER Haiku" "CLAUDE.md bans Haiku"
run_content_eval "$REPO_ROOT/CLAUDE.md" "intelligence > taste > cost" "CLAUDE.md orders the axes"
run_content_eval "$REPO_ROOT/CLAUDE.md" "Fable-5 1/10/9" "CLAUDE.md ranks Fable-5"
run_content_eval "$REPO_ROOT/CLAUDE.md" "GPT-5.6 \(codex\) 8/9/6" "CLAUDE.md ranks GPT-5.6"
run_content_eval "$REPO_ROOT/CLAUDE.md" "GPT-5.5 retired" "CLAUDE.md retires GPT-5.5"
run_content_eval "$REPO_ROOT/CLAUDE.md" "Cross-model review, automatic on every change" "CLAUDE.md mandates automatic cross-model review"
run_content_eval "$REPO_ROOT/CLAUDE.md" "author model never solely reviews its own work" "CLAUDE.md states the author-reviewer separation rule"
run_content_eval "$REPO_ROOT/AGENTS.md" "author model never solely reviews its own work" "AGENTS.md states the author-reviewer separation rule"
run_content_eval "$REPO_ROOT/codex/SKILL.md" "Adversarial exchange \(automatic" "codex skill has the automatic adversarial exchange mode"
run_content_eval "$REPO_ROOT/go/SKILL.md" "Cross-model adversarial review \(always, automatic\)" "go phase 4b runs cross-model review automatically"
run_content_eval "$REPO_ROOT/go/SKILL.md" "alternating models" "go phase 5b alternates reviewer models"
run_content_eval "$REPO_ROOT/review/SKILL.md" "Ninth hat, \*\*mandatory\*\*: cross-model" "review panel has a mandatory cross-model hat"
run_content_eval "$REPO_ROOT/review/SKILL.md" "diagnostic-only in every mode" "review is diagnostic-only; /go owns the fix loop"
run_content_eval "$REPO_ROOT/go/SKILL.md" "delegate per model routing|Fix P0/P1 now .delegate per model routing" "go owns automatic P0/P1 fix delegation"
run_content_eval "$REPO_ROOT/efficient-frontier/SKILL.md" "GPT-5.5 is retired" "efficient-frontier retires GPT-5.5"

# GPT-5.5 must not survive as an active routing target anywhere.
_stale55=$(grep -rlE "GPT-5\.5" "$REPO_ROOT/CLAUDE.md" "$REPO_ROOT/AGENTS.md" "$REPO_ROOT/codex/SKILL.md" "$REPO_ROOT/efficient-frontier/SKILL.md" "$REPO_ROOT/development-lifecycle/SKILL.md" "$REPO_ROOT/go/SKILL.md" "$REPO_ROOT/review/SKILL.md" 2>/dev/null | xargs -I{} sh -c 'grep -lE "GPT-5\.5" {} | xargs grep -LE "retired" 2>/dev/null' || true)
if [ -n "$_stale55" ]; then
  echo "  FAIL  GPT-5.5 still an active routing target in: $_stale55"
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: GPT-5.5 still active"
else
  echo "  PASS  GPT-5.5 appears only in retirement notes"
  PASS=$((PASS + 1))
fi
run_content_eval "$REPO_ROOT/CLAUDE.md" 'Fable-5: `high` or lower' "CLAUDE.md caps Fable effort at high"
run_content_eval "$REPO_ROOT/AGENTS.md" "NEVER Haiku" "AGENTS.md bans Haiku"
run_content_eval "$REPO_ROOT/efficient-frontier/SKILL.md" "Model rankings" "efficient-frontier has the rankings section"
run_content_eval "$REPO_ROOT/efficient-frontier/SKILL.md" "Never use Haiku" "efficient-frontier bans Haiku"
run_content_eval "$REPO_ROOT/agents/verifier.md" "model: sonnet" "verifier agent no longer uses haiku"

# No agent definition may use haiku
if grep -l "model: haiku" "$REPO_ROOT/agents/"*.md >/dev/null 2>&1; then
  echo "  FAIL  an agent definition still uses haiku"
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: agent definition uses haiku"
else
  echo "  PASS  no agent definition uses haiku"
  PASS=$((PASS + 1))
fi
