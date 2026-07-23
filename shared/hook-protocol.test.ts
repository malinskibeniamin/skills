// Copyright 2026 Beniamin Malinski
//
// Unit tests for the typed hook protocol layer. The bash Channel Contracts
// suite pins the lib-level behavior; this pins the CLI surface itself:
// stream/exit per tier, escaping, parse coercion, and shell-quote safety.

import { describe, expect, test } from "bun:test";
import { unlinkSync } from "node:fs";

const ENTRY = new URL("./hook-protocol.ts", import.meta.url).pathname;
const TSC = new URL("../node_modules/.bin/tsc", import.meta.url).pathname;

function run(
  args: string[],
  stdin = "",
): {
  code: number;
  stdout: string;
  stderr: string;
} {
  const proc = Bun.spawnSync(["bun", ENTRY, ...args], {
    stdin: Buffer.from(stdin),
  });
  return {
    code: proc.exitCode,
    stdout: proc.stdout.toString(),
    stderr: proc.stderr.toString(),
  };
}

const HOSTILE = 'say "hi" and\nthen `stop` $(now) \\ done';

describe("emit: stream/exit contract per tier", () => {
  const cases: Array<[string, number, "stdout" | "stderr"]> = [
    ["warn", 0, "stdout"],
    ["nudge", 0, "stdout"],
    ["context", 0, "stdout"],
    ["block", 2, "stderr"],
    ["block-strict", 2, "stderr"],
    ["deny", 2, "stderr"],
    ["stop-block", 2, "stderr"],
  ];
  for (const [tier, code, stream] of cases) {
    test(`${tier} -> exit ${code}, payload on ${stream} only`, () => {
      const extra = tier === "context" ? ["UserPromptSubmit"] : [];
      const r = run(["emit", tier, HOSTILE, ...extra]);
      expect(r.code).toBe(code);
      const payload = stream === "stdout" ? r.stdout : r.stderr;
      const other = stream === "stdout" ? r.stderr : r.stdout;
      expect(other).toBe("");
      expect(() => JSON.parse(payload)).not.toThrow();
    });
  }

  test("hostile message round-trips through JSON exactly", () => {
    const r = run(["emit", "warn", HOSTILE]);
    expect(JSON.parse(r.stdout).systemMessage).toBe(HOSTILE);
  });

  test("nudge and block-strict carry their prefixes", () => {
    expect(JSON.parse(run(["emit", "nudge", "x"]).stdout).systemMessage).toBe(
      "[nudge] x",
    );
    expect(
      JSON.parse(run(["emit", "block-strict", "x"]).stderr).systemMessage,
    ).toBe("[STRICT] x");
  });

  test("context carries the required hookEventName", () => {
    const r = run(["emit", "context", HOSTILE, "PostCompact"]);
    expect(r.code).toBe(0);
    const payload = JSON.parse(r.stdout);
    expect(payload.hookSpecificOutput.hookEventName).toBe("PostCompact");
    expect(payload.hookSpecificOutput.additionalContext).toBe(HOSTILE);
  });

  test("context without an event name is a usage error, not a payload", () => {
    // The harness contract requires hookEventName next to additionalContext;
    // a payload without it must never reach the live stream.
    const r = run(["emit", "context", "some context"]);
    expect(r.code).toBe(2);
    expect(r.stdout).toBe("");
    expect(r.stderr).toContain("usage:");
  });

  test("inherited property names are not tiers", () => {
    for (const bad of [
      "toString",
      "constructor",
      "__proto__",
      "hasOwnProperty",
    ]) {
      const r = run(["emit", bad, "x"]);
      expect(r.code).toBe(2);
      expect(r.stderr).toContain("usage:");
      expect(r.stdout).toBe("");
    }
  });

  test("typecheck rejects warn on the blocking channel", async () => {
    const source = await Bun.file(ENTRY).text();
    const validWarn = `  warn: {\n    stream: "stdout",\n    exit: 0,`;
    const invalidWarn = `  warn: {\n    stream: "stderr",\n    exit: 2,`;
    expect(source).toContain(validWarn);

    const fixture = new URL(
      `./.hook-protocol-invalid-${crypto.randomUUID()}.ts`,
      import.meta.url,
    ).pathname;
    await Bun.write(fixture, source.replace(validWarn, invalidWarn));

    try {
      const proc = Bun.spawnSync([
        TSC,
        "--noEmit",
        "--ignoreConfig",
        "--strict",
        "--module",
        "Preserve",
        "--moduleDetection",
        "force",
        "--moduleResolution",
        "bundler",
        "--types",
        "bun",
        fixture,
      ]);
      const diagnostics = proc.stdout.toString() + proc.stderr.toString();
      expect(proc.exitCode).not.toBe(0);
      expect(diagnostics).toContain(
        `Type '"stderr"' is not assignable to type '"stdout"'`,
      );
      expect(diagnostics).toContain("Type '2' is not assignable to type '0'");
    } finally {
      unlinkSync(fixture);
    }
  });
});

describe("parse: coercion and shell-quote safety", () => {
  test("exports the fields the shell lib consumes", () => {
    const r = run(
      ["parse"],
      JSON.stringify({
        session_id: "s-1",
        tool_name: "Bash",
        tool_input: { command: "echo hi" },
      }),
    );
    expect(r.code).toBe(0);
    expect(r.stdout).toContain("hp_session_id='s-1'");
    expect(r.stdout).toContain("hp_tool_name='Bash'");
    expect(r.stdout).toContain("hp_command='echo hi'");
  });

  test("file_path and filename export separately (parity with the jq path)", () => {
    const r = run(
      ["parse"],
      JSON.stringify({
        filename: "/tmp/changed.ts",
        tool_input: { file_path: "/tmp/edited.ts" },
      }),
    );
    expect(r.stdout).toContain("hp_file_path='/tmp/edited.ts'");
    expect(r.stdout).toContain("hp_filename='/tmp/changed.ts'");
    const only = run(["parse"], JSON.stringify({ filename: "/tmp/f.ts" }));
    // The jq fallback cannot see .filename in file_path -- neither may we.
    expect(only.stdout).toContain("hp_file_path=''");
    expect(only.stdout).toContain("hp_filename='/tmp/f.ts'");
  });

  test("wrong-typed fields export as empty instead of crashing", () => {
    for (const payload of [
      { session_id: 7 },
      { tool_input: { file_path: {} } },
      { tool_name: ["Bash"] },
      { tool_input: { command: { nested: true } } },
    ]) {
      const r = run(["parse"], JSON.stringify(payload));
      expect(r.code).toBe(0);
      expect(r.stdout).toContain("hp_session_id=''");
    }
  });

  test("non-object and non-JSON stdin exit 0 with no output", () => {
    for (const input of ["not json", "[1,2]", '"str"', "7", ""]) {
      const r = run(["parse"], input);
      expect(r.code).toBe(0);
      expect(r.stdout).toBe("");
    }
  });

  test("quotes in values cannot escape the single-quoted assignment", () => {
    const r = run(
      ["parse"],
      JSON.stringify({
        tool_input: { command: "x'; rm -rf /tmp/pwned; echo '" },
      }),
    );
    // The '\'' escape keeps the payload inert data under eval.
    expect(r.stdout).toContain(
      `hp_command='x'\\''; rm -rf /tmp/pwned; echo '\\'''`,
    );
  });

  test("trailing newlines trim to command-substitution semantics", () => {
    // $(... | jq -r ...) strips ALL trailing newlines; the eval'd
    // assignment preserves them -- the typed layer must pre-trim or the
    // two paths disagree on byte-identical stdin.
    const r = run(
      ["parse"],
      JSON.stringify({
        tool_name: "Bash",
        tool_input: { command: "rm -rf /tmp/x\n\n", file_path: "/tmp/y\n" },
      }),
    );
    expect(r.stdout).toContain("hp_command='rm -rf /tmp/x'");
    expect(r.stdout).toContain("hp_file_path='/tmp/y'");
    // Interior newlines are data and must survive.
    const inner = run(
      ["parse"],
      JSON.stringify({ tool_input: { command: "a\nb" } }),
    );
    expect(inner.stdout).toContain("hp_command='a\nb'");
  });

  test("NUL bytes are stripped", () => {
    const r = run(["parse"], '{"session_id":"a\\u0000b"}');
    expect(r.stdout).toContain("hp_session_id='ab'");
  });
});
