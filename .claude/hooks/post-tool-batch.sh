#!/bin/bash
set -euo pipefail

_lib="$(dirname "$0")/_hook-lib.sh"
if [ -f "$_lib" ]; then
  source "$_lib"
else
  _m="${TMPDIR:-/tmp}/frontend-skills-broken.${CLAUDE_SESSION_ID:-fs}"
  [ -f "$_m" ] || { echo "[frontend-skills] _hook-lib.sh unavailable - run: /plugin install frontend-skills --force" >&2; touch "$_m" 2>/dev/null; }
  exit 0
fi

_hook_assert_bound_worktree
_input=$(cat)

_check_labels=(
  vendor-file-check
  react-rules-check
  tailwind-check
  accessibility-check
  zustand-check
  tanstack-router-check
  tanstack-router-gen
  connect-query-check
  aip-proto-check
  # Go checks stay GLOBAL, not golang-skill frontmatter: they act on *.proto
  # and e2e/testdata YAML, which never match the skill's *.go/go.mod paths
  # (PR 72 review) — skill scoping would silently drop coverage.
  go-proto-reserved-check
  go-test-image-pin-check
  ux-copy-check
  orchestration-guidance
  form-mode-check
  error-boundary-check
  test-convention-check
  ts-no-escape-hatches-check
  tsconfig-strict-check
  llm-failure-mode-check
  query-pattern-check
  copyright-check
  edit-loop-check
  lockfile-sync-check
)
_check_funcs=(
  run_vendor_file_check
  run_react_rules_check
  run_tailwind_check
  run_accessibility_check
  run_zustand_check
  run_tanstack_router_check
  run_tanstack_router_gen
  run_connect_query_check
  run_aip_proto_check
  run_go_proto_reserved_check
  run_go_test_image_pin_check
  run_ux_copy_check
  run_orchestration_guidance
  run_form_mode_check
  run_error_boundary_check
  run_test_convention_check
  run_ts_no_escape_hatches_check
  run_tsconfig_strict_check
  run_llm_failure_mode_check
  run_query_pattern_check
  run_copyright_check
  run_edit_loop_check
  run_lockfile_sync_check
)

for _label in "${_check_labels[@]}"; do
  # shellcheck source=/dev/null
  source "$(dirname "$0")/checks/${_label}.lib.sh"
done

tmp_dir=$(mktemp -d)
trap 'rm -rf "$tmp_dir"' EXIT
calls_file="$tmp_dir/calls.jsonl"
blocks_file="$tmp_dir/blocks"
review_file="$tmp_dir/review"
seen_file="$tmp_dir/seen"
: > "$blocks_file"
: > "$review_file"
: > "$seen_file"

# Canonical Codex apply_patch calls carry targets inside the patch body, not
# tool_input.file_path. Expand each into one synthetic per-target call (patch
# body preserved so the lib extracts added lines) BEFORE the dedup reduce.
_pb_root=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
_input=$(printf '%s' "$_input" | jq -c --arg root "$_pb_root" '
  .tool_calls = ([ (.tool_calls // [])[] |
    if (.tool_name == "apply_patch") then
      ( (if (.tool_input.command|type) == "array" then .tool_input.command[1:] | join("\n")
         elif (.tool_input.command|type) == "string" then .tool_input.command
         else (.tool_input.patch // .tool_input.input // "") end) ) as $body
      | [ $body | split("\n")[] | capture("^\\*\\*\\* (Update|Add|Delete) File: (?<f>.+)$").f ] as $targets
      | if ($targets | length) > 0 then
          $targets[] | (. as $t | {tool_name: "Edit", tool_input: {file_path: (if ($t|startswith("/")) then $t else $root + "/" + $t end), patch: $body, deleted: (($body | split("\n") | map(select(. == ("*** Delete File: " + $t))) | length) > 0)}})
        else empty end
    else . end ])
' 2>/dev/null || printf '%s' "$_input")

# A file edited more than once in the batch drops its old/new_string payload so
# hook_get_added_lines falls back to git-diff-vs-HEAD: checks then see the
# SURVIVING final-file additions (call-1 violations still present are caught;
# later-reverted lines are correctly absent), not just the last call's strings.
printf '%s' "$_input" | jq -c '
  reduce ((.tool_calls // [])[]) as $c
    ({order: [], by: {}, count: {}};
      ($c.tool_name // "") as $name |
      ($c.tool_input.file_path // "") as $fp |
      if (($name == "Edit" or $name == "Write" or $name == "MultiEdit") and $fp != "") then
        (if (.by[$fp] == null) then .order += [$fp] else . end)
        | .by[$fp] = $c
        | .count[$fp] = ((.count[$fp] // 0) + 1)
      else
        .
      end
    )
  | . as $acc
  | .order[] as $fp
  | $acc.by[$fp]
  | if ($acc.count[$fp] > 1) then .tool_input |= del(.old_string, .new_string, .content) else . end
' > "$calls_file" 2>/dev/null || true

[ -s "$calls_file" ] || exit 0

_display_path() {
  local target="$1" root=""
  root=$(git rev-parse --show-toplevel 2>/dev/null || true)
  if [ -n "$root" ]; then
    printf '%s' "${target#"$root"/}"
  else
    printf '%s' "$target"
  fi
}

_add_collected_line() {
  local display="$1" line="$2" severity rest rule message item key sink
  [ -z "$line" ] && return 0
  severity="${line%%|*}"
  rest="${line#*|}"
  rule="${rest%%|*}"
  message="${rest#*|}"
  [ -z "$rule" ] && return 0
  [ -z "$message" ] && return 0
  item="$display -- $message"
  key="$severity|$item"
  if grep -Fxq -- "$key" "$seen_file" 2>/dev/null; then
    return 0
  fi
  echo "$key" >> "$seen_file"
  case "$severity" in
    block|block-strict) sink="$blocks_file" ;;
    *) sink="$review_file" ;;
  esac
  echo "$item" >> "$sink"
}

while IFS= read -r call; do
  [ -z "$call" ] && continue
  tool_name=$(printf '%s' "$call" | jq -r '.tool_name // empty' 2>/dev/null || true)
  tool_input=$(printf '%s' "$call" | jq -c '.tool_input // {}' 2>/dev/null || echo '{}')
  file_path=$(printf '%s' "$tool_input" | jq -r '.file_path // empty' 2>/dev/null || true)
  [ -n "$file_path" ] || continue
  # Deleted apply_patch targets no longer exist on disk but path-based guards
  # (vendor-file-check) must still see them.
  _pb_deleted=$(printf '%s' "$tool_input" | jq -r '.deleted // false' 2>/dev/null || echo false)
  [ -f "$file_path" ] || [ "$_pb_deleted" = "true" ] || continue

  _hook_input=$(jq -nc --arg tool_name "$tool_name" --argjson tool_input "$tool_input" '{tool_name:$tool_name,tool_input:$tool_input}')
  _hook_tool_name="$tool_name"
  file_content=$(cat "$file_path" 2>/dev/null || true)

  if _hook_file_outside_current_worktree "$file_path"; then
    _hook_debug "skip session-touched-files: outside current worktree ($file_path)"
  else
    echo "$file_path" >> "$_hook_session_dir/session-touched-files" 2>/dev/null || true
  fi

  export HOOK_COLLECT=1
  collect_file="$tmp_dir/collect-$(printf '%s' "$file_path" | sed 's#[^A-Za-z0-9_.-]#_#g')"
  : > "$collect_file"
  HOOK_COLLECT_FILE="$collect_file"

  added_lines=""
  hook_get_added_lines || true

  _i=0
  while [ "$_i" -lt "${#_check_funcs[@]}" ]; do
    _hook_current_check="${_check_labels[$_i]}"
    ( "${_check_funcs[$_i]}" ) || true
    _i=$((_i + 1))
  done
  unset _hook_current_check

  display=$(_display_path "$file_path")
  while IFS= read -r collected; do
    _add_collected_line "$display" "$collected"
  done < "$collect_file"

done < "$calls_file"

unset HOOK_COLLECT HOOK_COLLECT_FILE

_findings_total=$(( $(wc -l < "$blocks_file" | tr -d '[:space:]') + $(wc -l < "$review_file" | tr -d '[:space:]') ))
[ "$_findings_total" -gt 0 ] || exit 0

context_file="$tmp_dir/context"
: > "$context_file"
remaining=40
emitted=0

_emit_section() {
  local title="$1" file="$2" count take
  count=$(wc -l < "$file" | tr -d '[:space:]')
  [ "${count:-0}" -gt 0 ] || return 0
  [ "$remaining" -gt 0 ] || return 0
  if [ -s "$context_file" ]; then
    echo "" >> "$context_file"
  fi
  echo "$title" >> "$context_file"
  take=$count
  if [ "$take" -gt "$remaining" ]; then
    take=$remaining
  fi
  head -n "$take" "$file" >> "$context_file"
  remaining=$((remaining - take))
  emitted=$((emitted + take))
}

_emit_section "MUST FIX before proceeding:" "$blocks_file"
_emit_section "Review:" "$review_file"

if [ "$_findings_total" -gt "$emitted" ]; then
  echo "+$((_findings_total - emitted)) more (rerun after fixing to see the rest)" >> "$context_file"
fi

_context=$(cat "$context_file")

# Hard tier: any block-severity finding turns the whole batch into a blocking
# decision (exit 2 + systemMessage), never advisory additionalContext. Warn-only
# batches stay advisory. Ordering is deterministic (file order, then check
# order), dedup by rule+message happens in _add_collected_line, truncation is
# the 40-line cap with an explicit "+N more" recovery hint.
_block_count=$(wc -l < "$blocks_file" | tr -d '[:space:]')
if [ "${_block_count:-0}" -gt 0 ]; then
  jq -n --arg msg "$_context" '{suppressOutput:true,systemMessage:$msg}' >&2
  exit 2
fi

jq -n --arg context "$_context" '{hookSpecificOutput:{hookEventName:"PostToolBatch",additionalContext:$context}}'
exit 0
