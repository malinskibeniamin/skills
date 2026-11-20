#!/usr/bin/env python3
"""Translate Antigravity command hooks to the shared frontend-skills checks."""
import hashlib
import json
import os
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile
from typing import NamedTuple

SOURCE = Path(__file__).resolve().parents[1] / "source"
HOOKS = SOURCE / ".claude/hooks"
EDIT_TOOLS = {"write_to_file", "replace_file_content", "multi_replace_file_content"}
NOTE_LIMIT = 8000
REQUIRED = ("bash", "jq", "git")
# Leave time to return a valid response before Antigravity treats a timeout
# as a no-op. Pre-edit can run two checks under one host deadline.
CHECK_TIMEOUT = {"SessionStart": 7, "PreToolUse": 5, "PostToolBatch": 25, "Stop": 110}


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

    def run(self, script, cwd, event, **fields):
        env = {
            **os.environ,
            # The legacy library uses these names internally. Keep this new
            # session isolated from any enclosing Claude/Codex process.
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

    def start(self):
        prerequisites = [command for command in REQUIRED if not shutil.which(command)]
        if prerequisites:
            return inject(f"Frontend Skills hooks are not ready: missing {', '.join(prerequisites)}.")
        if len(self.roots) != 1:
            return inject("Frontend Skills: Stop checks require a single workspace; tool checks still apply.")
        return inject(self.run("session-env.sh", self.roots[0], "SessionStart",
                               model=self.payload.get("modelName")).message)

    def tool(self, before):
        missing = [command for command in REQUIRED if not shutil.which(command)]
        if missing:
            raise ValueError(f"Missing dependencies: {', '.join(missing)}")
        tool = self.payload["toolCall"]
        name, args = tool["name"], tool["args"]
        if name == "run_command" and before:
            cwd = absolute(args["Cwd"], self.roots[0] if len(self.roots) == 1 else None)
            self.workspace(cwd)
            command = args["CommandLine"]
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
        if name not in EDIT_TOOLS:
            return {"decision": "allow"} if before else {}
        if not before and self.payload.get("error"):
            return {}
        file_path = absolute(args["TargetFile"], self.roots[0] if len(self.roots) == 1 else None)
        cwd = self.workspace(file_path)
        tool_name = "Write" if name == "write_to_file" else "Edit"
        tool_input = {"file_path": str(file_path)}
        if tool_name == "Write" and isinstance(args.get("CodeContent"), str):
            tool_input["content"] = args["CodeContent"]
        if before:
            for script in ("copyright-check.sh", "bend-laws-guard.sh"):
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
        if (len(self.roots) != 1 or self.payload.get("fullyIdle") is not True
                or self.payload.get("terminationReason") != "model_stop"
                or not (self.state / "agy-edited").is_file()):
            return {}
        result = self.run("stop-dispatch.sh", self.roots[0], "Stop")
        note = "\n\n".join(filter(None, (self.take_notes(), result.message)))
        if result.status and not note:
            note = f"Frontend Skills Stop checks exited {result.status} without diagnostics."
        if result.status == 0:
            if note:
                print(note, file=sys.stderr)
            (self.state / "agy-edited").unlink(missing_ok=True)
            (self.state / "agy-stop-retry").unlink(missing_ok=True)
            return {}
        # The host does not provide Claude's stop_hook_active bit. Request at
        # most one continuation for an unchanged prompt until checks are clean.
        key = digest(str(self.payload.get("lastUserInput", "")))
        marker = self.state / "agy-stop-retry"
        if marker.is_file() and marker.read_text() == key:
            print("Frontend Skills: Stop retry exhausted; diagnostics are not a pass.\n" + note,
                  file=sys.stderr)
            return {}
        marker.write_text(key)
        return {"decision": "continue", "reason": note[:NOTE_LIMIT]}

    def dispatch(self, event):
        if event == "SessionStart":
            return self.start()
        if event in {"PreToolUse", "PostToolUse"}:
            return self.tool(event == "PreToolUse")
        if event == "PostInvocation":
            return inject(self.take_notes())
        if event == "Stop":
            return self.stop()
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
