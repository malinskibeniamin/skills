# Evals for setup-accessibility skill
# Tests file structure, SKILL.md, REFERENCE.md, and hook script content

SCRIPT="$REPO_ROOT/accessibility/scripts/accessibility-check.sh"
SKILL_DIR="$REPO_ROOT/accessibility"

# ── File structure ──────────────────────────────────────────────

run_file_eval "$SKILL_DIR/SKILL.md" "SKILL.md exists"
run_file_eval "$SKILL_DIR/SETUP.md" "SETUP.md exists"
run_executable_eval "$SCRIPT" "accessibility-check.sh is executable"

# ── SKILL.md content ────────────────────────────────────────────

run_content_eval "$SKILL_DIR/SKILL.md" "^name: accessibility" "SKILL.md has correct name"
run_content_eval "$SKILL_DIR/SKILL.md" "^description:" "SKILL.md has description"
run_content_eval "$SKILL_DIR/SKILL.md" "Use when" "SKILL.md has trigger phrase"
run_content_eval "$SKILL_DIR/SKILL.md" "ARIA" "SKILL.md mentions ARIA"
run_content_eval "$SKILL_DIR/SKILL.md" "alt" "SKILL.md documents img alt rule"
run_content_eval "$SKILL_DIR/SKILL.md" "allow.*a11y-skip" "SKILL.md documents escape hatch"

# ── SETUP.md content (one-time setup, not auto-loaded) ──────────

run_content_eval "$SKILL_DIR/SETUP.md" "axe-core/playwright" "SETUP has Playwright AXE install"
run_content_eval "$SKILL_DIR/SETUP.md" "wcag2a.*wcag2aa" "SETUP has WCAG tag configuration"
run_content_eval "$SKILL_DIR/SETUP.md" "checkA11y" "SETUP has test helper function"

_a11y_tmpdir=$(mktemp -d /tmp/a11y-evals-XXXXXX)

# ── Hook: skip non-Edit/Write tools ────────────────────────────

run_hook_eval "$SCRIPT" \
  '{"tool_name":"Bash","tool_input":{"command":"echo hi"}}' \
  0 "skip: Bash tool"

run_hook_eval "$SCRIPT" \
  '{"tool_name":"Read","tool_input":{"file_path":"foo.tsx"}}' \
  0 "skip: Read tool"

# ── Hook: skip non-TSX/JSX files ───────────────────────────────

run_hook_eval "$SCRIPT" \
  '{"tool_name":"Edit","tool_input":{"file_path":"/tmp/test.ts"}}' \
  0 "skip: .ts file (hook only checks TSX/JSX)"

run_hook_eval "$SCRIPT" \
  '{"tool_name":"Edit","tool_input":{"file_path":"/tmp/test.css"}}' \
  0 "skip: .css file"

run_hook_eval "$SCRIPT" \
  '{"tool_name":"Edit","tool_input":{"file_path":"/tmp/test.py"}}' \
  0 "skip: .py file"

# ── Hook: skip nonexistent file ─────────────────────────────────

run_hook_eval "$SCRIPT" \
  '{"tool_name":"Write","tool_input":{"file_path":"/tmp/nonexistent-a11y-abc123.tsx"}}' \
  0 "skip: nonexistent file"

# ── Hook: skip empty file_path ──────────────────────────────────

run_hook_eval "$SCRIPT" \
  '{"tool_name":"Edit","tool_input":{"file_path":""}}' \
  0 "skip: empty file_path"

# ── Biome-delegated rules must NOT fire from the hook ────────────
# img alt, clickable div/span, combobox ARIA, label association are
# owned by Biome (ultracite preset); the hook stays silent on them.

tmpfile="$_a11y_tmpdir/test.tsx"
printf '<img src="photo.jpg" />\n' > "$tmpfile"

run_hook_eval "$SCRIPT" \
  "{\"tool_name\":\"Write\",\"tool_input\":{\"file_path\":\"$tmpfile\"}}" \
  0 "delegated to Biome: <img> without alt (a11y/useAltText)"

printf '<div onClick={handleClick}>Click me</div>\n' > "$tmpfile"

run_hook_eval "$SCRIPT" \
  "{\"tool_name\":\"Write\",\"tool_input\":{\"file_path\":\"$tmpfile\"}}" \
  0 "delegated to Biome: clickable <div> (a11y/useKeyWithClickEvents)"

printf '<input role="combobox" aria-autocomplete="both" />\n' > "$tmpfile"

run_hook_eval "$SCRIPT" \
  "{\"tool_name\":\"Write\",\"tool_input\":{\"file_path\":\"$tmpfile\"}}" \
  0 "delegated to Biome: combobox ARIA (a11y/useAriaPropsForRole)"

# ── Check: Ban role="tablist" without role="tab" children ────────

tmpfile="$_a11y_tmpdir/test.tsx"
printf '<div role="tablist"><button>Tab 1</button></div>\n' > "$tmpfile"

run_hook_eval "$SCRIPT" \
  "{\"tool_name\":\"Write\",\"tool_input\":{\"file_path\":\"$tmpfile\"}}" \
  2 "block: role=tablist without role=tab children" "role"

# Allow role="tablist" with role="tab" children
printf '<div role="tablist"><button role="tab">Tab 1</button></div>\n<div role="tabpanel">Content</div>\n' > "$tmpfile"

run_hook_eval "$SCRIPT" \
  "{\"tool_name\":\"Write\",\"tool_input\":{\"file_path\":\"$tmpfile\"}}" \
  0 "allow: role=tablist with role=tab children"

# ── React Doctor-delegated rules must NOT fire from the hook ─────
# dialog accessible name, redundant name wording, placeholder-as-label, and
# invalid-control descriptions
# are owned by React Doctor's a11y category (Stop hook).

tmpfile="$_a11y_tmpdir/test.tsx"
printf '<div role="dialog">Content</div>\n' > "$tmpfile"

run_hook_eval "$SCRIPT" \
  "{\"tool_name\":\"Write\",\"tool_input\":{\"file_path\":\"$tmpfile\"}}" \
  0 "delegated to React Doctor: dialog accessible name (a11y/dialog-has-accessible-name)"

printf '<input aria-invalid={true} />\n' > "$tmpfile"

run_hook_eval "$SCRIPT" \
  "{\"tool_name\":\"Write\",\"tool_input\":{\"file_path\":\"$tmpfile\"}}" \
  0 "delegated to React Doctor: invalid control description (no-aria-invalid-without-description)"

tmpfile="$_a11y_tmpdir/articulate.tsx"
printf '<Button aria-label="Search icon"><SearchIcon /></Button>\n' > "$tmpfile"

run_hook_eval "$SCRIPT" \
  "{\"tool_name\":\"Write\",\"tool_input\":{\"file_path\":\"$tmpfile\"}}" \
  0 "delegated to React Doctor: redundant name wording (a11y/img-redundant-alt)"

printf '<input placeholder="Email" />\n' > "$tmpfile"

run_hook_eval "$SCRIPT" \
  "{\"tool_name\":\"Write\",\"tool_input\":{\"file_path\":\"$tmpfile\"}}" \
  0 "delegated to React Doctor: placeholder-as-label (a11y/label-has-associated-control)"

printf '<label>Email</label><input id="email" />\n' > "$tmpfile"

run_hook_eval "$SCRIPT" \
  "{\"tool_name\":\"Write\",\"tool_input\":{\"file_path\":\"$tmpfile\"}}" \
  0 "delegated to Biome: label association (a11y/noLabelWithoutControl)"

printf '<label htmlFor="email">Email</label><input id="email" placeholder="name@example.com" />\n' > "$tmpfile"

run_hook_eval "$SCRIPT" \
  "{\"tool_name\":\"Write\",\"tool_input\":{\"file_path\":\"$tmpfile\"}}" \
  0 "allow: labelled input with helper placeholder"

printf '<label htmlFor={emailId}>Email</label><input id={emailId} placeholder="name@example.com" />\n' > "$tmpfile"

run_hook_eval "$SCRIPT" \
  "{\"tool_name\":\"Write\",\"tool_input\":{\"file_path\":\"$tmpfile\"}}" \
  0 "allow: dynamically labelled input with helper placeholder"

# ── Escape hatch: allow-a11y-skip ──────────────────────────────

tmpfile="$_a11y_tmpdir/test.tsx"
printf '// allow-a11y-skip: third-party component\n<div role="tablist"><button>Tab</button></div>\n' > "$tmpfile"

run_hook_eval "$SCRIPT" \
  "{\"tool_name\":\"Write\",\"tool_input\":{\"file_path\":\"$tmpfile\"}}" \
  0 "allow: escape hatch with allow-a11y-skip comment"

# tmpfile reused in tmpdir

# ── Hook script content ──────────────────────────────────────────

run_content_eval "$SCRIPT" "useAltText" "hook documents Biome delegation for img alt"
run_content_eval "$SCRIPT" "useKeyWithClickEvents" "hook documents Biome delegation for click events"
run_content_eval "$SCRIPT" "useAriaPropsForRole" "hook documents Biome delegation for role ARIA props"
run_content_eval "$SCRIPT" "noLabelWithoutControl" "hook documents Biome delegation for label association"
run_content_eval "$SCRIPT" "hook_block|hook_warn" "hook uses shared output functions"
run_content_eval "$SCRIPT" "hook_has_escape" "hook supports escape hatch"
run_content_eval "$SCRIPT" "WCAG" "hook references WCAG guidelines"
run_content_eval "$SCRIPT" "dialog-has-accessible-name" "hook documents React Doctor delegation for dialog names"
run_content_eval "$SCRIPT" "label-has-associated-control" "hook documents React Doctor delegation for placeholder-as-label"
run_content_eval "$SCRIPT" "no-aria-invalid-without-description" "hook documents React Doctor delegation for invalid-control descriptions"
if grep -qF "aria-invalid without aria-describedby" "$SCRIPT"; then
  echo "  FAIL  accessibility hook still duplicates React Doctor invalid-control diagnostics"
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: accessibility hook still duplicates React Doctor invalid-control diagnostics"
else
  echo "  PASS  accessibility hook no longer duplicates React Doctor invalid-control diagnostics"
  PASS=$((PASS + 1))
fi
run_content_eval "$SKILL_DIR/SKILL.md" "React Doctor" "SKILL.md routes structural rules to React Doctor"
run_content_eval "$SKILL_DIR/SKILL.md" "aria-invalid" "SKILL.md documents error-state pairing rules"
run_content_eval "$SKILL_DIR/SKILL.md" "DOM order" "SKILL.md documents DOM order"
run_content_eval "$SKILL_DIR/SKILL.md" "color-only" "SKILL.md documents color-only state"
run_content_eval "$SKILL_DIR/SKILL.md" "reduced motion.*opacity" "SKILL.md documents reduced-motion-safe feedback"
run_content_eval "$SKILL_DIR/SKILL.md" "hover: hover.*pointer: fine" "SKILL.md documents touch-safe hover media query"
run_content_eval "$SKILL_DIR/SKILL.md" "visualViewport" "SKILL.md documents virtual keyboard visualViewport review"
run_content_eval "$SKILL_DIR/SKILL.md" "physical device|simulator" "SKILL.md asks for physical device or simulator evidence"

rm -rf "$_a11y_tmpdir"
