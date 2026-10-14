import { afterEach, expect, test } from "bun:test";
import {
  chmodSync,
  copyFileSync,
  lstatSync,
  mkdirSync,
  mkdtempSync,
  readFileSync,
  rmSync,
  statSync,
  symlinkSync,
  writeFileSync,
} from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";

const template = new URL("./template.sh", import.meta.url).pathname;
const directories: string[] = [];
// Bound a broken interactive process; this is not a timing assertion.
const PROCESS_DEADLINE_MS = 5_000;

afterEach(() => {
  for (const directory of directories.splice(0)) {
    rmSync(directory, { recursive: true, force: true });
  }
});

function fixture() {
  const root = mkdtempSync(join(tmpdir(), "wizard test-"));
  directories.push(root);
  const bin = join(root, "bin");
  mkdirSync(bin);
  // Keep the real wizard entrypoint; isolate browser and remote-secret effects.
  for (const command of ["gh", "open", "xdg-open", "wslview", "explorer.exe"]) {
    const path = join(bin, command);
    writeFileSync(path, "#!/bin/bash\nexit 0\n", { mode: 0o755 });
  }
  const envFile = join(root, ".env");
  return {
    root,
    envFile,
    env: { PATH: `${bin}:/usr/bin:/bin`, ENV_FILE: envFile, LC_ALL: "C" },
  };
}

function runWizard(workspace: ReturnType<typeof fixture>, input: string) {
  return Bun.spawnSync(["/bin/bash", template], {
    cwd: workspace.root,
    env: workspace.env,
    stdin: Buffer.from(input),
    timeout: PROCESS_DEADLINE_MS,
  });
}

function readValues(workspace: ReturnType<typeof fixture>) {
  const result = Bun.spawnSync(
    [
      "/bin/bash",
      "-c",
      'source "$ENV_FILE"; printf "%s\\n%s\\n" "$STRIPE_PUBLISHABLE_KEY" "$STRIPE_SECRET_KEY"',
    ],
    {
      cwd: workspace.root,
      env: { ENV_FILE: workspace.envFile },
      timeout: PROCESS_DEADLINE_MS,
    },
  );
  expect(result.exitCode).toBe(0);
  return result.stdout.toString().trimEnd().split("\n");
}

test("generated wizard preserves literal values and rerun defaults without printing secrets", () => {
  const workspace = fixture();
  const publishable = "pk_test_space # literal";
  const secret = "sk_test_$literal'quote\\backslash";
  const first = runWizard(workspace, `\n${publishable}\n${secret}\n`);
  expect(first.exitCode).toBe(0);
  expect(first.stdout.toString()).toContain("Setup complete");
  expect(first.stdout.toString()).not.toContain(secret);
  expect(readValues(workspace)).toEqual([publishable, secret]);

  const rerun = runWizard(workspace, "\n\n\n");
  expect(rerun.exitCode).toBe(0);
  expect(readValues(workspace)).toEqual([publishable, secret]);
});

test.each(["\n", "\npk_test_fixture\n"])(
  "EOF stops the wizard before empty values or false completion: %j",
  (input) => {
    const workspace = fixture();
    const result = runWizard(workspace, input);
    expect(result.exitCode).not.toBe(0);
    expect(result.stdout.toString()).not.toContain("Setup complete");
    expect(Bun.file(workspace.envFile).size).toBe(0);
  },
);

test.each(["absolute", "relative chain"])(
  "env upserts preserve %s symlinks, permissions, and unrelated values",
  (kind) => {
    const workspace = fixture();
    const target = join(workspace.root, "shared.env");
    writeFileSync(target, "OTHER=kept\nSTRIPE_SECRET_KEY=old\n");
    chmodSync(target, 0o640);
    if (kind === "absolute") {
      symlinkSync(target, workspace.envFile);
    } else {
      symlinkSync("shared.env", join(workspace.root, "forward.env"));
      symlinkSync("forward.env", workspace.envFile);
    }

    const result = runWizard(workspace, "\npk_test_fixture\nsk_test_fixture\n");
    expect(result.exitCode).toBe(0);
    expect(lstatSync(workspace.envFile).isSymbolicLink()).toBe(true);
    expect(statSync(target).mode & 0o777).toBe(0o640);
    expect(readFileSync(target, "utf8")).toContain("OTHER=kept\n");
    expect(readValues(workspace)).toEqual([
      "pk_test_fixture",
      "sk_test_fixture",
    ]);
  },
);

test("new env files are private even with a permissive caller umask", () => {
  const workspace = fixture();
  const result = Bun.spawnSync(
    ["/bin/bash", "-c", 'umask 022; exec /bin/bash "$1"', "wizard", template],
    {
      cwd: workspace.root,
      env: workspace.env,
      stdin: Buffer.from("\npk_test_fixture\nsk_test_fixture\n"),
      timeout: PROCESS_DEADLINE_MS,
    },
  );
  expect(result.exitCode).toBe(0);
  expect(statSync(workspace.envFile).mode & 0o777).toBe(0o600);
});

test("a failed env rewrite leaves existing configuration intact", () => {
  const workspace = fixture();
  const original = `OTHER=${"x".repeat(2048)}\n`;
  writeFileSync(workspace.envFile, original);
  // A real filesystem-write failure, not a mocked implementation method.
  const result = Bun.spawnSync(
    ["/bin/bash", "-c", 'ulimit -f 1; exec /bin/bash "$1"', "wizard", template],
    {
      cwd: workspace.root,
      env: workspace.env,
      stdin: Buffer.from("\npk_test_fixture\nsk_test_fixture\n"),
      timeout: PROCESS_DEADLINE_MS,
    },
  );
  expect(result.exitCode).not.toBe(0);
  expect(result.stdout.toString()).not.toContain("Setup complete");
  expect(readFileSync(workspace.envFile, "utf8")).toBe(original);
});

test("an edit after the first prompt cannot change the running procedure", async () => {
  const workspace = fixture();
  const script = join(workspace.root, "setup.sh");
  copyFileSync(template, script);
  const child = Bun.spawn(["/bin/bash", script], {
    cwd: workspace.root,
    env: workspace.env,
    stdin: "pipe",
    stdout: "pipe",
    stderr: "pipe",
    timeout: PROCESS_DEADLINE_MS,
  });
  const reader = child.stdout.getReader();
  let output = "";
  try {
    while (!output.includes("Ready to start?")) {
      const chunk = await reader.read();
      if (chunk.done) throw new Error("Wizard ended before its first prompt");
      output += new TextDecoder().decode(chunk.value);
    }
    // Mutate only the isolated copy once the real procedure is awaiting input.
    writeFileSync(script, "this edited file is no longer valid Bash (\n");
    child.stdin.write("\npk_test_fixture\nsk_test_fixture\n");
    child.stdin.end();
    while (true) {
      const chunk = await reader.read();
      if (chunk.done) break;
      output += new TextDecoder().decode(chunk.value);
    }
    const stderr = await new Response(child.stderr).text();
    expect(await child.exited).toBe(0);
    expect(stderr).toBe("");
    expect(output).toContain("Setup complete");
    expect(readValues(workspace)).toEqual([
      "pk_test_fixture",
      "sk_test_fixture",
    ]);
  } finally {
    reader.releaseLock();
    child.kill();
    await child.exited;
  }
});
