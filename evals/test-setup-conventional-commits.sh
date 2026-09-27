# Evals for setup-conventional-commits skill

SCRIPT="$REPO_ROOT/.claude/hooks/conventional-commits-check.sh"
SKILL_DIR="$REPO_ROOT/frontend-starter-kit/references/conventional-commits"

# ── File structure ──────────────────────────────────────────────

run_file_eval "$SKILL_DIR/README.md" "SKILL.md exists"
run_file_eval "$SKILL_DIR/REFERENCE.md" "REFERENCE.md exists"
run_executable_eval "$SCRIPT" "conventional-commits-check.sh is executable"

# ── SKILL.md content ────────────────────────────────────────────

run_content_eval "$SKILL_DIR/README.md" "scope" "SKILL.md mentions scope requirement"

# ── Hook: skip non-Bash ─────────────────────────────────────────

run_hook_eval "$SCRIPT" \
  '{"tool_name":"Edit","tool_input":{"file_path":"test.tsx"}}' \
  0 "skip: Edit tool"

# ── Hook: skip non-commit commands ──────────────────────────────

run_hook_eval "$SCRIPT" \
  '{"tool_name":"Bash","tool_input":{"command":"git status"}}' \
  0 "skip: git status"

run_hook_eval "$SCRIPT" \
  '{"tool_name":"Bash","tool_input":{"command":"bun run test"}}' \
  0 "skip: non-git command"

# ── Hook: block missing type ────────────────────────────────────

run_hook_eval "$SCRIPT" \
  '{"tool_name":"Bash","tool_input":{"command":"git commit -m \"bad message\""}}' \
  2 "block: missing type" "type"

# ── Hook: block missing scope ───────────────────────────────────

run_hook_eval "$SCRIPT" \
  '{"tool_name":"Bash","tool_input":{"command":"git commit -m \"feat: add button\""}}' \
  2 "block: missing scope" "scope"

# ── Hook: block uppercase description ────────────────────────────

run_hook_eval "$SCRIPT" \
  '{"tool_name":"Bash","tool_input":{"command":"git commit -m \"feat(ui): Add button component\""}}' \
  2 "block: uppercase first letter" "lowercase"

# ── Hook: block trailing period ──────────────────────────────────

run_hook_eval "$SCRIPT" \
  '{"tool_name":"Bash","tool_input":{"command":"git commit -m \"feat(ui): add button component.\""}}' \
  2 "block: trailing period" "period"

# ── Hook: block short description ────────────────────────────────

run_hook_eval "$SCRIPT" \
  '{"tool_name":"Bash","tool_input":{"command":"git commit -m \"feat(ui): fix\""}}' \
  2 "block: description too short"

# ── Hook: allow valid commit ─────────────────────────────────────

run_hook_eval "$SCRIPT" \
  '{"tool_name":"Bash","tool_input":{"command":"git commit -m \"feat(webui): add user profile avatar upload\""}}' \
  0 "allow: valid conventional commit"

run_hook_eval "$SCRIPT" \
  '{"tool_name":"Bash","tool_input":{"command":"git commit -m \"fix(backend): handle null response from auth endpoint\""}}' \
  0 "allow: valid fix commit"

run_hook_eval "$SCRIPT" \
  '{"tool_name":"Bash","tool_input":{"command":"git commit -m \"chore(deps): bump tanstack-query to v5.62\""}}' \
  0 "allow: valid chore commit"

# ── Hook: allow single quotes ────────────────────────────────────

run_hook_eval "$SCRIPT" \
  "{\"tool_name\":\"Bash\",\"tool_input\":{\"command\":\"git commit -m 'refactor(api): extract validation utility'\"}}" \
  0 "allow: single-quoted commit message"

# ── Hook: subject comes from the FIRST -m (later -m are body paragraphs) ──

run_hook_eval "$SCRIPT" \
  '{"tool_name":"Bash","tool_input":{"command":"git commit -m \"fix(hooks): parse the first message flag\" -m \"Body paragraph. Ends with period.\""}}' \
  0 "allow: body -m after a valid subject"

run_hook_eval "$SCRIPT" \
  '{"tool_name":"Bash","tool_input":{"command":"git commit -m \"Bad subject\" -m \"fix(hooks): looks valid\""}}' \
  2 "block: invalid first -m even when a later -m looks valid" "Bad subject"

run_hook_eval "$SCRIPT" \
  '{"tool_name":"Bash","tool_input":{"command":"git commit -am \"docs(readme): explain hook rewrites\""}}' \
  0 "allow: -am combined flag"

run_hook_eval "$SCRIPT" \
  '{"tool_name":"Bash","tool_input":{"command":"git commit -am \"Update stuff\""}}' \
  2 "block: -am combined flag is validated" "Invalid commit type"

run_hook_eval "$SCRIPT" \
  '{"tool_name":"Bash","tool_input":{"command":"git commit --message=\"feat(ui): add avatar upload\""}}' \
  0 "allow: --message= form"

run_hook_eval "$SCRIPT" \
  '{"tool_name":"Bash","tool_input":{"command":"git commit -m \"$(cat <<'"'"'EOF'"'"'\nfix(hooks): read heredoc subject\n\nBody line. With period.\nEOF\n)\""}}' \
  0 "allow: heredoc subject"

run_hook_eval "$SCRIPT" \
  '{"tool_name":"Bash","tool_input":{"command":"git commit -m \"$(cat <<'"'"'EOF'"'"'\nUpdated the hooks\n\nfix(hooks): body mention\nEOF\n)\""}}' \
  2 "block: heredoc subject is the first line, not any conventional line" "Updated the hooks"

# ── Hook: -F reads the message file ──────────────────────────────

_cc_dir=$(mktemp -d "${TMPDIR:-/tmp}/cc-evals-XXXXXX")
printf 'fix(hooks): read the message file\n\nBody.\n' > "$_cc_dir/good.txt"
printf 'WIP\n' > "$_cc_dir/bad.txt"

run_hook_eval "$SCRIPT" \
  "{\"tool_name\":\"Bash\",\"cwd\":\"$_cc_dir\",\"tool_input\":{\"command\":\"git commit -F good.txt\"}}" \
  0 "allow: -F relative file with valid subject"

run_hook_eval "$SCRIPT" \
  "{\"tool_name\":\"Bash\",\"tool_input\":{\"command\":\"git commit -F $_cc_dir/bad.txt\"}}" \
  2 "block: -F file with invalid subject" "WIP"

run_hook_eval "$SCRIPT" \
  "{\"tool_name\":\"Bash\",\"tool_input\":{\"command\":\"git commit --file=$_cc_dir/good.txt -m ignored\"}}" \
  0 "allow: first flag -F wins over a later -m"
rm -rf "$_cc_dir"

# ── Hook: deny names the exact replacement subject ───────────────

run_hook_eval "$SCRIPT" \
  '{"tool_name":"Bash","tool_input":{"command":"git commit -m \"feature(ui): add avatar upload\""}}' \
  2 "block: common type typo suggests the fixed subject" "feat(ui): add avatar upload"

# ── Script content ──────────────────────────────────────────────

run_content_eval "$SCRIPT" "feat|fix|refactor" "hook validates commit types"
run_content_eval "$SCRIPT" "scope" "hook validates scope"
run_content_eval "$SCRIPT" "hook_deny" "hook uses shared deny function"
run_content_eval "$SCRIPT" "min 5" "hook validates min description length"
run_content_eval "$SCRIPT" "max 72" "hook validates max description length"
