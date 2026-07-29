#!/bin/bash
set -eo pipefail
trap 'exit 0' ERR

# FileChanged matcher: src/env.ts
# Env schema is the contract between app and its configured deployment surfaces.

input=$(cat 2>/dev/null || echo '{}')
file=$(echo "$input" | jq -r '.filename // .file_path // empty' 2>/dev/null)
[ -n "$file" ] || exit 0

case "$file" in
  */src/env.ts|src/env.ts)
    owners=""
    [ -f .env.example ] && owners="$owners .env.example"
    [ -d .github/workflows ] && owners="$owners .github/workflows"
    for directory in deploy deployment infra helm k8s kubernetes; do
      [ -d "$directory" ] && owners="$owners $directory/"
    done
    owners=$(printf '%s' "$owners" | xargs 2>/dev/null || true)
    [ -n "$owners" ] || owners="the repository's discovered environment consumers"
    msg="src/env.ts changed. Update only existing deployment owners: $owners. Add examples, secrets, or CI variables only where that surface already exists; verify missing-variable startup behavior."
    echo "{\"suppressOutput\":true,\"systemMessage\":\"[env] $msg\"}"
    ;;
esac

exit 0
