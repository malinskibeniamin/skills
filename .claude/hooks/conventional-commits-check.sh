#!/bin/bash
set -euo pipefail
_lib="$(dirname "$0")/_hook-lib.sh"; if [ -f "$_lib" ]; then source "$_lib"; else _m="${TMPDIR:-/tmp}/frontend-skills-broken.${CLAUDE_SESSION_ID:-fs}"; [ -f "$_m" ] || { echo "[frontend-skills] _hook-lib.sh unavailable - run: /plugin install frontend-skills --force" >&2; touch "$_m" 2>/dev/null; }; exit 0; fi

hook_parse_bash

# The subject is the FIRST -m (git turns later -m flags into body paragraphs)
# or the first line of the -F file. git rejects -m together with -F, so
# whichever message flag comes first after `git commit` owns the subject.
_commit_re='git[[:space:]]+((-C|-c)[[:space:]]+[^[:space:]]+[[:space:]]+)*commit([[:space:]].*)$'
[[ $command =~ $_commit_re ]] || exit 0
_after="${BASH_REMATCH[3]}"
# POSIX ERE takes the leftmost match, so this lands on the first message flag.
_flag_re='(^|[[:space:]])(-[a-zA-Z]*[mF]|--message|--file)(=|[[:space:]]*)(.*)$'
[[ $_after =~ $_flag_re ]] || exit 0
_flag="${BASH_REMATCH[2]}"
_val="${BASH_REMATCH[4]}"

# Read one shell word from $_val: "double" (backslash escapes), 'single', or bare.
_first_word() {
  local v="$1" q out="" i c
  q="${v:0:1}"
  case "$q" in
    \"|\')
      for ((i = 1; i < ${#v}; i++)); do
        c="${v:i:1}"
        if [ "$q" = '"' ] && [ "$c" = '\' ]; then out+="${v:i+1:1}"; i=$((i + 1)); continue; fi
        [ "$c" = "$q" ] && break
        out+="$c"
      done
      ;;
    *) out="${v%%[[:space:]]*}" ;;
  esac
  printf '%s' "$out"
}

msg=""
case "$_flag" in
  *F|--file)
    _path=$(_first_word "$_val")
    { [ -z "$_path" ] || [ "$_path" = "-" ]; } && exit 0
    _cwd=$(printf '%s' "${_hook_input:-}" | jq -r '.cwd // empty' 2>/dev/null || true)
    case "$_path" in /*) ;; *) _path="${_cwd:-$PWD}/$_path" ;; esac
    [ -r "$_path" ] || exit 0
    msg=$(sed '/^#/d' "$_path")
    ;;
  *)
    # -m "$(cat <<'EOF' ... EOF)": the message is the heredoc body.
    if [[ $_val =~ ^\"\$\(cat[[:space:]]+\<\<-?[\'\"]?([A-Za-z_]+) ]]; then
      _delim="${BASH_REMATCH[1]}"
      msg=$(printf '%s\n' "$_val" | awk -v d="$_delim" 'NR > 1 { if ($0 ~ "^[[:space:]]*" d "[[:space:]]*$") exit; print }')
    else
      # \"... or $var: an escaped or expanded value, not a literal message
      # (for example, a commit command quoted inside another command).
      case "$_val" in \\*|\$*) exit 0 ;; esac
      msg=$(_first_word "$_val")
      case "$msg" in \$*) exit 0 ;; esac
    fi
    ;;
esac

msg=$(printf '%s\n' "$msg" | sed '/./,$!d')
[ -z "$msg" ] && exit 0

# Split into subject line
subject=$(printf '%s\n' "$msg" | head -1 | sed 's/^[[:space:]]*//')

# ── Validate type ──────────────────────────────────────────────
valid_types="feat|fix|refactor|style|test|docs|chore|perf|ci|build|revert"

if ! echo "$subject" | grep -qE "^($valid_types)\("; then
  if echo "$subject" | grep -qE "^($valid_types):"; then
    hook_deny "Missing scope in \"$subject\". Use: type(scope): description, for example $(echo "$subject" | sed -E 's/^([a-z]+):/\1(<scope>):/')."
  fi
  # Common near-miss types map 1:1, so name the exact subject to rerun with.
  _typo=$(echo "$subject" | sed -nE 's/^([A-Za-z]+)[(:].*/\1/p' | tr '[:upper:]' '[:lower:]')
  case "$_typo" in
    feature|features|add) _fixed=feat ;;
    bugfix|hotfix|bug|fixes) _fixed=fix ;;
    doc) _fixed=docs ;;
    tests) _fixed="test" ;;
    chores) _fixed=chore ;;
    *) _fixed="" ;;
  esac
  if [ -n "$_fixed" ] && echo "$subject" | grep -qE '^[A-Za-z]+\('; then
    hook_deny "Invalid commit type in \"$subject\". Rerun with: $(echo "$subject" | sed -E "s/^[A-Za-z]+/$_fixed/")"
  fi
  hook_deny "Invalid commit type in \"$subject\". Use: type(scope): description with type feat|fix|refactor|style|test|docs|chore|perf|ci|build|revert."
fi

# ── Validate scope ─────────────────────────────────────────────
if ! echo "$subject" | grep -qE "^($valid_types)\([a-z][a-z0-9_-]*\):"; then
  hook_deny "Invalid scope. Lowercase alphanumeric+hyphens: type(my-scope): desc."
fi

# ── Extract description ────────────────────────────────────────
desc=$(echo "$subject" | sed -E "s/^($valid_types)\([a-z][a-z0-9_-]*\):[[:space:]]*//" )

if [ -z "$desc" ]; then
  hook_deny "Missing description after type(scope):."
fi

# ── Validate: lowercase first letter ──────────────────────────
first_char=$(echo "$desc" | cut -c1)
if echo "$first_char" | grep -qE '[A-Z]'; then
  hook_deny "Description must start lowercase."
fi

# ── Validate: no trailing period ───────────────────────────────
if echo "$desc" | grep -qE '\.$'; then
  hook_deny "No trailing period in description."
fi

# ── Validate length (5-72 chars) ──────────────────────────────
desc_len=${#desc}
if [ "$desc_len" -lt 5 ]; then
  hook_deny "Description too short ($desc_len chars, min 5)."
fi

if [ "$desc_len" -gt 72 ]; then
  hook_deny "Description too long ($desc_len chars, max 72). Move details to body."
fi

# ── Suggest body for feat/fix ──────────────────────────────────
body=$(echo "$msg" | tail -n +2 | sed '/^$/d')
commit_type=$(echo "$subject" | sed -E "s/^($valid_types)\(.*/\1/")

if [ -z "$body" ] && { [ "$commit_type" = "feat" ] || [ "$commit_type" = "fix" ]; }; then
  echo "{\"decision\":\"allow\",\"reason\":\"Consider adding body for $commit_type commits.\"}"
  exit 0
fi

exit 0
