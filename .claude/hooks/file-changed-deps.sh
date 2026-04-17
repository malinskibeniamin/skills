#!/bin/bash
set -eo pipefail
trap 'exit 0' ERR

# FileChanged matcher: package.json, bun.lockb
# Dependencies changed — remind about install, audit, lockfile consistency.

input=$(cat 2>/dev/null || echo '{}')
file=$(echo "$input" | jq -r '.filename // .file_path // empty' 2>/dev/null)
[ -n "$file" ] || exit 0

msg=""
case "$file" in
  */package.json|package.json)
    msg="package.json changed. Run \`bun install\` to sync bun.lockb. If adding a dep, verify peer deps and run type:check."
    ;;
  */bun.lockb|bun.lockb)
    msg="bun.lockb changed. Dependency tree shifted. Consider \`bun audit\` for vuln check before committing."
    ;;
  */package-lock.json|package-lock.json)
    msg="package-lock.json detected in bun project — this is wrong. Delete it, keep bun.lockb only. (enforce-toolchain bans npm.)"
    ;;
esac

[ -n "$msg" ] || exit 0
echo "{\"suppressOutput\":true,\"systemMessage\":\"[deps] $msg\"}" >&2
exit 0
