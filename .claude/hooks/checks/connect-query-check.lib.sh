#!/bin/bash
# Extracted check logic for connect-query-check.sh. Source ../_hook-lib.sh before this file.

run_connect_query_check() {
hook_filter_extensions "ts|tsx" || return 0
hook_skip_generated || return 0

added_lines="$(
  set +e
  hook_get_added_lines
  _status=$?
  if [ "$_status" -eq 0 ]; then
    printf '%s' "$added_lines"
  fi
  return 0
)"

# Read full file for context
file_content=$(cat "$file_path")

if [ -n "$added_lines" ] && ! hook_has_escape "direct-query"; then

# Detect if file uses ConnectRPC/Protobuf
uses_connect=false
if echo "$file_content" | grep -qE "from\s+['\"](@connectrpc/|@buf/)"; then
  uses_connect=true
fi

# ── Check 1: Ban raw useQuery/useMutation from @tanstack/react-query ─

if [ "$uses_connect" = true ]; then
  uses_connect_transport=false
  if echo "$file_content" | grep -qE "from\s+['\"]@connectrpc/connect['\"]|from\s+['\"]@connectrpc/connect-web['\"]|callUnaryMethod|callServerStreamMethod|createGrpcWebTransport|createConnectTransport|useTransport"; then
    uses_connect_transport=true
  fi

  if [ "$uses_connect_transport" = false ]; then
    tanstack_imports=$(echo "$added_lines" | grep -E "from\s+['\"]@tanstack/react-query['\"]" || true)
    if [ -n "$tanstack_imports" ] && echo "$tanstack_imports" | grep -qE '\buseQuery\b[^C]|\buseQuery\b\s*[,}]|\buseMutation\b[^S]|\buseMutation\b\s*[,}]'; then
      hook_block "useQuery/useMutation → import from @connectrpc/connect-query, not @tanstack/react-query. Escape: // allow: direct-query [reason]"
    fi
  fi
fi

# ── Check 2: Ban invalidateQueries() with no args ────────────────────

if echo "$added_lines" | grep -qE 'invalidateQueries\(\s*\)'; then
  hook_block "No invalidateQueries() with empty args (invalidates ALL). Scope: queryKey: [rpcMethod.service.typeName]."
fi

# ── Check 3: Warn on axios imports ────────────────────────────────────

if echo "$added_lines" | grep -qE "from\s+['\"]axios['\"]|require\(['\"]axios['\"]\)"; then
  hook_warn "Prefer ConnectRPC transport over axios. Bypass protobuf type safety. Escape: // allow: direct-query [reason]"
fi

# ── Check 4: Warn on fetch() calls ───────────────────────────────────

if echo "$added_lines" | grep -qE '\bfetch\s*\('; then
  if [ "$uses_connect" = true ]; then
    hook_block "No raw fetch() in ConnectRPC files. Use ConnectRPC transport. Escape: // allow: direct-query [reason]"
  fi
fi

# ── Check 5: (v2) Ban new Message() construction ────────────────────

if echo "$added_lines" | grep -qE '\bnew\s+[A-Z][a-zA-Z]*(Request|Response|Message)\s*\('; then
  if echo "$file_content" | grep -qE "from\s+['\"]@buf/"; then
    hook_block "Proto v2: no new Message(). Use create(Schema, { ... }) from @bufbuild/protobuf."
  fi
fi

# ── Check 6: (v2) Ban PlainMessage/PartialMessage ───────────────────

if echo "$added_lines" | grep -qE '\b(PlainMessage|PartialMessage)\b'; then
  if echo "$file_content" | grep -qE "from\s+['\"]@bufbuild/protobuf['\"]"; then
    hook_block "Proto v2: PlainMessage/PartialMessage are v1. Use MessageShape<typeof Schema> or MessageInitShape<typeof Schema>."
  fi
fi

# ── Check 7: (v2) Ban manual $typeName literals ─────────────────────

if echo "$added_lines" | grep -qE '\$typeName'; then
  is_proto_v2=false
  if [ -f "package.json" ] && grep -qE '"@bufbuild/protobuf":\s*"[\^~]?2' package.json 2>/dev/null; then
    is_proto_v2=true
  fi

  if [ "$is_proto_v2" = true ]; then
    hook_block "Proto v2: no manual \$typeName. Use create(Schema, { ... }) for type-safe construction."
  fi
fi

# ── Check 8: Warn on toJson/fromJson of Any without typeRegistry ──────

if echo "$added_lines" | grep -qE 'toJson|fromJson'; then
  if echo "$file_content" | grep -qE 'google.protobuf.Any|AnySchema|anyPack|anyUnpack'; then
    if ! echo "$file_content" | grep -qE 'typeRegistry|type_registry|createRegistry'; then
      hook_warn "toJson/fromJson with Any requires typeRegistry. Pass { typeRegistry } or configure on transport."
    fi
  fi
fi

# ── Check 9: Warn on Any construction without @type/typeUrl ───────

if echo "$added_lines" | grep -qE 'AnySchema|google\.protobuf\.Any'; then
  if echo "$added_lines" | grep -qE 'create\(.*Any' && ! echo "$added_lines" | grep -qE 'typeUrl|type_url|@type|anyPack'; then
    hook_warn "Any without typeUrl → JSON fails. Use anyPack() or set typeUrl."
  fi
fi

# ── Check 10: Warn on Timestamp as plain object ──────────────────

if echo "$added_lines" | grep -qE '\bTimestamp\b' || echo "$file_content" | grep -qE 'timestamp_pb'; then
  if echo "$added_lines" | grep -qE '\{\s*seconds\s*:|nanos\s*:' && echo "$file_content" | grep -qE '\bTimestamp\b|timestamp_pb'; then
    hook_warn "No manual { seconds, nanos } for Timestamp. Use timestampFromDate(new Date()) from @bufbuild/protobuf/wkt."
  fi
  if echo "$added_lines" | grep -qE 'new Date\(\)' && echo "$added_lines" | grep -qE '\bTimestamp\b'; then
    if ! echo "$added_lines" | grep -qE 'timestampFromDate|timestampDate|Timestamp\.fromDate|toTimestamp'; then
      hook_warn "No raw Date to Timestamp field. Use timestampFromDate(date) from @bufbuild/protobuf/wkt."
    fi
  fi
fi

fi

_is_test_file=false
case "$file_path" in
  *.test.*|*.spec.*|*/__tests__/*) _is_test_file=true ;;
esac

# ── absorbed from connect-error-check.sh (4.28 family consolidation) ──
# ── Check 1: Use ConnectError.from() in ConnectRPC files ─────────
# In files that import from @connectrpc/, throw new Error() loses
# gRPC status codes. Use ConnectError.from() for consistency.

if [ "$_is_test_file" = false ] && [ -n "$added_lines" ]; then
  # Gate: file uses connectrpc OR is in a project that does (sibling files import it)
  _uses_connect=false
  if echo "$file_content" | grep -qE "from\s+['\"]@connectrpc/"; then
    _uses_connect=true
  elif echo "$file_path" | grep -qE '/(routes|hooks|components)/'; then
    # Check if project uses connectrpc (nearest package.json or sibling imports)
    _dir=$(dirname "$file_path")
    while [ "$_dir" != "/" ]; do
      if [ -f "$_dir/package.json" ] && grep -q '@connectrpc' "$_dir/package.json" 2>/dev/null; then
        _uses_connect=true
        break
      fi
      _dir=$(dirname "$_dir")
    done
  fi

  if [ "$_uses_connect" = true ]; then
    if echo "$added_lines" | grep -qE 'throw\s+new\s+Error\('; then
      # Flag if near fetch/RPC context — queryFn, mutationFn, loader, fetch handler
      if echo "$file_content" | grep -qE 'queryFn|mutationFn|loader|\.fetch\(|callUnaryMethod'; then
        if ! hook_has_escape "connect-error"; then
          hook_warn "Use ConnectError.from() not throw new Error() in data-fetching code. Preserves gRPC status codes for consistent error handling. Escape: // allow: connect-error [reason]"
        fi
      fi
    fi
  fi
fi

# ── absorbed from connect-error-format-check.sh (4.28 family consolidation) ──
# ── Gate: only React/hook files with mutation or fetch context ────
is_relevant=false
if echo "$file_content" | grep -qE 'useMutation|mutationFn|mutateAsync|\.mutate\(|onError|catch\s*\('; then
  is_relevant=true
fi

if [ "$_is_test_file" = false ] && [ "$is_relevant" = true ] && [ -n "$added_lines" ]; then
  # ── Check 1: catch blocks should use ConnectError.from() ─────────
  # In projects using ConnectRPC, error formatting should be consistent.

  _uses_connect=false
  if echo "$file_content" | grep -qE "from\s+['\"]@connectrpc/"; then
    _uses_connect=true
  elif echo "$file_path" | grep -qE '/(routes|hooks|components)/'; then
    _dir=$(dirname "$file_path")
    while [ "$_dir" != "/" ]; do
      if [ -f "$_dir/package.json" ] && grep -q '@connectrpc' "$_dir/package.json" 2>/dev/null; then
        _uses_connect=true
        break
      fi
      _dir=$(dirname "$_dir")
    done
  fi

  if [ "$_uses_connect" = true ]; then
    # Check for catch blocks that create new Error instead of ConnectError.from
    if echo "$added_lines" | grep -qE 'catch\s*\('; then
      if echo "$added_lines" | grep -qE 'throw\s+new\s+Error\(|new\s+Error\('; then
        if ! hook_has_escape "connect-error-format"; then
          hook_warn "Use ConnectError.from(error) in catch blocks, not new Error(). Preserves gRPC status codes. Escape: // allow: connect-error-format [reason]" "connect-error-format-throw"
        fi
      fi
    fi

    # Check for toast error without formatToastErrorMessageGRPC
    if echo "$added_lines" | grep -qE 'toast\.(error|warning)\(|showToast\('; then
      if ! echo "$added_lines" | grep -qE 'formatToastErrorMessageGRPC|formatErrorMessage'; then
        if ! hook_has_escape "connect-error-format"; then
          hook_warn "Use formatToastErrorMessageGRPC(ConnectError.from(error)) for toast errors. Consistent gRPC error formatting. Escape: // allow: connect-error-format [reason]" "connect-error-format-toast"
        fi
      fi
    fi
  fi

  # (mutate/mutateAsync-without-onError is owned by query-pattern-check.lib.sh;
  # this file keeps only ConnectRPC-specific error formatting and field mapping.)
fi

# ── absorbed from connect-error-fieldmap-check.sh (4.28 family consolidation) ──
# Enforce: when a form file handles a ConnectError onError, it must
# unpack BadRequest.FieldViolation into form.setError per field — not
# just toast the aggregated message. Missing per-field mapping loses
# server-side validation feedback (fields stay green while toast dies).

if [ "$_is_test_file" = false ]; then
  # Gate: file must be a form handler (uses react-hook-form / useProtoForm)
  # AND surface ConnectError errors (formatConnectError / ConnectError.from).
  if echo "$file_content" | grep -qE 'useProtoForm|useForm\(|handleSubmit' && \
     echo "$file_content" | grep -qE 'formatConnectError|ConnectError\.from|ConnectError<'; then
    # If file already wires per-field mapping, pass.
    if ! echo "$file_content" | grep -qE '\.setError\(|setError\s*\(|fieldViolations|BadRequest'; then
      if ! hook_has_escape "connect-error-fieldmap"; then
        hook_warn "ConnectError surfaced with toast-only — lost server-side FieldViolation feedback. Unpack BadRequest.FieldViolation in onError and call form.setError({ type: 'server', message }) per field; reserve toast for non-field errors. Escape: // allow: connect-error-fieldmap [reason]" "connect-error-fieldmap"
      fi
    fi
  fi
fi

# ── Check: no inline staleTime/gcTime numbers — use tier constants ──
# Cache lifetimes are a policy, not a per-call magic number. Keep 2-3
# semantic tiers (SHORT/MEDIUM/LONG_LIVED_CACHE_STALE_TIME) in one file
# so global tuning stays possible; Infinity only for invalidate-driven data.

if echo "$added_lines" | grep -qE '(staleTime|gcTime)\s*:\s*[0-9]'; then
  if ! hook_has_escape "cache-tier"; then
    hook_warn "Inline staleTime/gcTime number. Use the semantic tier constants (SHORT/MEDIUM/LONG_LIVED_CACHE_STALE_TIME) from the shared query utils — cache lifetime is a policy, not a magic number. Escape: // allow: cache-tier [reason]" "cache-tier"
  fi
fi

# ── Check: proto optional fields are undefined, never null ────────
# protobuf-es models absent optional fields as undefined. Writing null
# into create()/message fields desyncs types and serialization.

if echo "$file_content" | grep -qE "from\s+['\"][^'\"]*_pb(\.js)?['\"]|@bufbuild/protobuf"; then
  if echo "$added_lines" | grep -qE 'create\([A-Za-z0-9_]+Schema' || echo "$file_content" | grep -qE 'create\([A-Za-z0-9_]+Schema'; then
    if echo "$added_lines" | grep -qE ':\s*null\b|=\s*null\b'; then
      if ! hook_has_escape "proto-null"; then
        hook_warn "null assigned in proto-adjacent code — protobuf-es models absent optionals as undefined, never null. Use undefined (or omit the field). Escape: // allow: proto-null [reason]" "proto-null"
      fi
    fi
  fi
fi

return 0
}
