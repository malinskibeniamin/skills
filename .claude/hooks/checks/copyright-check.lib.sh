#!/bin/bash
# Extracted check logic for copyright-check.sh. Source ../_hook-lib.sh before this file.

run_copyright_check() {
hook_get_added_lines || return 0

if printf '%s\n' "$added_lines" | grep -qiE \
  '^[[:space:]]*(//+|#+|/\*+|\*+|<!--|--)[[:space:]]*(copyright([[:space:]]+\(c\))?|spdx-filecopyrighttext:|spdx-license-identifier:|licensed under([[:space:]]+the)?[[:space:]])'; then
  _message="Copyright/license header comments are prohibited. Remove the added header."
  _event="${hp_event:-}"
  if [ -z "$_event" ]; then
    _event=$(printf '%s' "${_hook_input:-}" | jq -r '.hook_event_name // empty' 2>/dev/null || true)
  fi
  if [ "$_event" = "PreToolUse" ]; then
    hook_deny "$_message" "copyright-header"
  else
    hook_block_strict "$_message" "copyright-header"
  fi
fi

return 0
}
