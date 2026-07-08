# Evals for the model-routing policy and /codex delegation skill (2026-07).

run_file_eval "$REPO_ROOT/codex/SKILL.md" "codex skill exists"
run_content_eval "$REPO_ROOT/codex/SKILL.md" "codex exec" "codex skill uses codex exec"
run_content_eval "$REPO_ROOT/codex/SKILL.md" "-s read-only" "codex skill documents read-only investigation"
run_content_eval "$REPO_ROOT/codex/SKILL.md" "self-contained" "codex skill requires self-contained prompts"
run_content_eval "$REPO_ROOT/codex/SKILL.md" "GPT-5.5:" "codex skill mandates GPT-5.5: wrapper labels"
run_content_eval "$REPO_ROOT/codex/SKILL.md" "isolation.*worktree" "codex skill requires worktree isolation for parallel implementation"
run_content_eval "$REPO_ROOT/codex/SKILL.md" "budget" "codex skill notes codex work is invisible to workflow budgets"
run_content_eval "$REPO_ROOT/codex/SKILL.md" "timeout" "codex skill covers the bash timeout problem"
run_content_eval "$REPO_ROOT/codex/SKILL.md" "model: sonnet.*effort: low|sonnet.*effort. low" "codex wrapper is sonnet effort low"

run_content_eval "$REPO_ROOT/CLAUDE.md" "model routing" "CLAUDE.md has model routing section"
run_content_eval "$REPO_ROOT/CLAUDE.md" "NEVER Haiku" "CLAUDE.md bans Haiku"
run_content_eval "$REPO_ROOT/CLAUDE.md" "intelligence > taste > cost" "CLAUDE.md orders the axes"
run_content_eval "$REPO_ROOT/CLAUDE.md" "Fable-5 1/10/9" "CLAUDE.md ranks Fable-5"
run_content_eval "$REPO_ROOT/CLAUDE.md" "GPT-5.5 \(codex\) 9/5/5" "CLAUDE.md ranks GPT-5.5"
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
