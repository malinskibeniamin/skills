#!/bin/sh
# Proves every law directory beside this script and checks that its committed
# decisions.txt is exactly what the proven model prints. Unit tests compare the
# shipped code against decisions.txt, which is what ties that code to LAWS.bend.
#
#   laws/check.sh            prove and check (CI)
#   laws/check.sh --verdict  also recheck the proofs with Bend's Lean-proven kernel
#   laws/check.sh --write    regenerate decisions.txt after changing a model
set -eu

write=0
verdict=""
for arg in "$@"; do
  case "$arg" in
    --write) write=1 ;;
    --verdict) verdict="--verdict" ;;
    *) echo "usage: laws/check.sh [--write] [--verdict]" >&2; exit 2 ;;
  esac
done
cd "$(dirname "$0")"
bend=${BEND:-bend}
if ! command -v "$bend" >/dev/null 2>&1; then
  echo "bend not found: run laws/install-bend.sh and put \$BEND_HOME/bin on PATH" >&2
  exit 1
fi

# @unsafe and def f? skip the termination check, so a proof could prove anything.
escape='(^|[^[:alnum:]_])@unsafe([^[:alnum:]_]|$)|^[[:space:]]*def[[:space:]]+[A-Za-z0-9_.]+[?][[:space:]]*\('
# A bare capitalised pattern on an imported type binds every value instead of
# matching the constructor, so a law can pass vacuously (bendlang/bend#1328).
bare='^[[:space:]]*case([[:space:]]+[^[:space:]]+)*[[:space:]]+[A-Z][A-Za-z0-9_]*([[:space:]]+[^[:space:]]+)*[[:space:]]*:[[:space:]]*(#.*)?$'

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
status=0
found=0
for dir in $(for f in */LAWS.bend */PROOF.bend; do [ -e "$f" ] && dirname "$f"; done | sort -u); do
  found=1
  proof="$dir/PROOF.bend"
  if [ ! -f "$dir/LAWS.bend" ]; then
    echo "$dir: LAWS.bend is missing; a human writes the laws the proofs meet" >&2
    status=1
    continue
  fi
  if [ ! -f "$proof" ]; then
    echo "$dir: PROOF.bend is missing; prove every law before merging" >&2
    status=1
    continue
  fi
  if grep -nE "$escape" "$dir"/*.bend >&2; then
    echo "$dir: remove @unsafe and def f? from law files" >&2
    status=1
    continue
  fi
  if grep -nE "$bare" "$dir"/*.bend >&2; then
    echo "$dir: write imported constructors qualified and braced, like case P.Name{}: (bendlang/bend#1328)" >&2
    status=1
    continue
  fi
  if ! "$bend" "$proof" ${verdict:+"$verdict"} >"$tmp/proof.log" 2>&1 || ! grep -qx 'ALL PROOFS CHECK' "$tmp/proof.log"; then
    cat "$tmp/proof.log" >&2
    echo "$dir: bend PROOF.bend failed" >&2
    status=1
    continue
  fi
  "$bend" "$dir/oracle.bend" -o "$tmp/oracle.js" >/dev/null
  if ! node "$tmp/oracle.js" >"$tmp/oracle.out"; then
    echo "$dir: oracle failed; decisions.txt unchanged" >&2
    status=1
    continue
  fi
  sed '/^$/d' "$tmp/oracle.out" >"$tmp/decisions.txt"
  if [ "$write" = 1 ]; then
    cp "$tmp/decisions.txt" "$dir/decisions.txt"
    echo "$dir: laws proven, wrote decisions.txt"
  elif ! diff -u "$dir/decisions.txt" "$tmp/decisions.txt" >&2; then
    echo "$dir: decisions.txt is stale; run laws/check.sh --write and commit it" >&2
    status=1
  else
    echo "$dir: laws proven, decisions.txt fresh"
  fi
done
if [ "$found" -eq 0 ]; then
  echo "no law directories found: add a rule with LAWS.bend and PROOF.bend beside this script" >&2
  status=1
fi
exit $status
