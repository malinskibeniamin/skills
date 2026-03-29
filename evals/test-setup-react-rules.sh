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
run_content_eval "$SKILL_DIR/SKILL.md" "REACT_RULES_BAN_USEEFFECT" "SKILL.md documents useEffect opt-in env var"
run_content_eval "$SKILL_DIR/SKILL.md" "components/ui" "SKILL.md mentions components/ui"
run_content_eval "$SKILL_DIR/SKILL.md" "as any" "SKILL.md mentions as any ban"

# ── Hook: skip non-Edit/Write ───────────────────────────────────

run_hook_eval "$SCRIPT" \
  '{"tool_name":"Bash","tool_input":{"command":"echo"}}' \
  0 "skip: Bash tool"

# ── Hook: skip component library directories ─────────────────────

tmpdir=$(mktemp -d)
mkdir -p "$tmpdir/components/ui"
echo "useEffect(() => {}, [])" > "$tmpdir/components/ui/Component.tsx"

run_hook_eval "$SCRIPT" \
  "{\"tool_name\":\"Write\",\"tool_input\":{\"file_path\":\"$tmpdir/components/ui/Component.tsx\"}}" \
  0 "skip: components/ui directory"

mkdir -p "$tmpdir/redpanda-ui"
echo "useEffect(() => {}, [])" > "$tmpdir/redpanda-ui/Component.tsx"

UI_LIB_DIRS="components/ui|redpanda-ui" REACT_RULES_BAN_USEEFFECT=1 run_hook_eval "$SCRIPT" \
  "{\"tool_name\":\"Write\",\"tool_input\":{\"file_path\":\"$tmpdir/redpanda-ui/Component.tsx\"}}" \
  0 "skip: redpanda-ui via UI_LIB_DIRS override"

rm -rf "$tmpdir"

# ── Hook: skip non-JS/TS files ──────────────────────────────────

run_hook_eval "$SCRIPT" \
  '{"tool_name":"Edit","tool_input":{"file_path":"README.md"}}' \
  0 "skip: markdown file"

# Create a temp dir for all file-based tests (macOS mktemp doesn't support suffixes)
_rr_tmpdir=$(mktemp -d /tmp/react-rules-evals-XXXXXX)

# ── Check 1: useEffect ban (opt-in via env var) ────────────────

tmpfile="$_rr_tmpdir/test.tsx"

# useEffect allowed by default (opt-in disabled)
echo "import { useEffect } from 'react'; useEffect(() => {}, [])" > "$tmpfile"

run_hook_eval "$SCRIPT" \
  "{\"tool_name\":\"Write\",\"tool_input\":{\"file_path\":\"$tmpfile\"}}" \
  0 "allow: useEffect when REACT_RULES_BAN_USEEFFECT not set"

# Block useEffect when opt-in enabled
echo "import { useEffect } from 'react'; useEffect(() => {}, [])" > "$tmpfile"

REACT_RULES_BAN_USEEFFECT=1 run_hook_eval "$SCRIPT" \
  "{\"tool_name\":\"Write\",\"tool_input\":{\"file_path\":\"$tmpfile\"}}" \
  2 "block: useEffect with REACT_RULES_BAN_USEEFFECT=1" "useEffect"

# Block useLayoutEffect when opt-in enabled
echo "import { useLayoutEffect } from 'react'; useLayoutEffect(() => {}, [])" > "$tmpfile"

REACT_RULES_BAN_USEEFFECT=1 run_hook_eval "$SCRIPT" \
  "{\"tool_name\":\"Write\",\"tool_input\":{\"file_path\":\"$tmpfile\"}}" \
  2 "block: useLayoutEffect with opt-in" "useEffect"

# Block useInsertionEffect when opt-in enabled
echo "import { useInsertionEffect } from 'react'; useInsertionEffect(() => {})" > "$tmpfile"

REACT_RULES_BAN_USEEFFECT=1 run_hook_eval "$SCRIPT" \
  "{\"tool_name\":\"Write\",\"tool_input\":{\"file_path\":\"$tmpfile\"}}" \
  2 "block: useInsertionEffect with opt-in" "useEffect"

# Allow useEffect with escape hatch (even when opt-in enabled)
printf "// allow-useEffect: websocket cleanup\nimport { useEffect } from 'react';\nuseEffect(() => {}, [])\n" > "$tmpfile"

REACT_RULES_BAN_USEEFFECT=1 run_hook_eval "$SCRIPT" \
  "{\"tool_name\":\"Write\",\"tool_input\":{\"file_path\":\"$tmpfile\"}}" \
  0 "allow: useEffect with escape hatch"

# ── Check 2: raw HTML ban (TSX only) ────────────────────────────

echo '<button onClick={handleClick}>Click</button>' > "$tmpfile"

run_hook_eval "$SCRIPT" \
  "{\"tool_name\":\"Write\",\"tool_input\":{\"file_path\":\"$tmpfile\"}}" \
  2 "block: raw <button>" "component"

echo '<input type="text" />' > "$tmpfile"

run_hook_eval "$SCRIPT" \
  "{\"tool_name\":\"Write\",\"tool_input\":{\"file_path\":\"$tmpfile\"}}" \
  2 "block: raw <input>" "component"

# Allow <form> (not banned — raw <form> is acceptable)
echo '<form onSubmit={handle}>' > "$tmpfile"

run_hook_eval "$SCRIPT" \
  "{\"tool_name\":\"Write\",\"tool_input\":{\"file_path\":\"$tmpfile\"}}" \
  0 "allow: raw <form> (not banned)"

# Allow <a> tag (not banned)
echo '<a href="/about">About</a>' > "$tmpfile"

run_hook_eval "$SCRIPT" \
  "{\"tool_name\":\"Write\",\"tool_input\":{\"file_path\":\"$tmpfile\"}}" \
  0 "allow: <a> tag (not banned)"

# ── UI_LIB_DIRS override ─────────────────────────────────────────

tmpdir2=$(mktemp -d)
mkdir -p "$tmpdir2/custom-lib"
echo "useEffect(() => {}, [])" > "$tmpdir2/custom-lib/Widget.tsx"

UI_LIB_DIRS="custom-lib" REACT_RULES_BAN_USEEFFECT=1 run_hook_eval "$SCRIPT" \
  "{\"tool_name\":\"Write\",\"tool_input\":{\"file_path\":\"$tmpdir2/custom-lib/Widget.tsx\"}}" \
  0 "skip: custom UI_LIB_DIRS override"

rm -rf "$tmpdir2"

# ── Check 3: TypeScript escape hatches ──────────────────────────

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

# ── Protobuf: no false positive on Schema imports ────────────────

# Importing Schema types without spreading should NOT trigger
tmpfile="$_rr_tmpdir/test-proto.tsx"
printf "import { AWSSQSMCPConfigSchema } from 'proto/frontend/mcps/aws_sqs/v1/aws_sqs_config_pb';\nimport { AWSBedrockMCPConfigSchema } from 'proto/frontend/mcps/aws_bedrock/v1/config_pb';\nconst registry = { sqs: AWSSQSMCPConfigSchema };\n" > "$tmpfile"

run_hook_eval "$SCRIPT" \
  "{\"tool_name\":\"Write\",\"tool_input\":{\"file_path\":\"$tmpfile\"}}" \
  0 "allow: importing Schema types without spreading (no false positive)"

# tmpfile reused in tmpdir

# ── Check 14: dangerouslySetInnerHTML (TSX/JSX only) ─────────────

# Block dangerouslySetInnerHTML in TSX
tmpfile="$_rr_tmpdir/test.tsx"
echo '<div dangerouslySetInnerHTML={{ __html: content }} />' > "$tmpfile"

run_hook_eval "$SCRIPT" \
  "{\"tool_name\":\"Write\",\"tool_input\":{\"file_path\":\"$tmpfile\"}}" \
  2 "block: dangerouslySetInnerHTML in TSX" "XSS"

# Allow dangerouslySetInnerHTML with escape hatch
printf "// allow-dangerouslySetInnerHTML: sanitized upstream\n<div dangerouslySetInnerHTML={{ __html: content }} />\n" > "$tmpfile"

run_hook_eval "$SCRIPT" \
  "{\"tool_name\":\"Write\",\"tool_input\":{\"file_path\":\"$tmpfile\"}}" \
  0 "allow: dangerouslySetInnerHTML with escape hatch"

# tmpfile reused in tmpdir

# Skip dangerouslySetInnerHTML in .ts file (TSX/JSX only)
tmpfile="$_rr_tmpdir/test.ts"
echo '<div dangerouslySetInnerHTML={{ __html: content }} />' > "$tmpfile"

run_hook_eval "$SCRIPT" \
  "{\"tool_name\":\"Write\",\"tool_input\":{\"file_path\":\"$tmpfile\"}}" \
  0 "skip: dangerouslySetInnerHTML in .ts file"

# tmpfile reused in tmpdir

# ── Check 15: eval() and new Function() ──────────────────────────

# Block eval() in TS
tmpfile="$_rr_tmpdir/test.ts"
echo 'eval(userInput)' > "$tmpfile"

run_hook_eval "$SCRIPT" \
  "{\"tool_name\":\"Write\",\"tool_input\":{\"file_path\":\"$tmpfile\"}}" \
  2 "block: eval() in TS" "injection"

# tmpfile reused in tmpdir

# Block new Function() in TSX
tmpfile="$_rr_tmpdir/test.tsx"
echo "new Function('return ' + code)" > "$tmpfile"

run_hook_eval "$SCRIPT" \
  "{\"tool_name\":\"Write\",\"tool_input\":{\"file_path\":\"$tmpfile\"}}" \
  2 "block: new Function() in TSX"

# tmpfile reused in tmpdir

# Allow JSON.parse (not flagged)
tmpfile="$_rr_tmpdir/test.ts"
echo 'JSON.parse(data)' > "$tmpfile"

run_hook_eval "$SCRIPT" \
  "{\"tool_name\":\"Write\",\"tool_input\":{\"file_path\":\"$tmpfile\"}}" \
  0 "allow: JSON.parse (not eval)"

# tmpfile reused in tmpdir

# ── Check 16: .innerHTML assignment (TSX/JSX only) ───────────────

# Block innerHTML assignment in TSX
tmpfile="$_rr_tmpdir/test.tsx"
echo 'element.innerHTML = userContent' > "$tmpfile"

run_hook_eval "$SCRIPT" \
  "{\"tool_name\":\"Write\",\"tool_input\":{\"file_path\":\"$tmpfile\"}}" \
  2 "block: innerHTML assignment in TSX" "innerHTML"

# Allow textContent (safe alternative)
echo 'element.textContent = userContent' > "$tmpfile"

run_hook_eval "$SCRIPT" \
  "{\"tool_name\":\"Write\",\"tool_input\":{\"file_path\":\"$tmpfile\"}}" \
  0 "allow: textContent assignment in TSX"

# tmpfile reused in tmpdir

# Skip innerHTML in .ts file (TSX/JSX only)
tmpfile="$_rr_tmpdir/test.ts"
echo 'element.innerHTML = userContent' > "$tmpfile"

run_hook_eval "$SCRIPT" \
  "{\"tool_name\":\"Write\",\"tool_input\":{\"file_path\":\"$tmpfile\"}}" \
  0 "skip: innerHTML in .ts file"

# tmpfile reused in tmpdir

# ── Check 17: Ban inline style={{}} ──────────────────────────────

tmpfile="$_rr_tmpdir/test.tsx"
echo '<div style={{ marginTop: 16 }}>content</div>' > "$tmpfile"

run_hook_eval "$SCRIPT" \
  "{\"tool_name\":\"Write\",\"tool_input\":{\"file_path\":\"$tmpfile\"}}" \
  2 "block: inline style={{}}" "Tailwind"

# Allow style in .ts files (not TSX)
tmpfile="$_rr_tmpdir/test.ts"
echo 'const style = { marginTop: 16 }' > "$tmpfile"

run_hook_eval "$SCRIPT" \
  "{\"tool_name\":\"Write\",\"tool_input\":{\"file_path\":\"$tmpfile\"}}" \
  0 "allow: style object in .ts file"

# ── Check 18: Ban raw hex/rgb in className ───────────────────────

tmpfile="$_rr_tmpdir/test.tsx"
echo '<div className="text-[#ff0000] mt-4">red</div>' > "$tmpfile"

run_hook_eval "$SCRIPT" \
  "{\"tool_name\":\"Write\",\"tool_input\":{\"file_path\":\"$tmpfile\"}}" \
  2 "block: raw hex in className" "design token"

tmpfile="$_rr_tmpdir/test.tsx"
echo '<div className="bg-[rgb(0,0,0)]">dark</div>' > "$tmpfile"

run_hook_eval "$SCRIPT" \
  "{\"tool_name\":\"Write\",\"tool_input\":{\"file_path\":\"$tmpfile\"}}" \
  2 "block: raw rgb in className" "design token"

# Allow normal Tailwind classes
tmpfile="$_rr_tmpdir/test.tsx"
echo '<div className="text-destructive bg-background mt-4">ok</div>' > "$tmpfile"

run_hook_eval "$SCRIPT" \
  "{\"tool_name\":\"Write\",\"tool_input\":{\"file_path\":\"$tmpfile\"}}" \
  0 "allow: Tailwind design token classes"

# ── Check 19: Ban !important ─────────────────────────────────────

tmpfile="$_rr_tmpdir/test.tsx"
echo '<div className="mt-4 !important">forced</div>' > "$tmpfile"

run_hook_eval "$SCRIPT" \
  "{\"tool_name\":\"Write\",\"tool_input\":{\"file_path\":\"$tmpfile\"}}" \
  2 "block: !important in className"

# ── Hook script content checks ──────────────────────────────────

run_content_eval "$SCRIPT" "hook_skip_ui_dirs" "hook uses shared UI dir skip"
run_content_eval "$SCRIPT" "REACT_RULES_BAN_USEEFFECT" "hook checks useEffect opt-in env var"
run_content_eval "$SCRIPT" "variant" "hook suggests using variant prop"
run_content_eval "$SCRIPT" "asChild" "hook suggests asChild for Link wrapping"
run_content_eval "$SCRIPT" "AlertTitle" "hook checks AlertTitle icon"
run_content_eval "$SCRIPT" "wrap.*create" "hook checks protobuf create()"
run_content_eval "$SCRIPT" "bufbuild/protobuf" "hook checks protobuf v2 only"
run_content_eval "$SCRIPT" "aria-label" "hook checks icon-only button a11y"
run_content_eval "$SCRIPT" "outline" "hook bans outline removal"
run_content_eval "$SCRIPT" "useMemo" "hook checks for manual memoization"
run_content_eval "$SCRIPT" "dangerouslySetInnerHTML" "hook checks dangerouslySetInnerHTML"
run_content_eval "$SCRIPT" "eval\(" "hook checks eval()"
run_content_eval "$SCRIPT" "innerHTML" "hook checks innerHTML"

# ── REFERENCE content ────────────────────────────────────────────

run_content_eval "$SKILL_DIR/REFERENCE.md" "allow-useEffect" "REFERENCE documents escape hatch"
run_content_eval "$SKILL_DIR/REFERENCE.md" "components/ui" "REFERENCE has component library mapping"

# ── Cleanup ─────────────────────────────────────────────────────

rm -rf "$_rr_tmpdir"
