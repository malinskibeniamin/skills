# Evals for stack-aware delivery and Conductor worktree safety.

SKILL="$REPO_ROOT/stacked-prs/SKILL.md"
BASE_RESOLVER="$REPO_ROOT/scripts/resolve-pr-base.sh"
WORKTREE_GUARD="$REPO_ROOT/scripts/stack-worktree-conflicts.sh"

run_file_eval "$SKILL" "stacked-prs skill exists"
run_file_eval "$BASE_RESOLVER" "stack-aware PR base resolver exists"
run_executable_eval "$BASE_RESOLVER" "PR base resolver is executable"
run_file_eval "$WORKTREE_GUARD" "stack worktree guard exists"
run_executable_eval "$WORKTREE_GUARD" "stack worktree guard is executable"

run_content_eval "$SKILL" '^name: stacked-prs$' "stacked-prs has matching name"
run_content_eval "$SKILL" 'one Conductor workspace.*one stack|one workspace.*whole stack' \
  "skill defaults to one Conductor workspace per stack"
run_content_eval "$SKILL" 'git worktree list --porcelain' \
  "skill inspects branch ownership before stack mutations"
run_content_eval "$SKILL" 'gh stack view --json' \
  "skill keeps status reads non-interactive"
run_content_eval "$SKILL" 'gh stack submit --auto.*--remote origin' \
  "skill submits stacks non-interactively to origin"
run_content_eval "$SKILL" 'multiple remotes.*--remote origin|--remote origin.*multiple remotes' \
  "skill resolves multiple remotes without prompting"
run_content_eval "$SKILL" 'draft' "stack submission defaults to draft PRs"
run_content_eval "$SKILL" 'without (a )?(separate|another) permission prompt|do not ask.*force-with-lease' \
  "skill does not repeatedly ask before safe cascading updates"
run_content_eval "$SKILL" 'Never merge|merge.*explicit' \
  "skill never merges without explicit intent"
run_content_eval "$SKILL" 'gh stack link' \
  "skill provides external-link mode for worktree-per-layer workflows"

run_content_eval "$REPO_ROOT/review/SKILL.md" 'resolve-pr-base\.sh' \
  "review resolves a stack layer parent"
run_content_eval "$REPO_ROOT/commit-push-pr/SKILL.md" '[Ss]tack' \
  "commit-push-pr accounts for stack membership"
run_content_eval "$REPO_ROOT/resolve-pr-feedback/SKILL.md" 'upstack|stack' \
  "PR feedback accounts for affected upper layers"
run_content_eval "$REPO_ROOT/dogfood/SKILL.md" 'resolve-pr-base\.sh' \
  "dogfood inventories only the current PR layer"
run_content_eval "$REPO_ROOT/go/SKILL.md" '/stacked-prs' \
  "shipping routes explicit stack delivery through stacked-prs"
run_content_eval "$REPO_ROOT/.claude-plugin/plugin.json" '"\./stacked-prs/"' \
  "Claude plugin registers stacked-prs"
run_content_eval "$REPO_ROOT/scripts/generate-skill-catalog.sh" '"stacked-prs":' \
  "Codex metadata defines stacked-prs"
run_file_eval "$REPO_ROOT/codex-skills/stacked-prs/SKILL.md" \
  "generated Codex stacked-prs proxy exists"
run_file_eval "$REPO_ROOT/codex-skills/stacked-prs/agents/openai.yaml" \
  "generated Codex stacked-prs metadata exists"
run_content_eval "$REPO_ROOT/codex-skills/stacked-prs/agents/openai.yaml" 'Stacked PRs' \
  "Codex displays the PR acronym correctly"
run_content_eval "$REPO_ROOT/ask-ben/SKILL.md" '/stacked-prs' \
  "generated catalog lists stacked-prs"

if [ -x "$BASE_RESOLVER" ]; then
  _stack_base_repo=$(mktemp -d)
  _stack_base_bin=$(mktemp -d)
  git -C "$_stack_base_repo" init -q
  git -C "$_stack_base_repo" config user.email stack@example.com
  git -C "$_stack_base_repo" config user.name Stack
  printf 'base\n' > "$_stack_base_repo/file"
  git -C "$_stack_base_repo" add file
  git -C "$_stack_base_repo" commit -qm base
  git -C "$_stack_base_repo" branch -M main
  git -C "$_stack_base_repo" update-ref refs/remotes/origin/main HEAD
  git -C "$_stack_base_repo" checkout -qb layer-one
  printf 'one\n' >> "$_stack_base_repo/file"
  git -C "$_stack_base_repo" commit -qam one
  git -C "$_stack_base_repo" update-ref refs/remotes/origin/layer-one HEAD
  git -C "$_stack_base_repo" checkout -qb layer-two

  cat > "$_stack_base_bin/gh" <<'EOF'
#!/bin/sh
if [ "$1 $2" = "pr view" ]; then
  if [ -n "${FAKE_PR_BASE:-}" ]; then
    printf '%s\n' "$FAKE_PR_BASE"
    exit 0
  fi
  exit 1
fi
if [ "$1 $2 $3" = "stack view --json" ]; then
  if [ -n "${FAKE_STACK_JSON:-}" ]; then
    printf '%s\n' "$FAKE_STACK_JSON"
    exit 0
  fi
  exit 1
fi
exit 1
EOF
  chmod +x "$_stack_base_bin/gh"

  _resolved_base=$(cd "$_stack_base_repo" && PATH="$_stack_base_bin:$PATH" FAKE_PR_BASE=layer-one "$BASE_RESOLVER")
  if [ "$_resolved_base" = "origin/layer-one" ]; then
    echo "  PASS  existing PR resolves its remote parent branch"
    PASS=$((PASS + 1))
  else
    echo "  FAIL  existing PR resolves its remote parent branch (got: $_resolved_base)"
    FAIL=$((FAIL + 1)); ERRORS="$ERRORS\n  FAIL: PR parent base resolution"
  fi

  _stack_json='{"trunk":"main","currentBranch":"layer-two","branches":[{"name":"layer-one","base":"main","isCurrent":false},{"name":"layer-two","base":"layer-one","isCurrent":true}]}'
  _resolved_stack_base=$(cd "$_stack_base_repo" && PATH="$_stack_base_bin:$PATH" FAKE_STACK_JSON="$_stack_json" "$BASE_RESOLVER")
  if [ "$_resolved_stack_base" = "origin/layer-one" ]; then
    echo "  PASS  unsubmitted stack layer resolves its tracked parent"
    PASS=$((PASS + 1))
  else
    echo "  FAIL  unsubmitted stack layer resolves its tracked parent (got: $_resolved_stack_base)"
    FAIL=$((FAIL + 1)); ERRORS="$ERRORS\n  FAIL: local stack parent base resolution"
  fi

  _resolved_default=$(cd "$_stack_base_repo" && PATH="$_stack_base_bin:$PATH" "$BASE_RESOLVER")
  if [ "$_resolved_default" = "origin/main" ]; then
    echo "  PASS  ordinary branch falls back to remote trunk"
    PASS=$((PASS + 1))
  else
    echo "  FAIL  ordinary branch falls back to remote trunk (got: $_resolved_default)"
    FAIL=$((FAIL + 1)); ERRORS="$ERRORS\n  FAIL: remote trunk fallback"
  fi

  _override_base=$(cd "$_stack_base_repo" && PATH="$_stack_base_bin:$PATH" PR_BASE_REF=release/next "$BASE_RESOLVER")
  if [ "$_override_base" = "release/next" ]; then
    echo "  PASS  explicit PR base override wins"
    PASS=$((PASS + 1))
  else
    echo "  FAIL  explicit PR base override wins (got: $_override_base)"
    FAIL=$((FAIL + 1)); ERRORS="$ERRORS\n  FAIL: explicit PR base override"
  fi

  rm -rf "$_stack_base_repo" "$_stack_base_bin"
fi

if [ -x "$WORKTREE_GUARD" ]; then
  _stack_worktree_repo=$(mktemp -d)
  _stack_worktree_peer=$(mktemp -d)
  _stack_worktree_bin=$(mktemp -d)
  git -C "$_stack_worktree_repo" init -q
  git -C "$_stack_worktree_repo" config user.email stack@example.com
  git -C "$_stack_worktree_repo" config user.name Stack
  printf 'base\n' > "$_stack_worktree_repo/file"
  git -C "$_stack_worktree_repo" add file
  git -C "$_stack_worktree_repo" commit -qm base
  git -C "$_stack_worktree_repo" branch -M main
  git -C "$_stack_worktree_repo" branch layer-one
  rmdir "$_stack_worktree_peer"
  git -C "$_stack_worktree_repo" worktree add -q "$_stack_worktree_peer" layer-one
  git -C "$_stack_worktree_repo" checkout -qb layer-two

  cat > "$_stack_worktree_bin/gh" <<'EOF'
#!/bin/sh
if [ "$1 $2 $3" = "stack view --json" ]; then
  printf '%s\n' '{"trunk":"main","currentBranch":"layer-two","branches":[{"name":"layer-one","base":"main","isCurrent":false},{"name":"layer-two","base":"layer-one","isCurrent":true}]}'
  exit 0
fi
exit 1
EOF
  chmod +x "$_stack_worktree_bin/gh"

  _guard_exit=0
  _guard_output=$(cd "$_stack_worktree_repo" && PATH="$_stack_worktree_bin:$PATH" "$WORKTREE_GUARD") || _guard_exit=$?
  if [ "$_guard_exit" -eq 2 ] && printf '%s' "$_guard_output" | grep -q "layer-one"; then
    echo "  PASS  guard reports stack branches owned by another worktree"
    PASS=$((PASS + 1))
  else
    echo "  FAIL  guard reports stack branches owned by another worktree"
    FAIL=$((FAIL + 1)); ERRORS="$ERRORS\n  FAIL: stack worktree conflict detection"
  fi

  git -C "$_stack_worktree_repo" worktree remove --force "$_stack_worktree_peer"
  _clear_guard_exit=0
  (cd "$_stack_worktree_repo" && PATH="$_stack_worktree_bin:$PATH" "$WORKTREE_GUARD") || _clear_guard_exit=$?
  if [ "$_clear_guard_exit" -eq 0 ]; then
    echo "  PASS  guard allows a stack owned by the current worktree"
    PASS=$((PASS + 1))
  else
    echo "  FAIL  guard allows a stack owned by the current worktree"
    FAIL=$((FAIL + 1)); ERRORS="$ERRORS\n  FAIL: clear stack worktree ownership"
  fi
  rm -rf "$_stack_worktree_repo" "$_stack_worktree_bin"
fi
