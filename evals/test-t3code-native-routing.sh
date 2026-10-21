# Public skill-routing contracts, not evidence of Browser/Device execution.
# These links are the shipped entrypoints consumed by agents in either host.

# A late pointer after generation cannot prevent a duplicate verifier.
for surface in app mobile; do
  if sed '/^## Generate/,$d' "$REPO_ROOT/create-verification-skill/SKILL.md" | \
    grep -qF "../t3code-skills/test-t3-$surface/SKILL.md"; then
    echo "  PASS  existing T3 $surface verification is resolved before generation"
    PASS=$((PASS + 1))
  else
    echo "  FAIL  existing T3 $surface verification is resolved before generation"
    FAIL=$((FAIL + 1))
    ERRORS="$ERRORS\n  FAIL: T3 $surface routing must precede verifier generation"
  fi
done

run_content_eval "$REPO_ROOT/maintain-verification-skill/SKILL.md" \
  '\]\(\.\./shared/T3CODE-SKILLS\.md#native-verification\)' \
  "maintenance resolves native verifiers without requiring a verify prefix"

run_content_eval "$REPO_ROOT/shared/delivery-workflow.md" \
  '\]\((\.\./shared/)?repo-navigation\.md\)' \
  "delivery resolves the target toolchain before choosing checks"
