# Evals for repository-wide formatting, linting, and type checking.

ROOT_PACKAGE="$REPO_ROOT/package.json"
ROOT_BIOME="$REPO_ROOT/biome.json"
ROOT_TSCONFIG="$REPO_ROOT/tsconfig.json"
CI_WORKFLOW="$REPO_ROOT/.github/workflows/evals.yml"
LEFTHOOK="$REPO_ROOT/lefthook.yml"

run_file_eval "$ROOT_PACKAGE" "root package.json owns quality scripts"
run_file_eval "$ROOT_BIOME" "root biome.json owns repository formatting and linting"
run_file_eval "$ROOT_TSCONFIG" "root tsconfig.json owns repository type checking"

for script in format format:check lint lint:fix type:check quality:gate check:files; do
  if jq -e --arg script "$script" '.scripts[$script] | strings' "$ROOT_PACKAGE" >/dev/null 2>&1; then
    echo "  PASS  root package exposes $script"
    PASS=$((PASS + 1))
  else
    echo "  FAIL  root package exposes $script"
    FAIL=$((FAIL + 1))
    ERRORS="$ERRORS\n  FAIL: missing root script $script"
  fi
done

if jq -e '.scripts.lint | startswith("biome lint ") and endswith(" .")' "$ROOT_PACKAGE" >/dev/null 2>&1 \
  && jq -e '.scripts["format:check"] | test("biome format \\.$")' "$ROOT_PACKAGE" >/dev/null 2>&1 \
  && ! grep -q 'hook-protocol\\.ts hook-protocol\\.test\\.ts' "$ROOT_PACKAGE"; then
  echo "  PASS  lint and format scan the repository instead of named files"
  PASS=$((PASS + 1))
else
  echo "  FAIL  lint and format scan the repository instead of named files"
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: root quality scripts remain file-scoped"
fi

if jq -e '.include | index("**/*.ts") and index("**/*.tsx")' "$ROOT_TSCONFIG" >/dev/null 2>&1; then
  echo "  PASS  root typecheck automatically includes repository TypeScript"
  PASS=$((PASS + 1))
else
  echo "  FAIL  root typecheck automatically includes repository TypeScript"
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: root typecheck is not repository-wide"
fi

if jq -e '.exclude | index("exemplars")' "$ROOT_TSCONFIG" >/dev/null 2>&1 \
  && jq -e '.files.includes | index("!exemplars")' "$ROOT_BIOME" >/dev/null 2>&1; then
  echo "  PASS  intentional code fixtures are excluded"
  PASS=$((PASS + 1))
else
  echo "  FAIL  intentional code fixtures are excluded"
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: intentional fixtures enter the global gate"
fi

if [ ! -e "$REPO_ROOT/shared/package.json" ] \
  && [ ! -e "$REPO_ROOT/shared/biome.json" ] \
  && [ ! -e "$REPO_ROOT/shared/tsconfig.json" ] \
  && [ ! -e "$REPO_ROOT/shared/bun.lock" ]; then
  echo "  PASS  shared no longer owns a narrow quality project"
  PASS=$((PASS + 1))
else
  echo "  FAIL  shared no longer owns a narrow quality project"
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: narrow shared quality project remains"
fi

run_content_eval "$CI_WORKFLOW" "run: bun install --frozen-lockfile" \
  "CI installs the root quality toolchain"
run_content_eval "$CI_WORKFLOW" "run: bun run quality:gate" \
  "CI enforces the full repository quality gate"

if ! grep -q 'cd shared' "$CI_WORKFLOW"; then
  echo "  PASS  CI no longer scopes quality checks to shared"
  PASS=$((PASS + 1))
else
  echo "  FAIL  CI no longer scopes quality checks to shared"
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: CI still scopes quality checks to shared"
fi

run_content_eval "$LEFTHOOK" "bun run check:files -- \\{push_files\\}" \
  "pre-push checks changed files through the root Biome config"
run_content_eval "$LEFTHOOK" "bun run type:check" \
  "pre-push uses the root typecheck"

if (cd "$REPO_ROOT" && bun run check:files -- agent-evals/evals/setup-accessibility/EVAL.ts) \
  >/dev/null 2>&1; then
  echo "  PASS  changed-file check matches the repository quality gate"
  PASS=$((PASS + 1))
else
  echo "  FAIL  changed-file check matches the repository quality gate"
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: pre-push rejects a file accepted by repository checks"
fi

mkdir -p "$REPO_ROOT/.context"
context_probe_dir=$(mktemp -d "$REPO_ROOT/.context/quality-gate.XXXXXX")
printf '{"unformatted":true}' > "$context_probe_dir/probe.json"
if (cd "$REPO_ROOT" && bun run format:check) >/dev/null 2>&1; then
  echo "  PASS  repository formatting ignores Conductor context artifacts"
  PASS=$((PASS + 1))
else
  echo "  FAIL  repository formatting ignores Conductor context artifacts"
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: gitignored .context artifacts enter the global gate"
fi
rm -f "$context_probe_dir/probe.json"
rmdir "$context_probe_dir"
rmdir "$REPO_ROOT/.context" 2>/dev/null || true
