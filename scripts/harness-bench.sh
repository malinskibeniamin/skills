#!/usr/bin/env bash
set -euo pipefail

RUNS=${RUNS:-5}
CAP_SECONDS=${CAP_SECONDS:-600}
MAIN_WT=${MAIN_WT:-/tmp/bench-main}
BRANCH_WT=${BRANCH_WT:-/tmp/bench-branch}
PROMPT_TEXT=${PROMPT_TEXT:-implement a new feature and open a PR}

ROOT=$(git rev-parse --show-toplevel)
BRANCH_REF=$(git -C "$ROOT" rev-parse HEAD)
TMP_BASE=$(mktemp -d "${TMPDIR:-/tmp}/harness-bench.XXXXXX")
CLONE_DIR="$TMP_BASE/source"

cleanup() {
  if [ -d "$CLONE_DIR/.git" ]; then
    git -C "$CLONE_DIR" worktree remove --force "$MAIN_WT" >/dev/null 2>&1 || true
    git -C "$CLONE_DIR" worktree remove --force "$BRANCH_WT" >/dev/null 2>&1 || true
  fi
  rm -rf "$TMP_BASE"
}
trap cleanup EXIT

need() {
  command -v "$1" >/dev/null 2>&1 || {
    echo "missing required command: $1" >&2
    exit 1
  }
}
need git
need jq
need sort

now_us() {
  if [ -z "${EPOCHREALTIME:-}" ]; then
    echo "EPOCHREALTIME is unavailable; run with bash 5+." >&2
    exit 1
  fi
  local t sec frac
  t=$EPOCHREALTIME
  sec=${t%.*}
  frac=${t#*.}
  frac=${frac:0:6}
  while [ ${#frac} -lt 6 ]; do frac="${frac}0"; done
  echo $((10#$sec * 1000000 + 10#$frac))
}

fmt_ms() {
  local us=$1
  printf '%d.%03d' $((us / 1000)) $((us % 1000))
}

pct_change() {
  local old=$1 new=$2 scaled sign=""
  if [ "$old" -eq 0 ]; then printf 'n/a'; return; fi
  scaled=$(( (new - old) * 1000 / old ))
  if [ "$scaled" -gt 0 ]; then sign="+"; fi
  printf '%s%d.%d%%' "$sign" $((scaled / 10)) $((scaled < 0 ? -scaled % 10 : scaled % 10))
}

median_of_values() {
  printf '%s\n' "$@" | sort -n | sed -n "$(((RUNS + 1) / 2))p"
}

byte_count_stdin() {
  LC_ALL=C wc -c | tr -d '[:space:]'
}

safe_remove_existing_path() {
  local path=$1
  [ -e "$path" ] || return 0
  case "$path" in
    /tmp/bench-main|/tmp/bench-branch) rm -rf "$path" ;;
    *) echo "Refusing to remove unexpected path: $path" >&2; exit 1 ;;
  esac
}

prepare_clone() {
  git clone --no-hardlinks --quiet "$ROOT" "$CLONE_DIR"
  if ! git -C "$CLONE_DIR" rev-parse --verify main >/dev/null 2>&1; then
    git -C "$CLONE_DIR" branch main origin/main >/dev/null
  fi
}

prepare_worktrees() {
  safe_remove_existing_path "$MAIN_WT"
  safe_remove_existing_path "$BRANCH_WT"
  prepare_clone
  git -C "$CLONE_DIR" worktree add "$MAIN_WT" main >/dev/null
  git -C "$CLONE_DIR" worktree add --detach "$BRANCH_WT" "$BRANCH_REF" >/dev/null
  if [ ! -d "$MAIN_WT/.git" ] && [ ! -f "$MAIN_WT/.git" ]; then
    echo "main worktree was not created: $MAIN_WT" >&2
    exit 1
  fi
  if [ ! -d "$BRANCH_WT/.git" ] && [ ! -f "$BRANCH_WT/.git" ]; then
    echo "branch worktree was not created: $BRANCH_WT" >&2
    exit 1
  fi
}

frontmatter_field() {
  local file=$1 key=$2
  awk -v key="$key" '
    NR == 1 && $0 == "---" { in_fm = 1; next }
    in_fm && $0 == "---" { exit }
    in_fm && index($0, key ":") == 1 {
      sub("^[^:]+:[[:space:]]*", "")
      print
      exit
    }
  ' "$file" 2>/dev/null || true
}

frontmatter_disable_model_invocation() {
  local file=$1
  awk '
    NR == 1 && $0 == "---" { in_fm = 1; next }
    in_fm && $0 == "---" { exit }
    in_fm && $0 ~ /^disable-model-invocation:[[:space:]]*true[[:space:]]*$/ { found = 1 }
    END { exit(found ? 0 : 1) }
  ' "$file" 2>/dev/null
}

measure_context_tax() {
  local tree=$1 label=$2 out=$3
  local total model_count skill_bytes claude_bytes skill_rel skill_dir skill_md name desc bytes
  total=$(jq '.skills | length' "$tree/.claude-plugin/plugin.json")
  model_count=0
  skill_bytes=0
  while IFS= read -r skill_rel; do
    skill_dir="$tree/${skill_rel#./}"
    skill_md="${skill_dir%/}/SKILL.md"
    [ -f "$skill_md" ] || continue
    if frontmatter_disable_model_invocation "$skill_md"; then
      continue
    fi
    name=$(frontmatter_field "$skill_md" name)
    desc=$(frontmatter_field "$skill_md" description)
    bytes=$(printf '%s%s' "$name" "$desc" | byte_count_stdin)
    skill_bytes=$((skill_bytes + bytes))
    model_count=$((model_count + 1))
  done < <(jq -r '.skills[]' "$tree/.claude-plugin/plugin.json")
  claude_bytes=$(LC_ALL=C wc -c < "$tree/CLAUDE.md" | tr -d '[:space:]')
  printf '%s|%s|%s|%s|%s\n' "$label" "$total" "$model_count" "$skill_bytes" "$claude_bytes" >> "$out"
}

measure_surface() {
  local tree=$1 label=$2 out=$3
  local total model_count scripts wired_total event_counts skill_rel skill_md
  total=$(jq '.skills | length' "$tree/.claude-plugin/plugin.json")
  model_count=0
  while IFS= read -r skill_rel; do
    skill_md="$tree/${skill_rel#./}"
    skill_md="${skill_md%/}/SKILL.md"
    [ -f "$skill_md" ] || continue
    if ! frontmatter_disable_model_invocation "$skill_md"; then
      model_count=$((model_count + 1))
    fi
  done < <(jq -r '.skills[]' "$tree/.claude-plugin/plugin.json")
  scripts=$(find "$tree/.claude/hooks" -type f -name '*.sh' | wc -l | tr -d '[:space:]')
  wired_total=$(jq '[.hooks | to_entries[] | .value[]?.hooks[]?] | length' "$tree/.claude/settings.json")
  event_counts=$(jq -r '.hooks | to_entries | map("\(.key)=\((.value // []) | map((.hooks // []) | length) | add // 0)") | join(", ")' "$tree/.claude/settings.json")
  printf '%s|%s|%s|%s|%s|%s\n' "$label" "$total" "$model_count" "$wired_total" "$scripts" "$event_counts" >> "$out"
}

write_bench_file() {
  local tree=$1 idx=$2 file
  file="$tree/.harness-bench/BenchViolation${idx}.tsx"
  mkdir -p "$(dirname "$file")"
  cat > "$file" <<'TSX'
export function BenchViolation({ value }: { value: unknown }) {
  return <input aria-label="Bench" value={value as any} onChange={() => {}} />;
}
TSX
  printf '%s' "$file"
}

edit_payload() {
  local file=$1
  jq -nc --arg file "$file" \
    --arg old 'export function BenchViolation({ value }: { value: unknown }) { return <div>{String(value)}</div>; }' \
    --arg new 'export function BenchViolation({ value }: { value: unknown }) { return <input aria-label="Bench" value={value as any} onChange={() => {}} />; }' \
    '{hook_event_name:"PostToolUse", tool_name:"Edit", tool_input:{file_path:$file, old_string:$old, new_string:$new}}'
}

batch_payload() {
  local payload file first=true
  printf '{"hook_event_name":"PostToolBatch","tool_calls":['
  for file in "$@"; do
    payload=$(edit_payload "$file" | jq -c '{tool_name, tool_input}')
    if [ "$first" = true ]; then first=false; else printf ','; fi
    printf '%s' "$payload"
  done
  printf ']}'
}

post_tool_edit_commands() {
  local tree=$1
  jq -r '
    .hooks.PostToolUse // []
    | .[]
    | select((.matcher // "") == "" or ((.matcher // "") | test("(^|\\|)(Edit|Write)(\\||$)")))
    | .hooks[]?
    | select(.type == "command")
    | .args[1] // empty
  ' "$tree/.claude/settings.json"
}

post_tool_batch_command() {
  local tree=$1
  jq -r '
    .hooks.PostToolBatch // []
    | .[]
    | .hooks[]?
    | select(.type == "command")
    | .args[1] // empty
  ' "$tree/.claude/settings.json" | head -1
}

run_hook_command() {
  local tree=$1 sid=$2 command_text=$3 payload=$4 stdout_file=$5 stderr_file=$6
  (
    cd "$tree"
    printf '%s' "$payload" | CLAUDE_PROJECT_DIR="$tree" CLAUDE_SESSION_ID="$sid" /bin/bash -lc "$command_text"
  ) >> "$stdout_file" 2>> "$stderr_file" || true
}

run_main_chain_once() {
  local tree=$1 count=$2 sid=$3 stdout_file=$4 stderr_file=$5
  local commands=() file payload cmd i
  while IFS= read -r cmd; do commands+=("$cmd"); done < <(post_tool_edit_commands "$tree")
  i=1
  while [ "$i" -le "$count" ]; do
    file=$(write_bench_file "$tree" "$sid-$i")
    payload=$(edit_payload "$file")
    for cmd in "${commands[@]}"; do
      run_hook_command "$tree" "$sid" "$cmd" "$payload" "$stdout_file" "$stderr_file"
    done
    i=$((i + 1))
  done
}

run_branch_batch_once() {
  local tree=$1 count=$2 sid=$3 stdout_file=$4 stderr_file=$5
  local files=() i file payload cmd
  cmd=$(post_tool_batch_command "$tree")
  i=1
  while [ "$i" -le "$count" ]; do
    file=$(write_bench_file "$tree" "$sid-$i")
    files+=("$file")
    i=$((i + 1))
  done
  payload=$(batch_payload "${files[@]}")
  run_hook_command "$tree" "$sid" "$cmd" "$payload" "$stdout_file" "$stderr_file"
}

measure_hook_wall_clock() {
  local label=$1 tree=$2 mode=$3 count=$4 out=$5 raw=$6
  local times=() run sid start end elapsed stdout_file stderr_file median
  run=1
  while [ "$run" -le "$RUNS" ]; do
    sid="bench-${label}-${mode}-${count}-${run}-$$"
    rm -rf "/tmp/hook-session-${sid}" 2>/dev/null || true
    stdout_file="$TMP_BASE/${label}-${mode}-${count}-${run}.stdout"
    stderr_file="$TMP_BASE/${label}-${mode}-${count}-${run}.stderr"
    : > "$stdout_file"
    : > "$stderr_file"
    start=$(now_us)
    if [ "$mode" = "main-chain" ]; then
      run_main_chain_once "$tree" "$count" "$sid" "$stdout_file" "$stderr_file"
    else
      run_branch_batch_once "$tree" "$count" "$sid" "$stdout_file" "$stderr_file"
    fi
    end=$(now_us)
    elapsed=$((end - start))
    times+=("$elapsed")
    printf '%s %s %s-edit run %d: %s ms (%s us)\n' "$label" "$mode" "$count" "$run" "$(fmt_ms "$elapsed")" "$elapsed" >> "$raw"
    run=$((run + 1))
  done
  median=$(median_of_values "${times[@]}")
  printf '%s|%s|%s|%s|%s\n' "$label" "$mode" "$count" "$median" "$(fmt_ms "$median")" >> "$out"
}

measure_intent() {
  local tree=$1 label=$2 out=$3 raw=$4
  local sid input combined context bytes
  sid="bench-intent-${label}-$$"
  rm -rf "/tmp/hook-session-${sid}" 2>/dev/null || true
  input=$(jq -nc --arg prompt "$PROMPT_TEXT" '{hook_event_name:"UserPromptSubmit", prompt:$prompt}')
  combined=$(
    cd "$tree"
    printf '%s' "$input" | CLAUDE_PROJECT_DIR="$tree" CLAUDE_SESSION_ID="$sid" bash .claude/hooks/intent-detect.sh 2>&1 || true
  )
  context=$(printf '%s' "$combined" | jq -r '.hookSpecificOutput.additionalContext // empty' 2>/dev/null || true)
  bytes=$(printf '%s' "$context" | byte_count_stdin)
  printf '%s|%s\n' "$label" "$bytes" >> "$out"
  {
    printf '%s intent bytes: %s\n' "$label" "$bytes"
    printf '%s\n' "$context" | sed 's/^/  /'
  } >> "$raw"
}

run_eval_with_cap() {
  local tree=$1 label=$2 out=$3 raw=$4
  local log_file pid start end elapsed exit_code=0 timed_out=false now elapsed_sec footer stopped
  log_file="$TMP_BASE/${label}-evals.log"
  : > "$log_file"
  start=$(now_us)
  (
    cd "$tree"
    bash evals/run.sh
  ) > "$log_file" 2>&1 &
  pid=$!
  while kill -0 "$pid" 2>/dev/null; do
    now=$(now_us)
    elapsed_sec=$(((now - start) / 1000000))
    if [ "$elapsed_sec" -ge "$CAP_SECONDS" ]; then
      timed_out=true
      kill "$pid" 2>/dev/null || true
      sleep 2
      kill -9 "$pid" 2>/dev/null || true
      break
    fi
    sleep 1
  done
  wait "$pid" 2>/dev/null || exit_code=$?
  end=$(now_us)
  elapsed=$((end - start))
  footer=$(grep -E 'Results: [0-9]+ passed, [0-9]+ failed, [0-9]+ skipped' "$log_file" | tail -1 || true)
  stopped=$(grep -E '^\[[^]]+\]$' "$log_file" | tail -1 || true)
  if [ "$timed_out" = true ]; then
    printf '%s|timeout|%s|%s|%s|%s\n' "$label" "$(fmt_ms "$elapsed")" "$footer" "$stopped" "$log_file" >> "$out"
  else
    printf '%s|exit %s|%s|%s|%s|%s\n' "$label" "$exit_code" "$(fmt_ms "$elapsed")" "$footer" "$stopped" "$log_file" >> "$out"
  fi
  {
    printf '%s eval status: %s, elapsed %s ms\n' "$label" "$([ "$timed_out" = true ] && printf timeout || printf 'exit %s' "$exit_code")" "$(fmt_ms "$elapsed")"
    printf '%s eval footer: %s\n' "$label" "${footer:-<none>}"
    printf '%s eval last marker: %s\n' "$label" "${stopped:-<none>}"
    printf '%s eval tail:\n' "$label"
    tail -40 "$log_file" | sed 's/^/  /'
  } >> "$raw"
}

print_comparison() {
  local hooks_file=$1 context_file=$2 surface_file=$3 intent_file=$4 eval_file=$5 raw_file=$6
  local main_1 branch_1 main_4 branch_4 main_tax branch_tax main_skill_bytes branch_skill_bytes main_claude branch_claude
  local main_surface_total main_surface_model main_wired main_scripts main_events
  local branch_surface_total branch_surface_model branch_wired branch_scripts branch_events
  local main_intent branch_intent main_eval branch_eval label total model wired scripts events
  main_1=$(awk -F'|' '$1=="main" && $3=="1" {print $4}' "$hooks_file")
  branch_1=$(awk -F'|' '$1=="branch" && $3=="1" {print $4}' "$hooks_file")
  main_4=$(awk -F'|' '$1=="main" && $3=="4" {print $4}' "$hooks_file")
  branch_4=$(awk -F'|' '$1=="branch" && $3=="4" {print $4}' "$hooks_file")
  main_skill_bytes=$(awk -F'|' '$1=="main" {print $4}' "$context_file")
  branch_skill_bytes=$(awk -F'|' '$1=="branch" {print $4}' "$context_file")
  main_claude=$(awk -F'|' '$1=="main" {print $5}' "$context_file")
  branch_claude=$(awk -F'|' '$1=="branch" {print $5}' "$context_file")
  main_tax=$((main_skill_bytes + main_claude))
  branch_tax=$((branch_skill_bytes + branch_claude))

  echo "# Harness benchmark"
  echo ""
  echo "Branch ref: $BRANCH_REF"
  echo "Main worktree: $MAIN_WT"
  echo "Branch worktree: $BRANCH_WT"
  echo "Runs per hook timing scenario: $RUNS"
  echo "Eval cap per tree: ${CAP_SECONDS}s"
  echo ""
  echo "## Comparison table"
  echo ""
  echo "| Metric | Main | Branch | Change |"
  echo "|---|---:|---:|---:|"
  printf '| 1-edit hook wall-clock median | %s ms | %s ms | %s |\n' "$(fmt_ms "$main_1")" "$(fmt_ms "$branch_1")" "$(pct_change "$main_1" "$branch_1")"
  printf '| 4-edit hook wall-clock median | %s ms | %s ms | %s |\n' "$(fmt_ms "$main_4")" "$(fmt_ms "$branch_4")" "$(pct_change "$main_4" "$branch_4")"
  printf '| Session-start context tax | %s bytes | %s bytes | %s |\n' "$main_tax" "$branch_tax" "$(pct_change "$main_tax" "$branch_tax")"
  printf '| Model-invoked skill metadata | %s bytes | %s bytes | %s |\n' "$main_skill_bytes" "$branch_skill_bytes" "$(pct_change "$main_skill_bytes" "$branch_skill_bytes")"
  printf '| CLAUDE.md | %s bytes | %s bytes | %s |\n' "$main_claude" "$branch_claude" "$(pct_change "$main_claude" "$branch_claude")"
  while IFS='|' read -r label total model wired scripts events; do
    if [ "$label" = main ]; then
      main_surface_total=$total; main_surface_model=$model; main_wired=$wired; main_scripts=$scripts; main_events=$events
    else
      branch_surface_total=$total; branch_surface_model=$model; branch_wired=$wired; branch_scripts=$scripts; branch_events=$events
    fi
  done < "$surface_file"
  printf '| Skills total | %s | %s | %s |\n' "$main_surface_total" "$branch_surface_total" "$(pct_change "$main_surface_total" "$branch_surface_total")"
  printf '| Model-invoked skills | %s | %s | %s |\n' "$main_surface_model" "$branch_surface_model" "$(pct_change "$main_surface_model" "$branch_surface_model")"
  printf '| Wired hooks total | %s | %s | %s |\n' "$main_wired" "$branch_wired" "$(pct_change "$main_wired" "$branch_wired")"
  printf '| Hook scripts under .claude/hooks (*.sh) | %s | %s | %s |\n' "$main_scripts" "$branch_scripts" "$(pct_change "$main_scripts" "$branch_scripts")"
  main_intent=$(awk -F'|' '$1=="main" {print $2}' "$intent_file")
  branch_intent=$(awk -F'|' '$1=="branch" {print $2}' "$intent_file")
  printf '| Intent-detect additionalContext | %s bytes | %s bytes | %s |\n' "$main_intent" "$branch_intent" "$(pct_change "$main_intent" "$branch_intent")"
  main_eval=$(awk -F'|' '$1=="main" {summary=$4; if (summary=="") summary="no footer; stopped at " $5; print $3 " (" $2 ") — " summary}' "$eval_file")
  branch_eval=$(awk -F'|' '$1=="branch" {summary=$4; if (summary=="") summary="no footer; stopped at " $5; print $3 " (" $2 ") — " summary}' "$eval_file")
  printf '| Eval depth | %s | %s | n/a |\n' "$main_eval" "$branch_eval"
  echo ""
  echo "## Wired hook counts per event"
  echo ""
  printf -- '- Main: %s\n' "$main_events"
  printf -- '- Branch: %s\n' "$branch_events"
  echo ""
  echo "## Raw runs"
  echo ""
  cat "$raw_file"
}

main() {
  local hooks_file context_file surface_file intent_file eval_file raw_file
  hooks_file="$TMP_BASE/hook-results.psv"
  context_file="$TMP_BASE/context-results.psv"
  surface_file="$TMP_BASE/surface-results.psv"
  intent_file="$TMP_BASE/intent-results.psv"
  eval_file="$TMP_BASE/eval-results.psv"
  raw_file="$TMP_BASE/raw.txt"
  : > "$hooks_file"
  : > "$context_file"
  : > "$surface_file"
  : > "$intent_file"
  : > "$eval_file"
  : > "$raw_file"

  prepare_worktrees
  measure_hook_wall_clock main "$MAIN_WT" main-chain 1 "$hooks_file" "$raw_file"
  measure_hook_wall_clock branch "$BRANCH_WT" branch-batch 1 "$hooks_file" "$raw_file"
  measure_hook_wall_clock main "$MAIN_WT" main-chain 4 "$hooks_file" "$raw_file"
  measure_hook_wall_clock branch "$BRANCH_WT" branch-batch 4 "$hooks_file" "$raw_file"
  measure_context_tax "$MAIN_WT" main "$context_file"
  measure_context_tax "$BRANCH_WT" branch "$context_file"
  measure_surface "$MAIN_WT" main "$surface_file"
  measure_surface "$BRANCH_WT" branch "$surface_file"
  measure_intent "$MAIN_WT" main "$intent_file" "$raw_file"
  measure_intent "$BRANCH_WT" branch "$intent_file" "$raw_file"
  run_eval_with_cap "$MAIN_WT" main "$eval_file" "$raw_file"
  run_eval_with_cap "$BRANCH_WT" branch "$eval_file" "$raw_file"
  print_comparison "$hooks_file" "$context_file" "$surface_file" "$intent_file" "$eval_file" "$raw_file"
}

main "$@"
