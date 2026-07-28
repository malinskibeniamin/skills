# Evals for the model-routing policy and /codex delegation skill (2026-07).

run_file_eval "$REPO_ROOT/codex/SKILL.md" "codex skill exists"

# Detailed Codex mechanics may live behind the SKILL.md context pointer.
run_content_eval() {
  local file="$1"
  local pattern="$2"
  local description="$3"
  local files=("$file")
  if [ "$file" = "$REPO_ROOT/codex/SKILL.md" ]; then
    files+=("$REPO_ROOT/codex/REFERENCE.md")
  fi
  if grep -qE -- "$pattern" "${files[@]}"; then
    echo "  PASS  $description"
    PASS=$((PASS + 1))
  else
    echo "  FAIL  $description (pattern not found: $pattern)"
    FAIL=$((FAIL + 1))
    ERRORS="$ERRORS\n  FAIL: $description"
  fi
}

run_content_eval "$REPO_ROOT/codex/SKILL.md" "codex exec" "codex skill uses codex exec"
run_content_eval "$REPO_ROOT/codex/SKILL.md" "-s read-only" "codex skill documents read-only investigation"
run_content_eval "$REPO_ROOT/codex/SKILL.md" "self-contained" "codex skill requires self-contained prompts"
run_content_eval "$REPO_ROOT/codex/SKILL.md" "GPT-5\.6-sol:" "codex skill mandates variant wrapper labels"
run_content_eval "$REPO_ROOT/codex/SKILL.md" "isolation.*worktree" "codex skill requires worktree isolation for parallel implementation"
run_content_eval "$REPO_ROOT/codex/SKILL.md" "budget" "codex skill notes codex work is invisible to workflow budgets"
run_content_eval "$REPO_ROOT/codex/SKILL.md" "timeout" "codex skill covers the bash timeout problem"
run_content_eval "$REPO_ROOT/codex/SKILL.md" "model: sonnet.*effort: low|sonnet.*effort. low" "codex wrapper is sonnet effort low"

run_content_eval "$REPO_ROOT/CLAUDE.md" "model routing" "CLAUDE.md has model routing section"
run_content_eval "$REPO_ROOT/CLAUDE.md" "NEVER Haiku" "CLAUDE.md bans Haiku"
run_content_eval "$REPO_ROOT/CLAUDE.md" "intelligence > taste > cost" "CLAUDE.md orders the axes"
run_content_eval "$REPO_ROOT/CLAUDE.md" "Fable-5 1/10/9" "CLAUDE.md ranks Fable-5"
run_content_eval "$REPO_ROOT/CLAUDE.md" "Opus-5 5/8/9" "CLAUDE.md ranks Opus-5"
run_content_eval "$REPO_ROOT/efficient-frontier/SKILL.md" '\| Opus-5 \| 5/8/9 \|' "efficient-frontier ranks Opus-5"
run_content_eval "$REPO_ROOT/CLAUDE.md" "Sonnet-5 6/5/5" "CLAUDE.md ranks Sonnet-5"
run_content_eval "$REPO_ROOT/efficient-frontier/SKILL.md" '\| Sonnet-5 \| 6/5/5 \|' "efficient-frontier ranks Sonnet-5"
run_content_eval "$REPO_ROOT/codex/SKILL.md" "User-facing output needs Fable or Opus taste" "user-facing routing excludes Sonnet-5"
run_content_eval "$REPO_ROOT/CLAUDE.md" "GPT-5.6 Sol \(codex\) 8/9/6" "CLAUDE.md ranks GPT-5.6 Sol"
run_content_eval "$REPO_ROOT/CLAUDE.md" "GPT-5.6 Terra 9/6/5" "CLAUDE.md ranks Terra"
run_content_eval "$REPO_ROOT/CLAUDE.md" "GPT-5.6 Luna 10/3/2" "CLAUDE.md ranks Luna"
run_content_eval "$REPO_ROOT/CLAUDE.md" "DIFFERENT family" "CLAUDE.md prefers cross-family reviewers"
run_content_eval "$REPO_ROOT/CLAUDE.md" "never product code or review" "Terra never writes product code or reviews"
run_content_eval "$REPO_ROOT/CLAUDE.md" "never development" "Luna is never used for development"
run_content_eval "$REPO_ROOT/codex/SKILL.md" "gpt-5.6-sol" "codex skill routes Sol"
run_content_eval "$REPO_ROOT/codex/SKILL.md" "gpt-5.6-terra" "codex skill routes Terra"
run_content_eval "$REPO_ROOT/codex/SKILL.md" "gpt-5.6-luna" "codex skill routes Luna"
run_content_eval "$REPO_ROOT/codex/SKILL.md" "DIFFERENT FAMILY" "codex adversarial exchange prefers cross-family"
run_content_eval "$REPO_ROOT/review/SKILL.md" "Cross-model axis" "review keeps a cross-model axis"
run_content_eval "$REPO_ROOT/review/SKILL.md" "Terra/Luna never review" "Terra and Luna banned from review"
run_content_eval "$REPO_ROOT/go/SKILL.md" "Terra/Luna never review" "Terra and Luna never review"
run_content_eval "$REPO_ROOT/efficient-frontier/SKILL.md" "GPT-5.6 Terra" "efficient-frontier ranks Terra"
run_content_eval "$REPO_ROOT/efficient-frontier/SKILL.md" "Sol.*exhaustive, explicit execution" "efficient-frontier describes Sol as exhaustive execution"
run_content_eval "$REPO_ROOT/efficient-frontier/SKILL.md" "Fable.*frontend.*sketches.*wireframes.*prototypes" "efficient-frontier routes visible and exploratory work to Fable"
run_content_eval "$REPO_ROOT/efficient-frontier/SKILL.md" "Opus.*tasteful work without orchestration" "efficient-frontier positions Opus as lower-friction taste"

# Effort floors are stated wherever a variant is routed.
run_content_eval "$REPO_ROOT/codex/SKILL.md" "implementation.*xhigh|xhigh.*implementation" "Sol implementation effort policy stated"
run_content_eval "$REPO_ROOT/codex/SKILL.md" 'model_reasoning_effort="xhigh"' "codex skill gives an executable Sol xhigh override"
run_content_eval "$REPO_ROOT/codex/SKILL.md" "Luna.*high" "Luna high-only floor stated"
run_content_eval "$REPO_ROOT/CLAUDE.md" "GPT-5.5 retired" "CLAUDE.md retires GPT-5.5"
run_content_eval "$REPO_ROOT/CLAUDE.md" "Cross-model review at non-trivial PR/ship endpoints" "CLAUDE.md scopes automatic cross-model review to delivery"
run_content_eval "$REPO_ROOT/CLAUDE.md" "author model never solely reviews its own work" "CLAUDE.md states the author-reviewer separation rule"
run_content_eval "$REPO_ROOT/AGENTS.md" "author model never solely reviews its own work" "AGENTS.md states the author-reviewer separation rule"
run_content_eval "$REPO_ROOT/codex/SKILL.md" "Adversarial exchange \(automatic" "codex skill has the automatic adversarial exchange mode"
run_content_eval "$REPO_ROOT/go/SKILL.md" "Cross-model adversarial review" "go keeps automatic cross-model review"
run_content_eval "$REPO_ROOT/go/SKILL.md" "[Dd]o not dispatch background or paired reviewers" "go avoids automatic reviewer delegation"
run_content_eval "$REPO_ROOT/go/SKILL.md" "up to 2 inline rounds" "go caps inline review rounds"
run_content_eval "$REPO_ROOT/review/SKILL.md" "Cross-model axis, \*\*mandatory for non-trivial PR/ship work\*\*" "review scopes the mandatory adversarial axis"
run_content_eval "$REPO_ROOT/review/SKILL.md" "foreground, awaited Sol high" "Claude review keeps one foreground cross-model hat"
run_content_eval "$REPO_ROOT/review/SKILL.md" "diagnostic-only in every mode" "review is diagnostic-only; /go owns the fix loop"
run_content_eval "$REPO_ROOT/CLAUDE.md" "Sol high.*checks Opus" "CLAUDE.md routes Opus adversarial review to Sol high"
run_content_eval "$REPO_ROOT/codex/SKILL.md" "Opus work gets Sol high|high for.*Opus work" "codex skill routes Opus review at high"
run_content_eval "$REPO_ROOT/codex/SKILL.md" "Sol-only.*xhigh|xhigh.*Sol-only" "codex skill routes Sol-only review at xhigh"
run_content_eval "$REPO_ROOT/CLAUDE.md" "Claude taste.*Fable high.*Fable medium.*Fable low.*Opus xhigh.*Opus medium.*Opus low" "CLAUDE.md records quota-aware taste routing"
run_content_eval "$REPO_ROOT/stay-within-limits/SKILL.md" "## Taste Profile" "stay-within-limits owns taste bands"
run_content_eval "$REPO_ROOT/development-lifecycle/SKILL.md" "[Ss]ingle owner" "implementation uses one primary owner"
run_content_eval "$REPO_ROOT/codex/SKILL.md" "Opus.*Sol high|Sol high.*Opus" "codex adversarial review checks Opus work at high"
run_content_eval "$REPO_ROOT/agents/code-reviewer.md" 'model_reasoning_effort="high"' "code-reviewer invokes Sol at high"
run_content_eval "$REPO_ROOT/go/SKILL.md" "GPT-5\\.6-sol: adversarial.*high" "go reviews Claude work with Sol high"
run_content_eval "$REPO_ROOT/go/SKILL.md" "Fix P0/P1 inline" "go fixes findings inline"

# GPT-5.5 must not survive as an active routing target anywhere.
_stale55=$(grep -hE "GPT-5\\.5" "$REPO_ROOT/CLAUDE.md" "$REPO_ROOT/AGENTS.md" "$REPO_ROOT/codex/SKILL.md" "$REPO_ROOT/efficient-frontier/SKILL.md" "$REPO_ROOT/development-lifecycle/SKILL.md" "$REPO_ROOT/go/SKILL.md" "$REPO_ROOT/review/SKILL.md" 2>/dev/null | grep -viE "retired|retirement" || true)
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
run_content_eval "$REPO_ROOT/efficient-frontier/SKILL.md" "## Model guide" "efficient-frontier has the model guide"
run_content_eval "$REPO_ROOT/agents/verifier.md" "model: sonnet" "verifier agent no longer uses haiku"

# Opus 4.8 may survive in release history, but never as an active routing target.
_stale_opus=$(grep -RInE "Opus-4\.8|claude-opus-4-8" "$REPO_ROOT" \
  --exclude-dir=.context --exclude-dir=.git --exclude-dir=node_modules \
  --exclude=CHANGELOG.md --exclude=test-model-routing.sh 2>/dev/null || true)
if [ -n "$_stale_opus" ]; then
  echo "  FAIL  Opus 4.8 still an active routing target in: $_stale_opus"
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: Opus 4.8 still active"
else
  echo "  PASS  Opus 4.8 appears only in release history"
  PASS=$((PASS + 1))
fi

# No agent definition may use haiku
if grep -l "model: haiku" "$REPO_ROOT/agents/"*.md >/dev/null 2>&1; then
  echo "  FAIL  an agent definition still uses haiku"
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: agent definition uses haiku"
else
  echo "  PASS  no agent definition uses haiku"
  PASS=$((PASS + 1))
fi
run_content_eval "$REPO_ROOT/codex/SKILL.md" "/dev/null. on background runs" "codex skill mandates stdin closure on background runs"
