#!/bin/bash
set -euo pipefail

path="${1:-}"
[ -n "$path" ] || {
  echo "usage: codeowners-teams.sh <repository-path>" >&2
  exit 2
}

repo_root=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
if [[ "$path" = /* ]]; then
  canonical_path=$(realpath "$path" 2>/dev/null || true)
  [ -n "$canonical_path" ] && path="$canonical_path"
fi
codeowners=""
for candidate in \
  "$repo_root/.github/CODEOWNERS" \
  "$repo_root/CODEOWNERS" \
  "$repo_root/docs/CODEOWNERS"; do
  if [ -f "$candidate" ]; then
    codeowners="$candidate"
    break
  fi
done

[ -n "$codeowners" ] || exit 0

# CODEOWNERS uses last-match-wins. Patterns containing a slash are repository-relative;
# basename patterns match at any depth.
target="${path#"$repo_root"/}"
target="${target#./}"
owners=$(
  awk -v target="$target" '
    function regex_escape(character) {
      if (character ~ /[][(){}.+^$|\\]/) return "\\" character
      return character
    }
    function codeowners_regex(pattern, rooted, has_slash, directory, output, i, character) {
      rooted = substr(pattern, 1, 1) == "/"
      has_slash = index(pattern, "/") > 0
      directory = substr(pattern, length(pattern), 1) == "/"
      sub(/^\/+/, "", pattern)
      sub(/\/+$/, "", pattern)

      output = ""
      for (i = 1; i <= length(pattern); i++) {
        character = substr(pattern, i, 1)
        if (character == "*" && substr(pattern, i, 2) == "**") {
          output = output ".*"
          i++
        } else if (character == "*") {
          output = output "[^/]*"
        } else if (character == "?") {
          output = output "[^/]"
        } else {
          output = output regex_escape(character)
        }
      }

      if (directory) output = output "/.*"
      if (!rooted && !has_slash) return "(^|.*/)" output "$"
      return "^" output "$"
    }
    /^[[:space:]]*#/ || NF < 2 { next }
    {
      pattern=$1
      regex=codeowners_regex(pattern)
      if (target ~ regex) {
        owners=""
        for (i=2; i<=NF && $i !~ /^#/; i++) owners=owners " " $i
      }
    }
    END { print owners }
  ' "$codeowners"
)

printf '%s\n' "$owners" \
  | tr ' ' '\n' \
  | grep -E '^@[^/[:space:]]+/[^/[:space:]]+$' \
  | sort -u \
  || true
