#!/bin/bash
set -eo pipefail

# Stop hook: use the consumer's file-scoped checks, never a whole-repo fixer.
_shim="$(dirname "$0")/source-hook-lib.sh"
if [ -f "$_shim" ]; then . "$_shim"; fi
if type hook_adopt_stdin_session &>/dev/null; then hook_adopt_stdin_session; fi
if type _hook_assert_bound_worktree &>/dev/null; then _hook_assert_bound_worktree; fi

repo_root=$(git rev-parse --show-toplevel 2>/dev/null) || exit 0
cwd=$(pwd -P)
repo_root=$(cd "$repo_root" && pwd -P)
prefix=""
[ "$cwd" = "$repo_root" ] || prefix="${cwd#"$repo_root"/}/"
[ -f package.json ] || exit 0

# check:files is read-only. Legacy Biome scripts may explicitly opt into a
# safe fixer; the final read-only check, not diagnostic text, owns the verdict.
check_script=$(jq -r '
  .scripts // {} |
  if (."check:files" | type) == "string" then "check:files"
  elif (."lint:file" | type) == "string" then "lint:file"
  else empty end
' package.json) || exit 0
[ -n "$check_script" ] || exit 0

if type hook_session_changed_files &>/dev/null; then
  all_changed=$(hook_session_changed_files "ts|tsx|mts|cts|js|jsx|mjs|cjs")
else
  all_changed=$({ git diff --name-only HEAD; git ls-files --others --exclude-standard; } | sort -u)
fi

_ui_dirs="${UI_LIB_DIRS:-components/ui}"
if [ -z "${UI_LIB_DIRS:-}" ]; then
  for dir in redpanda-ui src/ui packages/ui; do
    [ ! -d "$repo_root/$dir" ] || _ui_dirs="$_ui_dirs|$dir"
  done
fi

changed_files=()
while IFS= read -r path; do
  [ -n "$path" ] || continue
  case "$path" in "$prefix"*) path="${path#"$prefix"}" ;; *) continue ;; esac
  case "$path" in *.ts|*.tsx|*.mts|*.cts|*.js|*.jsx|*.mjs|*.cjs) ;; *) continue ;; esac
  # Preserve generated assets and avoid traversing symlinks into another owner.
  [ -f "$path" ] && [ ! -L "$path" ] || continue
  parent=$(cd "$(dirname "$path")" && pwd -P) || continue
  case "$parent/" in "$cwd/"*) ;; *) continue ;; esac
  case "$path" in *.gen.*|*_pb.*|*_connectquery.*) continue ;; esac
  if head -5 "$path" | grep -qE '(@generated|auto-generated|DO NOT EDIT)'; then continue; fi
  if printf '/%s\n' "$path" | grep -qE "/($_ui_dirs)/"; then continue; fi
  changed_files+=("./$path")
done <<< "$all_changed"
[ "${#changed_files[@]}" -gt 0 ] || exit 0

flags=()
if [ "$check_script" = "lint:file" ]; then
  flags=(-- --skip=lint/correctness/noUnusedImports)
  if type hook_has_session_tracking &>/dev/null && hook_has_session_tracking && \
    jq -e '.scripts["lint:fix:file"] | type == "string"' package.json >/dev/null; then
    # A fixer can exit nonzero even after applying safe changes. Always recheck.
    bun run lint:fix:file "${flags[@]}" "${changed_files[@]}" >/dev/null 2>&1 || true
  fi
  # Biome rejects duplicate boolean flags. Only supplement the legacy checker
  # when its declared command has not already requested strict warnings.
  if ! jq -e '.scripts["lint:file"] | contains("--error-on-warnings")' package.json >/dev/null; then
    flags=(-- --error-on-warnings --skip=lint/correctness/noUnusedImports)
  fi
fi
output=""
status=0
output=$(bun run "$check_script" "${flags[@]}" "${changed_files[@]}" 2>&1) || status=$?
[ "$status" -ne 0 ] || exit 0

message=$(printf 'File check %s failed (exit %s). Fix code or checker setup; keep verification rules intact.\n%s' \
  "$check_script" "$status" "$(printf '%s' "$output" | head -30 | cut -c1-300)")
if type hook_stop_finding &>/dev/null && type hook_stop_enforce &>/dev/null; then
  hook_stop_finding "$message"
  hook_stop_enforce
fi
# The copyable starter hook also works without the harness library.
jq -n --arg reason "$message" '{decision:"block",reason:$reason}' >&2
exit 2
