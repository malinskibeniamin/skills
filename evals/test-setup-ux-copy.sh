# Evals for setup-ux-copy skill

SCRIPT="$REPO_ROOT/ux-copy/scripts/ux-copy-check.sh"
SKILL_DIR="$REPO_ROOT/ux-copy"

# ── File structure ──────────────────────────────────────────────

run_file_eval "$SKILL_DIR/SKILL.md" "SKILL.md exists"
run_file_eval "$SKILL_DIR/REFERENCE.md" "REFERENCE.md exists"
run_file_eval "$SKILL_DIR/GLOSSARY.md" "GLOSSARY.md exists"
run_executable_eval "$SCRIPT" "ux-copy-check.sh is executable"

# ── SKILL.md content ────────────────────────────────────────────

run_content_eval "$SKILL_DIR/SKILL.md" "^name: ux-copy" "SKILL.md has correct name"
run_content_eval "$SKILL_DIR/SKILL.md" "Use when" "SKILL.md has trigger phrase"
run_content_eval "$SKILL_DIR/SKILL.md" "allow.*ux-copy" "SKILL.md documents escape hatch"
run_content_eval "$SKILL_DIR/SKILL.md" "capitalization" "SKILL.md mentions capitalization rules"
run_content_eval "$SKILL_DIR/SKILL.md" "canonical product names" "SKILL.md keeps product terminology generic"

if grep -qi "redpanda" "$SKILL_DIR/SKILL.md"; then
  echo "  FAIL  SKILL.md is product-neutral"
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: SKILL.md is product-neutral"
else
  echo "  PASS  SKILL.md is product-neutral"
  PASS=$((PASS + 1))
fi

_ux_description=$(awk '/^description:/{print; exit}' "$SKILL_DIR/SKILL.md")
if echo "$_ux_description" | grep -qiE 'documentation|docs|RFC'; then
  echo "  FAIL  SKILL.md keeps documentation prose out of UX-copy scope"
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: SKILL.md keeps documentation prose out of UX-copy scope"
else
  echo "  PASS  SKILL.md keeps documentation prose out of UX-copy scope"
  PASS=$((PASS + 1))
fi

# ── Hook: skip non-Edit/Write ───────────────────────────────────

run_hook_eval "$SCRIPT" \
  '{"tool_name":"Bash","tool_input":{"command":"echo"}}' \
  0 "skip: Bash tool"

run_hook_eval "$SCRIPT" \
  '{"tool_name":"Read","tool_input":{"file_path":"foo.tsx"}}' \
  0 "skip: Read tool"

# ── Hook: skip non-TS/TSX files ─────────────────────────────────

run_hook_eval "$SCRIPT" \
  '{"tool_name":"Edit","tool_input":{"file_path":"/tmp/test.json"}}' \
  0 "skip: .json file"

run_hook_eval "$SCRIPT" \
  '{"tool_name":"Edit","tool_input":{"file_path":"/tmp/test.css"}}' \
  0 "skip: .css file"

run_hook_eval "$SCRIPT" \
  '{"tool_name":"Edit","tool_input":{"file_path":"/tmp/test.py"}}' \
  0 "skip: .py file"

# ── Hook: skip generated files ──────────────────────────────────

_ux_gen_dir=$(mktemp -d /tmp/ux-gen-XXXXXX)
printf '// @generated\nconst msg = "Created successfully!"\n' > "$_ux_gen_dir/generated.ts"

run_hook_eval "$SCRIPT" \
  "{\"tool_name\":\"Write\",\"tool_input\":{\"file_path\":\"$_ux_gen_dir/generated.ts\"}}" \
  0 "skip: auto-generated file"

rm -rf "$_ux_gen_dir"

# Create temp dir for all file-based tests
_ux_tmpdir=$(mktemp -d /tmp/ux-copy-evals-XXXXXX)

# ── Check 1: Exclamation points ─────────────────────────────────

tmpfile="$_ux_tmpdir/test.ts"
echo 'const msg = "Something went wrong!"' > "$tmpfile"

run_hook_eval "$SCRIPT" \
  "{\"tool_name\":\"Write\",\"tool_input\":{\"file_path\":\"$tmpfile\"}}" \
  0 "warn: exclamation at end of string" "No !"

# Allow: no exclamation
echo 'const msg = "Something went wrong"' > "$tmpfile"

run_hook_eval "$SCRIPT" \
  "{\"tool_name\":\"Write\",\"tool_input\":{\"file_path\":\"$tmpfile\"}}" \
  0 "allow: string without exclamation"

# Allow: !== operator (not UI text)
echo 'if (value !== null) { return }' > "$tmpfile"

run_hook_eval "$SCRIPT" \
  "{\"tool_name\":\"Write\",\"tool_input\":{\"file_path\":\"$tmpfile\"}}" \
  0 "allow: !== operator"

# Allow: exclamation in middle of string (not end — likely code/template)
echo 'const tpl = "Use !important only when needed"' > "$tmpfile"

run_hook_eval "$SCRIPT" \
  "{\"tool_name\":\"Write\",\"tool_input\":{\"file_path\":\"$tmpfile\"}}" \
  0 "allow: exclamation in middle of string (not end)"

# ── Check 2: "successfully" ─────────────────────────────────────

tmpfile="$_ux_tmpdir/toast.ts"
echo "const msg = 'Topic successfully created'" > "$tmpfile"

run_hook_eval "$SCRIPT" \
  "{\"tool_name\":\"Write\",\"tool_input\":{\"file_path\":\"$tmpfile\"}}" \
  0 "warn: successfully in string" "successfully"

# Allow: past tense without "successfully"
echo "const msg = 'Topic created'" > "$tmpfile"

run_hook_eval "$SCRIPT" \
  "{\"tool_name\":\"Write\",\"tool_input\":{\"file_path\":\"$tmpfile\"}}" \
  0 "allow: past tense without successfully"

echo "const msg = 'Topic has been created'" > "$tmpfile"

run_hook_eval "$SCRIPT" \
  "{\"tool_name\":\"Write\",\"tool_input\":{\"file_path\":\"$tmpfile\"}}" \
  0 "warn: verbose completion toast" "past tense"

# ── Check 3: "click here" ───────────────────────────────────────

tmpfile="$_ux_tmpdir/test.tsx"
echo '<Link>click here</Link>' > "$tmpfile"

run_hook_eval "$SCRIPT" \
  "{\"tool_name\":\"Write\",\"tool_input\":{\"file_path\":\"$tmpfile\"}}" \
  0 "warn: click here link text" "click here"

echo '<a>here</a>' > "$tmpfile"

run_hook_eval "$SCRIPT" \
  "{\"tool_name\":\"Write\",\"tool_input\":{\"file_path\":\"$tmpfile\"}}" \
  0 "warn: bare here link text"

# Allow: descriptive link text
echo '<Link>View documentation</Link>' > "$tmpfile"

run_hook_eval "$SCRIPT" \
  "{\"tool_name\":\"Write\",\"tool_input\":{\"file_path\":\"$tmpfile\"}}" \
  0 "allow: descriptive link text"

# ── Check 4: Blame language ─────────────────────────────────────

tmpfile="$_ux_tmpdir/error.ts"
echo "const msg = \"Oops, something went wrong\"" > "$tmpfile"

run_hook_eval "$SCRIPT" \
  "{\"tool_name\":\"Write\",\"tool_input\":{\"file_path\":\"$tmpfile\"}}" \
  0 "warn: Oops in string" "casual"

echo "const msg = 'Uh oh, an error occurred'" > "$tmpfile"

run_hook_eval "$SCRIPT" \
  "{\"tool_name\":\"Write\",\"tool_input\":{\"file_path\":\"$tmpfile\"}}" \
  0 "warn: Uh oh in string"

# Allow: neutral error message
echo "const msg = 'Could not save changes'" > "$tmpfile"

run_hook_eval "$SCRIPT" \
  "{\"tool_name\":\"Write\",\"tool_input\":{\"file_path\":\"$tmpfile\"}}" \
  0 "allow: neutral error message"

# ── Check 5: Possessive pronouns ────────────────────────────────

tmpfile="$_ux_tmpdir/nav.ts"
echo "const title = 'My Settings'" > "$tmpfile"

run_hook_eval "$SCRIPT" \
  "{\"tool_name\":\"Write\",\"tool_input\":{\"file_path\":\"$tmpfile\"}}" \
  0 "warn: My in title" "possessive"

echo "const title = 'Your Clusters'" > "$tmpfile"

run_hook_eval "$SCRIPT" \
  "{\"tool_name\":\"Write\",\"tool_input\":{\"file_path\":\"$tmpfile\"}}" \
  0 "warn: Your in title" "possessive"

# Allow: just "Settings"
echo "const title = 'Settings'" > "$tmpfile"

run_hook_eval "$SCRIPT" \
  "{\"tool_name\":\"Write\",\"tool_input\":{\"file_path\":\"$tmpfile\"}}" \
  0 "allow: title without possessive pronoun"

# ── Check 6: Yes/No button labels ───────────────────────────────

tmpfile="$_ux_tmpdir/dialog.tsx"
echo '<Button onClick={handleConfirm}>Yes</Button>' > "$tmpfile"

run_hook_eval "$SCRIPT" \
  "{\"tool_name\":\"Write\",\"tool_input\":{\"file_path\":\"$tmpfile\"}}" \
  0 "warn: Yes button label" "Yes"

echo '<Button onClick={handleCancel}>No</Button>' > "$tmpfile"

run_hook_eval "$SCRIPT" \
  "{\"tool_name\":\"Write\",\"tool_input\":{\"file_path\":\"$tmpfile\"}}" \
  0 "warn: No button label" "No"

# Allow: action verb button
echo '<Button onClick={handleDelete}>Delete cluster</Button>' > "$tmpfile"

run_hook_eval "$SCRIPT" \
  "{\"tool_name\":\"Write\",\"tool_input\":{\"file_path\":\"$tmpfile\"}}" \
  0 "allow: action verb button label"

# ── Check 7: Formatting in strings ──────────────────────────────

tmpfile="$_ux_tmpdir/text.ts"
echo "const msg = 'Use **bold** text here'" > "$tmpfile"

run_hook_eval "$SCRIPT" \
  "{\"tool_name\":\"Write\",\"tool_input\":{\"file_path\":\"$tmpfile\"}}" \
  0 "warn: bold formatting in string" "bold"

# Allow: plain text
echo "const msg = 'Use plain text here'" > "$tmpfile"

run_hook_eval "$SCRIPT" \
  "{\"tool_name\":\"Write\",\"tool_input\":{\"file_path\":\"$tmpfile\"}}" \
  0 "allow: plain text string"

# ── Check 8: ALL CAPS ───────────────────────────────────────────

tmpfile="$_ux_tmpdir/emphasis.ts"
echo "const msg = 'THIS WILL DELETE YOUR DATA'" > "$tmpfile"

run_hook_eval "$SCRIPT" \
  "{\"tool_name\":\"Write\",\"tool_input\":{\"file_path\":\"$tmpfile\"}}" \
  0 "warn: ALL CAPS for emphasis" "CAPS"

# Allow: known acronyms
echo "const msg = 'Check TLS settings'" > "$tmpfile"

run_hook_eval "$SCRIPT" \
  "{\"tool_name\":\"Write\",\"tool_input\":{\"file_path\":\"$tmpfile\"}}" \
  0 "allow: TLS acronym (not all-caps emphasis)"

# ── Check 9: Redpanda terms (REDPANDA_KIT=1) ────────────────────

tmpfile="$_ux_tmpdir/rp.ts"
echo "const label = 'the admin api settings'" > "$tmpfile"

REDPANDA_KIT=1 run_hook_eval "$SCRIPT" \
  "{\"tool_name\":\"Write\",\"tool_input\":{\"file_path\":\"$tmpfile\"}}" \
  0 "warn: lowercase Redpanda product name (with REDPANDA_KIT)" "Capitalize"

# Allow: correctly capitalized
echo "const label = 'Admin API settings'" > "$tmpfile"

REDPANDA_KIT=1 run_hook_eval "$SCRIPT" \
  "{\"tool_name\":\"Write\",\"tool_input\":{\"file_path\":\"$tmpfile\"}}" \
  0 "allow: correctly capitalized Redpanda term"

# Allow: no REDPANDA_KIT → skip Redpanda checks
echo "const label = 'the admin api'" > "$tmpfile"

run_hook_eval "$SCRIPT" \
  "{\"tool_name\":\"Write\",\"tool_input\":{\"file_path\":\"$tmpfile\"}}" \
  0 "allow: Redpanda checks skipped without REDPANDA_KIT"

# ── Check 10: Title Case ────────────────────────────────────────

tmpfile="$_ux_tmpdir/heading.ts"
echo "const title = 'Create New Topic'" > "$tmpfile"

run_hook_eval "$SCRIPT" \
  "{\"tool_name\":\"Write\",\"tool_input\":{\"file_path\":\"$tmpfile\"}}" \
  0 "warn: Title Case detected" "Title Case"

# Allow: sentence case
echo "const title = 'Create new topic'" > "$tmpfile"

run_hook_eval "$SCRIPT" \
  "{\"tool_name\":\"Write\",\"tool_input\":{\"file_path\":\"$tmpfile\"}}" \
  0 "allow: sentence case"

# ── Check 11: Spelled-out numbers ────────────────────────────────

tmpfile="$_ux_tmpdir/count.ts"
echo "const msg = 'Select one option'" > "$tmpfile"

run_hook_eval "$SCRIPT" \
  "{\"tool_name\":\"Write\",\"tool_input\":{\"file_path\":\"$tmpfile\"}}" \
  0 "warn: spelled-out number" "numeral"

# Allow: numeral
echo "const msg = 'Select 1 option'" > "$tmpfile"

run_hook_eval "$SCRIPT" \
  "{\"tool_name\":\"Write\",\"tool_input\":{\"file_path\":\"$tmpfile\"}}" \
  0 "allow: numeral instead of spelled-out"

# Allow: excluded phrase "one of"
echo "const msg = 'one of the following options'" > "$tmpfile"

run_hook_eval "$SCRIPT" \
  "{\"tool_name\":\"Write\",\"tool_input\":{\"file_path\":\"$tmpfile\"}}" \
  0 "allow: one of (excluded phrase)"

# ── Check 12: "and/or" ───────────────────────────────────────────

tmpfile="$_ux_tmpdir/logic.ts"
echo "const msg = 'Enable and/or disable the feature'" > "$tmpfile"

run_hook_eval "$SCRIPT" \
  "{\"tool_name\":\"Write\",\"tool_input\":{\"file_path\":\"$tmpfile\"}}" \
  0 "warn: and/or in string" "and/or"

echo "const msg = 'Enable or disable the feature'" > "$tmpfile"

run_hook_eval "$SCRIPT" \
  "{\"tool_name\":\"Write\",\"tool_input\":{\"file_path\":\"$tmpfile\"}}" \
  0 "allow: or without and/or"

# ── Check 13: "etc." ────────────────────────────────────────────

tmpfile="$_ux_tmpdir/list.ts"
echo "const msg = 'Topics, schemas, etc.'" > "$tmpfile"

run_hook_eval "$SCRIPT" \
  "{\"tool_name\":\"Write\",\"tool_input\":{\"file_path\":\"$tmpfile\"}}" \
  0 "warn: etc. in string" "etc."

echo "const msg = 'Topics, schemas, and connectors'" > "$tmpfile"

run_hook_eval "$SCRIPT" \
  "{\"tool_name\":\"Write\",\"tool_input\":{\"file_path\":\"$tmpfile\"}}" \
  0 "allow: specific list without etc."

# ── Check 14: "e.g." / "i.e." ───────────────────────────────────

tmpfile="$_ux_tmpdir/latin.ts"
echo "const msg = 'Use a valid format, e.g. JSON'" > "$tmpfile"

run_hook_eval "$SCRIPT" \
  "{\"tool_name\":\"Write\",\"tool_input\":{\"file_path\":\"$tmpfile\"}}" \
  0 "warn: e.g. in string" "Latin"

echo "const msg = 'Use a valid format, i.e. JSON'" > "$tmpfile"

run_hook_eval "$SCRIPT" \
  "{\"tool_name\":\"Write\",\"tool_input\":{\"file_path\":\"$tmpfile\"}}" \
  0 "warn: i.e. in string" "Latin"

echo "const msg = 'Use a valid format, for example JSON'" > "$tmpfile"

run_hook_eval "$SCRIPT" \
  "{\"tool_name\":\"Write\",\"tool_input\":{\"file_path\":\"$tmpfile\"}}" \
  0 "allow: for example (plain English)"

# ── Check 15: "please" ──────────────────────────────────────────

tmpfile="$_ux_tmpdir/polite.ts"
echo "const msg = 'Please enter your email'" > "$tmpfile"

run_hook_eval "$SCRIPT" \
  "{\"tool_name\":\"Write\",\"tool_input\":{\"file_path\":\"$tmpfile\"}}" \
  0 "warn: Please imperative pattern" "Please"

# Allow: direct language
echo "const msg = 'Enter your email'" > "$tmpfile"

run_hook_eval "$SCRIPT" \
  "{\"tool_name\":\"Write\",\"tool_input\":{\"file_path\":\"$tmpfile\"}}" \
  0 "allow: direct language without Please"

# Allow: "please" mid-sentence (acceptable in error acknowledgments)
echo "const msg = 'If the problem persists, please contact support'" > "$tmpfile"

run_hook_eval "$SCRIPT" \
  "{\"tool_name\":\"Write\",\"tool_input\":{\"file_path\":\"$tmpfile\"}}" \
  0 "allow: please mid-sentence (not imperative)"

echo "const msg = 'Sorry for the interruption'" > "$tmpfile"

run_hook_eval "$SCRIPT" \
  "{\"tool_name\":\"Write\",\"tool_input\":{\"file_path\":\"$tmpfile\"}}" \
  0 "warn: sorry is reserved for real inconvenience" "sparingly"

echo "const msg = 'Thank you for submitting'" > "$tmpfile"

run_hook_eval "$SCRIPT" \
  "{\"tool_name\":\"Write\",\"tool_input\":{\"file_path\":\"$tmpfile\"}}" \
  0 "warn: thank you is reserved for real inconvenience" "sparingly"

tmpfile="$_ux_tmpdir/locale.ts"
echo "const msg = 'Update the organisation colour'" > "$tmpfile"

run_hook_eval "$SCRIPT" \
  "{\"tool_name\":\"Write\",\"tool_input\":{\"file_path\":\"$tmpfile\"}}" \
  0 "warn: common British spelling" "American English"

tmpfile="$_ux_tmpdir/placeholder.tsx"
echo '<Input placeholder="Example: cluster-name" />' > "$tmpfile"

run_hook_eval "$SCRIPT" \
  "{\"tool_name\":\"Write\",\"tool_input\":{\"file_path\":\"$tmpfile\"}}" \
  0 "warn: Example prefix in input placeholder" "placeholder"

tmpfile="$_ux_tmpdir/learn-more.tsx"
echo '<Link href="/docs">Learn more.</Link>' > "$tmpfile"

run_hook_eval "$SCRIPT" \
  "{\"tool_name\":\"Write\",\"tool_input\":{\"file_path\":\"$tmpfile\"}}" \
  0 "warn: Learn more trailing punctuation" "punctuation"

# ── Check 16: Non-inclusive terminology ──────────────────────────

tmpfile="$_ux_tmpdir/terms.ts"
echo "const list = whitelist" > "$tmpfile"

run_hook_eval "$SCRIPT" \
  "{\"tool_name\":\"Write\",\"tool_input\":{\"file_path\":\"$tmpfile\"}}" \
  0 "warn: whitelist (non-inclusive)" "Inclusive"

echo "const list = blacklist" > "$tmpfile"

run_hook_eval "$SCRIPT" \
  "{\"tool_name\":\"Write\",\"tool_input\":{\"file_path\":\"$tmpfile\"}}" \
  0 "warn: blacklist (non-inclusive)" "Inclusive"

echo "const role = master" > "$tmpfile"

run_hook_eval "$SCRIPT" \
  "{\"tool_name\":\"Write\",\"tool_input\":{\"file_path\":\"$tmpfile\"}}" \
  0 "warn: master (non-inclusive)" "Inclusive"

echo "const list = allowlist" > "$tmpfile"

run_hook_eval "$SCRIPT" \
  "{\"tool_name\":\"Write\",\"tool_input\":{\"file_path\":\"$tmpfile\"}}" \
  0 "allow: allowlist (inclusive term)"

echo "const role = leader" > "$tmpfile"

run_hook_eval "$SCRIPT" \
  "{\"tool_name\":\"Write\",\"tool_input\":{\"file_path\":\"$tmpfile\"}}" \
  0 "allow: leader (inclusive term)"

# ── Check 17: "There is" / "There are" ──────────────────────────

tmpfile="$_ux_tmpdir/there.ts"
echo "const msg = 'There are 3 configuration options'" > "$tmpfile"

run_hook_eval "$SCRIPT" \
  "{\"tool_name\":\"Write\",\"tool_input\":{\"file_path\":\"$tmpfile\"}}" \
  0 "warn: There are starter" "Subject first"

echo "const msg = 'There is no data available'" > "$tmpfile"

run_hook_eval "$SCRIPT" \
  "{\"tool_name\":\"Write\",\"tool_input\":{\"file_path\":\"$tmpfile\"}}" \
  0 "warn: There is starter" "Subject first"

echo "const msg = '3 configuration options are available'" > "$tmpfile"

run_hook_eval "$SCRIPT" \
  "{\"tool_name\":\"Write\",\"tool_input\":{\"file_path\":\"$tmpfile\"}}" \
  0 "allow: subject-first sentence"

# ── Check 18: "via" ─────────────────────────────────────────────

tmpfile="$_ux_tmpdir/via.ts"
echo "const msg = 'Connect via VPC peering'" > "$tmpfile"

run_hook_eval "$SCRIPT" \
  "{\"tool_name\":\"Write\",\"tool_input\":{\"file_path\":\"$tmpfile\"}}" \
  0 "warn: via in string" "via"

echo "const msg = 'Connect through VPC peering'" > "$tmpfile"

run_hook_eval "$SCRIPT" \
  "{\"tool_name\":\"Write\",\"tool_input\":{\"file_path\":\"$tmpfile\"}}" \
  0 "allow: through instead of via"

# ── Check 21: Impeccable copy slop ───────────────────────────────

tmpfile="$_ux_tmpdir/slop.ts"
echo "const msg = 'Deploy faster — without extra steps'" > "$tmpfile"

run_hook_eval "$SCRIPT" \
  "{\"tool_name\":\"Write\",\"tool_input\":{\"file_path\":\"$tmpfile\"}}" \
  0 "warn: em dash in UI string" "em dash"

echo "const msg = 'Supercharge your seamless workflow'" > "$tmpfile"

run_hook_eval "$SCRIPT" \
  "{\"tool_name\":\"Write\",\"tool_input\":{\"file_path\":\"$tmpfile\"}}" \
  0 "warn: marketing buzzwords in UI string" "buzzword"

echo "const msg = 'Not just monitoring, it is observability'" > "$tmpfile"

run_hook_eval "$SCRIPT" \
  "{\"tool_name\":\"Write\",\"tool_input\":{\"file_path\":\"$tmpfile\"}}" \
  0 "warn: not-just copy cadence" "not just"

echo "const msg = 'Productivity theater stops here'" > "$tmpfile"

run_hook_eval "$SCRIPT" \
  "{\"tool_name\":\"Write\",\"tool_input\":{\"file_path\":\"$tmpfile\"}}" \
  0 "warn: X theater copy" "theater"

echo "const msg = 'Build faster. No busywork. Just results.'" > "$tmpfile"

run_hook_eval "$SCRIPT" \
  "{\"tool_name\":\"Write\",\"tool_input\":{\"file_path\":\"$tmpfile\"}}" \
  0 "warn: aphoristic cadence copy" "cadence"

echo "const msg = 'Deploy faster without extra steps'" > "$tmpfile"

run_hook_eval "$SCRIPT" \
  "{\"tool_name\":\"Write\",\"tool_input\":{\"file_path\":\"$tmpfile\"}}" \
  0 "allow: direct non-slop copy"

# ── Check 28: Articulate copywriting rules ───────────────────────

tmpfile="$_ux_tmpdir/articulate-copy.tsx"
echo '<Button onClick={handleSubmit}>Submit</Button>' > "$tmpfile"

run_hook_eval "$SCRIPT" \
  "{\"tool_name\":\"Write\",\"tool_input\":{\"file_path\":\"$tmpfile\"}}" \
  0 "warn: generic CTA button label" "generic CTA"

echo "const msg = 'Invalid input'" > "$tmpfile"

run_hook_eval "$SCRIPT" \
  "{\"tool_name\":\"Write\",\"tool_input\":{\"file_path\":\"$tmpfile\"}}" \
  0 "warn: vague error message" "specific error"

echo "const empty = 'No items found'" > "$tmpfile"

run_hook_eval "$SCRIPT" \
  "{\"tool_name\":\"Write\",\"tool_input\":{\"file_path\":\"$tmpfile\"}}" \
  0 "warn: dead-end empty state" "empty state"

echo '<Button onClick={handleSave}>Save changes</Button>' > "$tmpfile"

run_hook_eval "$SCRIPT" \
  "{\"tool_name\":\"Write\",\"tool_input\":{\"file_path\":\"$tmpfile\"}}" \
  0 "allow: specific CTA button label"

# ── Escape hatch ────────────────────────────────────────────────

tmpfile="$_ux_tmpdir/legacy.ts"
printf '// allow-ux-copy: legacy external API text\nconst msg = "Created successfully!"\n' > "$tmpfile"

run_hook_eval "$SCRIPT" \
  "{\"tool_name\":\"Write\",\"tool_input\":{\"file_path\":\"$tmpfile\"}}" \
  0 "allow: escape hatch bypasses all checks"

# ── Hook script content checks ──────────────────────────────────

run_content_eval "$SCRIPT" "hook_has_escape" "hook supports escape hatch"
run_content_eval "$SCRIPT" "successfully" "hook checks for successfully"
run_content_eval "$SCRIPT" "click here" "hook checks for click here"
run_content_eval "$SCRIPT" "oops" "hook checks for blame language"
run_content_eval "$SCRIPT" "REDPANDA_KIT" "hook checks Redpanda terms"
run_content_eval "$SCRIPT" "Admin API" "hook checks Redpanda product names"
run_content_eval "$SCRIPT" "Title Case" "hook detects Title Case"
run_content_eval "$SCRIPT" "numeral" "hook checks for spelled-out numbers"
run_content_eval "$SCRIPT" "hook_block|hook_warn" "hook uses shared output functions"
run_content_eval "$SCRIPT" "and/or" "hook checks for and/or"
run_content_eval "$SCRIPT" "etc\." "hook checks for etc."
run_content_eval "$SCRIPT" "e\.g\." "hook checks for e.g."
run_content_eval "$SCRIPT" "Please" "hook checks for please"
run_content_eval "$SCRIPT" "whitelist|blacklist" "hook checks non-inclusive terms"
run_content_eval "$SCRIPT" "There is|There are" "hook checks There is/are starters"
run_content_eval "$SCRIPT" "via" "hook checks for via"
run_content_eval "$SCRIPT" "em dash" "hook checks em dashes in UI strings"
run_content_eval "$SCRIPT" "buzzword" "hook checks marketing buzzwords"
run_content_eval "$SCRIPT" "not just" "hook checks not-just copy cadence"
run_content_eval "$SCRIPT" "theater" "hook checks X theater copy"
run_content_eval "$SCRIPT" "aphoristic" "hook checks aphoristic cadence"
run_content_eval "$SCRIPT" "generic CTA" "hook checks generic CTA labels"
run_content_eval "$SCRIPT" "specific error" "hook checks vague error messages"
run_content_eval "$SCRIPT" "empty state" "hook checks dead-end empty states"

# ── REFERENCE content ───────────────────────────────────────────

run_content_eval "$SKILL_DIR/REFERENCE.md" "sentence" "REFERENCE has capitalization rules"
run_content_eval "$SKILL_DIR/REFERENCE.md" "Toast" "REFERENCE has toast message rules"
run_content_eval "$SKILL_DIR/REFERENCE.md" "Error" "REFERENCE has error message rules"
run_content_eval "$SKILL_DIR/REFERENCE.md" "Button" "REFERENCE has button label rules"
run_content_eval "$SKILL_DIR/REFERENCE.md" "Learn more" "REFERENCE has link placement rules"
run_content_eval "$SKILL_DIR/REFERENCE.md" "allowlist" "REFERENCE has inclusive terminology table"
run_content_eval "$SKILL_DIR/REFERENCE.md" "Directional" "REFERENCE has directional language guidance"
run_content_eval "$SKILL_DIR/REFERENCE.md" "Placeholder" "REFERENCE has placeholder format guidance"
run_content_eval "$SKILL_DIR/REFERENCE.md" "[Ee]m [Dd]ash" "REFERENCE has em dash guidance"
run_content_eval "$SKILL_DIR/REFERENCE.md" "front-loading" "REFERENCE has front-loading guidance"
run_content_eval "$SKILL_DIR/REFERENCE.md" "contextual help" "REFERENCE has contextual help guidance"
run_content_eval "$SKILL_DIR/REFERENCE.md" "destructive language" "REFERENCE has destructive language guidance"
run_content_eval "$SKILL_DIR/REFERENCE.md" "truncation" "REFERENCE has truncation strategy guidance"
run_content_eval "$SKILL_DIR/REFERENCE.md" "Redundant UX writing" "REFERENCE has redundant UX writing guidance"
run_content_eval "$SKILL_DIR/REFERENCE.md" "label.*helper.*placeholder" "REFERENCE tells labels helpers and placeholders not to repeat"
run_content_eval "$SKILL_DIR/REFERENCE.md" "Stress-test copy" "REFERENCE has copy stress-test guidance"
run_content_eval "$SKILL_DIR/REFERENCE.md" "German titles.*500s.*offline" "REFERENCE stress-tests localization and failure copy"
run_content_eval "$SKILL_DIR/REFERENCE.md" "Product naming" "REFERENCE covers product naming taste"
run_content_eval "$SKILL_DIR/REFERENCE.md" "please.*sorry.*thank you" "REFERENCE limits courtesy words"
run_content_eval "$SKILL_DIR/REFERENCE.md" "has been created" "REFERENCE rejects verbose completion toasts"
run_content_eval "$SKILL_DIR/REFERENCE.md" "input placeholder" "REFERENCE distinguishes input placeholders"
run_content_eval "$SKILL_DIR/REFERENCE.md" "nothing after.*link" "REFERENCE keeps Learn more links terminal"

# ── GLOSSARY content ────────────────────────────────────────────

run_content_eval "$SKILL_DIR/GLOSSARY.md" "Admin API" "GLOSSARY has Admin API"
run_content_eval "$SKILL_DIR/GLOSSARY.md" "Schema Registry" "GLOSSARY has Schema Registry"
run_content_eval "$SKILL_DIR/GLOSSARY.md" "grilling|domain-modeling" "GLOSSARY references active DDD skills"

# ── prose-style-check.sh ────────────────────────────────────────

PROSE="$REPO_ROOT/ux-copy/scripts/prose-style-check.sh"

run_executable_eval "$PROSE" "prose-style-check.sh is executable"

run_content_eval "$SKILL_DIR/SKILL.md" "prose-style-check" "SKILL.md documents prose-style script"
run_content_eval "$SKILL_DIR/SKILL.md" "allow.*prose-style" "SKILL.md documents prose-style escape hatch"

# Skip non-prose files
run_hook_eval "$PROSE" \
  '{"tool_name":"Edit","tool_input":{"file_path":"/tmp/test.tsx"}}' \
  0 "prose: skip .tsx file"

run_hook_eval "$PROSE" \
  '{"tool_name":"Edit","tool_input":{"file_path":"/tmp/test.json"}}' \
  0 "prose: skip .json file"

# Block: em dash
_em_file="$_ux_tmpdir/em.md"
printf 'This is fine — but it has an em dash.\n' > "$_em_file"
_em_content=$(cat "$_em_file")
_em_input=$(jq -nc --arg fp "$_em_file" --arg c "$_em_content" \
  '{tool_name:"Write", tool_input:{file_path:$fp, content:$c}}')
run_hook_eval "$PROSE" "$_em_input" 2 "prose: block em dash" "em dashes"

# Block: canned opener
_open_file="$_ux_tmpdir/opener.md"
printf "Let's dive in to the topic.\n" > "$_open_file"
_open_content=$(cat "$_open_file")
_open_input=$(jq -nc --arg fp "$_open_file" --arg c "$_open_content" \
  '{tool_name:"Write", tool_input:{file_path:$fp, content:$c}}')
run_hook_eval "$PROSE" "$_open_input" 2 "prose: block 'Let's dive in'" "canned opener"

# Block: AI-tell hard
_delve_file="$_ux_tmpdir/delve.md"
printf 'Let us delve into the architecture.\n' > "$_delve_file"
_delve_content=$(cat "$_delve_file")
_delve_input=$(jq -nc --arg fp "$_delve_file" --arg c "$_delve_content" \
  '{tool_name:"Write", tool_input:{file_path:$fp, content:$c}}')
run_hook_eval "$PROSE" "$_delve_input" 2 "prose: block 'delve'" "AI-tell"

# Warn (exit 0): AI-tell soft
_soft_file="$_ux_tmpdir/soft.md"
printf 'We leverage Redpanda for streaming.\n' > "$_soft_file"
_soft_content=$(cat "$_soft_file")
_soft_input=$(jq -nc --arg fp "$_soft_file" --arg c "$_soft_content" \
  '{tool_name:"Write", tool_input:{file_path:$fp, content:$c}}')
run_hook_eval "$PROSE" "$_soft_input" 0 "prose: warn 'leverage' (soft)" "leverage"

# Allow: clean prose
_clean_file="$_ux_tmpdir/clean.md"
printf 'This document explains the migration steps in plain English.\n' > "$_clean_file"
_clean_content=$(cat "$_clean_file")
_clean_input=$(jq -nc --arg fp "$_clean_file" --arg c "$_clean_content" \
  '{tool_name:"Write", tool_input:{file_path:$fp, content:$c}}')
run_hook_eval "$PROSE" "$_clean_input" 0 "prose: allow clean prose"

# Allow: em dash inside fenced code block (false-positive guard)
_fenced_file="$_ux_tmpdir/fenced.md"
printf '%s\n' '```' 'echo "x — y"' '```' > "$_fenced_file"
_fenced_content=$(cat "$_fenced_file")
_fenced_input=$(jq -nc --arg fp "$_fenced_file" --arg c "$_fenced_content" \
  '{tool_name:"Write", tool_input:{file_path:$fp, content:$c}}')
run_hook_eval "$PROSE" "$_fenced_input" 0 "prose: allow em dash in indented code"

# Allow: em dash inside inline code span
_inline_file="$_ux_tmpdir/inline.md"
printf 'Use the `git log --oneline — file.txt` command.\n' > "$_inline_file"
_inline_content=$(cat "$_inline_file")
_inline_input=$(jq -nc --arg fp "$_inline_file" --arg c "$_inline_content" \
  '{tool_name:"Write", tool_input:{file_path:$fp, content:$c}}')
run_hook_eval "$PROSE" "$_inline_input" 0 "prose: allow em dash in inline code"

# Warn: non-descriptive links
_link_file="$_ux_tmpdir/link.md"
printf 'Read [here](/docs).\n' > "$_link_file"
_link_content=$(cat "$_link_file")
_link_input=$(jq -nc --arg fp "$_link_file" --arg c "$_link_content" \
  '{tool_name:"Write", tool_input:{file_path:$fp, content:$c}}')
run_hook_eval "$PROSE" "$_link_input" 0 "prose: warn bare here link" "descriptive link text"

# Warn: non-inclusive terminology
_term_file="$_ux_tmpdir/term.md"
printf 'Add the address to the whitelist.\n' > "$_term_file"
_term_content=$(cat "$_term_file")
_term_input=$(jq -nc --arg fp "$_term_file" --arg c "$_term_content" \
  '{tool_name:"Write", tool_input:{file_path:$fp, content:$c}}')
run_hook_eval "$PROSE" "$_term_input" 0 "prose: warn non-inclusive term" "Inclusive terms"

# Warn: title-case Markdown heading
_heading_file="$_ux_tmpdir/heading.md"
printf '# Configure Your First Cluster\n' > "$_heading_file"
_heading_content=$(cat "$_heading_file")
_heading_input=$(jq -nc --arg fp "$_heading_file" --arg c "$_heading_content" \
  '{tool_name:"Write", tool_input:{file_path:$fp, content:$c}}')
run_hook_eval "$PROSE" "$_heading_input" 0 "prose: warn title-case heading" "sentence case"

printf '# Configure your first cluster\n' > "$_heading_file"
_heading_content=$(cat "$_heading_file")
_heading_input=$(jq -nc --arg fp "$_heading_file" --arg c "$_heading_content" \
  '{tool_name:"Write", tool_input:{file_path:$fp, content:$c}}')
run_hook_eval "$PROSE" "$_heading_input" 0 "prose: allow sentence-case heading"

# Allow: escape hatch (HTML comment)
_escape_file="$_ux_tmpdir/escape.md"
printf '<!-- allow: prose-style legacy doc -->\nWe leverage delve patterns — comprehensively.\n' > "$_escape_file"
_escape_content=$(cat "$_escape_file")
_escape_input=$(jq -nc --arg fp "$_escape_file" --arg c "$_escape_content" \
  '{tool_name:"Write", tool_input:{file_path:$fp, content:$c}}')
run_hook_eval "$PROSE" "$_escape_input" 0 "prose: escape hatch (HTML comment)"

# ── Cleanup ─────────────────────────────────────────────────────

rm -rf "$_ux_tmpdir"
