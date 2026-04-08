# Evals for setup-quality-gate skill

SCRIPT="$REPO_ROOT/setup-quality-gate/scripts/typecheck-stop.sh"
SKILL_DIR="$REPO_ROOT/setup-quality-gate"

# ── File structure ──────────────────────────────────────────────

run_file_eval "$SKILL_DIR/SKILL.md" "SKILL.md exists"
run_file_eval "$SKILL_DIR/REFERENCE.md" "REFERENCE.md exists"
run_executable_eval "$SCRIPT" "typecheck-stop.sh is executable"

# ── SKILL.md content ────────────────────────────────────────────

run_content_eval "$SKILL_DIR/SKILL.md" "^name: setup-quality-gate" "SKILL.md has correct name"
run_content_eval "$SKILL_DIR/SKILL.md" "Use when" "SKILL.md has trigger phrase"
run_content_eval "$SKILL_DIR/SKILL.md" "quality:gate" "SKILL.md mentions quality:gate script"
run_content_eval "$SKILL_DIR/SKILL.md" "type:check" "SKILL.md mentions type:check"
run_content_eval "$SKILL_DIR/SKILL.md" "GitHub Actions" "SKILL.md mentions CI"

# ── REFERENCE.md content ────────────────────────────────────────

run_content_eval "$SKILL_DIR/REFERENCE.md" "quality-gate.yml" "REFERENCE has workflow filename"
run_content_eval "$SKILL_DIR/REFERENCE.md" "git diff --exit-code" "REFERENCE has formatting integrity check"
run_content_eval "$SKILL_DIR/REFERENCE.md" "bun run type:check" "REFERENCE has type:check command"
run_content_eval "$SKILL_DIR/REFERENCE.md" "related" "REFERENCE mentions related tests"

# ── Hook script content ─────────────────────────────────────────

run_content_eval "$SCRIPT" "bun run type:check" "hook uses bun run type:check"
run_content_eval "$SCRIPT" "git diff --name-only" "hook checks for changed JS/TS files"
run_content_eval "$SCRIPT" "decision.*block" "hook blocks on failure"
run_content_eval "$SCRIPT" "head -30" "hook truncates output"

# ── bundle-guard.sh: File structure ───────────────────────────────

BUNDLE_SCRIPT="$REPO_ROOT/setup-quality-gate/scripts/bundle-guard.sh"
run_file_eval "$BUNDLE_SCRIPT" "bundle-guard.sh exists"
run_executable_eval "$BUNDLE_SCRIPT" "bundle-guard.sh is executable"

# ── bundle-guard.sh: skip non-package.json ────────────────────────

run_hook_eval "$BUNDLE_SCRIPT" \
  '{"tool_name":"Edit","tool_input":{"file_path":"/tmp/test.ts"}}' \
  0 "skip: non-package.json file"

# ── bundle-guard.sh: skip non-Edit/Write ─────────────────────────

run_hook_eval "$BUNDLE_SCRIPT" \
  '{"tool_name":"Bash","tool_input":{"command":"echo hi"}}' \
  0 "skip: Bash tool"

# ── bundle-guard.sh: block moment in dependencies ────────────────

tmpdir=$(mktemp -d /tmp/bundle-guard-XXXXXX)
printf '{"dependencies":{"moment":"^2.29.0"}}' > "$tmpdir/package.json"

run_hook_eval "$BUNDLE_SCRIPT" \
  "{\"tool_name\":\"Write\",\"tool_input\":{\"file_path\":\"$tmpdir/package.json\"}}" \
  2 "block: moment in dependencies" "moment"

rm -rf "$tmpdir"

# ── bundle-guard.sh: block lodash in dependencies ────────────────

tmpdir=$(mktemp -d /tmp/bundle-guard-XXXXXX)
printf '{"dependencies":{"lodash":"^4.17.0"}}' > "$tmpdir/package.json"

run_hook_eval "$BUNDLE_SCRIPT" \
  "{\"tool_name\":\"Write\",\"tool_input\":{\"file_path\":\"$tmpdir/package.json\"}}" \
  2 "block: lodash in dependencies" "lodash"

rm -rf "$tmpdir"

# ── bundle-guard.sh: allow lodash-es ─────────────────────────────

tmpdir=$(mktemp -d /tmp/bundle-guard-XXXXXX)
printf '{"dependencies":{"lodash-es":"^4.17.0"}}' > "$tmpdir/package.json"

run_hook_eval "$BUNDLE_SCRIPT" \
  "{\"tool_name\":\"Write\",\"tool_input\":{\"file_path\":\"$tmpdir/package.json\"}}" \
  0 "allow: lodash-es in dependencies"

rm -rf "$tmpdir"

# ── bundle-guard.sh: block jquery ────────────────────────────────

tmpdir=$(mktemp -d /tmp/bundle-guard-XXXXXX)
printf '{"dependencies":{"jquery":"^3.6.0"}}' > "$tmpdir/package.json"

run_hook_eval "$BUNDLE_SCRIPT" \
  "{\"tool_name\":\"Write\",\"tool_input\":{\"file_path\":\"$tmpdir/package.json\"}}" \
  2 "block: jquery in dependencies" "jQuery"

rm -rf "$tmpdir"

# ── bundle-guard.sh: allow moment in devDependencies ─────────────

tmpdir=$(mktemp -d /tmp/bundle-guard-XXXXXX)
printf '{"devDependencies":{"moment":"^2.29.0"}}' > "$tmpdir/package.json"

run_hook_eval "$BUNDLE_SCRIPT" \
  "{\"tool_name\":\"Write\",\"tool_input\":{\"file_path\":\"$tmpdir/package.json\"}}" \
  0 "allow: moment in devDependencies"

rm -rf "$tmpdir"

# ── bundle-guard.sh: block classnames ────────────────────────────

tmpdir=$(mktemp -d /tmp/bundle-guard-XXXXXX)
printf '{"dependencies":{"classnames":"^2.3.0"}}' > "$tmpdir/package.json"

run_hook_eval "$BUNDLE_SCRIPT" \
  "{\"tool_name\":\"Write\",\"tool_input\":{\"file_path\":\"$tmpdir/package.json\"}}" \
  2 "block: classnames in dependencies" "clsx"

rm -rf "$tmpdir"

# ── bundle-guard.sh: block core-js ───────────────────────────────

tmpdir=$(mktemp -d /tmp/bundle-guard-XXXXXX)
printf '{"dependencies":{"core-js":"^3.37.0"}}' > "$tmpdir/package.json"

run_hook_eval "$BUNDLE_SCRIPT" \
  "{\"tool_name\":\"Write\",\"tool_input\":{\"file_path\":\"$tmpdir/package.json\"}}" \
  2 "block: core-js in dependencies" "core-js"

rm -rf "$tmpdir"

# ── bundle-guard.sh: script content ──────────────────────────────

run_content_eval "$BUNDLE_SCRIPT" "moment" "bundle-guard checks moment"
run_content_eval "$BUNDLE_SCRIPT" "lodash" "bundle-guard checks lodash"
run_content_eval "$BUNDLE_SCRIPT" "jquery" "bundle-guard checks jquery"
run_content_eval "$BUNDLE_SCRIPT" "classnames" "bundle-guard checks classnames"
run_content_eval "$BUNDLE_SCRIPT" "core-js" "bundle-guard checks core-js"
