# CI keeps the comprehensive suite on Linux while macOS continuously checks the
# portability-sensitive paths. A scheduled/manual job retains the full macOS
# safety net without adding nine minutes to every pull request.

_ci_workflow="$REPO_ROOT/.github/workflows/evals.yml"
_macos_portability="$REPO_ROOT/scripts/run-macos-portability-ci.sh"

run_content_eval "$_ci_workflow" "os: \[ubuntu-latest, macos-latest\]" \
  "CI preserves the existing Linux and macOS check names"
_ci_full_condition="if: runner.os == 'Linux' || steps.macos-scope.outputs.full == 'true'"
_ci_full_condition_count=$(grep -cF -- "$_ci_full_condition" "$_ci_workflow" || true)
if [ "$_ci_full_condition_count" -eq 6 ]; then
  echo "  PASS  all comprehensive gates run on Linux or full-suite events"
  PASS=$((PASS + 1))
else
  echo "  FAIL  expected 6 comprehensive gate conditions, found $_ci_full_condition_count"
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: comprehensive gate conditions"
fi

run_content_eval "$_ci_workflow" "runner\.os == 'macOS'.*steps\.macos-scope\.outputs\.full != 'true'" \
  "pull requests run a focused macOS portability gate"
run_content_eval "$_ci_workflow" "id: macos-scope" \
  "the macOS matrix entry classifies the required coverage"
run_content_eval "$_ci_workflow" "git diff --name-only" \
  "macOS coverage considers the pull request file set"
run_content_eval "$_ci_workflow" '\\\.sh\$' \
  "shell changes request the full macOS suite"
run_content_eval "$_ci_workflow" "/bin/bash scripts/run-macos-portability-ci\.sh" \
  "the macOS matrix entry invokes the portability runner"
run_content_eval "$_ci_workflow" "^  schedule:" \
  "full macOS coverage has a recurring trigger"

if grep -qE -- "^  macos-full:" "$_ci_workflow"; then
  echo "  FAIL  full macOS coverage duplicates the matrix job"
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: duplicate full macOS job"
else
  echo "  PASS  scheduled full macOS coverage reuses the matrix job"
  PASS=$((PASS + 1))
fi
run_executable_eval "$_macos_portability" \
  "the macOS portability runner is executable"

for _ci_target in \
  ask-ben \
  hook-latency-budget \
  setup-toolchain \
  claude-plugin-install \
  codex-plugin-install
do
  run_content_eval "$_macos_portability" "$_ci_target" \
    "macOS portability covers $_ci_target"
done

run_content_eval "$_macos_portability" "hook-unit-tests-resilience\.sh" \
  "macOS portability covers malformed and binary hook input"
run_content_eval "$_macos_portability" "hook-protocol\.test\.ts" \
  "macOS portability covers the typed hook protocol"
run_content_eval "$_macos_portability" "cd shared" \
  "the typed hook protocol runs from its package directory"
run_content_eval "$_macos_portability" '"\$BASH_BIN" -n' \
  "macOS portability parses tracked shell scripts with Bash 3.2"
