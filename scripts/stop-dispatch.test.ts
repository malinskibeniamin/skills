import { afterEach, expect, test } from "bun:test";
import {
  copyFileSync,
  mkdtempSync,
  mkdirSync,
  rmSync,
  writeFileSync,
} from "node:fs";
import { tmpdir } from "node:os";
import { basename, join } from "node:path";

const cleanup: string[] = [];
const config = await Bun.file(
  new URL("../hooks/hooks.json", import.meta.url),
).json();
const command = config.hooks.Stop[0].hooks[0].command as string;

afterEach(() => {
  for (const path of cleanup.splice(0))
    rmSync(path, { recursive: true, force: true });
});

function fixture() {
  const root = mkdtempSync(join(tmpdir(), "stop-dispatch-"));
  const state = mkdtempSync("/tmp/hook-session-stop-dispatch-");
  cleanup.push(root, state);
  const session = basename(state).slice("hook-session-".length);
  const hooks = join(root, ".claude/hooks");
  mkdirSync(hooks, { recursive: true });
  copyFileSync(
    new URL("../.claude/hooks/stop-dispatch.sh", import.meta.url),
    join(hooks, "stop-dispatch.sh"),
  );
  writeFileSync(
    join(root, "skill-manifest.json"),
    JSON.stringify({ "x-stop-dispatch": ["check.sh"] }),
  );
  writeFileSync(
    join(hooks, "check.sh"),
    [
      "#!/bin/bash",
      'touch "$STATE/task-completed"',
      'if [ "$CHECK_EXIT" -eq 0 ]; then',
      '  printf "%s" "$CHECK_OUTPUT"',
      "else",
      '  printf "%s" "$CHECK_OUTPUT" >&2',
      "fi",
      'exit "$CHECK_EXIT"',
      "",
    ].join("\n"),
    { mode: 0o755 },
  );
  writeFileSync(
    join(hooks, "pr-review-auto-hook.sh"),
    '#!/bin/bash\ntouch "$STATE/released"\n',
    { mode: 0o755 },
  );
  return {
    state,
    run(
      active?: boolean,
      exit = 2,
      output = "tests failed\nexpected 1, received 2",
    ) {
      const result = Bun.spawnSync(["/bin/bash", "-c", command], {
        cwd: root,
        stdin: Buffer.from(
          JSON.stringify({
            session_id: session,
            hook_event_name: "Stop",
            stop_hook_active: active,
          }),
        ),
        env: {
          ...process.env,
          CLAUDE_PLUGIN_ROOT: root,
          CLAUDE_SESSION_ID: "",
          CODEX_SESSION_ID: "",
          STATE: state,
          CHECK_EXIT: String(exit),
          CHECK_OUTPUT: output,
        },
      });
      return {
        code: result.exitCode,
        out: result.stdout.toString(),
        err: result.stderr.toString(),
      };
    },
  };
}

test.each([undefined, false])(
  "a failed check blocks with stderr, active=%s",
  async (active) => {
    const f = fixture();
    const result = f.run(active);
    expect(result.code).toBe(2);
    expect(result.out).toBe("");
    expect(JSON.parse(result.err).systemMessage).toContain(
      "tests failed\nexpected 1, received 2",
    );
    expect(await Bun.file(join(f.state, "task-completed")).exists()).toBe(
      false,
    );
    expect(await Bun.file(join(f.state, "released")).exists()).toBe(false);
  },
);

test("a failing repair attempt ends visibly without another continuation", async () => {
  const f = fixture();
  expect(f.run(false).code).toBe(2);
  for (let attempt = 0; attempt < 2; attempt++) {
    // Tool activity must not replenish the dispatcher retry budget.
    writeFileSync(join(f.state, "session-touched-files"), "changed.ts\n");
    const result = f.run(true);
    expect(result.code).toBe(0);
    expect(result.err).toBe("");
    const message = JSON.parse(result.out);
    expect(message.systemMessage).toContain("Unresolved");
    expect(message.systemMessage).toContain("tests failed");
    expect(message.decision).toBeUndefined();
    expect(message.hookSpecificOutput).toBeUndefined();
    expect(await Bun.file(join(f.state, "task-completed")).exists()).toBe(
      false,
    );
    expect(await Bun.file(join(f.state, "released")).exists()).toBe(false);
  }
  // A new user turn is eligible to block again.
  expect(f.run(false).code).toBe(2);
});

test("a successful repair still runs completion and releases activity", async () => {
  const f = fixture();
  expect(f.run(false).code).toBe(2);
  const result = f.run(true, 0, "");
  expect(result).toEqual({ code: 0, out: "", err: "" });
  expect(await Bun.file(join(f.state, "task-completed")).exists()).toBe(true);
  expect(await Bun.file(join(f.state, "released")).exists()).toBe(true);
});

test("a silent exit 2 cannot become a passing check", () => {
  const result = fixture().run(false, 2, "");
  expect(result.code).toBe(2);
  expect(result.err).toContain("check");
  expect(result.err).toContain("2");
});

test.each([false, true])(
  "hook errors remain visible but non-blocking, active=%s",
  (active) => {
    const result = fixture().run(active, 1, "missing checker dependency");
    expect(result.code).toBe(0);
    expect(result.err).toBe("");
    const message = JSON.parse(result.out);
    expect(message.systemMessage).toContain("check exited 1");
    expect(message.systemMessage).toContain("missing checker dependency");
    expect(message.hookSpecificOutput).toBeUndefined();
  },
);

test("informational notes do not request a Stop continuation", () => {
  const result = fixture().run(
    false,
    0,
    '{"hookSpecificOutput":{"additionalContext":"timing summary"}}',
  );
  expect(result.code).toBe(0);
  expect(result.err).toBe("");
  const message = JSON.parse(result.out);
  expect(message.systemMessage).toContain("timing summary");
  expect(message.hookSpecificOutput).toBeUndefined();
});
