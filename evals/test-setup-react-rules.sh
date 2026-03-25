# Evals for setup-react-rules skill

SCRIPT="$REPO_ROOT/setup-react-rules/scripts/react-rules-check.sh"
SKILL_DIR="$REPO_ROOT/setup-react-rules"

# ── File structure ──────────────────────────────────────────────

run_file_eval "$SKILL_DIR/SKILL.md" "SKILL.md exists"
run_file_eval "$SKILL_DIR/REFERENCE.md" "REFERENCE.md exists"
run_executable_eval "$SCRIPT" "react-rules-check.sh is executable"

# ── SKILL.md content ────────────────────────────────────────────

run_content_eval "$SKILL_DIR/SKILL.md" "^name: setup-react-rules" "SKILL.md has correct name"
run_content_eval "$SKILL_DIR/SKILL.md" "Use when" "SKILL.md has trigger phrase"
run_content_eval "$SKILL_DIR/SKILL.md" "useEffect" "SKILL.md mentions useEffect ban"
run_content_eval "$SKILL_DIR/SKILL.md" "redpanda-ui" "SKILL.md mentions redpanda-ui"
run_content_eval "$SKILL_DIR/SKILL.md" "as any" "SKILL.md mentions as any ban"

# ── Hook: skip non-Edit/Write ───────────────────────────────────

run_hook_eval "$SCRIPT" \
  '{"tool_name":"Bash","tool_input":{"command":"echo"}}' \
  0 "skip: Bash tool"

# ── Hook: skip redpanda-ui directory ─────────────────────────────

tmpdir=$(mktemp -d)
mkdir -p "$tmpdir/redpanda-ui"
echo "useEffect(() => {}, [])" > "$tmpdir/redpanda-ui/Component.tsx"

run_hook_eval "$SCRIPT" \
  "{\"tool_name\":\"Write\",\"tool_input\":{\"file_path\":\"$tmpdir/redpanda-ui/Component.tsx\"}}" \
  0 "skip: redpanda-ui directory"

rm -rf "$tmpdir"

# ── Hook: skip non-JS/TS files ──────────────────────────────────

run_hook_eval "$SCRIPT" \
  '{"tool_name":"Edit","tool_input":{"file_path":"README.md"}}' \
  0 "skip: markdown file"

# ── Check 1: useEffect ban ──────────────────────────────────────

# Block useEffect
tmpfile=$(mktemp /tmp/react-rules-XXXX.tsx)
echo "import { useEffect } from 'react'; useEffect(() => {}, [])" > "$tmpfile"

run_hook_eval "$SCRIPT" \
  "{\"tool_name\":\"Write\",\"tool_input\":{\"file_path\":\"$tmpfile\"}}" \
  2 "block: useEffect" "useEffect"

# Block useLayoutEffect
echo "import { useLayoutEffect } from 'react'; useLayoutEffect(() => {}, [])" > "$tmpfile"

run_hook_eval "$SCRIPT" \
  "{\"tool_name\":\"Write\",\"tool_input\":{\"file_path\":\"$tmpfile\"}}" \
  2 "block: useLayoutEffect" "useEffect"

# Block useInsertionEffect
echo "import { useInsertionEffect } from 'react'; useInsertionEffect(() => {})" > "$tmpfile"

run_hook_eval "$SCRIPT" \
  "{\"tool_name\":\"Write\",\"tool_input\":{\"file_path\":\"$tmpfile\"}}" \
  2 "block: useInsertionEffect" "useEffect"

# Allow useEffect with escape hatch
printf "// allow-useEffect: websocket cleanup\nimport { useEffect } from 'react';\nuseEffect(() => {}, [])\n" > "$tmpfile"

run_hook_eval "$SCRIPT" \
  "{\"tool_name\":\"Write\",\"tool_input\":{\"file_path\":\"$tmpfile\"}}" \
  0 "allow: useEffect with escape hatch"

# ── Check 2: raw HTML ban (TSX only) ────────────────────────────

echo '<button onClick={handleClick}>Click</button>' > "$tmpfile"

run_hook_eval "$SCRIPT" \
  "{\"tool_name\":\"Write\",\"tool_input\":{\"file_path\":\"$tmpfile\"}}" \
  2 "block: raw <button>" "redpanda-ui"

echo '<input type="text" />' > "$tmpfile"

run_hook_eval "$SCRIPT" \
  "{\"tool_name\":\"Write\",\"tool_input\":{\"file_path\":\"$tmpfile\"}}" \
  2 "block: raw <input>" "redpanda-ui"

echo '<form onSubmit={handle}>' > "$tmpfile"

run_hook_eval "$SCRIPT" \
  "{\"tool_name\":\"Write\",\"tool_input\":{\"file_path\":\"$tmpfile\"}}" \
  2 "block: raw <form>" "AutoForm"

# Allow <a> tag (not banned)
echo '<a href="/about">About</a>' > "$tmpfile"

run_hook_eval "$SCRIPT" \
  "{\"tool_name\":\"Write\",\"tool_input\":{\"file_path\":\"$tmpfile\"}}" \
  0 "allow: <a> tag (not banned)"

# ── Check 3: Chakra/legacy imports ──────────────────────────────

echo "import { Box } from '@chakra-ui/react'" > "$tmpfile"

run_hook_eval "$SCRIPT" \
  "{\"tool_name\":\"Write\",\"tool_input\":{\"file_path\":\"$tmpfile\"}}" \
  2 "block: @chakra-ui/react import" "chakra"

echo "import { Button } from '@redpanda-data/ui'" > "$tmpfile"

run_hook_eval "$SCRIPT" \
  "{\"tool_name\":\"Write\",\"tool_input\":{\"file_path\":\"$tmpfile\"}}" \
  2 "block: @redpanda-data/ui import" "legacy"

# ── Check 4: TypeScript escape hatches ──────────────────────────

echo "const x = foo as any" > "$tmpfile"

run_hook_eval "$SCRIPT" \
  "{\"tool_name\":\"Write\",\"tool_input\":{\"file_path\":\"$tmpfile\"}}" \
  2 "block: as any" "as any"

echo "// @ts-ignore" > "$tmpfile"

run_hook_eval "$SCRIPT" \
  "{\"tool_name\":\"Write\",\"tool_input\":{\"file_path\":\"$tmpfile\"}}" \
  2 "block: @ts-ignore" "ts-ignore"

echo "// @ts-expect-error" > "$tmpfile"

run_hook_eval "$SCRIPT" \
  "{\"tool_name\":\"Write\",\"tool_input\":{\"file_path\":\"$tmpfile\"}}" \
  2 "block: @ts-expect-error" "ts-expect-error"

# Allow clean code
echo "const x: string = 'hello'" > "$tmpfile"

run_hook_eval "$SCRIPT" \
  "{\"tool_name\":\"Write\",\"tool_input\":{\"file_path\":\"$tmpfile\"}}" \
  0 "allow: clean TypeScript code"

# ── Check 5: Visual style overrides on registry components ───────

echo '<Button className="bg-red-500 mt-4">Click</Button>' > "$tmpfile"

run_hook_eval "$SCRIPT" \
  "{\"tool_name\":\"Write\",\"tool_input\":{\"file_path\":\"$tmpfile\"}}" \
  2 "block: visual style override on Button" "variant"

# Allow layout-only classes on components (with handler)
echo '<Button onClick={handleClick} className="mt-4 flex-1 w-full">Click</Button>' > "$tmpfile"

run_hook_eval "$SCRIPT" \
  "{\"tool_name\":\"Write\",\"tool_input\":{\"file_path\":\"$tmpfile\"}}" \
  0 "allow: layout classes on Button"

# ── Check 6: onClick+navigate instead of Link ───────────────────

echo '<Button onClick={() => navigate("/settings")}>Settings</Button>' > "$tmpfile"

run_hook_eval "$SCRIPT" \
  "{\"tool_name\":\"Write\",\"tool_input\":{\"file_path\":\"$tmpfile\"}}" \
  2 "block: onClick+navigate pattern" "navigate"

# ── Check 8: Alert double icon ──────────────────────────────────

echo '<AlertTitle><InfoIcon /> Warning</AlertTitle>' > "$tmpfile"

run_hook_eval "$SCRIPT" \
  "{\"tool_name\":\"Write\",\"tool_input\":{\"file_path\":\"$tmpfile\"}}" \
  2 "block: icon inside AlertTitle" "AlertTitle"

# ── Check 11: Icon-only button a11y ──────────────────────────────

echo '<Button onClick={handleClick}><SettingsIcon /></Button>' > "$tmpfile"

run_hook_eval "$SCRIPT" \
  "{\"tool_name\":\"Write\",\"tool_input\":{\"file_path\":\"$tmpfile\"}}" \
  2 "block: icon-only button without aria-label" "aria-label"

echo '<Button onClick={handleClick} aria-label="Settings"><SettingsIcon /></Button>' > "$tmpfile"

run_hook_eval "$SCRIPT" \
  "{\"tool_name\":\"Write\",\"tool_input\":{\"file_path\":\"$tmpfile\"}}" \
  0 "allow: icon button with aria-label"

# ── Check 12: outline removal ────────────────────────────────────

echo 'const style = { outline: none }' > "$tmpfile"

run_hook_eval "$SCRIPT" \
  "{\"tool_name\":\"Write\",\"tool_input\":{\"file_path\":\"$tmpfile\"}}" \
  2 "block: outline: none" "outline"

echo '<div className="outline-none focus:ring">' > "$tmpfile"

run_hook_eval "$SCRIPT" \
  "{\"tool_name\":\"Write\",\"tool_input\":{\"file_path\":\"$tmpfile\"}}" \
  2 "block: outline-none CSS class" "outline"

# ── Check 13: React Compiler — manual memoization ────────────────

echo 'const val = useMemo(() => compute(), [dep])' > "$tmpfile"

run_hook_eval "$SCRIPT" \
  "{\"tool_name\":\"Write\",\"tool_input\":{\"file_path\":\"$tmpfile\"}}" \
  2 "block: useMemo (React Compiler handles it)" "useMemo"

echo 'const cb = useCallback(() => {}, [])' > "$tmpfile"

run_hook_eval "$SCRIPT" \
  "{\"tool_name\":\"Write\",\"tool_input\":{\"file_path\":\"$tmpfile\"}}" \
  2 "block: useCallback (React Compiler handles it)" "useCallback"

# Allow with 'use no memo' directive
printf "'use no memo'\nconst val = useMemo(() => 1, [])\n" > "$tmpfile"

run_hook_eval "$SCRIPT" \
  "{\"tool_name\":\"Write\",\"tool_input\":{\"file_path\":\"$tmpfile\"}}" \
  0 "allow: useMemo with 'use no memo' directive"

rm -f "$tmpfile"

# ── Hook script content checks ──────────────────────────────────

run_content_eval "$SCRIPT" "variant" "hook suggests using variant prop"
run_content_eval "$SCRIPT" "asChild" "hook suggests asChild for Link wrapping"
run_content_eval "$SCRIPT" "AlertTitle" "hook checks AlertTitle icon"
run_content_eval "$SCRIPT" "wrap.*create" "hook checks protobuf create()"
run_content_eval "$SCRIPT" "bufbuild/protobuf" "hook checks protobuf v2 only"
run_content_eval "$SCRIPT" "aria-label" "hook checks icon-only button a11y"
run_content_eval "$SCRIPT" "outline" "hook bans outline removal"
run_content_eval "$SCRIPT" "useMemo" "hook checks for manual memoization"

# ── REFERENCE content ────────────────────────────────────────────

run_content_eval "$SKILL_DIR/REFERENCE.md" "allow-useEffect" "REFERENCE documents escape hatch"
run_content_eval "$SKILL_DIR/REFERENCE.md" "AutoForm" "REFERENCE maps <form> to AutoForm"
run_content_eval "$SKILL_DIR/REFERENCE.md" "redpanda-ui-registry.netlify.app" "REFERENCE has registry URL"
