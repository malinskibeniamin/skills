# Evals for setup-zustand skill

SCRIPT="$REPO_ROOT/setup-zustand/scripts/zustand-check.sh"
SKILL_DIR="$REPO_ROOT/setup-zustand"

# ── File structure ──────────────────────────────────────────────

run_file_eval "$SKILL_DIR/SKILL.md" "SKILL.md exists"
run_file_eval "$SKILL_DIR/REFERENCE.md" "REFERENCE.md exists"
run_executable_eval "$SCRIPT" "zustand-check.sh is executable"

# ── SKILL.md content ────────────────────────────────────────────

run_content_eval "$SKILL_DIR/SKILL.md" "^name: setup-zustand" "SKILL.md has correct name"
run_content_eval "$SKILL_DIR/SKILL.md" "Use when" "SKILL.md has trigger phrase"
run_content_eval "$SKILL_DIR/SKILL.md" "useShallow" "SKILL.md mentions useShallow"
run_content_eval "$SKILL_DIR/SKILL.md" "persist" "SKILL.md mentions persist middleware"

# ── Hook: skip non-Edit/Write tools ────────────────────────────

run_hook_eval "$SCRIPT" \
  '{"tool_name":"Bash","tool_input":{"command":"echo hi"}}' \
  0 "skip: Bash tool"

run_hook_eval "$SCRIPT" \
  '{"tool_name":"Read","tool_input":{"file_path":"foo.tsx"}}' \
  0 "skip: Read tool"

# ── Hook: skip non-JS/TS files ─────────────────────────────────

run_hook_eval "$SCRIPT" \
  '{"tool_name":"Edit","tool_input":{"file_path":"/tmp/test.go"}}' \
  0 "skip: .go file"

run_hook_eval "$SCRIPT" \
  '{"tool_name":"Edit","tool_input":{"file_path":"/tmp/test.css"}}' \
  0 "skip: .css file"

run_hook_eval "$SCRIPT" \
  '{"tool_name":"Edit","tool_input":{"file_path":"/tmp/test.py"}}' \
  0 "skip: .py file"

# ── Hook: skip nonexistent file ──────────────────────────────────

run_hook_eval "$SCRIPT" \
  '{"tool_name":"Write","tool_input":{"file_path":"/tmp/nonexistent-zustand-abc123.tsx"}}' \
  0 "skip: nonexistent file"

# ── Hook: skip empty file_path ───────────────────────────────────

run_hook_eval "$SCRIPT" \
  '{"tool_name":"Edit","tool_input":{"file_path":""}}' \
  0 "skip: empty file_path"

# ── Check 1: Ban single-parens create<T>() ───────────────────────

tmpfile=$(mktemp /tmp/zustand-eval-XXXX.ts)
printf "import { create } from 'zustand'\nconst useStore = create<State>((set) => ({}))\n" > "$tmpfile"

run_hook_eval "$SCRIPT" \
  "{\"tool_name\":\"Write\",\"tool_input\":{\"file_path\":\"$tmpfile\"}}" \
  2 "block: single-parens create<State>()" "middleware type inference"

rm -f "$tmpfile"

# ── Check 1: Allow double-parens create<T>()() ──────────────────

tmpfile=$(mktemp /tmp/zustand-eval-XXXX.ts)
printf "import { create } from 'zustand'\nconst useStore = create<State>()((set) => ({}))\n" > "$tmpfile"

run_hook_eval "$SCRIPT" \
  "{\"tool_name\":\"Write\",\"tool_input\":{\"file_path\":\"$tmpfile\"}}" \
  0 "allow: double-parens create<State>()()"

rm -f "$tmpfile"

# ── Check 1: Skip create check in non-zustand files ─────────────

tmpfile=$(mktemp /tmp/zustand-eval-XXXX.ts)
printf "import { create } from 'other-lib'\nconst x = create<Foo>((a) => ({}))\n" > "$tmpfile"

run_hook_eval "$SCRIPT" \
  "{\"tool_name\":\"Write\",\"tool_input\":{\"file_path\":\"$tmpfile\"}}" \
  0 "skip: create<T>() in non-zustand file"

rm -f "$tmpfile"

# ── Check 2: Ban inline object selectors ─────────────────────────

tmpfile=$(mktemp /tmp/zustand-eval-XXXX.tsx)
printf "const { a, b } = useAppStore((s) => ({ a: s.a, b: s.b }))\n" > "$tmpfile"

run_hook_eval "$SCRIPT" \
  "{\"tool_name\":\"Write\",\"tool_input\":{\"file_path\":\"$tmpfile\"}}" \
  2 "block: inline object selector" "useShallow"

rm -f "$tmpfile"

# ── Check 2: Allow single-value selectors ────────────────────────

tmpfile=$(mktemp /tmp/zustand-eval-XXXX.tsx)
printf "const count = useAppStore((s) => s.count)\n" > "$tmpfile"

run_hook_eval "$SCRIPT" \
  "{\"tool_name\":\"Write\",\"tool_input\":{\"file_path\":\"$tmpfile\"}}" \
  0 "allow: single-value selector"

rm -f "$tmpfile"

# ── Check 3: Ban localStorage in zustand store files ─────────────

tmpfile=$(mktemp /tmp/zustand-eval-XXXX.ts)
printf "import { create } from 'zustand'\nconst data = localStorage.getItem('key')\n" > "$tmpfile"

run_hook_eval "$SCRIPT" \
  "{\"tool_name\":\"Write\",\"tool_input\":{\"file_path\":\"$tmpfile\"}}" \
  2 "block: localStorage in zustand file" "persist middleware"

rm -f "$tmpfile"

# ── Check 3: Allow localStorage in non-zustand files ─────────────

tmpfile=$(mktemp /tmp/zustand-eval-XXXX.ts)
printf "const data = localStorage.getItem('key')\n" > "$tmpfile"

run_hook_eval "$SCRIPT" \
  "{\"tool_name\":\"Write\",\"tool_input\":{\"file_path\":\"$tmpfile\"}}" \
  0 "allow: localStorage in non-zustand file"

rm -f "$tmpfile"

# ── Hook script content ──────────────────────────────────────────

run_content_eval "$SCRIPT" "create<" "hook checks for create pattern"
run_content_eval "$SCRIPT" "useShallow" "hook suggests useShallow"
run_content_eval "$SCRIPT" "localStorage" "hook checks for localStorage"
run_content_eval "$SCRIPT" "persist" "hook suggests persist middleware"
run_content_eval "$SCRIPT" "suppressOutput" "hook uses suppressOutput"
