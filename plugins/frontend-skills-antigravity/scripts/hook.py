#!/usr/bin/env python3
"""Translate Antigravity command hooks (ACP, CLI, IDE, 2.0) to frontend-skills checks."""
import hashlib
import json
import os
from pathlib import Path
import re
import shutil
import subprocess
import sys
import tempfile
from typing import NamedTuple

SOURCE = Path(__file__).resolve().parents[1] / "source"
HOOKS = SOURCE / ".claude/hooks"
WRITE_TOOLS = {"write_file", "write_to_file"}
EDIT_ONLY_TOOLS = {"edit_file", "replace_file_content", "multi_replace_file_content"}
EDIT_TOOLS = WRITE_TOOLS | EDIT_ONLY_TOOLS
NOTE_LIMIT = 8000
REQUIRED = ("bash", "jq", "git")
# Leave headroom before Antigravity treats a timeout as a no-op.
CHECK_TIMEOUT = {
    "SessionStart": 7,
    "UserPromptSubmit": 6,
    "PreToolUse": 5,
    "PostToolBatch": 25,
    "Stop": 110,
}
COPYRIGHT_TRIGGER = re.compile(
    r"(copyright|spdx-filecopyrighttext|spdx-license-identifier|licensed under)",
    re.IGNORECASE,
)
# Normalize Antigravity single-underscore MCP names (mcp_<server>_<tool>)
# into the double-underscore convention expected by mcp-ban.sh.
MCP_SERVER_PREFIXES = (
    ("mcp_claude_ai_Atlassian_", "mcp__claude_ai_Atlassian__"),
    ("mcp_claude_ai_Gmail_", "mcp__claude_ai_Gmail__"),
    ("mcp_claude_ai_Google_Calendar_", "mcp__claude_ai_Google_Calendar__"),
    ("mcp_claude_ai_Google_Drive_", "mcp__claude_ai_Google_Drive__"),
    ("mcp_claude_ai_Buildkite_read-only_", "mcp__claude_ai_Buildkite_read-only__"),
    ("mcp_claude_ai_Box_", "mcp__claude_ai_Box__"),
    ("mcp_claude_ai_Microsoft_365_", "mcp__claude_ai_Microsoft_365__"),
    ("mcp_claude-in-chrome_", "mcp__claude-in-chrome__"),
    ("mcp_claude_in_chrome_", "mcp__claude-in-chrome__"),
    ("mcp_chrome-devtools_", "mcp__chrome-devtools__"),
    ("mcp_chrome_devtools_", "mcp__chrome-devtools__"),
    ("mcp_react-devtools_", "mcp__react-devtools__"),
    ("mcp_react_devtools_", "mcp__react_devtools__"),
    ("mcp_playwright_", "mcp__playwright__"),
    ("mcp_blacksmith_", "mcp__blacksmith__"),
    ("mcp_buildkite_", "mcp__buildkite__"),
    ("mcp_box_", "mcp__box__"),
    ("mcp_microsoft365_", "mcp__microsoft365__"),
    ("mcp_m365_", "mcp__m365__"),
    ("mcp_launchdarkly_", "mcp__launchdarkly__"),
)
CONSECUTIVE_FAILURE_THRESHOLD = 3


class Result(NamedTuple):
    status: int
    message: str
    updated_command: str | None


def digest(value):
    return hashlib.sha256(value.encode()).hexdigest()[:24]


def message(text):
    return {"systemMessage": {"systemMessage": text[:NOTE_LIMIT]}}


def inject(text):
    return {"injectSteps": [message(text)]} if text else {}


def absolute(value, base=None):
    if not isinstance(value, str) or not value:
        raise ValueError("Missing tool path")
    path = Path(value)
    if not path.is_absolute():
        if base is None:
            raise ValueError("Expected an absolute workspace path")
        path = base / path
    return path.resolve()


def normalize_mcp_name(name):
    if name.startswith("mcp__"):
        return name
    for prefix, canonical in MCP_SERVER_PREFIXES:
        if name.startswith(prefix):
            return canonical + name[len(prefix):]
    # Generic fallback for LaunchDarkly-like server names: mcp_<server>_<tool>
    if name.startswith("mcp_") and "launchdarkly" in name.lower():
        rest = name[len("mcp_"):]
        if "_" in rest:
            server, tool = rest.split("_", 1)
            return f"mcp__{server}__{tool}"
    return name


def extract_edit_payload(name, args, single_root):
    raw_path = args.get("Path") or args.get("TargetFile")
    file_path = absolute(raw_path, single_root)
    tool_name = "Write" if name in WRITE_TOOLS else "Edit"
    tool_input = {"file_path": str(file_path)}
    added_text = ""

    if tool_name == "Write":
        content = args.get("Content")
        if not isinstance(content, str):
            content = args.get("CodeContent")
        if isinstance(content, str):
            tool_input["content"] = content
            added_text = content
    elif name == "edit_file":
        if isinstance(args.get("Target"), str):
            tool_input["old_string"] = args["Target"]
        if isinstance(args.get("Replacement"), str):
            tool_input["new_string"] = args["Replacement"]
            added_text = args["Replacement"]
    elif name == "replace_file_content":
        if isinstance(args.get("TargetContent"), str):
            tool_input["old_string"] = args["TargetContent"]
        if isinstance(args.get("ReplacementContent"), str):
            tool_input["new_string"] = args["ReplacementContent"]
            added_text = args["ReplacementContent"]
    elif name == "multi_replace_file_content":
        chunks = args.get("ReplacementChunks")
        if not isinstance(chunks, list) or not chunks:
            raise ValueError("Missing Antigravity ReplacementChunks")
        edits = []
        for chunk in chunks:
            if not isinstance(chunk, dict):
                raise ValueError("Invalid Antigravity replacement chunk")
            old, new = chunk.get("TargetContent"), chunk.get("ReplacementContent")
            if not isinstance(old, str) or not isinstance(new, str):
                raise ValueError("Missing Antigravity chunk TargetContent or ReplacementContent")
            edits.append({"old_string": old, "new_string": new})
        tool_name = "MultiEdit"
        tool_input["edits"] = edits
        added_text = "\n".join(edit["new_string"] for edit in edits)

    return file_path, tool_name, tool_input, added_text


class Session:
    def __init__(self, payload):
        self.payload = payload
        conversation = payload.get("conversationId")
        if not isinstance(conversation, str) or not conversation:
            raise ValueError("Missing Antigravity conversationId")
        roots = payload.get("workspacePaths")
        if not isinstance(roots, list) or not roots:
            raise ValueError("Missing Antigravity workspacePaths")
        self.roots = list(dict.fromkeys(absolute(path) for path in roots))
        if not all(path.is_dir() for path in self.roots):
            raise ValueError("Workspace is not available on this machine")
        self.id = "agy-" + digest(conversation + "\n" + "\n".join(map(str, self.roots)))
        self.state = Path("/tmp") / f"hook-session-{self.id}"
        self.state.mkdir(mode=0o700, exist_ok=True)
        if self.state.is_symlink() or self.state.stat().st_uid != os.getuid():
            raise ValueError("Unsafe harness session directory")

    def single_root(self):
        return self.roots[0] if len(self.roots) == 1 else None

    def run(self, script, cwd, event, **fields):
        env = {
            **os.environ,
            # The shared library uses these names internally. Keep this session
            # isolated from any enclosing Claude/Codex process.
            "CLAUDE_PLUGIN_ROOT": str(SOURCE),
            "CLAUDE_SESSION_ID": self.id,
            "CLAUDE_ENV_FILE": "",
            "PR_REVIEW_AUTO_RUN": "1",  # Do not register as a Claude session.
            "HOOKS_FAIL_CLOSED": "1",
        }
        env.pop("CODEX_SESSION_ID", None)
        data = {"cwd": str(cwd), "session_id": self.id, "hook_event_name": event, **fields}
        child = subprocess.run(
            [str(HOOKS / script)], input=json.dumps(data), cwd=cwd, env=env,
            text=True, capture_output=True, timeout=CHECK_TIMEOUT[event],
        )
        output = child.stderr if child.returncode and child.stderr.strip() else child.stdout
        if not output.strip():
            return Result(child.returncode, "", None)
        try:
            response = json.loads(output)
        except json.JSONDecodeError:
            return Result(child.returncode, output.strip(), None)
        specific = response.get("hookSpecificOutput", {})
        reason = (
            response.get("reason") or response.get("systemMessage")
            or specific.get("additionalContext") or specific.get("permissionDecisionReason")
        )
        command = specific.get("updatedInput", {}).get("command")
        if specific.get("permissionDecision") == "deny" or response.get("decision") == "block":
            return Result(2, reason or "", None)
        return Result(child.returncode, reason or "", command)

    def workspace(self, path):
        for root in sorted(self.roots, key=lambda item: len(item.parts), reverse=True):
            if path.is_relative_to(root):
                return root
        raise ValueError(f"Tool path is outside the active workspaces: {path}")

    def queue_note(self, text):
        if text:
            with tempfile.NamedTemporaryFile(mode="w", encoding="utf-8", dir=self.state,
                                            delete=False) as note:
                note.write(text[:NOTE_LIMIT])
            Path(note.name).rename(Path(note.name + ".agy-note"))

    def take_notes(self):
        notes = []
        for path in sorted(self.state.glob("*.agy-note")):
            try:
                notes.append(path.read_text(encoding="utf-8")[:NOTE_LIMIT])
                path.unlink()
            except FileNotFoundError:
                continue
        return "\n\n".join(notes)[:NOTE_LIMIT]

    def resolve_cwd(self, args_cwd=None):
        raw = args_cwd or self.payload.get("cwd")
        if raw:
            cwd = absolute(raw, self.single_root())
            self.workspace(cwd)
            return cwd
        if len(self.roots) == 1:
            return self.roots[0]
        raise ValueError("Missing workspace cwd for multi-root session")

    def start(self):
        prerequisites = [command for command in REQUIRED if not shutil.which(command)]
        if prerequisites:
            return inject(f"Frontend Skills hooks are not ready: missing {', '.join(prerequisites)}.")
        if len(self.roots) != 1:
            return inject("Frontend Skills: Stop checks require a single workspace; tool checks still apply.")
        return inject(self.run("session-env.sh", self.roots[0], "SessionStart",
                               model=self.payload.get("modelName")).message)

    def pre_invocation(self):
        # Trajectory step counts change inside a turn. Keep the prompt marker
        # until an idle Stop accepts completion (not a repair continuation).
        prompt = self.payload.get("lastUserInput")
        if not isinstance(prompt, str) or not prompt.strip():
            return {}
        key = digest(prompt)
        marker = self.state / "agy-last-prompt"
        if marker.is_file() and marker.read_text(encoding="utf-8") == key:
            return {}
        marker.write_text(key, encoding="utf-8")
        (self.state / "agy-stop-retry").unlink(missing_ok=True)
        (self.state / "agy-consecutive-failures").unlink(missing_ok=True)

        if any(not shutil.which(command) for command in REQUIRED):
            return {}
        try:
            cwd = self.resolve_cwd()
        except ValueError:
            return {}

        notes = []
        for script in ("user-prompt-context.sh", "intent-detect.sh"):
            result = self.run(script, cwd, "UserPromptSubmit", prompt=prompt)
            if result.message:
                notes.append(result.message)
        return inject("\n\n".join(notes))

    def record_shell_outcome(self, failed):
        counter = self.state / "agy-consecutive-failures"
        if not failed:
            counter.unlink(missing_ok=True)
            return
        try:
            count = int(counter.read_text(encoding="utf-8").strip())
        except (FileNotFoundError, ValueError):
            count = 0
        count += 1
        counter.write_text(str(count), encoding="utf-8")
        if count >= CONSECUTIVE_FAILURE_THRESHOLD:
            self.queue_note(
                f"[consecutive-failure] {count} consecutive run_command failures. "
                "Stop retrying the same command; inspect the root cause, verify paths/env, "
                "or challenge your premise before the next attempt."
            )

    def tool(self, before):
        tool = self.payload["toolCall"]
        name, args = tool["name"], tool.get("args") or {}

        # Fast-allow T3 Code host MCP tools without spawning Bash.
        if name.startswith("mcp_t3-code_") or name.startswith("mcp__t3-code__"):
            return {"decision": "allow"} if before else {}

        if name == "run_command" and not before:
            self.record_shell_outcome(bool(self.payload.get("error")))
            return {}

        missing = [command for command in REQUIRED if not shutil.which(command)]
        if missing:
            raise ValueError(f"Missing dependencies: {', '.join(missing)}")

        if name == "run_command" and before:
            cwd = self.resolve_cwd(args.get("Cwd"))
            command = args.get("CommandLine")
            if not isinstance(command, str) or not command.strip():
                raise ValueError("Missing Antigravity CommandLine")
            result = self.run("pre-bash.sh", cwd, "PreToolUse",
                              tool_name="Bash", tool_input={"command": command})
            if result.status:
                return {"decision": "deny", "reason": result.message or "Frontend Skills shell check failed"}
            self.queue_note(result.message)
            if result.updated_command and result.updated_command != command:
                return {"decision": "allow", "overwrite": {"CommandLine": result.updated_command}}
            return {"decision": "allow"}

        if before and (name.startswith("mcp_") or name.startswith("mcp__")):
            canonical = normalize_mcp_name(name)
            cwd = self.roots[0]
            result = self.run("mcp-ban.sh", cwd, "PreToolUse",
                              tool_name=canonical, tool_input=args)
            if result.status:
                return {"decision": "deny", "reason": result.message or "MCP server blocked; use CLI equivalent"}
            return {"decision": "allow"}

        if name not in EDIT_TOOLS:
            return {"decision": "allow"} if before else {}
        if not before and self.payload.get("error"):
            return {}

        file_path, tool_name, tool_input, added_text = extract_edit_payload(
            name, args, self.single_root()
        )
        cwd = self.workspace(file_path)

        if before:
            checks = []
            # Fast-path: copyright-check only triggers on license/copyright headers;
            # bend-laws-guard only checks .bend files. Run copyright-check defensively
            # if edit text was omitted from the host payload.
            if not added_text or COPYRIGHT_TRIGGER.search(added_text):
                checks.append("copyright-check.sh")
            if file_path.suffix == ".bend":
                checks.append("bend-laws-guard.sh")
            for script in checks:
                result = self.run(script, cwd, "PreToolUse", tool_name=tool_name, tool_input=tool_input)
                if result.status:
                    return {"decision": "deny", "reason": result.message or f"{script} failed"}
                self.queue_note(result.message)
            return {"decision": "allow"}

        result = self.run("post-tool-batch.sh", cwd, "PostToolBatch",
                          tool_calls=[{"tool_name": tool_name, "tool_input": tool_input}])
        self.queue_note(result.message or ("Frontend Skills edit checks failed." if result.status else ""))
        (self.state / "agy-edited").touch()
        return {}

    def stop(self):
        reason = self.payload.get("terminationReason")
        if (len(self.roots) != 1 or self.payload.get("fullyIdle") is not True
                or reason not in {"NO_TOOL_CALL", "model_stop"}):
            return {}
        edited = (self.state / "agy-edited").is_file()
        endpoint_active = (self.state / "task-endpoint").is_file()
        if not edited and not endpoint_active:
            return {}

        continuation_active = self.payload.get("continuationActive") is True
        result = self.run(
            "stop-dispatch.sh",
            self.roots[0],
            "Stop",
            stop_hook_active=continuation_active,
        )
        note = "\n\n".join(filter(None, (self.take_notes(), result.message)))
        if result.status and not note:
            note = f"Frontend Skills Stop checks exited {result.status} without diagnostics."
        if result.status == 0:
            if note:
                print(note, file=sys.stderr)
            (self.state / "agy-edited").unlink(missing_ok=True)
            (self.state / "agy-stop-retry").unlink(missing_ok=True)
            return {}

        # Antigravity natively signals continuationActive on Stop retries.
        # Keep the prompt-hash fallback for hosts that omit continuationActive.
        if continuation_active:
            print("Frontend Skills: Stop continuation exhausted; diagnostics are not a pass.\n" + note,
                  file=sys.stderr)
            return {}
        key = digest(str(self.payload.get("lastUserInput", "")))
        marker = self.state / "agy-stop-retry"
        if "continuationActive" not in self.payload and marker.is_file() and marker.read_text(encoding="utf-8") == key:
            print("Frontend Skills: Stop retry exhausted; diagnostics are not a pass.\n" + note,
                  file=sys.stderr)
            return {}
        marker.write_text(key, encoding="utf-8")
        return {"decision": "continue", "reason": note[:NOTE_LIMIT]}

    def dispatch(self, event):
        if event == "SessionStart":
            return self.start()
        if event == "PreInvocation":
            return self.pre_invocation()
        if event in {"PreToolUse", "PostToolUse"}:
            return self.tool(event == "PreToolUse")
        if event == "PostInvocation":
            return inject(self.take_notes())
        if event == "Stop":
            result = {}
            try:
                result = self.stop()
                return result
            finally:
                if self.payload.get("fullyIdle") is True and result.get("decision") != "continue":
                    (self.state / "agy-last-prompt").unlink(missing_ok=True)
        raise ValueError(f"Unsupported hook event: {event}")


def main(event):
    try:
        result = Session(json.load(sys.stdin)).dispatch(event)
    except (AttributeError, KeyError, ValueError, TypeError, OSError, subprocess.SubprocessError) as exc:
        text = f"Frontend Skills {event}: checks unavailable: {exc}"
        print(text, file=sys.stderr)
        # Nonzero hook exits are ignored by Antigravity. Give the host a
        # syntactically valid denial instead of silently allowing an unchecked tool.
        result = {"decision": "deny", "reason": text} if event == "PreToolUse" else {}
    print(json.dumps(result))


if __name__ == "__main__":
    main(sys.argv[1])
