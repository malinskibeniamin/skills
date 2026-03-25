# Evals for setup-react-compiler skill

SCRIPT="$REPO_ROOT/setup-react-compiler/scripts/react-compiler-check.sh"
SKILL_DIR="$REPO_ROOT/setup-react-compiler"

# ── File structure ──────────────────────────────────────────────

run_file_eval "$SKILL_DIR/SKILL.md" "SKILL.md exists"
run_file_eval "$SKILL_DIR/REFERENCE.md" "REFERENCE.md exists"
run_executable_eval "$SCRIPT" "react-compiler-check.sh is executable"

# ── SKILL.md content ────────────────────────────────────────────

run_content_eval "$SKILL_DIR/SKILL.md" "^name: setup-react-compiler" "SKILL.md has correct name"
run_content_eval "$SKILL_DIR/SKILL.md" "Use when" "SKILL.md has trigger phrase"
run_content_eval "$SKILL_DIR/SKILL.md" "rsbuild" "SKILL.md mentions rsbuild"
run_content_eval "$SKILL_DIR/SKILL.md" "use no memo" "SKILL.md mentions escape hatch"

# ── Hook: skip non-Edit/Write tools ────────────────────────────

run_hook_eval "$SCRIPT" \
  '{"tool_name":"Bash","tool_input":{"command":"echo hi"}}' \
  0 "skip: Bash tool"

run_hook_eval "$SCRIPT" \
  '{"tool_name":"Read","tool_input":{"file_path":"foo.tsx"}}' \
  0 "skip: Read tool"

# ── Hook: skip non-JSX/TSX files ───────────────────────────────

run_hook_eval "$SCRIPT" \
  '{"tool_name":"Edit","tool_input":{"file_path":"/tmp/test.ts"}}' \
  0 "skip: .ts file (not tsx/jsx)"

run_hook_eval "$SCRIPT" \
  '{"tool_name":"Edit","tool_input":{"file_path":"/tmp/test.css"}}' \
  0 "skip: .css file"

# ── Hook: skip redpanda-ui directory ────────────────────────────

tmpdir=$(mktemp -d)
mkdir -p "$tmpdir/redpanda-ui"
echo "const x = useMemo(() => 1, [])" > "$tmpdir/redpanda-ui/Button.tsx"

run_hook_eval "$SCRIPT" \
  "{\"tool_name\":\"Write\",\"tool_input\":{\"file_path\":\"$tmpdir/redpanda-ui/Button.tsx\"}}" \
  0 "skip: redpanda-ui directory"

rm -rf "$tmpdir"

# ── Hook: skip files with 'use no memo' ────────────────────────

tmpfile=$(mktemp /tmp/compiler-eval-XXXX.tsx)
printf "'use no memo'\nconst x = useMemo(() => 1, [])\n" > "$tmpfile"

run_hook_eval "$SCRIPT" \
  "{\"tool_name\":\"Write\",\"tool_input\":{\"file_path\":\"$tmpfile\"}}" \
  0 "skip: file with 'use no memo' directive"

rm -f "$tmpfile"

# ── Hook: skip nonexistent file ─────────────────────────────────

run_hook_eval "$SCRIPT" \
  '{"tool_name":"Write","tool_input":{"file_path":"/tmp/nonexistent-abc123.tsx"}}' \
  0 "skip: nonexistent file"

# ── Hook: skip empty file_path ──────────────────────────────────

run_hook_eval "$SCRIPT" \
  '{"tool_name":"Edit","tool_input":{"file_path":""}}' \
  0 "skip: empty file_path"

# ── Hook script content ─────────────────────────────────────────

run_content_eval "$SCRIPT" "useMemo" "hook checks for useMemo"
run_content_eval "$SCRIPT" "useCallback" "hook checks for useCallback"
run_content_eval "$SCRIPT" "React.memo" "hook checks for React.memo"
run_content_eval "$SCRIPT" "redpanda-ui" "hook skips redpanda-ui"
run_content_eval "$SCRIPT" "use no memo" "hook respects 'use no memo'"
run_content_eval "$SCRIPT" "suppressOutput" "hook uses suppressOutput"
