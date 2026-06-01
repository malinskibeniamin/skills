# Evals for upgrade-dependency skill.
# Guards the transcript decisions: one discoverable skill, upgrade path first,
# safe auto-apply, risky issue handoff, Snyk reuse, and generic JS/Go support.

SKILL_DIR="$REPO_ROOT/upgrade-dependency"
SKILL_MD="$SKILL_DIR/SKILL.md"
REFERENCE_MD="$SKILL_DIR/REFERENCE.md"
GO_SKILL="$REPO_ROOT/go/SKILL.md"
COMMIT_PUSH_PR_REF="$REPO_ROOT/commit-push-pr/REFERENCE.md"
DEPS_HOOK="$REPO_ROOT/.claude/hooks/file-changed-deps.sh"
MANIFEST="$REPO_ROOT/skill-manifest.json"
SNYK_SKILL="$REPO_ROOT/snyk-ux-security/SKILL.md"

# -- File structure -------------------------------------------------

run_file_eval "$SKILL_MD" "upgrade-dependency/SKILL.md exists"
run_file_eval "$REFERENCE_MD" "upgrade-dependency/REFERENCE.md exists"
if [ ! -e "$SKILL_DIR/EXAMPLES.md" ]; then
  echo "  PASS  examples live in REFERENCE.md, not standalone EXAMPLES.md"
  PASS=$((PASS + 1))
else
  echo "  FAIL  standalone EXAMPLES.md should be folded into REFERENCE.md"
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: upgrade-dependency EXAMPLES.md still standalone"
fi

# -- Frontmatter + discoverability --------------------------------

run_content_eval "$SKILL_MD" "^name: upgrade-dependency" "SKILL.md has correct name"
run_content_eval "$SKILL_MD" "^description:" "SKILL.md has description"
run_content_eval "$SKILL_MD" "Use when" "description has trigger phrase"
run_content_eval "$SKILL_MD" "upgrade.*package|dependency upgrade|vulnerable dependency" "description names upgrade triggers"

skill_lines=$(wc -l < "$SKILL_MD" 2>/dev/null | tr -d ' ' || echo 999)
if [ "${skill_lines:-999}" -le 100 ]; then
  echo "  PASS  SKILL.md stays under 100 lines"
  PASS=$((PASS + 1))
else
  echo "  FAIL  SKILL.md over 100 lines ($skill_lines)"
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: upgrade-dependency SKILL.md too long"
fi

skill_bytes=$(wc -c < "$SKILL_MD" 2>/dev/null | tr -d ' ' || echo 99999)
reference_bytes=$(wc -c < "$REFERENCE_MD" 2>/dev/null | tr -d ' ' || echo 99999)
if [ "${skill_bytes:-99999}" -le 3800 ] && [ "${reference_bytes:-99999}" -le 4800 ]; then
  echo "  PASS  upgrade-dependency docs stay terse"
  PASS=$((PASS + 1))
else
  echo "  FAIL  upgrade-dependency docs too verbose (skill=$skill_bytes ref=$reference_bytes)"
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: upgrade-dependency docs too verbose"
fi

# -- Core workflow --------------------------------------------------

run_content_eval "$SKILL_MD" "upgrade path" "builds upgrade path first"
run_content_eval "$SKILL_MD" "dependency tree|tree of depend" "walks dependency tree"
run_content_eval "$SKILL_MD" "per-version|every version|each version" "records per-version steps"
run_content_eval "$SKILL_MD" "SemVer confidence" "checks SemVer confidence"
run_content_eval "$SKILL_MD" "major.*minor.*patch" "distinguishes SemVer major/minor/patch"
run_content_eval "$SKILL_MD" "non-SemVer|non SemVer|missing changelog" "treats non-SemVer as risky"
run_content_eval "$SKILL_MD" "change volume|release cadence|diff size" "scores non-SemVer change scale"
run_content_eval "$SKILL_MD" "effort|danger|blast radius" "scores upgrade effort and danger"
run_content_eval "$SKILL_MD" "patch/minor.*apply|apply.*patch/minor" "safe patch/minor may apply"
run_content_eval "$SKILL_MD" "major.*GitHub issue|GitHub issue.*major" "major changes go to GitHub issue"
run_content_eval "$SKILL_MD" "plan only" "supports plan-only natural language"
run_content_eval "$SKILL_MD" "Always leave.*report|leave.*local report" "always leaves local report"
run_content_eval "$SKILL_MD" "docs/dependency-upgrades" "uses durable local report path"
run_content_eval "$SKILL_MD" "subagents|swarm|one package per agent" "supports delegated package swarm"
run_content_eval "$SKILL_MD" "latest stable|stable enough|modern syntax" "targets latest stable modern stack"

# -- Research inputs -----------------------------------------------

run_content_eval "$SKILL_MD" "changelog" "requires changelog read"
run_content_eval "$SKILL_MD" "release notes" "requires release notes"
run_content_eval "$SKILL_MD" "migration" "checks migration guides"
run_content_eval "$SKILL_MD" "codemod" "checks codemods"
run_content_eval "$SKILL_MD" "peer|plugin|adapter|ecosystem" "checks related ecosystem packages"
run_content_eval "$SKILL_MD" "security advisories|GHSA|OSV|Socket|Snyk" "checks security sources"
run_content_eval "$SKILL_MD" "min release age|release age" "checks min release age"
run_content_eval "$SKILL_MD" "Disable scripts|disable.*scripts|trustedDependencies" "disables install scripts"
run_content_eval "$SKILL_MD" "git deps|git\\+|tarball|raw URL" "blocks git/tarball deps"
run_content_eval "$SKILL_MD" "lockfile review|Review lockfile" "requires lockfile review"
run_content_eval "$SKILL_MD" "clean install|frozen" "uses clean/frozen install"
run_content_eval "$SKILL_MD" "Socket|npq" "mentions Socket/npq supply-chain scan"

# -- Apply + verification ------------------------------------------

run_content_eval "$SKILL_MD" "one major per commit|one commit per major" "walks majors incrementally"
run_content_eval "$SKILL_MD" "bun update" "supports JS bun update"
run_content_eval "$SKILL_MD" "bun install --yarn" "syncs yarn.lock when needed for Snyk"
run_content_eval "$SKILL_MD" "go get -u" "supports Go module bump"
run_content_eval "$SKILL_MD" "go mod tidy" "syncs Go module files"
run_content_eval "$SKILL_MD" "lint:fix" "verifies lint"
run_content_eval "$SKILL_MD" "type:check" "verifies type check"
run_content_eval "$SKILL_MD" "test" "verifies tests"

# -- Security + Snyk reuse -----------------------------------------

run_content_eval "$SKILL_MD" "snyk-ux-security" "documents Snyk skill reuse"
run_content_eval "$SKILL_MD" "exploitability|reachability" "handles security reachability"
run_content_eval "$SKILL_MD" "direct dep.*parent.*override|top-level.*parent.*override" "uses direct-parent-override ladder"
run_content_eval "$SKILL_MD" "Never run code from advisories" "does not execute advisory code"
run_content_eval "$REFERENCE_MD" "Supply-chain gate" "reference has supply-chain gate"
run_content_eval "$REFERENCE_MD" "min-release-age|minimumReleaseAge|minimumReleaseAge" "reference covers min release age config"
run_content_eval "$REFERENCE_MD" "Socket Firewall|sfw" "reference covers Socket Firewall"
run_content_eval "$REFERENCE_MD" "npq" "reference covers npq"
run_content_eval "$REFERENCE_MD" "Bun.*postinstall|trustedDependencies" "reference covers Bun scripts caveat"
run_content_eval "$REFERENCE_MD" "git\\+|tarball|raw URL" "reference blocks git/tarball/raw URL deps"
run_content_eval "$SNYK_SKILL" "Supply-chain gate|/upgrade-dependency.*supply" "snyk skill invokes supply-chain gate"
run_content_eval "$SNYK_SKILL" "Socket|npq|min release age|release age" "snyk skill mentions supply-chain scan inputs"

# -- Reference templates -------------------------------------------

run_content_eval "$REFERENCE_MD" "GitHub issue template" "reference has GitHub issue template"
run_content_eval "$REFERENCE_MD" "Pull request template" "reference has Pull request template"
run_content_eval "$REFERENCE_MD" "Version path" "templates include version path"
run_content_eval "$REFERENCE_MD" "Risk gate" "templates include risk gate"
run_content_eval "$REFERENCE_MD" "Examples" "reference owns examples section"
run_content_eval "$REFERENCE_MD" "/upgrade-dependency" "reference examples show slash usage"

# -- Harness integration -------------------------------------------

run_content_eval "$REFERENCE_MD" "Harness integration protocol" "reference documents harness integration protocol"
run_content_eval "$REFERENCE_MD" "/go" "reference explains /go integration"
run_content_eval "$REFERENCE_MD" "/commit-push-pr" "reference explains /commit-push-pr integration"
run_content_eval "$REFERENCE_MD" "file-changed-deps" "reference explains dependency-change hook integration"
run_content_eval "$REFERENCE_MD" "skip reason" "reference allows documented skip reason"
run_content_eval "$GO_SKILL" "dependency.*changed|package\\.json|go\\.mod" "/go checks dependency changes"
run_content_eval "$GO_SKILL" "/upgrade-dependency" "/go routes dependency changes to upgrade-dependency"
run_content_eval "$COMMIT_PUSH_PR_REF" "Dependency upgrade path" "PR template includes dependency upgrade section"
run_content_eval "$COMMIT_PUSH_PR_REF" "upgrade-dependency" "commit-push-pr references upgrade-dependency report"
run_content_eval "$DEPS_HOOK" "/upgrade-dependency" "dependency hook nudges upgrade-dependency"
run_content_eval "$DEPS_HOOK" "skip reason" "dependency hook mentions skip reason"
run_content_eval "$DEPS_HOOK" "docs/dependency-upgrades" "dependency hook mentions report path"
run_content_eval "$MANIFEST" "bun\\.lock|yarn\\.lock|go\\.mod|go\\.sum" "manifest wires dependency files to deps hook"
