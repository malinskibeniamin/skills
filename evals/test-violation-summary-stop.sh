# The real Stop entrypoint reports violations, not pressure to reduce LOC.

if python3 - "$REPO_ROOT" <<'PY'
import json
import os
import pathlib
import shutil
import subprocess
import sys
import tempfile
import uuid

hook = pathlib.Path(sys.argv[1]) / ".claude/hooks/violation-summary-stop.sh"
sid = f"eval-violation-summary-{uuid.uuid4().hex}"
session = pathlib.Path("/tmp") / f"hook-session-{sid}"
env = {key: value for key, value in os.environ.items() if key not in {"CLAUDE_SESSION_ID", "CODEX_SESSION_ID"}}
session.mkdir()
try:
    with tempfile.TemporaryDirectory(prefix="violation-summary-") as directory:
        cwd = pathlib.Path(directory)
        subprocess.run(["git", "init", "-q"], cwd=cwd, check=True)
        source = cwd / "example.ts"
        source.write_text("export const value = 1;\n")
        subprocess.run(["git", "add", "example.ts"], cwd=cwd, check=True)
        subprocess.run(["git", "-c", "user.name=Eval", "-c", "user.email=eval@example.invalid", "-c", "core.hooksPath=/dev/null", "commit", "-qm", "baseline"], cwd=cwd, check=True)
        source.write_text("export const value = 1;\nexport const nextValue = 2;\n")
        (session / "files").write_text(f"Write:{source}\n")

        def stop():
            result = subprocess.run(["bash", str(hook)], input=json.dumps({"hook_event_name": "Stop", "session_id": sid}), text=True, capture_output=True, cwd=cwd, env=env, check=True)
            assert not result.stderr, result.stderr
            return result.stdout

        assert stop() == "", "ordinary source additions must not produce LOC pressure"
        violations = session / "violations"
        violations.write_text("type-safety\ntype-safety\nworktree\n")
        context = json.loads(stop())["hookSpecificOutput"]["additionalContext"]
        assert "3 total" in context and "2x type-safety" in context and "1x worktree" in context, context
        assert "LOC" not in context, context
        assert not violations.exists(), "reported violations must be consumed"
        assert stop() == "", "a subsequent Stop must not repeat the report"
finally:
    shutil.rmtree(session)
PY
then
  echo "  PASS  Stop reports and consumes violations without LOC pressure"
  PASS=$((PASS + 1))
else
  echo "  FAIL  Stop violation reporting contract"
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: Stop violation reporting contract"
fi
