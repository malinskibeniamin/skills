#!/bin/bash
# Extracted check logic for ts-no-escape-hatches-check.sh. Source ../_hook-lib.sh before this file.

run_ts_no_escape_hatches_check() {
# Hard-block TypeScript escape hatches that erase type safety.
# Complements the absorbed as-cast rules (focused on `as` casts) and Biome's
# noExplicitAny (lint-time only). This runs at Edit/Write time so
# the AI cannot keep shipping escape hatches across the codebase.
#
# Blocks:
#   - bare `: any`, `any[]`, `Array<any>`, `Promise<any>`, `ReadonlyArray<any>`
#   - `Record<string, any>`, `Record<string, unknown>`, `Record<any, ...>`
#   - type aliases to escape types: `type X = any | unknown | never | {}`
#   - `<any>` as a generic argument (angle-bracket form)
#   - `as unknown as T` double-cast chain
#   - `!.` non-null assertions when bang is added in this diff (warn — common but lossy)
#
# Escape hatch: `// allow: ts-escape [reason]` on the same line.

hook_filter_extensions "ts|tsx|js|jsx|mts|cts" || return 0
hook_skip_generated || return 0
hook_get_added_lines || return 0

_is_test_file=false
case "$file_path" in
  *.test.*|*.spec.*|*/__tests__/*) _is_test_file=true ;;
esac

if [ "$_is_test_file" = false ]; then
case "$file_path" in
  *.ts|*.tsx)
if ! hook_has_escape "ts-escape"; then

# Normalize: strip leading + from diff lines for regex clarity.
_lines=$(printf '%s' "$added_lines" | sed 's/^+//')

# Skip if the only `any` mentions are in strings/comments — heuristic:
# drop lines that are obvious string literals or line-starting comments.
_scan=$(printf '%s\n' "$_lines" | grep -vE '^\s*(//|\*|/\*)' || true)

# ── 1. Bare `: any` type annotations ─────────────────────────────
if printf '%s' "$_scan" | grep -qE ':\s*any\b'; then
  hook_block "TypeScript escape hatch: ': any' annotation. Use a concrete type, a generic parameter, or 'unknown' with a type guard. No 'any' in production code." "ts-escape-any"
fi
if printf '%s' "$_scan" | grep -qE '\bany\[\]'; then
  hook_block "TypeScript escape hatch: 'any[]'. Use a concrete element type or a generic parameter." "ts-escape-any-array"
fi
if printf '%s' "$_scan" | grep -qE '\b(Array|Promise|ReadonlyArray|Set|Map)<\s*any\b'; then
  hook_block "TypeScript escape hatch: generic '<any>'. Specify the element/resolved type." "ts-escape-generic-any"
fi

# ── 2. Record<string, any | unknown> in declarations ─────────────
if printf '%s' "$_scan" | grep -qE '\bRecord<\s*[A-Za-z_]+\s*,\s*(any|unknown)\s*>'; then
  hook_block "Record<…, any/unknown> is any with extra steps. Define a concrete shape (interface / union) or use 'Record<K, Schema>' with zod." "ts-escape-record"
fi
if printf '%s' "$_scan" | grep -qE '\bRecord<\s*any\s*,'; then
  hook_block "Record<any, …> loses key typing. Use 'Record<string, T>' or a concrete union of keys." "ts-escape-record-keys"
fi

# ── 3. Type alias to escape type ─────────────────────────────────
if printf '%s' "$_scan" | grep -qE '\btype\s+[A-Z][A-Za-z0-9_]*\s*=\s*(any|unknown|never|\{\s*\})\s*[;|$]'; then
  hook_block "Type alias to 'any/unknown/never/{}' is a rename for an escape hatch. Define the actual shape." "ts-escape-alias"
fi

# ── 4. `as unknown as T` double-cast ─────────────────────────────
if printf '%s' "$_scan" | grep -qE '\bas\s+unknown\s+as\s+'; then
  hook_block "Double cast 'as unknown as T' hides a type error. Fix the underlying mismatch (type guard, schema, generic)." "ts-escape-double-cast"
fi

# ── 5. Non-null assertion added on a property access ─────────────
# Warn, not block — sometimes legitimate after a runtime guard.
_bang=$(printf '%s' "$_scan" | grep -cE '[A-Za-z0-9_)\]]!\.' || true)
_bang=${_bang:-0}
if [ "$_bang" -gt 0 ]; then
  if ! hook_has_escape "ts-nonnull"; then
    hook_warn "${_bang} non-null assertion(s) '!.'. Prefer a guard that narrows the type. Escape: // allow: ts-nonnull [reason]" "ts-escape-nonnull"
  fi
fi

fi
    ;;
esac
fi

# ── absorbed from as-cast-check.sh (4.28 family consolidation) ──
# ── Check 1: Hard block `as never` / `as any` ───────────────────
# These suppress TypeScript entirely. Fix types properly.

if [ "$_is_test_file" = false ]; then
case "$file_path" in
  *.ts|*.tsx)
    if echo "$added_lines" | grep -qE '\bas\s+never\b'; then
      hook_block "No 'as never' casts. Fix the underlying type mismatch — use type guards, generics, or discriminated unions."
    fi

    if echo "$added_lines" | grep -qE '\bas\s+any\b'; then
      hook_block "No 'as any' casts. Fix types properly — type guards, generics, schema validation."
    fi

    if echo "$added_lines" | grep -qE '\bas\s+Record<string,\s*(any|unknown)>'; then
      hook_block "No 'as Record<string, any/unknown>'. Use concrete interface or type guard."
    fi

    if echo "$added_lines" | grep -qF '@ts-ignore'; then
      hook_block "@ts-ignore banned. Fix type error directly."
    fi

    if echo "$added_lines" | grep -qF '@ts-expect-error'; then
      hook_block "@ts-expect-error banned. Fix underlying type error."
    fi

    # ── Check 2: Warn on `as TypeName` casts in .tsx ─────────────────
    # Prefer type guards (isServerlessCluster(x)) over casts (x as Cluster).
    # Allow: 'as const', 'as string', 'as number', 'as boolean' (primitives).

    as_casts=$(echo "$added_lines" | grep -E '\bas\s+[A-Z][A-Za-z]+' | grep -vE '\bas\s+const\b|\bas\s+unknown\b|\bas\s+React\.' || true)

    if [ -n "$as_casts" ]; then
      _count=$(echo "$as_casts" | wc -l | tr -d '[:space:]')
      if [ "${_count:-0}" -gt 2 ]; then
        if ! hook_has_escape "as-cast"; then
          sample=$(echo "$as_casts" | head -2 | sed 's/^+//' | tr '\n' ' ')
          hook_warn "${_count} type casts with 'as'. Prefer type guards for safety. Found: $sample. Escape: // allow: as-cast [reason]" "as-cast"
        fi
      fi
    fi
    ;;
esac
fi

# ── absorbed from biome-ignore-check.sh (4.28 family consolidation) ──
# ── Check: Block all new biome-ignore comments ───────────────────
# No lint suppression. Generated files are skipped above. Everything else
# must fix the lint/style/type issue at source; every ignore pattern gets
# copied by LLMs and becomes normalized debt.
#
# @ts-ignore/@ts-expect-error are owned by the absorbed as-cast rule.

ignore_lines=$(echo "$added_lines" | grep -E 'biome-ignore' || true)

if [ -n "$ignore_lines" ]; then
  sample=$(echo "$ignore_lines" | head -2 | sed 's/^+//' | tr '\n' ' ')
  if echo "$ignore_lines" | grep -qE 'noExplicitAny'; then
    hook_block "No lint suppression. biome-ignore noExplicitAny is banned; fix types with type guards, generics, or schema validation. Found: $sample" "biome-ignore"
  fi
  hook_block "No lint suppression. Every biome-ignore gets copied by LLMs; fix the lint/style issue at source. Found: $sample" "biome-ignore"
fi

# ── absorbed from legacy-linter-check.sh (4.28 family consolidation) ──
# ── Check 1: eslint directive comments ────────────────────────────
# Project uses Biome, not ESLint. eslint-disable comments are dead
# weight and signal wrong toolchain knowledge.

if echo "$added_lines" | grep -qE '(//|/\*)\s*eslint-disable'; then
  hook_block "ESLint directive found. Project uses Biome, not ESLint. Fix the code or project rule config; do not add suppression comments."
fi

if echo "$added_lines" | grep -qF 'eslint-enable'; then
  hook_block "eslint-enable found. Project uses Biome, not ESLint. Remove eslint directives."
fi

# ── Check 2: prettier directive comments ──────────────────────────

if echo "$added_lines" | grep -qE '(//|/\*|<!--)\s*prettier-ignore'; then
  hook_block "prettier-ignore found. Project uses Biome for formatting. Remove prettier directives."
fi

return 0
}
