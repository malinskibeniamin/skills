# Evals for bend-laws-guard.sh: agents never edit human-owned LAWS.bend and never
# add proof escape hatches (@unsafe, def f?) beside it.

HOOKS_DIR="$REPO_ROOT/.claude/hooks"
_bend_hook="$HOOKS_DIR/bend-laws-guard.sh"

run_file_eval "$_bend_hook" "bend-laws-guard.sh exists"
run_executable_eval "$_bend_hook" "bend-laws-guard.sh is executable"

_bend_tmp=$(mktemp -d)
_bend_laws="$_bend_tmp/laws/mcp/LAWS.bend"
_bend_proof="$_bend_tmp/laws/mcp/PROOF.bend"
_bend_model="$_bend_tmp/laws/mcp/policy.bend"
_bend_loose="$_bend_tmp/scratch/game.bend"
mkdir -p "$(dirname "$_bend_laws")" "$(dirname "$_bend_loose")"
printf 'law manual_asks:\n  for a: P.Annotations\n' > "$_bend_laws"
printf 'def Laws.manual_asks(a):\n  {==}\n' > "$_bend_proof"

_bend_write() {
  jq -nc --arg f "$1" --arg c "$2" \
    '{hook_event_name:"PreToolUse",tool_name:"Write",tool_input:{file_path:$f,content:$c}}'
}
_bend_edit() {
  jq -nc --arg f "$1" --arg o "$2" --arg n "$3" \
    '{hook_event_name:"PreToolUse",tool_name:"Edit",tool_input:{file_path:$f,old_string:$o,new_string:$n}}'
}
_bend_bash() {
  jq -nc --arg c "$1" '{hook_event_name:"PreToolUse",tool_name:"Bash",tool_input:{command:$c}}'
}

# LAWS.bend is human-owned.
run_hook_eval "$_bend_hook" "$(_bend_write "$_bend_laws" "law x:\n  {==}")" 2 \
  "denies Write to LAWS.bend" "LAWS.bend is human-owned"
run_hook_eval "$_bend_hook" "$(_bend_edit "$_bend_laws" "for a: P.Annotations" "for a: P.Mode")" 2 \
  "denies Edit to LAWS.bend" "LAWS.bend is human-owned"
_bend_out=$(_bend_edit "$_bend_laws" "for a: P.Annotations" "for a: P.Mode" | BEND_LAWS_AUTHOR=1 "$_bend_hook" 2>&1) && _bend_code=0 || _bend_code=$?
if [ "$_bend_code" -eq 0 ]; then
  echo "  PASS  BEND_LAWS_AUTHOR=1 lets a human-owned session edit LAWS.bend"
  PASS=$((PASS + 1))
else
  echo "  FAIL  BEND_LAWS_AUTHOR=1 lets a human-owned session edit LAWS.bend (exit $_bend_code: $_bend_out)"
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: BEND_LAWS_AUTHOR=1 lets a human-owned session edit LAWS.bend"
fi

# Proof escape hatches beside LAWS.bend.
run_hook_eval "$_bend_hook" "$(_bend_write "$_bend_proof" "@unsafe def Laws.manual_asks(a):\n  Laws.manual_asks(a)")" 2 \
  "denies @unsafe in PROOF.bend" "@unsafe"
run_hook_eval "$_bend_hook" "$(_bend_write "$_bend_model" "def spin?(n: Nat) -> Nat:\n  spin(n)")" 2 \
  "denies def f? in a model beside LAWS.bend" "termination"
run_hook_eval "$_bend_hook" "$(_bend_edit "$_bend_proof" "  {==}" "  ?TODO")" 0 \
  "allows ?TODO because bend PROOF.bend already fails on it"
run_hook_eval "$_bend_hook" "$(_bend_write "$_bend_proof" "def Laws.manual_asks(a):\n  {==}")" 0 \
  "allows ordinary proofs"
run_hook_eval "$_bend_hook" "$(_bend_write "$_bend_loose" "@unsafe def serve(n: Nat) -> Nat:\n  serve(n)")" 0 \
  "ignores Bend files outside a law directory"
run_hook_eval "$_bend_hook" "$(_bend_write "$_bend_tmp/laws/mcp/README.md" "Never use @unsafe here.")" 0 \
  "ignores non-Bend files that mention @unsafe"

# Shell writes.
run_hook_eval "$_bend_hook" "$(_bend_bash "sed -i '' 's/Mode/Hint/' laws/mcp/LAWS.bend")" 2 \
  "denies sed -i on LAWS.bend" "LAWS.bend is human-owned"
run_hook_eval "$_bend_hook" "$(_bend_bash "echo 'law x:' >> laws/mcp/LAWS.bend")" 2 \
  "denies appending to LAWS.bend" "LAWS.bend is human-owned"
run_hook_eval "$_bend_hook" "$(_bend_bash "cp /tmp/draft.bend laws/mcp/LAWS.bend")" 2 \
  "denies copying over LAWS.bend" "LAWS.bend is human-owned"
run_hook_eval "$_bend_hook" "$(_bend_bash "rm laws/mcp/LAWS.bend")" 2 \
  "denies deleting LAWS.bend" "LAWS.bend is human-owned"
run_hook_eval "$_bend_hook" "$(_bend_bash "cat > laws/mcp/PROOF.bend <<'EOF'
@unsafe def Laws.manual_asks(a):
  Laws.manual_asks(a)
EOF")" 2 \
  "denies heredoc writing @unsafe into a Bend file" "@unsafe"
run_hook_eval "$_bend_hook" "$(_bend_bash "cat laws/mcp/LAWS.bend")" 0 \
  "allows reading LAWS.bend"
run_hook_eval "$_bend_hook" "$(_bend_bash "cp laws/mcp/LAWS.bend /tmp/laws-backup.bend")" 0 \
  "allows copying LAWS.bend elsewhere"
run_hook_eval "$_bend_hook" "$(_bend_bash "bend laws/mcp/PROOF.bend")" 0 \
  "allows running the proof gate"
run_hook_eval "$_bend_hook" "$(_bend_bash "grep -rn '@unsafe' laws/ && exit 1")" 0 \
  "allows searching for @unsafe"

rm -rf "$_bend_tmp"

# Wiring.
if jq -e '.hooks.PreToolUse["Edit|Write"] | index("bend-laws-guard.sh")' \
  "$REPO_ROOT/skill-manifest.json" >/dev/null 2>&1; then
  echo "  PASS  bend-laws-guard runs before Edit and Write"
  PASS=$((PASS + 1))
else
  echo "  FAIL  bend-laws-guard missing from Edit|Write PreToolUse"
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: bend-laws-guard missing from Edit|Write PreToolUse"
fi
run_content_eval "$HOOKS_DIR/pre-bash.sh" "bend-laws-guard\\.sh\\|" "pre-bash dispatcher routes Bend writes to bend-laws-guard"
