#!/bin/bash

# Shared state model for dogfood skill invocation and completion enforcement.
# This file is sourced by skill-fire-log.sh and dogfood-stop.sh.

dogfood_repo_root() {
  git rev-parse --show-toplevel 2>/dev/null
}

dogfood_base_ref() {
  if [ -n "${DOGFOOD_BASE_REF:-}" ] \
    && git rev-parse --verify "${DOGFOOD_BASE_REF}^{commit}" >/dev/null 2>&1; then
    printf '%s\n' "$DOGFOOD_BASE_REF"
    return
  fi

  local origin_head
  origin_head=$(git symbolic-ref --quiet --short refs/remotes/origin/HEAD 2>/dev/null || true)
  if [ -n "$origin_head" ] \
    && git rev-parse --verify "${origin_head}^{commit}" >/dev/null 2>&1; then
    printf '%s\n' "$origin_head"
    return
  fi

  local candidate
  for candidate in origin/main origin/master main master; do
    if git rev-parse --verify "${candidate}^{commit}" >/dev/null 2>&1; then
      printf '%s\n' "$candidate"
      return
    fi
  done

  git rev-parse --verify HEAD 2>/dev/null
}

dogfood_base_commit() {
  local base_ref
  base_ref=$(dogfood_base_ref) || return 1
  git merge-base "$base_ref" HEAD 2>/dev/null \
    || git rev-parse --verify "${base_ref}^{commit}" 2>/dev/null
}

dogfood_changed_files() {
  local root base
  root=$(dogfood_repo_root) || return 0
  base=$(dogfood_base_commit) || return 0

  {
    git -C "$root" diff --name-only "$base" -- 2>/dev/null
    git -C "$root" ls-files --others --exclude-standard 2>/dev/null
  } | LC_ALL=C sort -u
}

dogfood_path_in_skill() {
  local path="$1" root="$2" base="$3" dir
  dir=$(dirname "$path")

  while [ "$dir" != "." ] && [ "$dir" != "/" ] && [ -n "$dir" ]; do
    if [ -f "$root/$dir/SKILL.md" ] \
      || git -C "$root" cat-file -e "$base:$dir/SKILL.md" 2>/dev/null; then
      return 0
    fi
    dir=$(dirname "$dir")
  done
  return 1
}

dogfood_is_runnable_artifact() {
  local path="${1#./}" root base
  [ -n "$path" ] || return 1

  case "$path" in
    .context/*|*/.context/*|node_modules/*|*/node_modules/*|dist/*|*/dist/*|\
    build/*|*/build/*|coverage/*|*/coverage/*|.cache/*|*/.cache/*|\
    .turbo/*|*/.turbo/*)
      return 1
      ;;
    evals/*|*/evals/*|agent-evals/*|*/agent-evals/*|e2e/*|*/e2e/*|\
    tests/*|*/tests/*|__tests__/*|*/__tests__/*|*.test.*|*.spec.*|*.snap)
      return 1
      ;;
  esac

  case "$path" in
    SKILL.md|*/SKILL.md)
      return 0
      ;;
  esac

  root=$(dogfood_repo_root) || return 1
  base=$(dogfood_base_commit) || return 1
  if dogfood_path_in_skill "$path" "$root" "$base"; then
    return 0
  fi

  case "$path" in
    *.md|*.mdx|*.txt|*.rst|*.png|*.jpg|*.jpeg|*.gif|*.webp|*.svg|\
    *.ico|*.woff|*.woff2|*.ttf)
      return 1
      ;;
  esac
  return 0
}

dogfood_runnable_files() {
  local path
  while IFS= read -r path; do
    [ -n "$path" ] || continue
    if dogfood_is_runnable_artifact "$path"; then
      printf '%s\n' "$path"
    fi
  done < <(dogfood_changed_files)
}

dogfood_state_fingerprint() {
  local root base path blob executable
  root=$(dogfood_repo_root) || return 1
  base=$(dogfood_base_commit) || return 1

  {
    printf 'base\t%s\n' "$base"
    while IFS= read -r path; do
      [ -n "$path" ] || continue
      if [ -e "$root/$path" ] || [ -L "$root/$path" ]; then
        blob=$(git -C "$root" hash-object -- "$path" 2>/dev/null || printf 'unreadable')
        if [ -x "$root/$path" ]; then executable=x; else executable=-; fi
        printf 'file\t%s\t%s\t%s\n' "$path" "$blob" "$executable"
      else
        printf 'file\t%s\tdeleted\t-\n' "$path"
      fi
    done < <(dogfood_runnable_files)
  } | git -C "$root" hash-object --stdin 2>/dev/null
}

dogfood_normalize_touched_path() {
  local path="$1" root dir
  root=$(dogfood_repo_root) || return 1
  root=$(cd "$root" 2>/dev/null && pwd -P) || return 1
  case "$path" in
    /*)
      dir=$(cd "$(dirname "$path")" 2>/dev/null && pwd -P) || return 1
      path="$dir/$(basename "$path")"
      case "$path" in
        "$root"/*) printf '%s\n' "${path#"$root"/}" ;;
        *) return 1 ;;
      esac
      ;;
    *) printf '%s\n' "${path#./}" ;;
  esac
}

dogfood_receipt_is_pass() {
  local message="$1" field
  printf '%s\n' "$message" | grep -qE 'Verdict:[[:space:]]*PASS' || return 1
  for field in Entrypoint Actions Observations Repairs Limits; do
    printf '%s\n' "$message" \
      | grep -qE "(^|[*_-])[[:space:]*_-]*${field}:[[:space:]]*" \
      || return 1
  done
  return 0
}
