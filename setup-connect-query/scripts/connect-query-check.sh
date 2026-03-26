#!/bin/bash
set -euo pipefail

input=$(cat)
tool_name=$(echo "$input" | jq -r '.tool_name // empty')

if [ "$tool_name" != "Edit" ] && [ "$tool_name" != "Write" ]; then
  exit 0
fi

file_path=$(echo "$input" | jq -r '.tool_input.file_path // empty')

if [ -z "$file_path" ] || [ ! -f "$file_path" ]; then
  exit 0
fi

# Only check TS/TSX/JS/JSX files
case "$file_path" in
  *.ts|*.tsx|*.js|*.jsx) ;;
  *) exit 0 ;;
esac

# Check for escape hatch
if [ -f "$file_path" ]; then
  if grep -qE '//\s*allow-direct-query:' "$file_path"; then
    exit 0
  fi
fi

# Get added lines from diff
diff_output=""
diff_output=$(git diff HEAD -- "$file_path" 2>/dev/null) || true

if [ -z "$diff_output" ]; then
  added_lines=$(cat "$file_path")
else
  added_lines=$(echo "$diff_output" | grep '^+' | grep -v '^+++' || true)
fi

if [ -z "$added_lines" ]; then
  exit 0
fi

# Read full file for context
file_content=$(cat "$file_path")

# Detect if file uses ConnectRPC/Protobuf
uses_connect=false
if echo "$file_content" | grep -qE "from\s+['\"](@connectrpc/|@buf/)"; then
  uses_connect=true
fi

# ── Check 1: Ban raw useQuery/useMutation from @tanstack/react-query ─

if [ "$uses_connect" = true ]; then
  # Allow useQueryClient, useTransport, etc. — only ban useQuery and useMutation exactly
  tanstack_imports=$(echo "$added_lines" | grep -E "from\s+['\"]@tanstack/react-query['\"]" || true)
  if [ -n "$tanstack_imports" ] && echo "$tanstack_imports" | sed -E 's/useQueryClient//g; s/useTransport//g' | grep -qE '\buseQuery\b|\buseMutation\b'; then
    echo '{"suppressOutput":true,"systemMessage":"Do not import useQuery/useMutation from @tanstack/react-query in files using ConnectRPC. Use Connect Query instead:\n\n// BAD\nimport { useQuery } from '\''@tanstack/react-query'\''\n\n// GOOD\nimport { useQuery } from '\''@connectrpc/connect-query'\''\n\nConnect Query provides type-safe hooks that understand your protobuf service definitions."}' >&2
    exit 2
  fi
fi

# ── Check 2: Ban invalidateQueries() with no args ────────────────────

if echo "$added_lines" | grep -qE 'invalidateQueries\(\s*\)'; then
  echo '{"suppressOutput":true,"systemMessage":"invalidateQueries() with no args invalidates ALL queries — this is almost never what you want.\n\nInvalidate by service type name instead:\n\nawait queryClient.invalidateQueries({\n  queryKey: [yourRpcMethod.service.typeName],\n  exact: false,\n})"}' >&2
  exit 2
fi

# ── Check 3: Warn on axios imports ────────────────────────────────────

if echo "$added_lines" | grep -qE "from\s+['\"]axios['\"]|require\(['\"]axios['\"]\)"; then
  echo '{"suppressOutput":true,"systemMessage":"Prefer ConnectRPC transport over axios for API calls. axios bypasses the ConnectRPC transport layer and loses protobuf type safety.\n\nIf this is a legitimate REST endpoint (non-gRPC), add: // allow-direct-query: REST endpoint for [service]"}' >&2
  # Warn only — do not block
  exit 0
fi

# ── Check 4: Warn on fetch() calls ───────────────────────────────────

if echo "$added_lines" | grep -qE '\bfetch\s*\('; then
  if [ "$uses_connect" = true ]; then
    echo '{"suppressOutput":true,"systemMessage":"Prefer ConnectRPC transport over raw fetch() in files using ConnectRPC. Raw fetch bypasses the transport layer.\n\nIf this is a legitimate use case (file download, external API), add: // allow-direct-query: [reason]"}' >&2
    # Warn only — do not block
    exit 0
  fi
fi

# ── Check 5: (v2 only) Ban new Message() construction ────────────────
# Remove this check for protobuf v1 projects

if echo "$added_lines" | grep -qE '\bnew\s+[A-Z][a-zA-Z]*(Request|Response|Message)\s*\('; then
  if echo "$file_content" | grep -qE "from\s+['\"]@buf/"; then
    echo '{"suppressOutput":true,"systemMessage":"Protobuf v2: Do not use new Message() constructor. Use create() with the schema:\n\n// BAD (v1 pattern)\nconst req = new ListTopicsRequest({ filter: '\''active'\'' })\n\n// GOOD (v2 pattern)\nimport { create } from '\''@bufbuild/protobuf'\''\nimport { ListTopicsRequestSchema } from '\''./gen/topics_pb'\''\nconst req = create(ListTopicsRequestSchema, { filter: '\''active'\'' })"}' >&2
    exit 2
  fi
fi

# ── Check 6: (v2 only) Ban PlainMessage/PartialMessage ───────────────
# Remove this check for protobuf v1 projects

if echo "$added_lines" | grep -qE '\b(PlainMessage|PartialMessage)\b'; then
  if echo "$file_content" | grep -qE "from\s+['\"]@bufbuild/protobuf['\"]"; then
    echo '{"suppressOutput":true,"systemMessage":"Protobuf v2: PlainMessage and PartialMessage are v1 types. Use the v2 equivalents:\n\n// BAD (v1)\nPlainMessage<ListTopicsRequest>\nPartialMessage<ListTopicsRequest>\n\n// GOOD (v2)\nMessageShape<typeof ListTopicsRequestSchema>\nMessageInitShape<typeof ListTopicsRequestSchema>"}' >&2
    exit 2
  fi
fi

exit 0
