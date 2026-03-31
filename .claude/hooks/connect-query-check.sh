#!/bin/bash
set -euo pipefail
source "$(dirname "$0")/_hook-lib.sh"

hook_parse_edit_write
hook_filter_extensions "ts|tsx|js|jsx"
hook_skip_generated

# Check for escape hatch
if grep -qE '//\s*allow-direct-query:' "$file_path"; then
  exit 0
fi

hook_get_added_lines

# Read full file for context
file_content=$(cat "$file_path")

# Detect if file uses ConnectRPC/Protobuf
uses_connect=false
if echo "$file_content" | grep -qE "from\s+['\"](@connectrpc/|@buf/)"; then
  uses_connect=true
fi

# ── Check 1: Ban raw useQuery/useMutation from @tanstack/react-query ─

if [ "$uses_connect" = true ]; then
  # Allow raw useQuery/useMutation when file imports from @connectrpc/connect directly
  # (useTransport/callUnaryMethod pattern is legitimate)
  uses_connect_transport=false
  if echo "$file_content" | grep -qE "from\s+['\"]@connectrpc/connect['\"]"; then
    uses_connect_transport=true
  fi

  if [ "$uses_connect_transport" = false ]; then
    # Allow useQueryClient, useTransport, etc. — only ban useQuery and useMutation exactly
    tanstack_imports=$(echo "$added_lines" | grep -E "from\s+['\"]@tanstack/react-query['\"]" || true)
    if [ -n "$tanstack_imports" ] && echo "$tanstack_imports" | sed -E 's/useQueryClient//g; s/useTransport//g' | grep -qE '\buseQuery\b|\buseMutation\b'; then
      hook_block "Do not import useQuery/useMutation from @tanstack/react-query in files using ConnectRPC. Use Connect Query instead:\n\n// BAD\nimport { useQuery } from '@tanstack/react-query'\n\n// GOOD\nimport { useQuery } from '@connectrpc/connect-query'\n\nConnect Query provides type-safe hooks that understand your protobuf service definitions.\n\nException: if using useTransport/callUnaryMethod from @connectrpc/connect, raw TanStack Query hooks are allowed."
    fi
  fi
fi

# ── Check 2: Ban invalidateQueries() with no args ────────────────────

if echo "$added_lines" | grep -qE 'invalidateQueries\(\s*\)'; then
  hook_block "invalidateQueries() with no args invalidates ALL queries — this is almost never what you want.\n\nInvalidate by service type name instead:\n\nawait queryClient.invalidateQueries({\n  queryKey: [yourRpcMethod.service.typeName],\n  exact: false,\n})"
fi

# ── Check 3: Warn on axios imports ────────────────────────────────────

if echo "$added_lines" | grep -qE "from\s+['\"]axios['\"]|require\(['\"]axios['\"]\)"; then
  hook_warn "Prefer ConnectRPC transport over axios for API calls. axios bypasses the ConnectRPC transport layer and loses protobuf type safety.\n\nIf this is a legitimate REST endpoint (non-gRPC), add: // allow-direct-query: REST endpoint for [service]"
fi

# ── Check 4: Warn on fetch() calls ───────────────────────────────────

if echo "$added_lines" | grep -qE '\bfetch\s*\('; then
  if [ "$uses_connect" = true ]; then
    hook_warn "Prefer ConnectRPC transport over raw fetch() in files using ConnectRPC. Raw fetch bypasses the transport layer.\n\nIf this is a legitimate use case (file download, external API), add: // allow-direct-query: [reason]"
  fi
fi

# ── Check 5: (v2 only) Ban new Message() construction ────────────────

if echo "$added_lines" | grep -qE '\bnew\s+[A-Z][a-zA-Z]*(Request|Response|Message)\s*\('; then
  if echo "$file_content" | grep -qE "from\s+['\"]@buf/"; then
    hook_block "Protobuf v2: Do not use new Message() constructor. Use create() with the schema:\n\n// BAD (v1 pattern)\nconst req = new ListTopicsRequest({ filter: 'active' })\n\n// GOOD (v2 pattern)\nimport { create } from '@bufbuild/protobuf'\nimport { ListTopicsRequestSchema } from './gen/topics_pb'\nconst req = create(ListTopicsRequestSchema, { filter: 'active' })"
  fi
fi

# ── Check 6: (v2 only) Ban PlainMessage/PartialMessage ───────────────

if echo "$added_lines" | grep -qE '\b(PlainMessage|PartialMessage)\b'; then
  if echo "$file_content" | grep -qE "from\s+['\"]@bufbuild/protobuf['\"]"; then
    hook_block "Protobuf v2: PlainMessage and PartialMessage are v1 types. Use the v2 equivalents:\n\n// BAD (v1)\nPlainMessage<ListTopicsRequest>\nPartialMessage<ListTopicsRequest>\n\n// GOOD (v2)\nMessageShape<typeof ListTopicsRequestSchema>\nMessageInitShape<typeof ListTopicsRequestSchema>"
  fi
fi

# ── Check 7: (v2 only) Ban manual object literals with $typeName ─────

if echo "$added_lines" | grep -qE '\$typeName'; then
  # Only flag for protobuf v2+
  is_proto_v2=false
  if [ -f "package.json" ] && grep -qE '"@bufbuild/protobuf":\s*"[\^~]?2' package.json 2>/dev/null; then
    is_proto_v2=true
  fi

  if [ "$is_proto_v2" = true ]; then
    hook_block "Protobuf v2: Do not construct messages as manual object literals with \$typeName. Use create() for type-safe construction that breaks at compile time when the schema changes:\n\n// BAD — manual object literal\nconst msg = { \$typeName: 'foo.Bar', field: 'value' }\n\n// GOOD — create() with schema\nimport { create } from '@bufbuild/protobuf'\nconst msg = create(BarSchema, { field: 'value' })"
  fi
fi

# ── Check 8: Warn on toJson/fromJson of Any without typeRegistry ──────

if echo "$added_lines" | grep -qE 'toJson|fromJson'; then
  if echo "$file_content" | grep -qE 'google.protobuf.Any|AnySchema|anyPack|anyUnpack'; then
    if ! echo "$file_content" | grep -qE 'typeRegistry|type_registry|createRegistry'; then
      hook_warn "This file uses google.protobuf.Any with toJson/fromJson but no typeRegistry is visible. Without a registry, Any serialization fails at runtime:\\n\\ncannot encode message google.protobuf.Any to JSON: type not in registry\\n\\nPass { typeRegistry } to toJson/fromJson, or ensure the transport is configured with jsonOptions: { typeRegistry }.\\n\\nSee setup-connect-query REFERENCE.md for the createRegistry pattern."
    fi
  fi
fi

exit 0
