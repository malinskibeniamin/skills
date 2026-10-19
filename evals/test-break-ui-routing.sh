# Public prompt contract only: workflow entrypoints must name the installed
# dependency explicitly. This does not prove model selection or UI resilience.

for workflow in diagnosing-bugs dogfood visual-review; do
  run_content_eval "$REPO_ROOT/$workflow/SKILL.md" \
    'Call the Skill tool with "break-ui"' \
    "$workflow routes UI data/layout stress to break-ui"
done

if python3 - "$REPO_ROOT" <<'PY'
import pathlib
import re
import sys

skill = (pathlib.Path(sys.argv[1]) / "break-ui/SKILL.md").read_text()
frontmatter = skill.split("---", 2)[1]
description = re.search(r"^description: (.+)$", frontmatter, re.M).group(1)
for trigger in ("diagnosis", "dogfood", "visual review"):
    assert trigger in description, f"break-ui discovery omits {trigger}"
PY
then
  echo "  PASS  break-ui discovery includes its workflow callers"
  PASS=$((PASS + 1))
else
  echo "  FAIL  break-ui discovery omits workflow callers"
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: break-ui discovery omits workflow callers"
fi
