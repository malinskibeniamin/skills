#!/usr/bin/env python3
"""Read native Codex allowance and gate host events without starting a model turn."""

import json
import math
import os
import select
import subprocess
import sys
import time


class GuardError(Exception):
    pass


def number(value, low, high):
    if isinstance(value, bool):
        raise GuardError("invalid quota guard configuration or reading")
    value = float(value)
    if not math.isfinite(value) or not low <= value <= high:
        raise GuardError("invalid quota guard configuration or reading")
    return value


class CodexReader:
    def __init__(self, timeout):
        self.deadline = time.monotonic() + timeout
        self.buffer = b""
        self.received = 0
        self.sequence = 0
        self.process = subprocess.Popen(
            ["codex", "app-server"],
            stdin=subprocess.PIPE,
            stdout=subprocess.PIPE,
            stderr=subprocess.DEVNULL,
        )

    def close(self):
        if self.process.poll() is None:
            self.process.terminate()
            try:
                self.process.wait(timeout=0.5)
            except subprocess.TimeoutExpired:
                self.process.kill()
                self.process.wait(timeout=0.5)
        for stream in (self.process.stdin, self.process.stdout):
            if stream is not None:
                stream.close()

    def send(self, message):
        if self.process.stdin is None:
            raise GuardError("native quota unavailable")
        self.process.stdin.write((json.dumps(message) + "\n").encode())
        self.process.stdin.flush()

    def call(self, method, params=None):
        self.sequence += 1
        identity = self.sequence
        request = {"id": identity, "method": method}
        if params is not None:
            request["params"] = params
        self.send(request)
        while True:
            while b"\n" in self.buffer:
                line, self.buffer = self.buffer.split(b"\n", 1)
                message = json.loads(line)
                if not isinstance(message, dict):
                    raise GuardError("native quota unavailable")
                if message.get("id") != identity:
                    continue
                if "error" in message or not isinstance(message.get("result"), dict):
                    raise GuardError("native quota unavailable")
                return message["result"]
            remaining = self.deadline - time.monotonic()
            if remaining <= 0 or self.process.stdout is None:
                raise GuardError("native quota unavailable (collector timeout)")
            ready, _, _ = select.select([self.process.stdout], [], [], remaining)
            if not ready:
                raise GuardError("native quota unavailable (collector timeout)")
            chunk = os.read(self.process.stdout.fileno(), 65536)
            self.received += len(chunk)
            if not chunk or self.received > 524288:
                raise GuardError("native quota unavailable (invalid response)")
            self.buffer += chunk


def check_account(result, expected):
    account = result.get("account")
    if (
        result.get("requiresOpenaiAuth") is not True
        or not isinstance(account, dict)
        or account.get("type") != "chatgpt"
        or not isinstance(account.get("email"), str)
        or account["email"].casefold() != expected.casefold()
    ):
        raise GuardError("selected native account does not match the configured ChatGPT account")


def check_limits(result, threshold):
    buckets = []
    if "rateLimitsByLimitId" in result:
        mapped = result["rateLimitsByLimitId"]
        if not isinstance(mapped, dict) or not mapped:
            raise GuardError("native quota unavailable (missing allowance buckets)")
        buckets.extend(mapped.values())
    legacy = result.get("rateLimits")
    if legacy is not None:
        buckets.append(legacy)
    if not buckets:
        raise GuardError("native quota unavailable (missing allowance windows)")
    now = time.time()
    for bucket in buckets:
        if not isinstance(bucket, dict):
            raise GuardError("native quota unavailable (invalid allowance bucket)")
        if bucket.get("rateLimitReachedType") is not None:
            raise GuardError("an allowance limit is already reached; wait for reset")
        windows = [bucket.get(key) for key in ("primary", "secondary")]
        present = [window for window in windows if window is not None]
        if not present:
            raise GuardError("native quota unavailable (missing allowance windows)")
        for window in present:
            if not isinstance(window, dict):
                raise GuardError("native quota unavailable (invalid allowance window)")
            used = window.get("usedPercent")
            reset = window.get("resetsAt")
            if (
                isinstance(used, bool)
                or not isinstance(used, (int, float))
                or isinstance(reset, bool)
                or not isinstance(reset, int)
                or reset <= now
            ):
                raise GuardError("native quota unavailable (invalid or stale allowance)")
            used = number(used, 0, 100)
            if used >= threshold:
                raise GuardError(
                    f"allowance is {used:g}% used (threshold {threshold:g}%); wait for reset"
                )


def check(provider):
    if os.environ.get("HARNESS_QUOTA_GUARD") != "1":
        raise GuardError("set HARNESS_QUOTA_GUARD to 0 or 1")
    if provider != "codex":
        raise GuardError("Claude pre-request quota collection is unsupported; no fresh allowance was assumed")
    expected = os.environ.get("HARNESS_QUOTA_GUARD_ACCOUNT", "").strip()
    if not expected or "@" not in expected or any(c.isspace() for c in expected):
        raise GuardError("set HARNESS_QUOTA_GUARD_ACCOUNT to the native ChatGPT account email")
    threshold = number(os.environ.get("HARNESS_QUOTA_GUARD_THRESHOLD", "90"), 1, 99)
    timeout = number(os.environ.get("HARNESS_QUOTA_GUARD_TIMEOUT", "5"), 0.1, 10)
    if any(os.environ.get(key) for key in (
        "OPENAI_API_KEY", "CODEX_API_KEY", "OPENAI_BASE_URL", "CHATGPT_BASE_URL"
    )):
        raise GuardError("API credentials or endpoint overrides are unsupported by the native quota guard")
    reader = CodexReader(timeout)
    try:
        reader.call("initialize", {
            "clientInfo": {"name": "frontend_skills_quota_guard", "version": "1"}
        })
        reader.send({"method": "initialized"})
        config = reader.call("config/read", {"includeLayers": False}).get("config")
        if (
            not isinstance(config, dict)
            or config.get("model_provider") not in (None, "openai")
            or config.get("openai_base_url")
            or config.get("chatgpt_base_url") not in (
                None, "", "https://chatgpt.com/backend-api", "https://chatgpt.com/backend-api/"
            )
        ):
            raise GuardError("custom providers and gateways have no verified native quota binding")
        check_account(reader.call("account/read", {"refreshToken": False}), expected)
        limits = reader.call("account/rateLimits/read")
        check_account(reader.call("account/read", {"refreshToken": False}), expected)
        check_limits(limits, threshold)
    finally:
        reader.close()


def block(event, reason):
    reason = "Quota guard blocked: " + reason + ". No paid fallback was selected."
    if event == "PreToolUse":
        payload = {"hookSpecificOutput": {
            "hookEventName": event,
            "permissionDecision": "deny",
            "permissionDecisionReason": reason,
        }}
    elif event == "PostToolUse":
        payload = {"continue": False, "stopReason": reason}
    else:
        payload = {"decision": "block", "reason": reason}
    print(json.dumps(payload))


def main():
    if os.environ.get("HARNESS_QUOTA_GUARD", "0") in ("", "0"):
        return
    supported = ("UserPromptSubmit", "PreToolUse", "PostToolUse")
    event = sys.argv[2] if len(sys.argv) > 2 and sys.argv[2] in supported else "UserPromptSubmit"
    try:
        raw = sys.stdin.buffer.read(262145)
        if len(raw) > 262144:
            raise GuardError("hook input is too large to validate")
        data = json.loads(raw)
        if not isinstance(data, dict):
            raise GuardError("invalid hook input")
        event = data.get("hook_event_name", "UserPromptSubmit")
        if event not in supported:
            raise GuardError("unsupported quota guard checkpoint")
        check(sys.argv[1] if len(sys.argv) >= 2 else "unsupported")
    except GuardError as error:
        block(event, str(error))
    except Exception:
        # A hook failure must not allow work or reflect secret-bearing RPC output.
        block(event, "native quota unavailable; verify the native login and collector")


if __name__ == "__main__":
    main()
