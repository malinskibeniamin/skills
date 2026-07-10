#!/bin/bash
# Extracted check logic for aip-proto-check.sh. Source ../_hook-lib.sh before this file.

run_aip_proto_check() {
case "$file_path" in
  *.proto) ;;
  *) return 0 ;;
esac
hook_skip_generated || return 0
hook_get_added_lines || return 0

content=$(cat "$file_path" 2>/dev/null || true)
msg=""

_add_msg() {
  local text="$1"
  if [ -z "$msg" ]; then
    msg="$text"
  else
    msg="$msg | $text"
  fi
}

# Resource annotations without pattern create type-only resources; AIP-122 needs a name pattern.
if echo "$added_lines" | grep -q 'google.api.resource' && ! echo "$content" | grep -qE '^\s*pattern\s*:'; then
  _add_msg "resource option lacks pattern; add full path pattern and make field 1 name IDENTIFIER"
fi

# IDENTIFIER already implies immutable and not Create input; extra behavior is misleading.
if echo "$content" | grep -q 'IDENTIFIER' && echo "$content" | awk '/string name = 1/,/];/' | grep -qE 'OUTPUT_ONLY|IMMUTABLE'; then
  _add_msg "name IDENTIFIER should not also be OUTPUT_ONLY/IMMUTABLE"
fi

# New request identity should be full resource name, not bare id, except compatibility.
if echo "$added_lines" | grep -qE 'message (Get|Delete|Update)[A-Za-z0-9]*Request|string id = 1|/\{id\}'; then
  if echo "$added_lines" | grep -qE 'string id = 1|/\{id\}'; then
    _add_msg "new standard methods should identify resources by full name, not bare id; use id only for compatibility"
  fi
fi

# New Create/Update HTTP bodies should name the resource field. body:"*" makes path/body ownership muddy.
if echo "$added_lines" | grep -qE 'body:\s*"\*"'; then
  _add_msg "prefer explicit HTTP body field (for example body: \"book\") over body: \"*\" for AIP Create/Update"
fi

# Update requests need required field mask for patch semantics.
if echo "$added_lines" | grep -qE 'message Update[A-Za-z0-9]*Request' && ! echo "$content" | grep -q 'FieldMask update_mask'; then
  _add_msg "Update request should include google.protobuf.FieldMask update_mask"
fi

[ -n "$msg" ] || return 0
hook_warn "AIP proto nudge: $msg. See /aip." "aip-proto"
}
