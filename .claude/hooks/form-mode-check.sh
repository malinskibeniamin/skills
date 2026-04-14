#!/bin/bash
set -euo pipefail
source "$(dirname "$0")/_hook-lib.sh"

hook_parse_edit_write
hook_filter_extensions "ts|tsx|js|jsx"
hook_skip_generated
hook_get_added_lines

# ── Check 1: Ban mode: 'onBlur' / 'onSubmit' in form options ────
# Forms must use onChange for immediate validation feedback.

if echo "$added_lines" | grep -qE "mode:\s*['\"]on(Blur|Submit)['\"]"; then
  if ! hook_has_escape "form-mode"; then
    hook_warn "Form mode should be 'onChange' for immediate validation feedback. Avoid 'onBlur'/'onSubmit'. Escape: // allow: form-mode [reason]"
  fi
fi

exit 0
