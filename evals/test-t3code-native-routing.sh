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

# PR routing must reach the shared owner and continuation sections, not a second recipe.
if python3 - "$REPO_ROOT" <<'PY'
import pathlib
import re
import sys

repo = pathlib.Path(sys.argv[1])
batch = repo / "pr-shepherd/REFERENCE.md"
native = repo / "shared/T3CODE-NATIVE.md"
links = re.findall(r"\[[^\]]+\]\(([^)]+)\)", batch.read_text())
headings = {
    re.sub(r"[^\w -]", "", heading.lower()).replace(" ", "-")
    for heading in re.findall(r"^#{1,6} (.+)$", native.read_text(), re.MULTILINE)
}
for anchor in ("find-the-existing-pr-owner", "continue-the-owning-session"):
    target = f"../shared/T3CODE-NATIVE.md#{anchor}"
    assert target in links, f"Batch PR maintenance must load {target}"
    assert anchor in headings, f"Missing native PR routing section: {anchor}"
print("  PASS  batch PR maintenance reaches shared T3 ownership and continuation guidance")
PY
then
  PASS=$((PASS + 1))
else
  echo "  FAIL  batch PR maintenance cannot reach shared T3 ownership/continuation guidance"
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: T3 PR ownership/continuation routing"
fi
