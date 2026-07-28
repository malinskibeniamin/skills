#!/bin/bash
set -eo pipefail
trap 'exit 0' ERR

# FileChanged matcher: dependency manifests/lockfiles
# Dependencies changed -- remind about install, audit, and PR evidence.

input=$(cat 2>/dev/null || echo '{}')
file=$(echo "$input" | jq -r '.filename // .file_path // empty' 2>/dev/null)
[ -n "$file" ] || exit 0

msg=""
run_audit=false
case "$file" in
  */package.json|package.json)
    msg="package.json changed. Run \`bun install\` and verify affected call sites. If this is a version upgrade, run /upgrade-dependency; otherwise record the dependency add/remove reason."
    run_audit=true
    # Package admission: heavy/banned deps blocked at the manifest, not just at
    # import time (Biome noRestrictedImports cannot reject an unused dependency).
    banned=$(jq -r '(.dependencies // {}) | keys[]' "$file" 2>/dev/null \
      | grep -xE 'moment|lodash|jquery|core-js|classnames' | head -5 | tr '\n' ' ' || true)
    if [ -n "$banned" ]; then
      echo "{\"decision\":\"block\",\"reason\":\"Banned heavy dependency in package.json: ${banned}-- use date-fns/lodash-es/clsx/native platform. Biome blocks the imports; this guard blocks the admission.\"}" >&2
      exit 2
    fi
    ;;
  */bun.lock|bun.lock)
    msg="bun.lock changed. Verify it matches package.json and the intended install. If this is a version upgrade, run /upgrade-dependency; ordinary install drift does not require that workflow."
    run_audit=true
    ;;
  */yarn.lock|yarn.lock)
    msg="yarn.lock changed. Verify the Snyk mirror matches bun.lock. If this is a version upgrade, run /upgrade-dependency; ordinary mirror regeneration does not require it."
    run_audit=true
    ;;
  */bun.lockb|bun.lockb)
    msg="bun.lockb changed. Prefer text bun.lock. If this is a version upgrade, run /upgrade-dependency; otherwise regenerate the supported lockfile."
    run_audit=true
    ;;
  */go.mod|go.mod)
    msg="go.mod changed. Run \`go mod tidy\` and verify affected packages. If this is a version upgrade, run /upgrade-dependency; otherwise record the module add/remove reason."
    run_audit=true
    ;;
  */go.sum|go.sum)
    msg="go.sum changed. Verify it matches go.mod and \`go mod tidy\`. If this is a version upgrade, run /upgrade-dependency; ordinary checksum drift does not require it."
    run_audit=true
    ;;
  */package-lock.json|package-lock.json)
    msg="package-lock.json detected in bun project -- wrong. Delete it; keep bun.lock/yarn.lock only when needed."
    ;;
esac

# Auto-audit on lockfile/manifest change. Prefer snyk, fall back to bun.
# Graceful skip if neither installed. npm tools are banned per toolchain.
if [ "$run_audit" = true ]; then
  audit_result=""
  if command -v snyk >/dev/null 2>&1; then
    audit_result=$(snyk test --severity-threshold=high --json 2>/dev/null \
      | jq -r '.vulnerabilities[]? | "\(.severity | ascii_upcase) \(.packageName)@\(.version): \(.title)"' 2>/dev/null | head -5 || true)
  elif command -v bun >/dev/null 2>&1; then
    audit_result=$(bun audit 2>/dev/null | grep -E '(HIGH|CRITICAL)' | head -5 || true)
  fi
  if [ -n "$audit_result" ]; then
    msg="$msg | vulns: $(printf '%s' "$audit_result" | tr '\n' ';' | head -c 300)"
  fi
fi

[ -n "$msg" ] || exit 0
echo "{\"suppressOutput\":true,\"systemMessage\":\"[deps] $msg\"}"
exit 0
