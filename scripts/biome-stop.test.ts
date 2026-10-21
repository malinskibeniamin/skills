import { afterEach, describe, expect, test } from "bun:test";
import {
  mkdtempSync,
  mkdirSync,
  rmSync,
  symlinkSync,
  writeFileSync,
} from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";

const hooks = [
  new URL("../.claude/hooks/biome-autofix.sh", import.meta.url).pathname,
  new URL(
    "../frontend-starter-kit/references/biome/scripts/biome-autofix.sh",
    import.meta.url,
  ).pathname,
];
const cleanup: string[] = [];

afterEach(() => {
  for (const path of cleanup.splice(0)) {
    rmSync(path, { recursive: true, force: true });
  }
});

function fixture(scripts: Record<string, string>, files = ["src/index.ts"]) {
  const root = mkdtempSync(join(tmpdir(), "biome-stop-"));
  const session = `biome-stop-${crypto.randomUUID()}`;
  const state = `/tmp/hook-session-${session}`;
  cleanup.push(root, state);
  mkdirSync(join(root, "bin"));
  mkdirSync(state);
  writeFileSync(join(root, "package.json"), JSON.stringify({ scripts }));
  writeFileSync(
    join(root, "bin/bun"),
    `#!/bin/bash\nprintf "%s\\n" "$@" >> "$CAPTURE"\nprintf "%s\\n" "\${CHECK_OUTPUT:-}"\nexit "\${CHECK_EXIT:-0}"\n`,
    { mode: 0o755 },
  );
  for (const file of files) {
    mkdirSync(join(root, file, ".."), { recursive: true });
    writeFileSync(join(root, file), "export const value = 1;\n");
  }
  function git(...args: string[]) {
    const result = Bun.spawnSync(["git", ...args], { cwd: root });
    expect(result.exitCode).toBe(0);
  }
  git("init", "-q");
  git("add", ".");
  git(
    "-c",
    "user.name=Fixture",
    "-c",
    "user.email=fixture@example.com",
    "commit",
    "-qm",
    "fixture",
  );
  for (const file of files) {
    writeFileSync(join(root, file), "export const value = 2;\n");
  }
  writeFileSync(
    join(state, "session-touched-files"),
    `${files.map((file) => join(root, file)).join("\n")}\n`,
  );
  return { root, state, session };
}

function run(
  hook: string,
  f: ReturnType<typeof fixture>,
  env: Record<string, string> = {},
  cwd = f.root,
) {
  return Bun.spawnSync(["/bin/bash", hook], {
    cwd,
    stdin: Buffer.from(JSON.stringify({ session_id: f.session })),
    env: {
      ...process.env,
      CLAUDE_SESSION_ID: "",
      CODEX_SESSION_ID: "",
      PATH: `${join(f.root, "bin")}:${process.env.PATH}`,
      CAPTURE: join(f.root, "calls"),
      HOOK_PROTOCOL: "shell",
      HOOK_METRICS_DISABLED: "1",
      HOOK_STOP_BLOCK_CAP_GUARD: "0",
      ...env,
    },
  });
}

for (const hook of hooks) {
  describe(hook, () => {
    test("runs the consumer's file checker and reports a failed invocation", async () => {
      const f = fixture({ "check:files": "consumer-check" });
      const result = run(hook, f, {
        CHECK_EXIT: "1",
        CHECK_OUTPUT: "Invalid checker configuration",
      });
      expect(result.exitCode).toBe(2);
      expect(result.stderr.toString()).toContain(
        "Invalid checker configuration",
      );
      expect(await Bun.file(join(f.root, "calls")).text()).toBe(
        "run\ncheck:files\n./src/index.ts\n",
      );
    });

    test("a silent checker crash is not a pass", () => {
      const f = fixture({ "check:files": "consumer-check" });
      const result = run(hook, f, { CHECK_EXIT: "127" });
      expect(result.exitCode).toBe(2);
      expect(result.stderr.toString()).toContain("exit 127");
    });

    test("keeps spaced JavaScript paths intact and prefers the read-only script", async () => {
      const f = fixture(
        {
          "check:files": "check",
          "lint:file": "legacy",
          "lint:fix:file": "fix",
        },
        ["src/a name.jsx"],
      );
      const result = run(hook, f, { CLAUDE_SESSION_ID: f.session });
      expect(result.exitCode).toBe(0);
      expect(await Bun.file(join(f.root, "calls")).text()).toBe(
        "run\ncheck:files\n./src/a name.jsx\n",
      );
    });

    test("checks an untracked session-owned file, not another session's change", async () => {
      const f = fixture({ "check:files": "check" }, ["src/other.ts"]);
      writeFileSync(join(f.root, "src/new.ts"), "export const added = 1;\n");
      writeFileSync(
        join(f.state, "session-touched-files"),
        `${f.root}/src/new.ts\n`,
      );
      expect(run(hook, f).exitCode).toBe(0);
      expect(await Bun.file(join(f.root, "calls")).text()).toBe(
        "run\ncheck:files\n./src/new.ts\n",
      );
    });

    test("preserves generated files and symlink targets", async () => {
      const f = fixture({ "check:files": "check" }, [
        "route.gen.ts",
        "item_pb.js",
        "rpc_connectquery.ts",
        "marked.ts",
        "linked.ts",
      ]);
      writeFileSync(
        join(f.root, "marked.ts"),
        "// DO NOT EDIT\nexport const value = 2;\n",
      );
      rmSync(join(f.root, "linked.ts"));
      symlinkSync(join(f.root, "marked.ts"), join(f.root, "linked.ts"));
      expect(run(hook, f).exitCode).toBe(0);
      expect(await Bun.file(join(f.root, "calls")).exists()).toBe(false);
    });

    test("a package invocation excludes siblings and registry-owned UI", async () => {
      const f = fixture({ "check:files": "check" }, [
        "app/src/index.ts",
        "src/index.ts",
        "app/components/ui/button.tsx",
      ]);
      writeFileSync(
        join(f.root, "app/package.json"),
        JSON.stringify({ scripts: { "check:files": "check" } }),
      );
      expect(run(hook, f, {}, join(f.root, "app")).exitCode).toBe(0);
      expect(await Bun.file(join(f.root, "calls")).text()).toBe(
        "run\ncheck:files\n./src/index.ts\n",
      );
    });

    test("legacy checker requests strict warnings without requiring a fixer", async () => {
      const f = fixture({ "lint:file": "check" });
      expect(run(hook, f, { CHECK_OUTPUT: "0 warnings" }).exitCode).toBe(0);
      expect(await Bun.file(join(f.root, "calls")).text()).toBe(
        "run\nlint:file\n--\n--error-on-warnings\n--skip=lint/correctness/noUnusedImports\n./src/index.ts\n",
      );
    });

    test("an opted-in legacy fixer never substitutes for the final check", async () => {
      const f = fixture({ "lint:file": "check", "lint:fix:file": "fix" });
      const result = run(hook, f, {
        CHECK_EXIT: "1",
        CHECK_OUTPUT: "Parse failed",
      });
      expect(result.exitCode).toBe(2);
      expect(result.stderr.toString()).toContain("Parse failed");
      expect(await Bun.file(join(f.root, "calls")).text()).toBe(
        "run\nlint:fix:file\n--\n--skip=lint/correctness/noUnusedImports\n./src/index.ts\n" +
          "run\nlint:file\n--\n--error-on-warnings\n--skip=lint/correctness/noUnusedImports\n./src/index.ts\n",
      );
    });

    test("preserves a legacy checker that already declares strict warnings", async () => {
      const f = fixture({ "lint:file": "biome check --error-on-warnings" });
      expect(run(hook, f).exitCode).toBe(0);
      expect(await Bun.file(join(f.root, "calls")).text()).toBe(
        "run\nlint:file\n--\n--skip=lint/correctness/noUnusedImports\n./src/index.ts\n",
      );
    });

    test("does not invent a whole-project command when no file script exists", async () => {
      const f = fixture({ "lint:fix": "fix-everything ." });
      expect(run(hook, f).exitCode).toBe(0);
      expect(await Bun.file(join(f.root, "calls")).exists()).toBe(false);
    });

    test("missing ownership tracking permits checking but not automatic edits", async () => {
      const f = fixture({ "lint:file": "check", "lint:fix:file": "fix" });
      rmSync(join(f.state, "session-touched-files"));
      expect(run(hook, f).exitCode).toBe(0);
      expect(await Bun.file(join(f.root, "calls")).text()).toBe(
        "run\nlint:file\n--\n--error-on-warnings\n--skip=lint/correctness/noUnusedImports\n./src/index.ts\n",
      );
    });
  });
}
