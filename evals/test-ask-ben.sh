# Evals for the local /ask-ben router.

ASK_BEN="$REPO_ROOT/ask-ben/SKILL.md"

run_file_eval "$ASK_BEN" "ask-ben SKILL.md exists"
run_content_eval "$ASK_BEN" "^name: ask-ben$" "ask-ben frontmatter name matches directory"
run_content_eval "$ASK_BEN" "^# Ask Ben$" "ask-ben title is local to Ben"
run_content_eval "$ASK_BEN" "frontend/React/TypeScript/Go" "ask-ben names Ben's frontend stack"
run_content_eval "$ASK_BEN" "skills repo" "ask-ben names skills repo work"
run_content_eval "$ASK_BEN" "installable plugin surfaces" "ask-ben names plugin release surface"

forbidden_project="Query""lane"
forbidden_refs=$(grep -R --exclude-dir=.git --exclude-dir=.context --exclude-dir=node_modules \
  -nF "$forbidden_project" "$REPO_ROOT" 2>/dev/null || true)
if [ -z "$forbidden_refs" ]; then
  echo "  PASS  ask-ben avoids unrelated project names"
  PASS=$((PASS + 1))
else
  echo "  FAIL  unrelated project name still present"
  echo "$forbidden_refs" | sed 's/^/        /'
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: unrelated project name still present"
fi

# The old upstream router name should not leak after localizing the router.
old_router_slug="ask""-matt"
old_router_title="Ask ""Matt"
stale_router_refs=$(grep -R --exclude-dir=.git --exclude-dir=.context --exclude-dir=node_modules \
  -nE "$old_router_slug|$old_router_title" "$REPO_ROOT" 2>/dev/null || true)
if [ -z "$stale_router_refs" ]; then
  echo "  PASS  old router name fully removed"
  PASS=$((PASS + 1))
else
  echo "  FAIL  old router name still present"
  echo "$stale_router_refs" | sed 's/^/        /'
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: old router name still present"
fi

# Every local skill should have exactly one explanatory table row in /ask-ben.
missing_rows=""
extra_rows=""
duplicate_rows=""
all_skills=$(find "$REPO_ROOT" -maxdepth 2 -name SKILL.md -not -path '*/agent-evals/*' -print | sed "s#^$REPO_ROOT/##; s#/SKILL.md##" | sort)
table_rows=$(grep -E '^\| `/[^`]+` \|' "$ASK_BEN" | sed -E 's/^\| `\/([^`]+)` \|.*/\1/' | sort)

while IFS= read -r skill; do
  [ -n "$skill" ] || continue
  count=$(printf '%s\n' "$table_rows" | { grep -Fx "$skill" || true; } | wc -l | tr -d ' ')
  if [ "$count" -eq 0 ]; then
    missing_rows="$missing_rows $skill"
  elif [ "$count" -gt 1 ]; then
    duplicate_rows="$duplicate_rows $skill($count)"
  fi
done <<< "$all_skills"

while IFS= read -r row_skill; do
  [ -n "$row_skill" ] || continue
  if ! grep -Fxq "$row_skill" <<< "$all_skills"; then
    extra_rows="$extra_rows $row_skill"
  fi
done <<< "$table_rows"

if [ -z "$missing_rows" ] && [ -z "$duplicate_rows" ] && [ -z "$extra_rows" ]; then
  echo "  PASS  ask-ben table explains every local skill exactly once"
  PASS=$((PASS + 1))
else
  echo "  FAIL  ask-ben table drift"
  [ -z "$missing_rows" ] || echo "        missing:$missing_rows"
  [ -z "$duplicate_rows" ] || echo "        duplicate:$duplicate_rows"
  [ -z "$extra_rows" ] || echo "        extra:$extra_rows"
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: ask-ben table drift"
fi
