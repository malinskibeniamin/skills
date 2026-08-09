CODEX_APPENDIX="$REPO_ROOT/.agents/codex-appendix.md"
README="$REPO_ROOT/README.md"
MCP_POLICY="$REPO_ROOT/.claude/hooks/mcp-ban.sh"

run_content_eval "$CODEX_APPENDIX" "TraceDecay graph" \
  "Codex guidance names TraceDecay as the code-exploration graph"
run_content_eval "$CODEX_APPENDIX" "before broad shell search" \
  "Codex guidance prefers semantic exploration before broad shell search"
run_content_eval "$CODEX_APPENDIX" "tracedecay tool" \
  "Codex guidance documents the CLI fallback"
run_content_eval "$CODEX_APPENDIX" "scoped.*rg" \
  "Codex guidance retains a scoped native-search fallback"

for command in \
  "brew install ScriptedAlchemy/tap/tracedecay" \
  "tracedecay install --agent codex" \
  "codex plugin add tracedecay@personal" \
  "tracedecay daemon install-service" \
  "tracedecay init" \
  "tracedecay doctor --agent codex"; do
  run_content_eval "$README" "$command" "README documents: $command"
done

run_content_eval "$README" "Token-first hook profile.*UserPromptSubmit" \
  "README documents the measured token-first hook profile"
run_content_eval "$MCP_POLICY" "TraceDecay" \
  "MCP policy explicitly preserves TraceDecay"
