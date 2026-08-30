#!/bin/bash
# Pure detector shared by the edit-time test hook and repository audit.

declarative_metadata_test_is_candidate() {
  case "$1" in
    *.test.ts|*.test.tsx|*.test.js|*.test.jsx|*.test.mjs|*.test.cjs|\
    *.spec.ts|*.spec.tsx|*.spec.js|*.spec.jsx|*.spec.mjs|*.spec.cjs|\
    *.integration.ts|*.integration.tsx|*.integration.js|*.integration.jsx|\
    */__tests__/*.ts|*/__tests__/*.tsx|*/__tests__/*.js|*/__tests__/*.jsx|\
    */__tests__/*.mjs|*/__tests__/*.cjs)
      return 0
      ;;
    *) return 1 ;;
  esac
}

declarative_metadata_test_has_escape() {
  printf '%s\n' "$1" | grep -qE '//[[:space:]]*allow:[[:space:]]*test-declarative-metadata\b'
}

_declarative_metadata_test_strip_comments() {
  if command -v perl >/dev/null 2>&1; then
    perl -0pe 's{/\*.*?\*/}{}gs; s{//[^\n]*}{}g'
  else
    grep -vE '^[[:space:]]*//' || true
  fi
}

declarative_metadata_test_detect() {
  local content="$1"
  local changed_content="${2:-$1}"
  local compact
  local target read metadata assertion matcher

  target='(package[.]json|package-lock[.]json|pnpm-lock[.]yaml|yarn[.]lock|bun[.]lockb?)'
  metadata='(dependencies|devDependencies|peerDependencies|optionalDependencies|scripts|packageManager|version)'

  printf '%s\n' "$changed_content" | grep -qE "${target}|${metadata}" || return 1
  declarative_metadata_test_has_escape "$content" && return 1

  compact=$(printf '%s\n' "$content" | _declarative_metadata_test_strip_comments | tr '\n' ' ')
  read='(readFile(Sync)?|readJson(Sync)?|Bun[.]file|Deno[.]readTextFile|require[[:space:]]*[(]|import[[:space:]]*[(]|import[^;]*from)'
  assertion='(expect[[:space:]]*[(]|assert[.](equal|strictEqual|deepEqual|match)[[:space:]]*[(])'
  matcher='(toBe|toEqual|toStrictEqual|toContain|toMatch|toMatchObject|toHaveProperty)'

  printf '%s\n' "$compact" | grep -qE "${read}[^;]*${target}" || return 1
  printf '%s\n' "$compact" | grep -qE "${assertion}[^;]*${metadata}[^;]*${matcher}|${assertion}[^;]*${matcher}[^;]*${metadata}" || return 1
  return 0
}
