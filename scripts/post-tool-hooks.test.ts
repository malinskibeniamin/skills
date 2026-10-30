import { afterEach, describe, expect, test } from "bun:test";
import { mkdtempSync, readFileSync, rmSync, statSync } from "node:fs";
import { tmpdir } from "node:os";
import { basename, join } from "node:path";
import { z } from "zod";

const cleanup: string[] = [];
const bashOutputSchema = z
  .object({
    stdout: z.string(),
    stderr: z.string(),
    interrupted: z.boolean(),
    isImage: z.boolean(),
  })
  .passthrough();
const outputSchema = z.object({
  systemMessage: z.string().optional(),
  hookSpecificOutput: z
    .object({
      hookEventName: z.string(),
      updatedToolOutput: bashOutputSchema.optional(),
    })
    .optional(),
});

function postTool(stdout: string, stderr = "") {
  return {
    hook_event_name: "PostToolUse",
    tool_name: "Bash",
    tool_input: { command: "python3 script.py" },
    tool_response: {
      stdout,
      stderr,
      interrupted: false,
      isImage: false,
      noOutputExpected: false,
    },
  };
}

describe("llm-truncate", () => {
  test("rewrites long single-line stdout without a user-facing warning", () => {
    const input = postTool(`BEGIN${"x".repeat(10_000)}END`);
    const { output } = run("llm-truncate", input);
    expect(output?.systemMessage).toBeUndefined();
    expect(output?.hookSpecificOutput?.hookEventName).toBe("PostToolUse");
    const replacement = bashOutputSchema.parse(
      output?.hookSpecificOutput?.updatedToolOutput,
    );
    expect(Buffer.byteLength(replacement.stdout)).toBeLessThanOrEqual(4096);
    expect(replacement.stdout).toStartWith("BEGIN");
    expect(replacement.stdout).toEndWith("END");
    expect(replacement.stderr).toBe("");
    expect(replacement).toMatchObject({
      interrupted: false,
      isImage: false,
      noOutputExpected: false,
    });
    const log = z
      .string()
      .parse(replacement.stdout.match(/full: ([^\]\n]+)\]/)?.[1]);
    expect(JSON.parse(readFileSync(log, "utf8"))).toEqual(input.tool_response);
    expect(statSync(log).mode & 0o077).toBe(0);
  });

  test.each([
    ["Unicode", `BEGIN${"🐈界".repeat(2000)}END`, ""],
    ["multiline", `BEGIN\n${"line\n".repeat(5000)}END`, ""],
    ["large pipeline", `BEGIN${"x".repeat(200_000)}END`, ""],
    ["stderr only", "", `BEGIN${"error".repeat(2000)}END`],
    ["both channels", "x".repeat(6000), "error".repeat(2000)],
    ["small stdout", "ok\n", "error".repeat(2000)],
  ])(
    "bounds %s by bytes across both output channels",
    (_name, stdout, stderr) => {
      const { output } = run("llm-truncate", postTool(stdout, stderr), {
        LLM_TRUNCATE_BYTES: "512",
      });
      const replacement = bashOutputSchema.parse(
        output?.hookSpecificOutput?.updatedToolOutput,
      );
      expect(
        Buffer.byteLength(replacement.stdout) +
          Buffer.byteLength(replacement.stderr),
      ).toBeLessThanOrEqual(512);
      expect(replacement.stdout + replacement.stderr).not.toContain("�");
      expect(replacement.stdout + replacement.stderr).toContain("full:");
      expect(Boolean(replacement.stdout)).toBe(Boolean(stdout));
      expect(Boolean(replacement.stderr)).toBe(Boolean(stderr));
    },
  );

  test("honors head-only and tail-only windows without splitting Unicode", () => {
    for (const { head, tail, startsWith, endsWith } of [
      { head: "1", tail: "0", startsWith: "BEGIN", endsWith: "...\n" },
      { head: "0", tail: "1", startsWith: "\n...", endsWith: "END" },
    ]) {
      const { output } = run(
        "llm-truncate",
        postTool(`BEGIN${"🐈".repeat(2000)}END`),
        { LLM_TRUNCATE_HEAD: head, LLM_TRUNCATE_TAIL: tail },
      );
      const replacement = bashOutputSchema.parse(
        output?.hookSpecificOutput?.updatedToolOutput,
      );
      expect(replacement.stdout).toStartWith(startsWith);
      expect(replacement.stdout).toEndWith(endsWith);
      expect(Buffer.byteLength(replacement.stdout)).toBeLessThanOrEqual(4096);
      expect(replacement.stdout).not.toContain("�");
    }
  });

  test("tiny budgets stay bounded even when the full-output marker cannot fit", () => {
    const { output } = run("llm-truncate", postTool("界".repeat(3000)), {
      LLM_TRUNCATE_BYTES: "7",
    });
    const replacement = bashOutputSchema.parse(
      output?.hookSpecificOutput?.updatedToolOutput,
    );
    expect(replacement.stdout).toBe("界界");
  });

  test("a trailing newline does not displace the final diagnostic line", () => {
    const { output } = run(
      "llm-truncate",
      postTool(`${"line\n".repeat(2000)}FINAL\n`),
      { LLM_TRUNCATE_HEAD: "0", LLM_TRUNCATE_TAIL: "1" },
    );
    const replacement = bashOutputSchema.parse(
      output?.hookSpecificOutput?.updatedToolOutput,
    );
    expect(replacement.stdout).toEndWith("FINAL\n");
  });

  test("supports the tool_result alias without changing result metadata", () => {
    const { tool_response, ...input } = postTool("x".repeat(6000), "warning\n");
    const { output } = run("llm-truncate", {
      ...input,
      tool_result: { ...tool_response, exit_code: 3, interrupted: true },
    });
    expect(output?.hookSpecificOutput?.updatedToolOutput).toMatchObject({
      stderr: "warning\n",
      exit_code: 3,
      interrupted: true,
      noOutputExpected: false,
    });
  });

  test.each([
    { LLM_TRUNCATE_BYTES: "bad" },
    { LLM_TRUNCATE_BYTES: "0" },
    { LLM_TRUNCATE_HEAD: "-1" },
    { LLM_TRUNCATE_TAIL: "no" },
    { LLM_TRUNCATE_HEAD: "0", LLM_TRUNCATE_TAIL: "0" },
  ])("invalid truncation configuration passes through: %j", (env) => {
    expect(run("llm-truncate", postTool("x".repeat(6000)), env).stdout).toBe(
      "",
    );
  });

  test("passes through small output even with large metadata", () => {
    const input = postTool("ok\n");
    expect(
      run("llm-truncate", {
        ...input,
        tool_response: { ...input.tool_response, metadata: "x".repeat(6000) },
      }).stdout,
    ).toBe("");
    expect(run("llm-truncate", postTool("x".repeat(4096))).stdout).toBe("");
  });

  test("keeps the original output when its full backup cannot be saved", () => {
    expect(
      run("llm-truncate", postTool("x".repeat(6000)), { TMPDIR: "/dev/null" })
        .stdout,
    ).toBe("");
  });

  test("ignores non-Bash and unsupported response shapes", () => {
    for (const input of [
      { ...postTool("x".repeat(6000)), tool_name: "Read" },
      { ...postTool(""), tool_response: "x".repeat(6000) },
      { ...postTool(""), tool_response: null },
      {
        ...postTool(""),
        tool_response: {
          ...postTool("x".repeat(6000)).tool_response,
          isImage: true,
        },
      },
    ]) {
      expect(run("llm-truncate", input).stdout).toBe("");
    }
  });
});

afterEach(() => {
  for (const path of cleanup.splice(0)) {
    rmSync(path, { recursive: true, force: true });
  }
});

function run(script: string, input: unknown, env: Record<string, string> = {}) {
  const root = mkdtempSync(join(tmpdir(), "post-tool-hooks-"));
  const state = mkdtempSync("/tmp/hook-session-post-tool-hooks-");
  cleanup.push(root, state);
  const proc = Bun.spawnSync(
    [
      "bash",
      new URL(`../.claude/hooks/${script}.sh`, import.meta.url).pathname,
    ],
    {
      stdin: Buffer.from(JSON.stringify(input)),
      env: {
        ...Bun.env,
        CLAUDE_SESSION_ID: basename(state).slice("hook-session-".length),
        TMPDIR: root,
        HOOK_METRICS_DISABLED: "1",
        HOOK_PROTOCOL: "shell",
        LLM_TRUNCATE_BYTES: "4096",
        LLM_TRUNCATE_HEAD: "80",
        LLM_TRUNCATE_TAIL: "120",
        ...env,
      },
    },
  );
  expect(proc.exitCode).toBe(0);
  expect(proc.stderr.toString()).toBe("");
  const stdout = proc.stdout.toString();
  return {
    stdout,
    output: stdout ? outputSchema.parse(JSON.parse(stdout)) : null,
  };
}

const failure = {
  hook_event_name: "PostToolUseFailure",
  tool_name: "Bash",
  tool_input: { command: "python3 script.py" },
  error:
    "Exit code 1\nSyntaxError: unexpected character after line continuation character",
  is_interrupt: false,
};

describe("post-tool-failure", () => {
  test("reports the real exit code from Claude's failure event", () => {
    const { output } = run("post-tool-failure", failure);
    expect(output?.systemMessage).toContain("Command failed (exit 1)");
  });

  test("uses the failure error for command-not-found and install hints", () => {
    expect(
      run("post-tool-failure", {
        ...failure,
        error: "Exit code 127\ncommand not found: python3",
      }).output?.systemMessage,
    ).toContain("[tool-fail:command-not-found]");
    expect(
      run("post-tool-failure", {
        ...failure,
        tool_input: { command: "bun install" },
        error: "Exit code 1\nerror: ENOTFOUND registry.example.test",
      }).output?.systemMessage,
    ).toContain("Network issue installing deps");
  });

  test("does not invent a successful exit code for an unstructured failure", () => {
    expect(
      run("post-tool-failure", {
        ...failure,
        error: "Unable to start shell process",
      }).output?.systemMessage,
    ).toContain("exit unknown");
  });

  test("ignores interrupted events and successful Codex post-tool events", () => {
    for (const input of [
      { ...failure, is_interrupt: true },
      {
        ...failure,
        hook_event_name: "PostToolUse",
        error: undefined,
        tool_result: { exit_code: 0, stdout: "ok", stderr: "" },
      },
      {
        ...failure,
        hook_event_name: "PostToolUse",
        error: undefined,
        tool_response: { stdout: "ok", stderr: "" },
      },
    ]) {
      expect(run("post-tool-failure", input).stdout).toBe("");
    }
  });

  test("still categorizes failed Codex post-tool events", () => {
    expect(
      run("post-tool-failure", {
        ...failure,
        hook_event_name: "PostToolUse",
        error: undefined,
        tool_result: { exit_code: 2, stdout: "", stderr: "failed" },
      }).output?.systemMessage,
    ).toContain("Command failed (exit 2)");
  });
});
