#!/bin/bash
# Extracted check logic for bend-laws-guard.sh. Source ../_hook-lib.sh before this file.
#
# Law-driven development: a human owns LAWS.bend (the acceptance criteria); the
# agent owns the model and PROOF.bend, and `bend PROOF.bend` is the gate. Two
# moves would make that gate meaningless, so both are denied before they land:
# editing the laws, and `@unsafe` / `def f?` defs, which skip Bend's
# termination check and can "prove" anything. `?TODO` stays allowed because
# the gate already fails on it. Shell detection is best effort; CODEOWNERS on
# LAWS.bend and the CI gate remain the real enforcement.

_BEND_LAWS_MSG="LAWS.bend is human-owned: it states the acceptance criteria the proofs must meet. Propose the law change to the user instead of editing it. A human can opt a session in with BEND_LAWS_AUTHOR=1."
_BEND_ESCAPE_MSG="Bend proof escape hatch blocked: @unsafe and def f? skip the termination check, so a proof beside LAWS.bend could prove anything. Write a terminating def (count down a Nat fuel argument for loops bounded by the outside world)."
_BEND_ESCAPE_RE='(^|[^[:alnum:]_])@unsafe([^[:alnum:]_]|$)|^[[:space:]]*def[[:space:]]+[A-Za-z0-9_.]+[?][[:space:]]*\('

_bend_is_law_file() {
  case "$(basename "$1")" in
    *.bend) ;;
    *) return 1 ;;
  esac
  [ "$(basename "$1")" = "PROOF.bend" ] || [ -f "$(dirname "$1")/LAWS.bend" ]
}

run_bend_laws_edit_check() {
  [ -n "${file_path:-}" ] || return 0

  if [ "$(basename "$file_path")" = "LAWS.bend" ] && [ "${BEND_LAWS_AUTHOR:-0}" != "1" ]; then
    hook_deny "$_BEND_LAWS_MSG" "bend-laws-human-owned"
  fi

  _bend_is_law_file "$file_path" || return 0
  hook_get_added_lines || return 0
  if printf '%s\n' "$added_lines" | grep -qE "$_BEND_ESCAPE_RE"; then
    hook_deny "$_BEND_ESCAPE_MSG" "bend-proof-escape-hatch"
  fi
  return 0
}

# True when the shell command writes to a path matching $1 (an ERE for the
# path's tail): redirects, tee, in-place sed/perl, rm/truncate, dd of=, or
# cp/mv/install/ln with the path as the last argument of its segment.
_bend_shell_writes() {
  local target="$1" end='([[:space:];&|)]|$)' seg='[^;&|]*'
  printf '%s' "$_bend_cmd" | grep -qE \
    ">{1,2}[[:space:]]*[^[:space:];&|]*${target}${end}|(^|[[:space:];&|(])tee${seg}[[:space:]][^[:space:];&|]*${target}${end}|(^|[[:space:];&|(])(g?sed|perl)[[:space:]]+(${seg}[[:space:]])?-[A-Za-z]*i${seg}${target}${end}|(^|[[:space:];&|(])(rm|truncate|unlink|shred)[[:space:]]${seg}${target}${end}|of=[^[:space:]]*${target}${end}|(^|[[:space:];&|(])(git[[:space:]]+mv|cp|mv|install|ln)([[:space:]]+[^[:space:];&|]+)*[[:space:]]+[^[:space:];&|]*${target}[[:space:]]*([;&|)]|$)"
}

run_bend_laws_bash_check() {
  # Quote and backslash splitting ("LAWS".bend, r\m) must not evade the match.
  _bend_cmd=$(printf '%s' "$command" | tr -d "\\\\\"'")

  if [ "${BEND_LAWS_AUTHOR:-0}" != "1" ] && _bend_shell_writes 'LAWS\.bend'; then
    hook_deny "$_BEND_LAWS_MSG" "bend-laws-human-owned"
  fi

  if _bend_shell_writes '\.bend' && printf '%s\n' "$_bend_cmd" | grep -qE "$_BEND_ESCAPE_RE"; then
    hook_deny "$_BEND_ESCAPE_MSG" "bend-proof-escape-hatch"
  fi
  return 0
}
