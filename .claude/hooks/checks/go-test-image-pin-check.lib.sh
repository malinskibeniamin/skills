#!/bin/bash
# Extracted check logic for go-test-image-pin-check.sh. Source ../_hook-lib.sh before this file.
# Floating test-service images make failures non-reproducible and can test
# unreleased behavior against incompatible clients.

run_go_test_image_pin_check() {
case "$file_path" in
  *_test.go) ;;
  */e2e/*.go|*/e2e/*.yml|*/e2e/*.yaml) ;;
  */integrationtest/*.go|*/integrationtest/*.yml|*/integrationtest/*.yaml) ;;
  */testdata/*.yml|*/testdata/*.yaml) ;;
  *) return 0 ;;
esac
hook_skip_generated || return 0
hook_has_escape "floating-image" && return 0
hook_get_added_lines || return 0
[ -n "$added_lines" ] || return 0

local hits
# registry/repo:floating-tag anywhere, or a bare repo:floating-tag on an image-shaped line
hits=$(printf '%s\n' "$added_lines" \
  | grep -E '"[a-z0-9]([a-z0-9._-]*[a-z0-9])?(/[a-z0-9._-]+)+:(latest|main|master)"|[Ii]mage[^"]*["'\'': ][a-z0-9._-]+:(latest|main|master)(["'\''[:space:]]|$)' \
  | grep -oE '[a-z0-9._/-]+:(latest|main|master)(["'\''[:space:]]|$)?' | sed 's/[^a-z0-9]$//' | sort -u | head -3 || true)
[ -n "$hits" ] || return 0

hook_warn "Test image floats ($(printf '%s' "$hits" | tr '\n' ' ' | sed 's/ $//')): pin a supported release tag; floating main/master/latest makes failures non-reproducible. Escape: // allow: floating-image [reason]. See /golang." "go-test-image-pin"
}
