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

# ── Check 1: Ban <img> without alt ──────────────────────────────

tmpfile="$_a11y_tmpdir/test.tsx"
printf '<img src="photo.jpg" />\n' > "$tmpfile"

run_hook_eval "$SCRIPT" \
  "{\"tool_name\":\"Write\",\"tool_input\":{\"file_path\":\"$tmpfile\"}}" \
  2 "block: <img> without alt" "WCAG 1.1.1"

# tmpfile reused in tmpdir

# ── Check 1: Allow <img> with alt ──────────────────────────────

tmpfile="$_a11y_tmpdir/test.tsx"
printf '<img src="photo.jpg" alt="Team photo" />\n' > "$tmpfile"

run_hook_eval "$SCRIPT" \
  "{\"tool_name\":\"Write\",\"tool_input\":{\"file_path\":\"$tmpfile\"}}" \
  0 "allow: <img> with alt"

# tmpfile reused in tmpdir

# ── Check 1: Allow <img> with empty alt (decorative) ───────────

tmpfile="$_a11y_tmpdir/test.tsx"
printf '<img src="divider.png" alt="" />\n' > "$tmpfile"

run_hook_eval "$SCRIPT" \
  "{\"tool_name\":\"Write\",\"tool_input\":{\"file_path\":\"$tmpfile\"}}" \
  0 "allow: <img> with empty alt (decorative)"

# tmpfile reused in tmpdir

# ── Check 2: Ban clickable div without keyboard support ─────────

tmpfile="$_a11y_tmpdir/test.tsx"
printf '<div onClick={handleClick}>Click me</div>\n' > "$tmpfile"

run_hook_eval "$SCRIPT" \
  "{\"tool_name\":\"Write\",\"tool_input\":{\"file_path\":\"$tmpfile\"}}" \
  2 "block: <div onClick> without role/tabIndex/keyboard" "WCAG 2.1.1"

# tmpfile reused in tmpdir

# ── Check 2: Allow clickable div with full a11y support ─────────

tmpfile="$_a11y_tmpdir/test.tsx"
printf '<div role="button" tabIndex={0} onClick={handleClick} onKeyDown={handleKey}>Click me</div>\n' > "$tmpfile"

run_hook_eval "$SCRIPT" \
  "{\"tool_name\":\"Write\",\"tool_input\":{\"file_path\":\"$tmpfile\"}}" \
  0 "allow: <div onClick> with role + tabIndex + onKeyDown"

# tmpfile reused in tmpdir

# ── Check 2: Ban clickable span without keyboard support ────────

tmpfile="$_a11y_tmpdir/test.tsx"
printf '<span onClick={toggle}>Toggle</span>\n' > "$tmpfile"

run_hook_eval "$SCRIPT" \
  "{\"tool_name\":\"Write\",\"tool_input\":{\"file_path\":\"$tmpfile\"}}" \
  2 "block: <span onClick> without keyboard support"

# tmpfile reused in tmpdir

# ── Check 3: Ban role="combobox" without aria-expanded ──────────

tmpfile="$_a11y_tmpdir/test.tsx"
printf '<input role="combobox" aria-autocomplete="both" />\n' > "$tmpfile"

run_hook_eval "$SCRIPT" \
  "{\"tool_name\":\"Write\",\"tool_input\":{\"file_path\":\"$tmpfile\"}}" \
  2 "block: role=combobox without aria-expanded/aria-controls" "aria-expanded"

# tmpfile reused in tmpdir

# ── Check 3: Allow role="combobox" with required attrs ──────────

tmpfile="$_a11y_tmpdir/test.tsx"
printf '<input role="combobox" aria-expanded={isOpen} aria-controls="listbox-1" aria-autocomplete="both" />\n' > "$tmpfile"

run_hook_eval "$SCRIPT" \
  "{\"tool_name\":\"Write\",\"tool_input\":{\"file_path\":\"$tmpfile\"}}" \
  0 "allow: role=combobox with aria-expanded + aria-controls"

# tmpfile reused in tmpdir

# ── Check 4: Ban role="tablist" without role="tab" children ──────

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

# ── Check 5: Ban role="dialog" without aria-label ───────────────

tmpfile="$_a11y_tmpdir/test.tsx"
printf '<div role="dialog">Content</div>\n' > "$tmpfile"

run_hook_eval "$SCRIPT" \
  "{\"tool_name\":\"Write\",\"tool_input\":{\"file_path\":\"$tmpfile\"}}" \
  2 "block: role=dialog without aria-label" "aria-label"

# tmpfile reused in tmpdir

# ── Check 5: Allow role="dialog" with aria-labelledby ───────────

tmpfile="$_a11y_tmpdir/test.tsx"
printf '<div role="dialog" aria-labelledby="title-1">Content</div>\n' > "$tmpfile"

run_hook_eval "$SCRIPT" \
  "{\"tool_name\":\"Write\",\"tool_input\":{\"file_path\":\"$tmpfile\"}}" \
  0 "allow: role=dialog with aria-labelledby"

# tmpfile reused in tmpdir

# ── Index articulation accessibility checks ─────────────────────

tmpfile="$_a11y_tmpdir/articulate.tsx"
printf '<Button aria-label="Search icon"><SearchIcon /></Button>\n' > "$tmpfile"

run_hook_eval "$SCRIPT" \
  "{\"tool_name\":\"Write\",\"tool_input\":{\"file_path\":\"$tmpfile\"}}" \
  0 "warn: aria-label describes element type" "describe the action"

printf '<input placeholder="Email" />\n' > "$tmpfile"

run_hook_eval "$SCRIPT" \
  "{\"tool_name\":\"Write\",\"tool_input\":{\"file_path\":\"$tmpfile\"}}" \
  2 "block: placeholder-only input label" "Placeholder cannot replace a label"

printf '<label>Email</label><input placeholder="Email" />\n' > "$tmpfile"

run_hook_eval "$SCRIPT" \
  "{\"tool_name\":\"Write\",\"tool_input\":{\"file_path\":\"$tmpfile\"}}" \
  2 "block: placeholder input with unassociated label" "Placeholder cannot replace a label"

printf '<label>Email</label><input id="email" />\n' > "$tmpfile"

run_hook_eval "$SCRIPT" \
  "{\"tool_name\":\"Write\",\"tool_input\":{\"file_path\":\"$tmpfile\"}}" \
  0 "warn: label missing htmlFor" "label association"

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
printf '// allow-a11y-skip: third-party component\n<img src="x.png" />\n' > "$tmpfile"

run_hook_eval "$SCRIPT" \
  "{\"tool_name\":\"Write\",\"tool_input\":{\"file_path\":\"$tmpfile\"}}" \
  0 "allow: escape hatch with allow-a11y-skip comment"

# tmpfile reused in tmpdir

# ── Hook script content ──────────────────────────────────────────

run_content_eval "$SCRIPT" "aria-expanded" "hook checks for aria-expanded"
run_content_eval "$SCRIPT" "aria-controls" "hook checks for aria-controls"
run_content_eval "$SCRIPT" "tabIndex" "hook checks for tabIndex"
run_content_eval "$SCRIPT" "onKeyDown" "hook checks for keyboard handlers"
run_content_eval "$SCRIPT" "hook_block|hook_warn" "hook uses shared output functions"
run_content_eval "$SCRIPT" "hook_has_escape" "hook supports escape hatch"
run_content_eval "$SCRIPT" "WCAG" "hook references WCAG guidelines"
run_content_eval "$SCRIPT" "describe the action" "hook checks accessible-name action language"
run_content_eval "$SCRIPT" "Placeholder cannot replace a label" "hook checks placeholder-only controls"
run_content_eval "$SCRIPT" "label association" "hook checks label association"
run_content_eval "$SKILL_DIR/SKILL.md" "accessible names.*action" "SKILL.md documents action-based accessible names"
run_content_eval "$SKILL_DIR/SKILL.md" "placeholder.*label" "SKILL.md documents placeholders cannot replace labels"
run_content_eval "$SKILL_DIR/SKILL.md" "DOM order" "SKILL.md documents DOM order"
run_content_eval "$SKILL_DIR/SKILL.md" "color-only" "SKILL.md documents color-only state"
run_content_eval "$SKILL_DIR/SKILL.md" "reduced motion.*opacity" "SKILL.md documents reduced-motion-safe feedback"
run_content_eval "$SKILL_DIR/SKILL.md" "hover: hover.*pointer: fine" "SKILL.md documents touch-safe hover media query"
run_content_eval "$SKILL_DIR/SKILL.md" "visualViewport" "SKILL.md documents virtual keyboard visualViewport review"
run_content_eval "$SKILL_DIR/SKILL.md" "physical device|simulator" "SKILL.md asks for physical device or simulator evidence"

rm -rf "$_a11y_tmpdir"
