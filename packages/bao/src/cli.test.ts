import { expect, test } from "bun:test";
import { mkdtempSync, rmSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";

const cli = join(import.meta.dir, "cli.ts");

test("the standalone command stores and retrieves wiki knowledge and repo pointers", () => {
  const scratch = mkdtempSync(join(tmpdir(), "bao-cli-"));
  try {
    const home = join(scratch, "home");
    function run(...args: string[]) {
      const r = Bun.spawnSync([process.execPath, cli, ...args], {
        cwd: scratch,
        stdin: Buffer.from("Keep the home repo local."),
        timeout: 5000,
      });
      expect(r.stderr.toString()).toBe("");
      expect(r.exitCode).toBe(0);
      return JSON.parse(r.stdout.toString());
    }

    run("wiki", "--home", home, "init");
    run(
      "wiki",
      "--home",
      home,
      "ingest",
      "home-repo",
      "--title",
      "Home repo",
      "--source",
      "Owner decision",
      "--stdin",
    );
    expect(run("wiki", "--home", home, "search", "keep the home")).toEqual([
      {
        slug: "home-repo",
        title: "Home repo",
        line: 1,
        text: "Keep the home repo local.",
      },
    ]);
    run(
      "repo",
      "--home",
      home,
      "add",
      "skills",
      "--path",
      scratch,
      "--summary",
      "Skills checkout",
    );
    expect(run("repo", "list", "--home", home)).toEqual([
      { name: "skills", path: scratch, summary: "Skills checkout" },
    ]);
  } finally {
    rmSync(scratch, { recursive: true, force: true });
  }
});

test("doctor rejects an API-key backend and never requests credentials or a model turn", () => {
  const scratch = mkdtempSync(join(tmpdir(), "bao-doctor-"));
  try {
    writeFileSync(
      join(scratch, "codex"),
      `#!${process.execPath}
import { createInterface } from "node:readline";
if (Bun.argv[2] !== "app-server") process.exit(2);
let index = 0;
for await (const line of createInterface({ input: process.stdin })) {
  const request = JSON.parse(line);
  const expected = ["initialize", "initialized", "account/read"][index++];
  if (request.method !== expected) process.exit(2);
  if (expected === "initialize") console.log(JSON.stringify({ id: request.id, result: {} }));
  if (expected === "account/read" && request.params.refreshToken === false) {
    console.log(JSON.stringify({ id: request.id, result: {
      account: { type: "apiKey", secret: "fake-must-not-be-printed" },
      requiresOpenaiAuth: true,
    } }));
    break;
  }
}
`,
      { mode: 0o700 },
    );
    const r = Bun.spawnSync([process.execPath, cli, "doctor", "--json"], {
      env: { PATH: scratch },
      timeout: 10_000,
    });
    expect(r.exitCode).toBe(1);
    expect(JSON.parse(r.stdout.toString())).toMatchObject({
      ok: false,
      code: "login-required",
    });
    expect(r.stdout.toString()).not.toContain("fake-must-not-be-printed");
  } finally {
    rmSync(scratch, { recursive: true, force: true });
  }
});
