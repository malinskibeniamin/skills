#!/bin/bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
BASH_BIN="${BASH_BIN:-/bin/bash}"
cd "$REPO_ROOT"

# Keep this suite centered on behavior that can differ under macOS's Bash 3.2,
# BSD utilities, and default locale. Platform-neutral coverage belongs in the
# comprehensive Linux job.
echo "::group::Parse tracked shell scripts with $("$BASH_BIN" --version | head -1)"
git ls-files -- '*.sh' | while IFS= read -r shell_file; do
  "$BASH_BIN" -n "$shell_file"
done
echo "::endgroup::"

export CLAUDE_PLUGIN_INSTALL_REQUIRED=1
export CODEX_PLUGIN_INSTALL_REQUIRED=1

for eval_target in \
  ask-ben \
  hook-latency-budget \
  setup-toolchain \
  claude-plugin-install \
  codex-plugin-install
do
  echo "::group::Eval: $eval_target"
  "$BASH_BIN" evals/run.sh "$eval_target"
  echo "::endgroup::"
done

echo "::group::Typed hook protocol"
(
  cd shared
  bun test hook-protocol.test.ts
)
echo "::endgroup::"

echo "::group::Malformed, UTF-8, and binary hook input"
"$BASH_BIN" agent-evals/hook-unit-tests-resilience.sh
echo "::endgroup::"
