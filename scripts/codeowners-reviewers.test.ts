import { afterAll, beforeAll, describe, expect, test } from "bun:test";
import { mkdtempSync, mkdirSync, rmSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";

const resolver = new URL("./codeowners-reviewers.py", import.meta.url).pathname;
const legacy = new URL(
  "../snyk-ux-security/scripts/codeowners-teams.sh",
  import.meta.url,
).pathname;
let repo: string;

function git(...args: string[]) {
  const result = Bun.spawnSync(["git", ...args], { cwd: repo });
  if (result.exitCode !== 0) throw new Error(result.stderr.toString());
}

function owners(content: string) {
  writeFileSync(join(repo, ".github/CODEOWNERS"), content);
}

function run(args: string[], stdin = "") {
  const result = Bun.spawnSync(["python3", resolver, ...args], {
    cwd: repo,
    stdin: Buffer.from(stdin),
  });
  return {
    code: result.exitCode,
    stdout: result.stdout.toString().trim(),
    stderr: result.stderr.toString(),
  };
}

beforeAll(() => {
  repo = mkdtempSync(join(tmpdir(), "pr-owners-"));
  mkdirSync(join(repo, ".github"));
  git("init", "-q");
  git("config", "user.name", "Fixture");
  git("config", "user.email", "fixture@example.com");
  owners("* @acme/base-team @alice\n");
  git("add", ".github/CODEOWNERS");
  git("-c", "core.hooksPath=/dev/null", "commit", "-qm", "base");
  git("branch", "base");
});

afterAll(() => rmSync(repo, { recursive: true, force: true }));

describe("CODEOWNERS reviewer CLI", () => {
  test("prefers teams per file, preserves person-only areas, and deduplicates", () => {
    owners("* @acme/team-xyz @alice\n/docs/ @bob\n");
    const result = run(["src/a.ts", "docs/a.md", "src/b.ts"]);
    expect(result.code).toBe(0);
    expect(result.stdout).toBe("acme/team-xyz\nbob");
  });

  test("uses the PR base ownership rather than a changed head policy", () => {
    owners("* @acme/head-team\n");
    const result = run(["--base", "base", "src/a.ts"]);
    expect(result.code).toBe(0);
    expect(result.stdout).toBe("acme/base-team");
  });

  test("does not silently fall back to head when a base ref is unavailable", () => {
    const result = run(["--base", "missing-base", "src/a.ts"]);
    expect(result.code).not.toBe(0);
    expect(result.stdout).toBe("");
    expect(result.stderr).toContain("missing-base");
  });

  test("accepts NUL-separated paths and escaped spaces in CODEOWNERS", () => {
    owners("* @acme/default\n/design\\ files/ @acme/design\n");
    const result = run(["--stdin0"], "design files/new view.tsx\0");
    expect(result.code).toBe(0);
    expect(result.stdout).toBe("acme/design");
  });

  test("the legacy team-only entrypoint honors an explicit unowned override", () => {
    owners("* @acme/default\n/generated/\n");
    const result = Bun.spawnSync(["bash", legacy, "generated/a.ts"], {
      cwd: repo,
    });
    expect(result.exitCode).toBe(0);
    expect(result.stdout.toString().trim()).toBe("");
  });

  test("reports email-only owners rather than returning an invalid reviewer handle", () => {
    owners("* docs@example.com\n");
    const result = run(["docs/readme.md"]);
    expect(result.code).not.toBe(0);
    expect(result.stdout).toBe("");
    expect(result.stderr).toContain("email");
  });

  test("matches basename, directory and zero-directory globstars with last match wins", () => {
    owners(
      "* @acme/all\n*.ts @acme/types\n/src/ @acme/frontend\n/src/**/secret?.ts @acme/security\n/generated/\n",
    );
    const result = run([
      "nested/config.ts",
      "src/view.tsx",
      "src/secret1.ts",
      "src/deep/secret2.ts",
      "generated/output.ts",
    ]);
    expect(result.code).toBe(0);
    expect(result.stdout).toBe("acme/frontend\nacme/security\nacme/types");
  });

  test("keeps root rules rooted, matches case sensitively and ignores unsupported ranges", () => {
    owners(
      "/src/*.ts @acme/frontend\n*.md @acme/docs\n/[ab].md @acme/invalid\n",
    );
    const result = run(["nested/src/a.ts", "src/A.TS", "[ab].md"]);
    expect(result.code).toBe(0);
    expect(result.stdout).toBe("acme/docs");
  });

  test("retains the legacy team-only handle format and absolute path support", () => {
    owners("* @acme/team-xyz @alice\n");
    const result = Bun.spawnSync(["bash", legacy, join(repo, "deleted.ts")], {
      cwd: repo,
    });
    expect(result.exitCode).toBe(0);
    expect(result.stdout.toString().trim()).toBe("@acme/team-xyz");
  });

  test("does not let repeated stars inside a segment cross directories", () => {
    owners("* @acme/default\nfoo**bar @acme/special\n");
    const result = run(["foo/deep/bar"]);
    expect(result.code).toBe(0);
    expect(result.stdout).toBe("acme/default");
  });

  test("rejects an empty path instead of routing the repository root", () => {
    owners("* @acme/default\n");
    const result = run([""]);
    expect(result.code).not.toBe(0);
    expect(result.stdout).toBe("");
    expect(result.stderr).toContain("path");
  });

  test("uses the first existing CODEOWNERS file, even when it is empty", () => {
    owners("");
    writeFileSync(join(repo, "CODEOWNERS"), "* @acme/root\n");
    const result = run(["src/a.ts"]);
    expect(result.code).toBe(0);
    expect(result.stdout).toBe("");
  });
});
