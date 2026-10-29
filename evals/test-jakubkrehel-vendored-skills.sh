# Public importer CLI and installed prompt/discovery contracts; no model calls.
if python3 "$REPO_ROOT/evals/test-jakubkrehel-sync.py" &&
   python3 "$REPO_ROOT/scripts/vendor-jakubkrehel.py" --check &&
   bash "$REPO_ROOT/scripts/generate-skill-catalog.sh" --check; then
  echo "  PASS  interface pin, complete resources, invocation policy and owner composition"
  PASS=$((PASS + 1))
else
  echo "  FAIL  interface vendoring/distribution contract"
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: interface vendoring/distribution contract"
fi

# Exercise the documented consumer module boundary without editing source bytes.
# UMD .js helpers require CommonJS even when the consuming app is type: module.
helper_root="$(mktemp -d "${TMPDIR:-/tmp}/interface-helpers.XXXXXX")"
trap 'rm -rf "$helper_root"' EXIT
cp -R "$REPO_ROOT/vendor/jakubkrehel/skills/teardown" "$helper_root/teardown"
printf '%s\n' '{"type":"commonjs"}' > "$helper_root/teardown/package.json"
# Pure upstream helper contracts only. No Chrome/CDP, installs or export claims.
for helper in "$helper_root"/teardown/scripts/test-*.cjs; do
  if node "$helper"; then
    echo "  PASS  $(basename "$helper")"
    PASS=$((PASS + 1))
  else
    echo "  FAIL  $(basename "$helper")"
    FAIL=$((FAIL + 1))
    ERRORS="$ERRORS\n  FAIL: interface helper $(basename "$helper")"
  fi
done
