#!/bin/bash
set -euo pipefail
source "$(dirname "$0")/_hook-lib.sh"

hook_parse_edit_write
hook_skip_generated
hook_filter_extensions "ts|tsx"
hook_get_added_lines

# Escape hatch: // allow-ux-copy: [reason]
if grep -qE '//\s*allow-ux-copy:' "$file_path" 2>/dev/null; then
  exit 0
fi

# ── Check 1: Ban exclamation points at end of string literals ─────
# Only match strings that END with ! (the actual anti-pattern).
# Avoids false positives from template literals, regex, negation operators.

if echo "$added_lines" | grep -qE "!['\"]|!\\\\n|!\s*['\"]"; then
  # Exclude operators and code patterns
  if ! echo "$added_lines" | grep -E '!["\x27]' | grep -qE '!==|!=|!important|http'; then
    hook_block "No exclamation points in UI text. Remove the '!'.\n\nExclamation points convey unnecessary excitement or alarm in product interfaces."
  fi
fi

# ── Check 2: Ban "successfully" in UI text ────────────────────────

if echo "$added_lines" | grep -qiE "(['\"])[^'\"]*successfully[^'\"]*\1"; then
  hook_block "Remove 'successfully' from UI text. Use past-tense verb instead.\n\nBAD:  'Topic successfully created'\nGOOD: 'Topic created'"
fi

# ── Check 3: Ban "click here" / bare "here" link text ────────────

case "$file_path" in
  *.tsx)
    if echo "$added_lines" | grep -qiE '>[[:space:]]*(click here|here)[[:space:]]*<'; then
      hook_block "No 'click here' link text. Use descriptive text that explains the destination.\n\nBAD:  <Link>Click here</Link>\nGOOD: <Link>View documentation</Link>"
    fi
    ;;
esac

# ── Check 4: Ban blame language ───────────────────────────────────

if echo "$added_lines" | grep -qiE "(['\"])[^'\"]*\b(oops|uh oh|oh no|whoops)\b[^'\"]*\1"; then
  hook_block "No casual error language. State the problem clearly and provide a solution.\n\nBAD:  'Oops! Something went wrong'\nGOOD: 'Could not save changes. Check your connection and try again.'"
fi

# ── Check 5: Warn on possessive pronouns in titles/nav ────────────

if echo "$added_lines" | grep -qE "(['\"])(My |Your )[A-Z]"; then
  hook_warn "Avoid possessive pronouns in page names, menu items, and titles.\n\nBAD:  'My Settings', 'Your Clusters'\nGOOD: 'Settings', 'Clusters'"
fi

# ── Check 6: Ban "Yes"/"No" button labels ─────────────────────────

case "$file_path" in
  *.tsx)
    if echo "$added_lines" | grep -qE '<Button[^>]*>[[:space:]]*(Yes|No)[[:space:]]*</Button>'; then
      hook_block "No 'Yes'/'No' button labels. Use clear action verbs.\n\nBAD:  <Button>Yes</Button> <Button>No</Button>\nGOOD: <Button>Delete cluster</Button> <Button>Keep cluster</Button>"
    fi
    ;;
esac

# ── Check 7: Warn on formatting in string literals ────────────────

if echo "$added_lines" | grep -qE '(\*\*[^*]+\*\*|__[^_]+__)'; then
  hook_warn "No bold or italic formatting in UI text. Use plain text.\nIf markup is needed, use the component library formatting props."
fi

# ── Check 8: Warn on ALL CAPS for emphasis ────────────────────────

if echo "$added_lines" | grep -qE "(['\"])[^'\"]*\b[A-Z]{3,}\s+[A-Z]{3,}\b[^'\"]*\1"; then
  _caps_line=$(echo "$added_lines" | grep -E "(['\"])[^'\"]*\b[A-Z]{3,}\s+[A-Z]{3,}\b" | head -1)
  if ! echo "$_caps_line" | grep -qE '\b(HTTP|HTTPS|API|TLS|MTLS|OIDC|SASL|BYOC|VPC|CIDR|PSC|ACL|RBAC|AWS|GCP|DNS|URL|URI|SSH|SSL|IAM|ARN|EKS|GKE|CLI)\b'; then
    hook_warn "No ALL CAPS for emphasis in UI text. Use sentence case.\nException: acronyms (API, TLS, VPC)."
  fi
fi

# ── Check 9: Redpanda term capitalization (REDPANDA_KIT=1) ───────

if [ "${REDPANDA_KIT:-}" = "1" ]; then
  if echo "$added_lines" | grep -qiE "(['\"])[^'\"]*\b(admin api|schema registry|http proxy|redpanda console)\b[^'\"]*\1" && \
     ! echo "$added_lines" | grep -qE "(Admin API|Schema Registry|HTTP Proxy|Redpanda Console)"; then
    hook_block "Redpanda product names must be capitalized correctly.\n\nAdmin API, Schema Registry, HTTP Proxy, Redpanda Console, Dedicated Cloud, BYOC."
  fi

  if echo "$added_lines" | grep -qiE "(['\"])[^'\"]*\bthe console\b[^'\"]*\1"; then
    hook_warn "Use 'Redpanda Console' instead of 'the console'."
  fi
fi

# ── Check 10: Title Case detection in strings ─────────────────────

if echo "$added_lines" | grep -qE "(['\"])[A-Z][a-z]+\s+[A-Z][a-z]+\s+[A-Z][a-z]+" ; then
  _title_line=$(echo "$added_lines" | grep -E "(['\"])[A-Z][a-z]+\s+[A-Z][a-z]+\s+[A-Z][a-z]+" | head -1)
  if ! echo "$_title_line" | grep -qE '(Admin API|Schema Registry|HTTP Proxy|Redpanda Console|Dedicated Cloud|Bring Your Own Cloud|Private Service Connect|Virtual Private Cloud)'; then
    hook_warn "Possible Title Case detected. Use sentence-style capitalization.\n\nBAD:  'Create New Topic'\nGOOD: 'Create new topic'\n\nExceptions: product names (Admin API, Schema Registry)."
  fi
fi

# ── Check 11: Spelled-out numbers (one through nine) ──────────────

if echo "$added_lines" | grep -qE "(['\"])[^'\"]*\b(one|two|three|four|five|six|seven|eight|nine)\b[^'\"]*\1"; then
  _num_line=$(echo "$added_lines" | grep -E "(['\"])[^'\"]*\b(one|two|three|four|five|six|seven|eight|nine)\b" | head -1)
  if ! echo "$_num_line" | grep -qiE '(one of|one or|one-time|one-way|two-factor|two-way|day one)'; then
    hook_warn "Use numerals (1-9) instead of spelled-out numbers in UI text.\n\nBAD:  'Select one option'\nGOOD: 'Select 1 option'"
  fi
fi

# ── Check 12: Ban "and/or" ────────────────────────────────────────

if echo "$added_lines" | grep -qE "(['\"])[^'\"]*\band/or\b[^'\"]*\1"; then
  hook_warn "Avoid 'and/or'. Use 'and', 'or', or 'A, B, or both' instead."
fi

# ── Check 13: Ban "etc." in UI text ──────────────────────────────

if echo "$added_lines" | grep -qE "(['\"])[^'\"]*\betc\.[^'\"]*\1"; then
  hook_warn "Avoid 'etc.' in UI text. List specific items or use 'such as' with concrete examples."
fi

# ── Check 14: Ban "e.g." / "i.e." — suggest plain English ────────

if echo "$added_lines" | grep -qE "(['\"])[^'\"]*\b(e\.g\.|i\.e\.)[^'\"]*\1"; then
  hook_warn "Avoid Latin abbreviations in UI text.\n\nBAD:  'e.g.' / 'i.e.'\nGOOD: 'for example' / 'that is'"
fi

# ── Check 15: Ban "Please ..." imperative pattern in UI strings ───
# Only fires on strings starting with "Please" (the imperative anti-pattern).
# "please" mid-sentence in error acknowledgments is acceptable.

if echo "$added_lines" | grep -qE "(['\"])Please [^'\"]*\1"; then
  hook_warn "Avoid starting UI text with 'Please' — it implies the action is optional.\nUse direct language: 'Enter your email' not 'Please enter your email'."
fi

# ── Check 16: Ban non-inclusive terminology ───────────────────────

if echo "$added_lines" | grep -qiE '\b(whitelist|blacklist|master|slave)\b'; then
  hook_block "Use inclusive terminology.\n\nBAD:  whitelist/blacklist, master/slave\nGOOD: allowlist/denylist, leader/follower, primary/secondary"
fi

# ── Check 17: Warn on "There is" / "There are" starters ─────────

if echo "$added_lines" | grep -qE "(['\"])(There is |There are )[^'\"]*\1"; then
  hook_warn "Avoid starting with 'There is/are'. Put the subject first.\n\nBAD:  'There are 3 configuration options'\nGOOD: '3 configuration options are available'"
fi

# ── Check 18: Warn on "via" in UI text ───────────────────────────

if echo "$added_lines" | grep -qE "(['\"])[^'\"]*\bvia\b[^'\"]*\1"; then
  hook_warn "Avoid 'via' in UI text. Use 'through', 'using', or 'with' instead."
fi

exit 0
