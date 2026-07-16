#!/bin/bash
# Extracted check logic for go-proto-reserved-check.sh. Source ../_hook-lib.sh before this file.
# Shipped protobuf field numbers and names are a compatibility surface; removal
# must reserve both, and renumbering is never safe.

# Sets _go_removed/_go_added. hook_get_added_lines is unusable here: it exits
# the hook on removal-only edits, the exact case this check watches.
_go_proto_changed_lines() {
  _go_removed=""
  _go_added=""
  local tool
  tool=$(echo "$_hook_input" | jq -r '.tool_name // empty' 2>/dev/null || true)

  if [ "$tool" = "Edit" ]; then
    local _patch
    _patch=$(echo "$_hook_input" | jq -r '.tool_input.patch // empty' 2>/dev/null || true)
    if [ -n "$_patch" ]; then
      local _hunk
      _hunk=$(printf '%s\n' "$_patch" | awk -v f="$file_path" '
        /^\*\*\* (Update|Add|Delete) File: / { h = substr($0, index($0, ": ") + 2); in_target = (h == f || (length(f) > length(h) && substr(f, length(f) - length(h)) == "/" h)); next }
        /^\*\*\*/ { in_target = 0; next }
        in_target { print }')
      _go_removed=$(printf '%s\n' "$_hunk" | grep '^-' | sed 's/^-//' || true)
      _go_added=$(printf '%s\n' "$_hunk" | grep '^+' | sed 's/^+//' || true)
      return 0
    fi
    local has_old
    has_old=$(echo "$_hook_input" | jq -r '.tool_input | has("old_string")' 2>/dev/null || echo "false")
    if [ "$has_old" = "true" ]; then
      local old_str new_str _d
      old_str=$(echo "$_hook_input" | jq -r '.tool_input.old_string // ""' 2>/dev/null || true)
      new_str=$(echo "$_hook_input" | jq -r '.tool_input.new_string // ""' 2>/dev/null || true)
      _d=$(diff <(printf '%s\n' "$old_str") <(printf '%s\n' "$new_str") 2>/dev/null || true)
      _go_removed=$(printf '%s\n' "$_d" | grep '^<' | sed 's/^< //' || true)
      _go_added=$(printf '%s\n' "$_d" | grep '^>' | sed 's/^> //' || true)
      return 0
    fi
  fi

  local _d
  _d=$(git diff HEAD -- "$file_path" 2>/dev/null || true)
  _go_removed=$(printf '%s\n' "$_d" | grep '^-' | grep -v '^---' | sed 's/^-//' || true)
  _go_added=$(printf '%s\n' "$_d" | grep '^+' | grep -v '^+++' | sed 's/^+//' || true)
}

_go_proto_field_sed='s/^[[:space:]]*(optional[[:space:]]+|repeated[[:space:]]+)?([A-Za-z_][A-Za-z0-9_.]*|map[[:space:]]*<[^>]*>)[[:space:]]+([a-z_][a-z0-9_]*)[[:space:]]*=[[:space:]]*([0-9]+).*/'

run_go_proto_reserved_check() {
case "$file_path" in
  *.proto) ;;
  *) return 0 ;;
esac
hook_skip_generated || return 0
if hook_has_escape "proto-unshipped"; then return 0; fi
local _go_removed="" _go_added=""
_go_proto_changed_lines
[ -n "$_go_removed" ] || return 0

local content msg="" line fname fnum
content=$(cat "$file_path" 2>/dev/null || true)

_add_msg() {
  if [ -z "$msg" ]; then msg="$1"; else msg="$msg | $1"; fi
}

while IFS= read -r line; do
  # Skip commented-out lines and reserved statements, not fields that merely
  # carry a trailing comment or a name containing "reserved".
  if printf '%s' "$line" | grep -qE '^[[:space:]]*(//|reserved[[:space:]])'; then
    continue
  fi
  fname=$(printf '%s' "$line" | sed -nE "${_go_proto_field_sed}\\3/p")
  fnum=$(printf '%s' "$line" | sed -nE "${_go_proto_field_sed}\\4/p")
  [ -n "$fname" ] && [ -n "$fnum" ] || continue

  # Same name and number re-added: the field only moved.
  if printf '%s\n' "$_go_added" | grep -qE "[[:space:]]$fname[[:space:]]*=[[:space:]]*$fnum\b"; then
    continue
  fi
  # Name re-added under a different number: renumbering shipped fields breaks the wire format.
  if printf '%s\n' "$_go_added" | grep -qE "[[:space:]]$fname[[:space:]]*=[[:space:]]*[0-9]+"; then
    _add_msg "field '$fname' looks renumbered; never renumber shipped proto fields, add a new field and reserve the old"
    continue
  fi
  if ! printf '%s' "$content" | grep -qE "reserved[^;]*\b$fnum\b"; then
    _add_msg "removed field '$fname' ($fnum): reserve the number (reserved $fnum;)"
  fi
  if ! printf '%s' "$content" | grep -qE "reserved[^;]*\"$fname\""; then
    _add_msg "removed field '$fname': reserve the name (reserved \"$fname\";)"
  fi
done <<EOF
$_go_removed
EOF

[ -n "$msg" ] || return 0
hook_warn "Proto compatibility: $msg. Never-shipped field: // allow: proto-unshipped [reason]. See /golang." "go-proto-reserved"
}
