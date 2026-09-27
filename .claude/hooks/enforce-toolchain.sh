#!/bin/bash
set -euo pipefail

# MIRROR: hooks/frontend-skills.rules carries these bans as Codex execpolicy
# prefix_rules (deterministic floor when Codex hooks are off). When adding or
# removing a ban here, update that file too — the generator drift-checks the
# .codex/rules/ copy.

input=$(cat)
command=$(echo "$input" | jq -r '.tool_input.command // empty' 2>/dev/null || true)

if [ -z "$command" ]; then
  exit 0
fi

# Fast path: one union grep decides whether ANY rule below could match.
# Most Bash calls are innocent; they exit here after 1 pipeline instead of ~40.
# The union is the set of trigger tokens from every rule in this file -- when
# adding a rule below, add its trigger token here (eval fixtures catch drift).
# De-escape BEFORE the fast path: r\m and r"m" are guard evasion; argv
# still resolves to rm. All rule regexes below run on the same de-escaped text.
_raw_command="$command"
command=$(printf '%s' "$command" | tr -d '\\')
if ! printf '%s' "$command" | grep -qE 'npm|npx|yarn|pnpm|tsgo|eslint|prettier|bun|rm|sleep|git|cat <<|killall|pkill|osascript'; then
  exit 0
fi

# A deny discards the whole ;/&& chain, so the lint/test steps chained with the
# offending part never run. Where the safe form is unambiguous, rewrite the
# command instead (emitted as updatedInput at the end) and keep checking it.
_rewrite_notes=""
_sleep_lead='^[[:space:]]*sleep[[:space:]]+[0-9.]+[smhd]?[[:space:]]*(&&|;)[[:space:]]*'
# Leading `sleep N &&`/`;` only postpones the real command. A sleep anywhere
# else may pace a loop -- dropping it could busy-spin -- so that stays a deny.
if printf '%s' "$_raw_command" | grep -qE "$_sleep_lead"; then
  _rest="$_raw_command"
  while printf '%s' "$_rest" | grep -qE "$_sleep_lead"; do
    _rest=$(printf '%s' "$_rest" | sed -E "s/$_sleep_lead//")
  done
  if [ -n "$(printf '%s' "$_rest" | tr -d '[:space:]')" ]; then
    _raw_command="$_rest"
    _rewrite_notes="${_rewrite_notes}Dropped leading sleep; wait on events (gh pr checks <n> --watch, Monitor), not time. "
  fi
fi
# Per push segment: --force / -f -> --force-with-lease.
_force_re='(git[[:space:]]+push([[:space:]]+[^;&|[:space:]]+)*)[[:space:]]+(--force|-f)([[:space:];&|]|$)'
# Require a match outside quotes too, so a commit message is never edited.
if printf '%s' "$_raw_command" | grep -qE "$_force_re" \
  && printf '%s' "$_raw_command" | sed "s/\"[^\"]*\"//g; s/'[^']*'//g" | grep -qE "$_force_re"; then
  _raw_command=$(printf '%s' "$_raw_command" | sed -E -e ':a' -e "s/$_force_re/\\1 --force-with-lease\\4/" -e 'ta')
  _rewrite_notes="${_rewrite_notes}Rewrote git push --force to --force-with-lease. "
fi
if [ -n "$_rewrite_notes" ]; then
  command=$(printf '%s' "$_raw_command" | tr -d '\\')
fi

# Split a command into one line per ;/&&/||/| segment.
_segments() { printf '%s\n' "$1" | awk '{ gsub(/&&|\|\||;|\|/, "\n"); print }'; }

# Name the package.json script that already wraps a tool so the deny message
# carries the exact command to rerun. Reads the session cwd, not the hook's.
_cwd=$(printf '%s' "$input" | jq -r '.cwd // empty' 2>/dev/null || true)
[ -d "$_cwd" ] || _cwd="$PWD"
_scripts=""
[ -f "$_cwd/package.json" ] && _scripts=$(jq -r '.scripts // {} | to_entries[] | "\(.key)\t\(.value)"' "$_cwd/package.json" 2>/dev/null || true)
_has_script() { printf '%s\n' "$_scripts" | cut -f1 | grep -qxF -- "$1"; }
_script_running() { printf '%s\n' "$_scripts" | awk -F'\t' -v t="$1" 'index($2, t) { print $1; exit }'; }

# For git commit/tag commands, strip the message to avoid false positives
_cmd_for_check="$command"
if echo "$command" | grep -qE '(^|\s|&&|\|\||;)git\s+(commit|tag)\s'; then
  # Get everything before -m/-F flag (first line only, discard rest)
  _cmd_for_check=$(printf '%s\n' "$command" | head -1 | sed 's/[[:space:]]-[mF][[:space:]].*//')
fi

# Strip quoted strings and heredoc content to avoid matching banned words
_cmd_stripped=$(echo "$_cmd_for_check" | sed 's/"[^"]*"//g' | sed "s/'[^']*'//g" | tr -d '\\')
if echo "$_cmd_for_check" | grep -qE 'cat <<'; then
  _cmd_stripped=$(echo "$_cmd_stripped" | sed '/<<.*EOF/,/^[[:space:]]*EOF/d')
fi

# Never terminate a human-owned browser to make it available for automation.
_browser_apps='google[[:space:]]+chrome|chrome|chromium|safari|firefox|arc|brave([[:space:]]+browser)?|microsoft[[:space:]]+edge'
_browser_app_match="(^|[^[:alnum:]_])($_browser_apps)([^[:alnum:]_]|$)"
if printf '%s' "$command" | grep -qiE "(^|[;&|][;&|]?[[:space:]]*)(sudo[[:space:]]+)?(killall|pkill)[^;&|]*${_browser_app_match}" \
  || printf '%s' "$command" | grep -qiE "(^|[;&|][;&|]?[[:space:]]*)osascript[^;&|]*((quit|close)[^;&|]*${_browser_app_match}|${_browser_app_match}[^;&|]*(quit|close))"; then
  echo '{"hookSpecificOutput":{"permissionDecision":"deny"},"systemMessage":"Refusing to close a human-owned browser. Use an isolated agent-browser or Playwright session; if isolation is unavailable, report blocked verification."}' >&2
  exit 2
fi

# Block npm commands — include exact replacement
if echo "$_cmd_stripped" | grep -qE '(^|\s|&&|\|\||;)npm\s'; then
  _rewritten=$(echo "$command" | sed -E 's/(^|[[:space:]])npm[[:space:]]/\1bun /g')
  echo "{\"hookSpecificOutput\":{\"permissionDecision\":\"deny\"},\"systemMessage\":\"npm banned. Rerun with bun: ${_rewritten}\"}" >&2
  exit 2
fi

# Block npx commands — include exact replacement
if echo "$_cmd_stripped" | grep -qE '(^|\s|&&|\|\||;)npx\s'; then
  _rewritten=$(echo "$command" | sed -E 's/(^|[[:space:]])npx[[:space:]]/\1bunx /g')
  echo "{\"hookSpecificOutput\":{\"permissionDecision\":\"deny\"},\"systemMessage\":\"npx banned. Rerun with bunx: ${_rewritten}\"}" >&2
  exit 2
fi

# Block tsgo commands — TypeScript 7 ships the Go compiler as tsc
if echo "$_cmd_stripped" | grep -qE '(^|\s|&&|\|\||;)tsgo(\s|$)'; then
  _rewritten=$(echo "$command" | sed -E 's/(^|[[:space:]]|&&|\|\||;)tsgo([[:space:]]|$)/\1tsc\2/g')
  echo "{\"hookSpecificOutput\":{\"permissionDecision\":\"deny\"},\"systemMessage\":\"tsgo banned. tsc is now the TypeScript 7 Go compiler. Rerun with tsc: ${_rewritten}\"}" >&2
  exit 2
fi

# Block global installs
if echo "$_cmd_stripped" | grep -qE 'bun\s+(add|install)\s+.*-g(\s|$)' || echo "$_cmd_stripped" | grep -qE 'bun\s+(add|install)\s+.*--global(\s|$)'; then
  echo '{"hookSpecificOutput":{"permissionDecision":"deny"},"systemMessage":"Global installs banned. Use bun add -D."}' >&2
  exit 2
fi

# Block installing eslint or prettier
if echo "$_cmd_stripped" | grep -qE 'bun\s+(add|install)\s.*\b(eslint|prettier)\b'; then
  echo '{"hookSpecificOutput":{"permissionDecision":"deny"},"systemMessage":"eslint/prettier banned. Use Biome: bun run lint|lint:fix."}' >&2
  exit 2
fi

# Block eslint as a direct command
if echo "$_cmd_stripped" | grep -qE '(^|\s|&&|\|\||;)eslint(\s|$)'; then
  echo '{"hookSpecificOutput":{"permissionDecision":"deny"},"systemMessage":"eslint banned. Use Biome: bun run lint."}' >&2
  exit 2
fi

# Block prettier as a direct command
if echo "$_cmd_stripped" | grep -qE '(^|\s|&&|\|\||;)prettier(\s|$)'; then
  echo '{"hookSpecificOutput":{"permissionDecision":"deny"},"systemMessage":"prettier banned. Use Biome: bun run lint:fix."}' >&2
  exit 2
fi

# Block direct bunx for tools that have package.json scripts
if echo "$_cmd_stripped" | grep -qE '(^|\s|&&|\|\||;)bunx\s+(ultracite|biome|@biomejs/biome|react-doctor|tsr|@tanstack/router-cli|eslint|prettier)'; then
  _bunx_seg=$(printf '%s' "$command" | grep -oE 'bunx[[:space:]]+[^;&|]*' | head -1 | sed -E 's/[[:space:]]+$//')
  tool=$(printf '%s' "$_bunx_seg" | awk '{print $2}')
  _script="" _paths="" _write=false
  case "$tool" in
    ultracite|biome|@biomejs/biome|eslint|prettier)
      set -f
      for _w in $(printf '%s' "$_bunx_seg" | cut -d' ' -f3-); do
        case "$_w" in
          --write|--fix|--apply|--unsafe|format|fix) _write=true ;;
          -*|check|lint|ci|.|./) ;;
          *) _paths="$_paths $_w" ;;
        esac
      done
      set +f
      if [ -n "$_paths" ]; then
        for _s in lint:file check:files; do _has_script "$_s" && { _script="$_s"; break; }; done
      fi
      if [ -z "$_script" ]; then
        _paths=""
        if [ "$_write" = true ]; then _s=lint:fix; else _s=lint; fi
        _has_script "$_s" && _script="$_s"
      fi
      [ -z "$_script" ] && _script=$(_script_running biome)
      ;;
    tsr|@tanstack/router-cli) _script=$(_script_running tsr); [ -z "$_script" ] && _script=$(_script_running router-cli) ;;
    *) _script=$(_script_running "$tool") ;;
  esac
  if [ -n "$_script" ]; then
    _hint="Rerun: ${command/"$_bunx_seg"/bun run $_script$_paths}"
  else
    _hint="Add a package.json script that runs $tool, then use bun run <script>."
  fi
  hook_msg=$(jq -cn --arg m "${tool} via bunx banned. $_hint" '{hookSpecificOutput:{permissionDecision:"deny"},systemMessage:$m}')
  echo "$hook_msg" >&2
  exit 2
fi

# Block destructive rm -rf / rm -r / rm --recursive (allow safe targets)
if echo "$_cmd_stripped" | grep -qE '(^|\s|&&|\|\||;)rm\s+(-[a-zA-Z]*r[a-zA-Z]*|--recursive)(\s|$)' \
   && ! echo "$_cmd_stripped" | grep -qE '(^|\s|&&|\|\||;)git\s+rm\s'; then
  safe_targets="node_modules .next dist build .cache .turbo coverage __pycache__ .claude/skills .claude/hooks skills-lock.json"
  _tmp="${TMPDIR:-/tmp}"; _tmp="${_tmp%/}"
  # Safe = a path component chain containing a safe name, or strictly inside a
  # temp dir. `..` could climb out of either, so it is never safe.
  _rm_target_safe() {
    local t="${1%/}" s
    case "/$t/" in */../*) return 1 ;; esac
    case "$t" in
      /tmp/?*|/private/tmp/?*|"$_tmp"/?*|'$TMPDIR'/?*|'${TMPDIR}'/?*|'${TMPDIR:-/tmp}'/?*) return 0 ;;
    esac
    for s in $safe_targets; do
      case "/$t/" in */"$s"/*) return 0 ;; esac
    done
    return 1
  }
  unsafe=""
  set -f
  while IFS= read -r _seg; do
    printf '%s' "$_seg" | grep -qE '(^|\s)rm\s+(-[a-zA-Z]*r[a-zA-Z]*|--recursive)(\s|$)' || continue
    printf '%s' "$_seg" | grep -qE '(^|\s)git\s+rm\s' && continue
    for word in $(printf '%s' "$_seg" | sed -E 's/^(.*[[:space:]])?rm[[:space:]]+//'); do
      word=$(printf '%s' "$word" | tr -d "\"'")
      case "$word" in -*) continue ;; esac
      _rm_target_safe "$word" || unsafe="${unsafe:+$unsafe }$word"
    done
  done < <(_segments "$command")
  set +f

  if [ -n "$unsafe" ]; then
    hook_msg=$(jq -cn --arg u "$unsafe" --arg safe "$safe_targets" '{hookSpecificOutput:{permissionDecision:"deny"},systemMessage:("rm -r blocked for: " + $u + ". If tracked: git rm -r " + $u + ". Scratch data belongs under $TMPDIR/ or /tmp/ (deletable). Always safe: " + $safe + ". Anything else: ask the user.")}')
    echo "$hook_msg" >&2
    exit 2
  fi
fi

# Block all sleep commands — always a sign of polling instead of proper waiting
# (A leading `sleep N &&` was already rewritten away above.)
if echo "$_cmd_stripped" | grep -qE '(^|\s|&&|\|\||;)sleep\s'; then
  _sleep_tok='sleep[[:space:]]+[0-9.]+[smhd]?[[:space:]]*'
  _without=$(printf '%s' "$_raw_command" | sed -E -e "s/(&&|;)[[:space:]]*${_sleep_tok}(&&|;)/\\1/g" -e "s/[[:space:]]*(&&|;)[[:space:]]*${_sleep_tok}\$//")
  _hint=""
  printf '%s' "$_without" | grep -qE '(^|[[:space:]])sleep[[:space:]]' || _hint=" Rerun without it: $_without"
  hook_msg=$(jq -cn --arg h "$_hint" '{hookSpecificOutput:{permissionDecision:"deny"},systemMessage:("sleep banned. Wait on the event, not time: gh pr checks <n> --watch, gh run watch <id>, or Bash run_in_background + Monitor. If the user explicitly requested persistent background work, join or stop it before final status." + $h)}')
  echo "$hook_msg" >&2
  exit 2
fi

# git push --force / -f is rewritten to --force-with-lease above; this catches
# forms the rewrite cannot place (for example, -f bundled in a flag cluster).
if _segments "$_cmd_stripped" | grep -E '(^|\s)git\s+push\s' | grep -qE '\s(--force|-f)(\s|$)'; then
  echo '{"hookSpecificOutput":{"permissionDecision":"deny"},"systemMessage":"git push --force blocked. Replace --force/-f with --force-with-lease and rerun."}' >&2
  exit 2
fi

# Block git reset --hard; --keep resets the same way but refuses to discard
# uncommitted changes.
if echo "$_cmd_stripped" | grep -qE '(^|\s|&&|\|\||;)git\s+reset\s+--hard'; then
  _keep=$(printf '%s' "$_raw_command" | sed -E 's/(git[[:space:]]+reset[[:space:]]+)--hard/\1--keep/g')
  hook_msg=$(jq -cn --arg k "$_keep" '{hookSpecificOutput:{permissionDecision:"deny"},systemMessage:("git reset --hard blocked. Rerun with --keep (refuses to drop uncommitted work): " + $k)}')
  echo "$hook_msg" >&2
  exit 2
fi

# Block git hook bypass flag
# _cmd_for_check: commit message text (heredoc bodies included) never counts.
_cmd_no_quotes=$(echo "$_cmd_for_check" | sed 's/"[^"]*"//g; s/'"'"'[^'"'"']*'"'"'//g')
if echo "$_cmd_no_quotes" | grep -qE '(^|\s|&&|\|\||;)git\s+(commit|push|merge|rebase)\s' && echo "$_cmd_no_quotes" | grep -qE '\s--no-verify(\s|$)'; then
  _verified=$(printf '%s' "$_raw_command" | sed -E 's/[[:space:]]+--no-verify([[:space:]]|$)/\1/g')
  hook_msg=$(jq -cn --arg v "$_verified" '{hookSpecificOutput:{permissionDecision:"deny"},systemMessage:("--no-verify blocked. Fix the hook failure, then rerun: " + $v)}')
  echo "$hook_msg" >&2
  exit 2
fi

# Block git checkout . / git restore .
if echo "$_cmd_stripped" | grep -qE '(^|\s|&&|\|\||;)git\s+(checkout|restore)\s+\.\s*($|;|&&|\|\|)'; then
  echo '{"hookSpecificOutput":{"permissionDecision":"deny"},"systemMessage":"git checkout/restore . blocked. Use specific files."}' >&2
  exit 2
fi

# No permissionDecision: a rewrite must not auto-approve what would prompt.
if [ -n "$_rewrite_notes" ]; then
  printf '%s' "$input" | jq -c --arg c "$_raw_command" --arg n "${_rewrite_notes% }" '{hookSpecificOutput:{hookEventName:"PreToolUse",permissionDecisionReason:$n,additionalContext:$n,updatedInput:(.tool_input | .command = $c)}}'
fi
exit 0
