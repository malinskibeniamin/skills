#!/bin/bash
# Extracted check logic for form-mode-check.sh. Source ../_hook-lib.sh before this file.

run_form_mode_check() {
hook_filter_extensions "ts|tsx" || return 0
hook_skip_generated || return 0
hook_skip_tests || return 0

added_lines="$(
  set +e
  hook_get_added_lines
  _status=$?
  if [ "$_status" -eq 0 ]; then
    printf '%s' "$added_lines"
  fi
  return 0
)"

file_content=$(cat "$file_path")

if [ -n "$added_lines" ]; then

# Allow escape hatch: // allow: form-mode [reason]
# (covers all checks in this hook)

# ── Check 1: Ban mode: 'onBlur' / 'onSubmit' in form options ────
# Forms must use onChange for immediate validation feedback.

if echo "$added_lines" | grep -qE "mode:\s*['\"]on(Blur|Submit)['\"]"; then
  if ! hook_has_escape "form-mode"; then
    hook_warn "Form mode should be 'onChange' for immediate validation feedback. Avoid 'onBlur'/'onSubmit'. Escape: // allow: form-mode [reason]"
  fi
fi

# ── Check 2: Forms without field validation ──────────────────────
# Forms should use validate/required/pattern rules on register(),
# OR a schema resolver (zodResolver, yupResolver, etc.).
# Skip if no useForm/useFormContext in file.

_is_form_file=false
if echo "$file_content" | grep -qE 'useForm\s*[(<]|useFormContext\s*\('; then
  _is_form_file=true
fi

if [ "$_is_form_file" = true ]; then
  # Skip if using a resolver (validation at schema level)
  _has_resolver=false
  if echo "$file_content" | grep -qE 'resolver\s*:|zodResolver|yupResolver|joiResolver|superstructResolver|valibotResolver'; then
    _has_resolver=true
  fi

  if [ "$_has_resolver" = false ]; then
    # Check if any register call uses validation options
    _has_field_validation=false
    if echo "$file_content" | grep -qE 'validate\s*:|required\s*:|pattern\s*:|minLength\s*:|maxLength\s*:|min\s*:|max\s*:'; then
      _has_field_validation=true
    fi

    if [ "$_has_field_validation" = false ]; then
      if ! hook_has_escape "form-validate"; then
        hook_warn "Form has no field validation. Add validate/required/pattern to register() or use a resolver (zodResolver). Escape: // allow: form-validate [reason]" "form-mode-validate"
      fi
    fi
  fi

  # ── Check 3: Forms without inline error display ──────────────────
  # Errors must surface next to fields — not just in toasts or hidden.
  # Look for: FormMessage, FieldError, FormDescription with error,
  # errors.fieldName?.message, or Field component (wraps error display).

  _has_error_display=false
  if echo "$file_content" | grep -qE 'FormMessage|FieldError|FormErrorDescription|ErrorDescription|FormDescription.*error|errors\.\w+\??\.\s*message|formState\.errors|<Field[\s>]|FieldInfo'; then
    _has_error_display=true
  fi

  if [ "$_has_error_display" = false ]; then
    if ! hook_has_escape "form-errors"; then
      hook_warn "Form lacks inline error display next to fields. Surface errors via FormMessage/FieldError/Field component with error descriptions. Escape: // allow: form-errors [reason]" "form-mode-errors"
    fi
  fi
fi

fi

# ── absorbed from form-watch-check.sh (4.28 family consolidation) ──
# ── Check: form.watch() should be useWatch() ─────────────────────
# React Compiler needs useWatch for proper rerender tracking.
# form.watch() doesn't trigger component rerenders reliably.

if [ -n "$added_lines" ] && echo "$added_lines" | grep -qE '\.watch\(\s*['\''"]|form\.watch\(|\.watch\(\)'; then
  # Only fire if file uses react-hook-form
  if echo "$file_content" | grep -qE "from\s+['\"]react-hook-form['\"]|useForm\(|useFormContext\("; then
    if ! hook_has_escape "form-watch"; then
      hook_block "Use useWatch() instead of form.watch() for React Compiler compatibility. useWatch triggers proper rerenders. Escape: // allow: form-watch [reason]"
    fi
  fi
fi

# ── absorbed from form-setvalue-options-check.sh (4.28 family consolidation) ──
# Enforce: form.setValue(name, value) must pass { shouldDirty: true,
# shouldValidate: true } options unless intentional. Without options,
# value updates silently and validation state goes stale — surprising
# users and bypassing resolver feedback.

if [ -n "$added_lines" ] && echo "$added_lines" | grep -qE '\.setValue\('; then
  # Multiline scan the file for setValue calls lacking shouldDirty/shouldValidate.
  # Grep for setValue(...) arguments — if the call closes on same line with
  # only 2 args (no options object), flag it.
  _bad=$(echo "$added_lines" | grep -E '\.setValue\(' | grep -vE 'shouldDirty|shouldValidate' || true)

  if [ -n "$_bad" ]; then
    # Filter out setValue calls that span multiple lines (no closing paren
    # on same line). Same-line closers without options object are the clear
    # violation — nested wrappers ({ ... }) after the call are fine.
    _real_bad=$(echo "$_bad" | grep -E '\.setValue\([^)]*\)' || true)

    if [ -n "$_real_bad" ]; then
      if ! hook_has_escape "setvalue-options"; then
        hook_warn "form.setValue() missing { shouldDirty: true, shouldValidate: true } — value updates silently, validation goes stale. Pass options unless the silence is intentional. Escape: // allow: setvalue-options [reason]" "setvalue-options"
      fi
    fi
  fi
fi

# ── React Hook Form v7.82+: delayError is opt-in for setValue ────
# A form-level delayError does not apply to programmatic validation unless
# setValue opts in. Keep this a narrow nudge: only inspect newly added calls.

_setvalue_timing=""
if [ -n "$added_lines" ] && echo "$added_lines" | grep -qE '\.setValue[[:space:]]*\('; then
  _setvalue_timing=$(
    echo "$added_lines" | awk '
      /\.setValue[[:space:]]*\(/ {
        in_call = 1
        validates = 0
        explicit_timing = 0
        numeric_timing = 0
      }
      in_call {
        if ($0 ~ /shouldValidate[[:space:]]*:[[:space:]]*true/) validates = 1
        if ($0 ~ /delayError[[:space:]]*:/ || $0 ~ /(^|[, {])delayError([, }]|$)/) explicit_timing = 1
        if ($0 ~ /delayError[[:space:]]*:[[:space:]]*[0-9]/) numeric_timing = 1
        if ($0 ~ /\)[[:space:]]*[;,}]?[[:space:]]*$/) {
          if (numeric_timing) numeric_found = 1
          else if (validates && !explicit_timing) implicit_found = 1
          in_call = 0
        }
      }
      END {
        if (numeric_found) print "numeric"
        else if (implicit_found) print "implicit"
      }
    '
  )
fi

if [ "$_setvalue_timing" = "numeric" ] && ! hook_has_escape "setvalue-delay-error-type"; then
  hook_nudge "setValue delayError is boolean in react-hook-form v7.82. Keep milliseconds on useForm({ delayError: 500 }) and pass delayError: true here; the release-note snippet's number does not match the shipped type. Escape: // allow: setvalue-delay-error-type [reason]" "setvalue-delay-error-type"
fi

if [ "$_setvalue_timing" = "implicit" ] && \
   echo "$file_content" | grep -qE 'useForm\s*[(<]' && \
   echo "$file_content" | grep -qE 'delayError\s*:'; then
  if ! hook_has_escape "setvalue-immediate-error"; then
    hook_nudge "useForm({ delayError }) does not delay setValue validation automatically. With react-hook-form v7.82+, add delayError: true for consistent delayed errors, or keep this immediate behavior intentionally. Escape: // allow: setvalue-immediate-error [reason]" "setvalue-delay-error"
  fi
fi

# ── absorbed from form-error-summary-check.sh (4.28 family consolidation) ──
# Enforce: a submittable form (useProtoForm + handleSubmit) must render
# a top-level error summary for screen readers and visual scanning.
# Accept any of:
#   - <FormErrorSummary ...>
#   - role="alert" on an element rendering form errors
#   - aria-live on a status region
# Without one, users hit submit, errors appear inline only, and AT /
# offscreen errors are invisible.

if echo "$file_content" | grep -qE 'useProtoForm\b|useForm\(' && \
   echo "$file_content" | grep -qE 'handleSubmit\('; then
  # Gate 2: summary primitive present?
  if ! echo "$file_content" | grep -qE 'FormErrorSummary|role="alert"|role={"alert"}|aria-live='; then
    # Skip tiny inline forms (single-field search, filter bars) — heuristic:
    # file must render more than one FormField / ProtoField to earn the nudge.
    _field_count=$(echo "$file_content" | grep -cE '<(FormField|ProtoField)\b' || true)
    if [ "${_field_count:-0}" -ge 2 ]; then
      if ! hook_has_escape "form-error-summary"; then
        hook_warn "Multi-field form with no <FormErrorSummary /> / role=\"alert\" / aria-live region. Submit-time errors stay inline-only — screen readers miss them and offscreen errors are invisible. Render a summary from form.formState.errors (or useProtoForm.getNestedErrors). Escape: // allow: form-error-summary [reason]" "form-error-summary"
      fi
    fi
  fi
fi

# ── absorbed from proto-form-parallel-state-check.sh (4.28 family consolidation) ──
# Enforce: a file that uses useProtoForm must not hold form-shape state
# in parallel useState hooks — that splits the source of truth, defeats
# protovalidate / resolver, and forces manual sync with custom
# validateXFields / surfaceXErrors workarounds.

if echo "$file_content" | grep -qE 'useProtoForm\b'; then
  # Heuristic: a useState whose type annotation or initial value carries
  # form-shape intent — Config, Auth, Credentials, Secret, Provider,
  # Settings, FieldValues, Params, Schema — is suspicious.
  _suspect_patterns='useState<\s*(Record<|Partial<|\w*Config|\w*Auth|\w*Credentials|\w*Secret|\w*Provider|\w*Settings|\w*Params|\w*FieldValues|\w*Schema|\w*Form)'

  if echo "$file_content" | grep -qE "$_suspect_patterns"; then
    if ! hook_has_escape "proto-form-parallel-state"; then
      hook_warn "useState holds form-shape state beside useProtoForm — drift risk. Register the field via form.register / nested FormField / useFieldArray so protovalidate + resolver own validation. Escape: // allow: proto-form-parallel-state [reason]" "proto-form-parallel-state"
    fi
  fi
fi

# ── absorbed from field-mask-check.sh (4.28 family consolidation) ──
# ── Check 1: Warn on hardcoded FieldMask paths arrays ────────────
# Static paths arrays in FieldMask can drift when proto schema changes.
# Suggest computing paths dynamically from dirty/changed fields.

if [ -n "$added_lines" ] && echo "$added_lines" | grep -qE 'FieldMaskSchema|FieldMask|fieldMask|field_mask|updateMask|update_mask'; then
  # Count hardcoded path strings in paths array — match both single/double quotes,
  # across multiple lines (paths: [\n  'x',\n  'y'\n])
  # Extract the paths array block (up to closing bracket) and count string literals
  path_block=$(echo "$file_content" | sed -n '/paths.*\[/,/\]/p' 2>/dev/null || true)
  path_count=$(echo "$path_block" | grep -oE "['\"][a-z_]+['\"]" 2>/dev/null | wc -l | tr -d '[:space:]')
  path_count=${path_count:-0}

  if [ "$path_count" -gt 2 ]; then
    if ! hook_has_escape "field-mask"; then
      hook_warn "FieldMask with ${path_count} hardcoded paths. Compute from dirty fields: Object.keys(form.formState.dirtyFields). Escape: // allow: field-mask [reason]"
    fi
  fi
fi

# ── Check: mark required, never "(optional)" ──────────────────────
# Convention: required fields carry a RequiredIndicator (asterisk);
# optional fields carry no annotation. "(optional)" labels invert the
# signal and drift out of sync with validation.

case "$file_path" in
  *.tsx)
    if echo "$added_lines" | grep -qiE '\(optional\)'; then
      if ! hook_has_escape "optional-label"; then
        hook_warn "\"(optional)\" in a form label — convention is the inverse: mark REQUIRED fields with RequiredIndicator (*), leave optional fields unannotated. Escape: // allow: optional-label [reason]" "optional-label"
      fi
    fi
    ;;
esac

return 0
}
