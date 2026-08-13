#!/bin/bash
set -eo pipefail
trap 'exit 0' ERR

# Shared FileChanged watch discovery (not a hook — exec'd by session-env.sh
# at SessionStart and cwd-changed.sh after /cd). FileChanged matchers are
# literal filenames only, so pattern-shaped names are found here and
# registered via the watchPaths output field. Prints up to 201 ABSOLUTE
# paths, one per line (callers cap at 200 and report the overflow).

root="${1:-$PWD}"
[ -d "$root" ] || exit 0

find "$root" -maxdepth 4 \
  \( -name '*.proto' -o -name '*.graphql' -o -name '*.graphqls' \
     -o -name 'tsconfig.*.json' -o -name 'vitest.config.*' -o -name 'rstest.config.*' \
     -o -name 'biome.json' -o -name 'biome.jsonc' -o -name 'tsconfig.json' \) \
  -not -path '*/node_modules/*' -not -path '*/.git/*' 2>/dev/null | head -201

exit 0
