# Evals for setup-connect-query skill

SCRIPT="$REPO_ROOT/setup-connect-query/scripts/connect-query-check.sh"
SKILL_DIR="$REPO_ROOT/setup-connect-query"

# ── File structure ──────────────────────────────────────────────

run_file_eval "$SKILL_DIR/SKILL.md" "SKILL.md exists"
run_file_eval "$SKILL_DIR/REFERENCE.md" "REFERENCE.md exists"
run_executable_eval "$SCRIPT" "connect-query-check.sh is executable"

# ── SKILL.md content ────────────────────────────────────────────

run_content_eval "$SKILL_DIR/SKILL.md" "^name: setup-connect-query" "SKILL.md has correct name"
run_content_eval "$SKILL_DIR/SKILL.md" "Use when" "SKILL.md has trigger phrase"
run_content_eval "$SKILL_DIR/SKILL.md" "ConnectRPC" "SKILL.md mentions ConnectRPC"
run_content_eval "$SKILL_DIR/SKILL.md" "allow-direct-query" "SKILL.md mentions escape hatch"

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

# ── Hook: skip nonexistent file ──────────────────────────────────

run_hook_eval "$SCRIPT" \
  '{"tool_name":"Write","tool_input":{"file_path":"/tmp/nonexistent-cq-abc123.tsx"}}' \
  0 "skip: nonexistent file"

# ── Hook: skip empty file_path ───────────────────────────────────

run_hook_eval "$SCRIPT" \
  '{"tool_name":"Edit","tool_input":{"file_path":""}}' \
  0 "skip: empty file_path"

# ── Hook: respect escape hatch ───────────────────────────────────

tmpfile=$(mktemp /tmp/cq-eval-XXXX.tsx)
printf "// allow-direct-query: REST endpoint for legacy auth\nimport { useQuery } from '@tanstack/react-query'\nimport { listUsers } from '@connectrpc/connect-query'\n" > "$tmpfile"

run_hook_eval "$SCRIPT" \
  "{\"tool_name\":\"Write\",\"tool_input\":{\"file_path\":\"$tmpfile\"}}" \
  0 "skip: file with allow-direct-query escape hatch"

rm -f "$tmpfile"

# ── Check 1: Ban raw useQuery from @tanstack/react-query with ConnectRPC ─

tmpfile=$(mktemp /tmp/cq-eval-XXXX.tsx)
printf "import { useQuery } from '@tanstack/react-query'\nimport { listTopics } from '@buf/redpandadata_cloud.connectrpc_query-es'\n" > "$tmpfile"

run_hook_eval "$SCRIPT" \
  "{\"tool_name\":\"Write\",\"tool_input\":{\"file_path\":\"$tmpfile\"}}" \
  2 "block: useQuery from @tanstack/react-query with ConnectRPC" "Connect Query"

rm -f "$tmpfile"

# ── Check 1: Allow raw useQuery without ConnectRPC (REST) ────────

tmpfile=$(mktemp /tmp/cq-eval-XXXX.tsx)
printf "import { useQuery } from '@tanstack/react-query'\nconst { data } = useQuery({ queryKey: ['users'], queryFn: fetchUsers })\n" > "$tmpfile"

run_hook_eval "$SCRIPT" \
  "{\"tool_name\":\"Write\",\"tool_input\":{\"file_path\":\"$tmpfile\"}}" \
  0 "allow: useQuery from @tanstack/react-query without ConnectRPC"

rm -f "$tmpfile"

# ── Check 1: Ban raw useMutation with ConnectRPC ─────────────────

tmpfile=$(mktemp /tmp/cq-eval-XXXX.tsx)
printf "import { useMutation } from '@tanstack/react-query'\nimport { createTopic } from '@connectrpc/connect-query'\n" > "$tmpfile"

run_hook_eval "$SCRIPT" \
  "{\"tool_name\":\"Write\",\"tool_input\":{\"file_path\":\"$tmpfile\"}}" \
  2 "block: useMutation from @tanstack/react-query with ConnectRPC"

rm -f "$tmpfile"

# ── Check 2: Ban invalidateQueries() with no args ────────────────

tmpfile=$(mktemp /tmp/cq-eval-XXXX.ts)
printf "await queryClient.invalidateQueries()\n" > "$tmpfile"

run_hook_eval "$SCRIPT" \
  "{\"tool_name\":\"Write\",\"tool_input\":{\"file_path\":\"$tmpfile\"}}" \
  2 "block: invalidateQueries() with no args" "invalidates ALL"

rm -f "$tmpfile"

# ── Check 2: Allow invalidateQueries with args ───────────────────

tmpfile=$(mktemp /tmp/cq-eval-XXXX.ts)
printf "await queryClient.invalidateQueries({ queryKey: [listTopics.service.typeName], exact: false })\n" > "$tmpfile"

run_hook_eval "$SCRIPT" \
  "{\"tool_name\":\"Write\",\"tool_input\":{\"file_path\":\"$tmpfile\"}}" \
  0 "allow: invalidateQueries with queryKey"

rm -f "$tmpfile"

# ── Check 3: Warn on axios imports ───────────────────────────────

tmpfile=$(mktemp /tmp/cq-eval-XXXX.ts)
printf "import axios from 'axios'\n" > "$tmpfile"

run_hook_eval "$SCRIPT" \
  "{\"tool_name\":\"Write\",\"tool_input\":{\"file_path\":\"$tmpfile\"}}" \
  0 "warn: axios import (exit 0, not block)" "ConnectRPC transport"

rm -f "$tmpfile"

# ── Check 5: (v2) Ban new Message() construction ─────────────────

tmpfile=$(mktemp /tmp/cq-eval-XXXX.ts)
printf "import { ListTopicsRequest } from '@buf/redpandadata_cloud.bufbuild_es'\nconst req = new ListTopicsRequest({ filter: 'active' })\n" > "$tmpfile"

run_hook_eval "$SCRIPT" \
  "{\"tool_name\":\"Write\",\"tool_input\":{\"file_path\":\"$tmpfile\"}}" \
  2 "block: new Message() construction (v2)" "create()"

rm -f "$tmpfile"

# ── Check 6: (v2) Ban PlainMessage ───────────────────────────────

tmpfile=$(mktemp /tmp/cq-eval-XXXX.ts)
printf "import { PlainMessage } from '@bufbuild/protobuf'\ntype Req = PlainMessage<ListTopicsRequest>\n" > "$tmpfile"

run_hook_eval "$SCRIPT" \
  "{\"tool_name\":\"Write\",\"tool_input\":{\"file_path\":\"$tmpfile\"}}" \
  2 "block: PlainMessage (v2)" "MessageShape"

rm -f "$tmpfile"

# ── Hook script content ──────────────────────────────────────────

run_content_eval "$SCRIPT" "connectrpc" "hook checks for ConnectRPC imports"
run_content_eval "$SCRIPT" "invalidateQueries" "hook checks for invalidateQueries"
run_content_eval "$SCRIPT" "axios" "hook checks for axios"
run_content_eval "$SCRIPT" "PlainMessage" "hook checks for PlainMessage"
run_content_eval "$SCRIPT" "suppressOutput" "hook uses suppressOutput"
run_content_eval "$SCRIPT" "allow-direct-query" "hook respects escape hatch"
