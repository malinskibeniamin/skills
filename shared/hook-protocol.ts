#!/usr/bin/env bun
// Copyright 2026 Beniamin Malinski
//
// Typed hook protocol layer: the single owner of "which stream, which exit
// code, which JSON shape" for every hook tier (issue #60 P1 structural).
//
// allow: json-raw — this file IS the validation layer for hook stdin; it is
// dependency-free by design (no zod in shell-adjacent shared/), narrows via
// the asHookStdin type guard, and every field read is optional-chained.
//
// Why this exists: the shell emitters shipped two whole bug classes that a
// type system makes impossible — JSON posted to the stream the harness never
// parses (exit-0 stderr), and hand-rolled string interpolation producing
// invalid JSON. Both were found live in PR #61. Here the payload shapes are
// types and the stream/exit-code pairing is a lookup table.
//
// Contract (Claude Code, mirrored by the Codex adapter):
//   exit 0 — JSON parsed from STDOUT (systemMessage / hookSpecificOutput)
//   exit 2 — block/deny reason read from STDERR
//
// CLI (called from _hook-lib.sh when bun is available; shell fallback
// otherwise, HOOK_PROTOCOL=shell forces it):
//   hook-protocol.ts emit <tier> <message>
//     tier: warn | nudge | block | block-strict | deny | stop-block | context
//   hook-protocol.ts parse                     # stdin JSON -> shell vars
//
// Latency budget (explicit decision): each typed emit pays one bun process
// start, ~+15ms over the pure-shell path. Emits fire only on violations --
// the hot no-violation path never reaches this file.
//
// `parse` prints NUL-safe, single-quoted shell assignments for the fields
// the shell lib actually consumes, so `eval "$(... parse)"` can never break
// on quotes/newlines in tool input.

type Tier =
  | "warn"
  | "nudge"
  | "block"
  | "block-strict"
  | "deny"
  | "stop-block"
  | "context";

interface SystemMessagePayload {
  suppressOutput: true;
  systemMessage: string;
}

interface DenyPayload {
  hookSpecificOutput: { permissionDecision: "deny" };
  systemMessage: string;
}

interface StopBlockPayload {
  decision: "block";
  reason: string;
}

interface ContextPayload {
  hookSpecificOutput: { additionalContext: string };
}

type EmitPayload =
  | SystemMessagePayload
  | DenyPayload
  | StopBlockPayload
  | ContextPayload;

type StdoutTier = "warn" | "nudge" | "context";

type TierSpec<T extends Tier> = {
  build: (message: string) => EmitPayload;
} & (T extends StdoutTier
  ? { stream: "stdout"; exit: 0 }
  : { stream: "stderr"; exit: 2 });

// The whole channel contract in one table. A new tier MUST declare its
// stream and exit code here — there is no way to emit without them.
const TIERS = {
  warn: {
    stream: "stdout",
    exit: 0,
    build: (m) => ({ suppressOutput: true, systemMessage: m }),
  },
  nudge: {
    stream: "stdout",
    exit: 0,
    build: (m) => ({ suppressOutput: true, systemMessage: `[nudge] ${m}` }),
  },
  context: {
    stream: "stdout",
    exit: 0,
    build: (m) => ({ hookSpecificOutput: { additionalContext: m } }),
  },
  block: {
    stream: "stderr",
    exit: 2,
    build: (m) => ({ suppressOutput: true, systemMessage: m }),
  },
  "block-strict": {
    stream: "stderr",
    exit: 2,
    build: (m) => ({ suppressOutput: true, systemMessage: `[STRICT] ${m}` }),
  },
  deny: {
    stream: "stderr",
    exit: 2,
    build: (m) => ({
      hookSpecificOutput: { permissionDecision: "deny" },
      systemMessage: m,
    }),
  },
  "stop-block": {
    stream: "stderr",
    exit: 2,
    build: (m) => ({ decision: "block", reason: m }),
  },
} satisfies { [T in Tier]: TierSpec<T> };

function emit(tier: Tier, message: string): never {
  const spec = TIERS[tier];
  const line = JSON.stringify(spec.build(message));
  if (spec.stream === "stdout") {
    console.log(line);
  } else {
    console.error(line);
  }
  process.exit(spec.exit);
}

// ── Inbound payloads ─────────────────────────────────────────────

interface HookStdin {
  session_id?: string;
  hook_event_name?: string;
  tool_name?: string;
  filename?: string; // FileChanged
  tool_input?: {
    file_path?: string;
    command?: string | string[];
    content?: string;
    old_string?: string;
    new_string?: string;
  };
}

// Narrowing guard: stdin is attacker-adjacent text, not a trusted object.
// Only a JSON object passes; scalars/arrays are rejected so downstream
// optional-chaining reads stay within the declared shape.
function asHookStdin(value: unknown): HookStdin | null {
  if (typeof value !== "object" || value === null || Array.isArray(value)) {
    return null;
  }
  return value as HookStdin;
}

function shellQuote(value: string): string {
  // Single-quote with the classic '\'' escape; strip NUL which no shell
  // variable can carry.
  return `'${value.replaceAll("\0", "").replaceAll("'", `'\\''`)}'`;
}

async function parse(): Promise<never> {
  let raw = "";
  try {
    raw = await Bun.stdin.text();
  } catch {
    process.exit(0);
  }
  let data: HookStdin;
  try {
    const narrowed = asHookStdin(JSON.parse(raw));
    if (narrowed === null) process.exit(0);
    data = narrowed;
  } catch {
    // Not JSON — nothing to export; callers treat empty output as skip.
    process.exit(0);
  }
  // Every exported field is coerced: JSON that is valid but wrong-typed
  // ({"session_id":7}, {"tool_input":{"file_path":{}}}) must export as ""
  // -- never crash before an eval'ing caller enforces anything.
  const str = (v: unknown): string => (typeof v === "string" ? v : "");
  const rawCommand = data.tool_input?.command;
  const command =
    typeof rawCommand === "string"
      ? rawCommand
      : Array.isArray(rawCommand)
        ? rawCommand
            .filter((c): c is string => typeof c === "string")
            .join("\n")
        : "";
  const fields: Record<string, string> = {
    hp_session_id: str(data.session_id),
    hp_event: str(data.hook_event_name),
    hp_tool_name: str(data.tool_name),
    hp_file_path: str(data.tool_input?.file_path) || str(data.filename),
    hp_command: command,
  };
  const out = Object.entries(fields)
    .map(([k, v]) => `${k}=${shellQuote(v)}`)
    .join("\n");
  console.log(out);
  process.exit(0);
}

// ── CLI dispatch ─────────────────────────────────────────────────

const [, , cmd, arg1, arg2] = process.argv;

function isTier(value: string | undefined): value is Tier {
  // Object.hasOwn, not `in`: the prototype chain must not mint tiers
  // ("toString" would reach spec.build as undefined and crash).
  return value !== undefined && Object.hasOwn(TIERS, value);
}

switch (cmd) {
  case "emit": {
    if (!isTier(arg1) || arg2 === undefined) {
      console.error("usage: hook-protocol.ts emit <tier> <message>");
      process.exit(2);
    }
    emit(arg1, arg2);
    break;
  }
  case "parse": {
    await parse();
    break;
  }
  default: {
    console.error("usage: hook-protocol.ts emit|parse ...");
    process.exit(2);
  }
}
