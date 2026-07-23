# Evals for the model-routing policy and /codex delegation skill (2026-07).

run_file_eval "$REPO_ROOT/codex/SKILL.md" "codex skill exists"
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
run_content_eval "$REPO_ROOT/review/SKILL.md" "cross-FAMILY" "review ninth hat prefers cross-family"
run_content_eval "$REPO_ROOT/review/SKILL.md" "Terra/Luna never review" "Terra and Luna banned from review"
run_content_eval "$REPO_ROOT/go/SKILL.md" "Terra/Luna never review" "Terra and Luna never review"
run_content_eval "$REPO_ROOT/efficient-frontier/SKILL.md" "GPT-5.6 Terra" "efficient-frontier ranks Terra"

# Effort floors are stated wherever a variant is routed.
run_content_eval "$REPO_ROOT/codex/SKILL.md" "medium.*high.*review/plan.*xhigh" "Sol effort policy stated"
run_content_eval "$REPO_ROOT/codex/SKILL.md" 'model_reasoning_effort="xhigh"' "codex skill gives an executable Sol xhigh override"
run_content_eval "$REPO_ROOT/codex/SKILL.md" 'Luna.*`high` only' "Luna high-only floor stated"
run_content_eval "$REPO_ROOT/CLAUDE.md" "GPT-5.5 retired" "CLAUDE.md retires GPT-5.5"
run_content_eval "$REPO_ROOT/CLAUDE.md" "Cross-model review, automatic on every non-trivial change" "CLAUDE.md mandates automatic cross-model review, honestly scoped"
run_content_eval "$REPO_ROOT/CLAUDE.md" "author model never solely reviews its own work" "CLAUDE.md states the author-reviewer separation rule"
run_content_eval "$REPO_ROOT/AGENTS.md" "author model never solely reviews its own work" "AGENTS.md states the author-reviewer separation rule"
run_content_eval "$REPO_ROOT/codex/SKILL.md" "Adversarial exchange \(automatic" "codex skill has the automatic adversarial exchange mode"
run_content_eval "$REPO_ROOT/go/SKILL.md" "Cross-model adversarial review" "go keeps automatic cross-model review"
run_content_eval "$REPO_ROOT/go/SKILL.md" "Native Codex runs inline and does not recurse" "go avoids recursive Codex review delegation"
run_content_eval "$REPO_ROOT/go/SKILL.md" "fresh usage before each round" "go phase 5b reroutes each reviewer round"
run_content_eval "$REPO_ROOT/review/SKILL.md" "Eighth axis, \*\*mandatory\*\*" "review panel keeps the mandatory adversarial axis"
run_content_eval "$REPO_ROOT/review/SKILL.md" "Claude-hosted always runs.*GPT-5.6-sol" "Claude review keeps the cross-model hat"
run_content_eval "$REPO_ROOT/review/SKILL.md" "diagnostic-only in every mode" "review is diagnostic-only; /go owns the fix loop"
run_content_eval "$REPO_ROOT/CLAUDE.md" "Sol.*xhigh.*review|review.*Sol.*xhigh" "CLAUDE.md routes review to Sol xhigh"
run_content_eval "$REPO_ROOT/codex/SKILL.md" "Review.*xhigh|review.*xhigh" "codex skill routes review at xhigh"
run_content_eval "$REPO_ROOT/CLAUDE.md" "Claude review/plan.*Fable.*Opus.*Sonnet|Fable.*20%.*Opus.*50%.*Sonnet.*90%" "CLAUDE.md records quota-aware Claude routing"
run_content_eval "$REPO_ROOT/efficient-frontier/SKILL.md" "Fable.*20%.*Opus.*50%.*Sonnet.*90%" "efficient-frontier records review bands"
run_content_eval "$REPO_ROOT/go/SKILL.md" "delegate per model routing|Fix P0/P1 now .delegate per model routing" "go owns automatic P0/P1 fix delegation"
run_content_eval "$REPO_ROOT/efficient-frontier/SKILL.md" "GPT-5.5 is retired" "efficient-frontier retires GPT-5.5"

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
run_content_eval "$REPO_ROOT/codex/SKILL.md" "/dev/null. on background runs" "codex skill mandates stdin closure on background runs"
