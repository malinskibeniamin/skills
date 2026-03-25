# Evals for setup-biome skill
# Tests file structure, SKILL.md, REFERENCE.md, and hook script content

SCRIPT="$REPO_ROOT/setup-biome/scripts/biome-autofix.sh"
SKILL_DIR="$REPO_ROOT/setup-biome"

# ── File structure ──────────────────────────────────────────────

run_file_eval "$SKILL_DIR/SKILL.md" "SKILL.md exists"
run_file_eval "$SKILL_DIR/REFERENCE.md" "REFERENCE.md exists"
run_executable_eval "$SCRIPT" "biome-autofix.sh is executable"

# ── SKILL.md content ────────────────────────────────────────────

run_content_eval "$SKILL_DIR/SKILL.md" "^name: setup-biome" "SKILL.md has correct name"
run_content_eval "$SKILL_DIR/SKILL.md" "^description:" "SKILL.md has description"
run_content_eval "$SKILL_DIR/SKILL.md" "Use when" "SKILL.md description has trigger phrase"
run_content_eval "$SKILL_DIR/SKILL.md" "ultracite" "SKILL.md mentions ultracite"
run_content_eval "$SKILL_DIR/SKILL.md" "Stop" "SKILL.md mentions Stop hook"
run_content_eval "$SKILL_DIR/SKILL.md" "noUnusedImports" "SKILL.md mentions import loop prevention"

# ── REFERENCE.md content ────────────────────────────────────────

run_content_eval "$SKILL_DIR/REFERENCE.md" "ultracite/biome/core" "REFERENCE has core extends"
run_content_eval "$SKILL_DIR/REFERENCE.md" "ultracite/biome/react" "REFERENCE has react extends"
run_content_eval "$SKILL_DIR/REFERENCE.md" "noConsole" "REFERENCE has noConsole override"
run_content_eval "$SKILL_DIR/REFERENCE.md" "maxAllowedComplexity.*15" "REFERENCE has complexity threshold 15"
run_content_eval "$SKILL_DIR/REFERENCE.md" "noDeprecatedImports" "REFERENCE has noDeprecatedImports"
run_content_eval "$SKILL_DIR/REFERENCE.md" "moment" "REFERENCE restricts moment"
run_content_eval "$SKILL_DIR/REFERENCE.md" "lodash" "REFERENCE restricts lodash"
run_content_eval "$SKILL_DIR/REFERENCE.md" "classnames" "REFERENCE restricts classnames"
run_content_eval "$SKILL_DIR/REFERENCE.md" "mobx" "REFERENCE restricts mobx"
run_content_eval "$SKILL_DIR/REFERENCE.md" "yup" "REFERENCE restricts yup"
run_content_eval "$SKILL_DIR/REFERENCE.md" "useExhaustiveSwitchCases" "REFERENCE has exhaustive switch cases"
run_content_eval "$SKILL_DIR/REFERENCE.md" "noClassComponent" "REFERENCE has noClassComponent"
run_content_eval "$SKILL_DIR/REFERENCE.md" "noExplicitAny.*error" "REFERENCE re-enables noExplicitAny in tests"
run_content_eval "$SKILL_DIR/REFERENCE.md" "useIgnoreFile" "REFERENCE has VCS ignore file"
run_content_eval "$SKILL_DIR/REFERENCE.md" "noRestrictedImports" "REFERENCE has restricted imports rule"

# ── Hook script content checks ──────────────────────────────────

run_content_eval "$SCRIPT" "noUnusedImports" "hook skips noUnusedImports"
run_content_eval "$SCRIPT" "bun run lint:fix" "hook runs bun run lint:fix"
run_content_eval "$SCRIPT" "git diff --name-only" "hook checks for changed JS/TS files"
run_content_eval "$SCRIPT" "decision.*block" "hook blocks on unfixable errors"
