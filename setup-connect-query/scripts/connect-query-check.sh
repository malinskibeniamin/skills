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
      hook_block "Import useQuery/useMutation from @connectrpc/connect-query.\nDo not import from @tanstack/react-query in ConnectRPC files.\n\n// BAD\nimport { useQuery } from '@tanstack/react-query'\n\n// GOOD\nimport { useQuery } from '@connectrpc/connect-query'\n\nEscape hatch: // allow-direct-query: [reason]"
    fi
  fi
fi

# ── Check 2: Ban invalidateQueries() with no args ────────────────────

if echo "$added_lines" | grep -qE 'invalidateQueries\(\s*\)'; then
  hook_block "Do not call invalidateQueries() with no args (invalidates ALL queries).\nScope to a service type name: queryKey: [yourRpcMethod.service.typeName]."
fi

# ── Check 3: Warn on axios imports ────────────────────────────────────

if echo "$added_lines" | grep -qE "from\s+['\"]axios['\"]|require\(['\"]axios['\"]\)"; then
  hook_warn "Prefer ConnectRPC transport over axios for API calls.\naxios bypasses protobuf type safety. Escape hatch: // allow-direct-query: REST endpoint for [service]"
fi

# ── Check 4: Warn on fetch() calls ───────────────────────────────────

if echo "$added_lines" | grep -qE '\bfetch\s*\('; then
  if [ "$uses_connect" = true ]; then
    hook_warn "Prefer ConnectRPC transport over raw fetch() in ConnectRPC files.\nEscape hatch: // allow-direct-query: [reason]"
  fi
fi

# ── Check 5: (v2 only) Ban new Message() construction ────────────────

if echo "$added_lines" | grep -qE '\bnew\s+[A-Z][a-zA-Z]*(Request|Response|Message)\s*\('; then
  if echo "$file_content" | grep -qE "from\s+['\"]@buf/"; then
    hook_block "Protobuf v2: Do not use new Message() constructor.\nUse create(Schema, { ... }) from @bufbuild/protobuf instead.\n\n// BAD\nconst req = new ListTopicsRequest({ filter: 'active' })\n\n// GOOD\nconst req = create(ListTopicsRequestSchema, { filter: 'active' })"
  fi
fi

# ── Check 6: (v2 only) Ban PlainMessage/PartialMessage ───────────────

if echo "$added_lines" | grep -qE '\b(PlainMessage|PartialMessage)\b'; then
  if echo "$file_content" | grep -qE "from\s+['\"]@bufbuild/protobuf['\"]"; then
    hook_block "Protobuf v2: PlainMessage/PartialMessage are v1 types.\nUse MessageShape<typeof Schema> or MessageInitShape<typeof Schema> instead."
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
    hook_block "Protobuf v2: Do not construct messages with manual \$typeName literals.\nUse create(Schema, { ... }) for type-safe construction.\n\n// BAD\nconst msg = { \$typeName: 'foo.Bar', field: 'value' }\n\n// GOOD\nconst msg = create(BarSchema, { field: 'value' })"
  fi
fi

# ── Check 8: Warn on toJson/fromJson of Any without typeRegistry ──────

if echo "$added_lines" | grep -qE 'toJson|fromJson'; then
  if echo "$file_content" | grep -qE 'google.protobuf.Any|AnySchema|anyPack|anyUnpack'; then
    if ! echo "$file_content" | grep -qE 'typeRegistry|type_registry|createRegistry'; then
      hook_warn "toJson/fromJson with google.protobuf.Any requires a typeRegistry.\nPass { typeRegistry } to toJson/fromJson or configure it on the transport.\n\nSee setup-connect-query REFERENCE.md for the createRegistry pattern."
    fi
  fi
fi

# ── Check 9: Warn on Any construction without @type/typeUrl ───────

if echo "$added_lines" | grep -qE 'AnySchema|google\.protobuf\.Any'; then
  if echo "$added_lines" | grep -qE 'create\(.*Any' && ! echo "$added_lines" | grep -qE 'typeUrl|type_url|@type|anyPack'; then
    hook_warn "Any message constructed without typeUrl.\nWithout @type, JSON serialization fails: '\"@type\" is empty'.\nUse anyPack() or set typeUrl: 'type.googleapis.com/' + Schema.typeName.\n\nSee setup-connect-query REFERENCE.md."
  fi
fi

# ── Check 10: Warn on Timestamp as plain object ──────────────────

# Only trigger on protobuf Timestamp type (capitalized) or timestamp_pb imports, not generic "timestamp" variables
if echo "$added_lines" | grep -qE '\bTimestamp\b' || echo "$file_content" | grep -qE 'timestamp_pb'; then
  # Detect manual { seconds, nanos } construction
  if echo "$added_lines" | grep -qE '\{\s*seconds\s*:|nanos\s*:' && echo "$file_content" | grep -qE '\bTimestamp\b|timestamp_pb'; then
    hook_warn "Do not construct Timestamp as { seconds, nanos } object.\nJSON decode fails: 'cannot decode Timestamp from JSON: object'.\nUse timestampFromDate(new Date()) or timestampDate(ts) from @bufbuild/protobuf/wkt.\n\nSee setup-connect-query REFERENCE.md."
  fi
  # Detect raw Date passed to Timestamp field without conversion
  if echo "$added_lines" | grep -qE 'new Date\(\)' && echo "$added_lines" | grep -qE '\bTimestamp\b'; then
    if ! echo "$added_lines" | grep -qE 'timestampFromDate|timestampDate|Timestamp\.fromDate|toTimestamp'; then
      hook_warn "Do not pass raw Date to a Timestamp field.\nUse timestampFromDate(date) from @bufbuild/protobuf/wkt to convert.\n\nSee setup-connect-query REFERENCE.md."
    fi
  fi
fi

exit 0
