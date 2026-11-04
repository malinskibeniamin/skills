import { afterEach, expect, test } from "bun:test";
import { mkdirSync, mkdtempSync, rmSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";

const entry = new URL("./pr-maintenance-squash.sh", import.meta.url).pathname;
const directories: string[] = [];

afterEach(() => {
  for (const directory of directories.splice(0)) {
    rmSync(directory, { recursive: true, force: true });
  }
});

function fixture() {
  const root = mkdtempSync(join(tmpdir(), "pr-maintenance-squash-"));
  directories.push(root);
  const git = (...args: string[]) => {
    const result = Bun.spawnSync(["git", ...args], { cwd: root });
    expect(result.exitCode).toBe(0);
    return result.stdout.toString().trim();
  };
  git("init", "-b", "main");
  git("config", "user.name", "Test owner");
  git("config", "user.email", "owner@example.com");
  git("config", "commit.gpgSign", "false");
  git("commit", "--allow-empty", "-m", "feat(test): initial");
  const base = git("rev-parse", "HEAD");
  git("switch", "-c", "ben-malinski/T-1/feature");
  const commit = (body: string, author?: string) => {
    writeFileSync(join(root, "feature.txt"), body);
    git("add", "feature.txt");
    git(
      "commit",
      "-m",
      "fix(test): feature iteration",
      ...(author ? ["--author", author] : []),
    );
  };
  const run = (
    head = git("rev-parse", "HEAD"),
    target = "main",
    env: Record<string, string> = {},
  ) => {
    const result = Bun.spawnSync(
      [entry, target, head, "feat(test): complete feature"],
      { cwd: root, env: { ...Bun.env, ...env } },
    );
    return {
      code: result.exitCode,
      out: result.stdout.toString(),
      err: result.stderr.toString(),
    };
  };
  return { root, git, base, commit, run };
}

test("consolidates linear owned work without changing its tree or index", () => {
  const f = fixture();
  f.commit("first");
  f.commit("final\n");
  const old = f.git("rev-parse", "HEAD");
  const tree = f.git("rev-parse", "HEAD^{tree}");
  const index = f.git("write-tree");
  expect(f.run().code).toBe(0);
  expect(f.git("rev-list", "--count", `${f.base}..HEAD`)).toBe("1");
  expect(f.git("rev-parse", "HEAD^{tree}")).toBe(tree);
  expect(f.git("write-tree")).toBe(index);
  expect(f.git("status", "--porcelain")).toBe("");
  expect(f.git("log", "-1", "--format=%s")).toBe(
    "feat(test): complete feature",
  );
  expect(f.git("rev-parse", "HEAD@{1}")).toBe(old);
});

test("consolidation then rebase integrates a newer base once", () => {
  const f = fixture();
  f.commit("first");
  f.commit("final");
  f.git("switch", "main");
  writeFileSync(join(f.root, "base.txt"), "new base");
  f.git("add", "base.txt");
  f.git("commit", "-m", "feat(test): base advance");
  f.git("switch", "ben-malinski/T-1/feature");
  expect(f.run().code).toBe(0);
  expect(f.git("rev-parse", "HEAD^")).toBe(f.base);
  f.git("rebase", "main");
  expect(f.git("rev-list", "--count", "main..HEAD")).toBe("1");
  expect(f.git("show", "HEAD:base.txt")).toBe("new base");
  expect(f.git("show", "HEAD:feature.txt")).toBe("final");
});

test("one existing feature commit is left intact", () => {
  const f = fixture();
  f.commit("final");
  const old = f.git("rev-parse", "HEAD");
  expect(f.run().out).toContain("1 feature commit(s); unchanged");
  expect(f.git("rev-parse", "HEAD")).toBe(old);
});

test("a stale expected HEAD never rewrites newer work", () => {
  const f = fixture();
  f.commit("first");
  const stale = f.git("rev-parse", "HEAD");
  f.commit("newer");
  const current = f.git("rev-parse", "HEAD");
  expect(f.run(stale).err).toContain("HEAD changed");
  expect(f.git("rev-parse", "HEAD")).toBe(current);
});

test("dirty or active operations preserve the original tip", () => {
  const f = fixture();
  f.commit("first");
  f.commit("final");
  const old = f.git("rev-parse", "HEAD");
  const file = join(f.root, "untracked.txt");
  writeFileSync(file, "user work");
  expect(f.run().err).toContain("Dirty worktree");
  f.git("add", "untracked.txt");
  expect(f.run().err).toContain("Dirty worktree");
  // Undo only this test fixture's staged probe, not product code behavior.
  f.git("restore", "--staged", "untracked.txt");
  rmSync(file);
  const operation = join(f.root, ".git", "sequencer");
  mkdirSync(operation);
  expect(f.run().err).toContain("active git operation");
  expect(f.git("rev-parse", "HEAD")).toBe(old);
});

for (const identity of ["author", "committer"]) {
  test(`foreign ${identity} is not folded into the owner`, () => {
    const f = fixture();
    if (identity === "committer") {
      f.git("config", "user.email", "other@example.com");
    }
    f.commit("first", "Other person <other@example.com>");
    if (identity === "committer") {
      f.git(
        "commit",
        "--amend",
        "--author",
        "Test owner <owner@example.com>",
        "--no-edit",
      );
    }
    f.git("config", "user.email", "owner@example.com");
    f.commit("final");
    const old = f.git("rev-parse", "HEAD");
    expect(f.run().err).toContain("Foreign author/committer");
    expect(f.git("rev-parse", "HEAD")).toBe(old);
  });
}

test("merge topology is not silently flattened", () => {
  const f = fixture();
  f.commit("feature");
  f.git("switch", "-c", "side", f.base);
  f.git("commit", "--allow-empty", "-m", "feat(test): side history");
  f.git("switch", "ben-malinski/T-1/feature");
  f.git("merge", "--no-ff", "side", "-m", "feat(test): merge side");
  const old = f.git("rev-parse", "HEAD");
  expect(f.run().err).toContain("Merge topology");
  expect(f.git("rev-parse", "HEAD")).toBe(old);
});

test("default, base, detached, and multiply checked out branches are rejected", () => {
  const f = fixture();
  f.commit("first");
  f.commit("final");
  const old = f.git("rev-parse", "HEAD");
  expect(f.run(old, "ben-malinski/T-1/feature").err).toContain("base branch");
  f.git("switch", "--detach");
  expect(f.run().err).toContain("Detached HEAD");
  f.git("switch", "main");
  expect(f.run().err).toContain("Default/shared");
  f.git("switch", "ben-malinski/T-1/feature");
  const other = join(
    tmpdir(),
    `pr-maintenance-other-${process.pid}-${Date.now()}`,
  );
  directories.push(other);
  f.git("worktree", "add", "--force", other, "ben-malinski/T-1/feature");
  expect(f.run().err).toContain("another worktree owner");
  expect(f.git("rev-parse", "HEAD")).toBe(old);
});

test("the observed remote default is protected even with a custom name", () => {
  const f = fixture();
  f.commit("first");
  f.commit("final");
  f.git("branch", "-m", "release");
  f.git("update-ref", "refs/remotes/origin/release", "HEAD");
  f.git(
    "symbolic-ref",
    "refs/remotes/origin/HEAD",
    "refs/remotes/origin/release",
  );
  expect(f.run().err).toContain("Default branch");
  expect(f.git("rev-list", "--count", "main..HEAD")).toBe("2");
});

test("a concurrent ref update is rejected atomically without overwriting it", () => {
  const f = fixture();
  f.commit("first");
  f.commit("final");
  const old = f.git("rev-parse", "HEAD");
  const bin = mkdtempSync(join(tmpdir(), "pr-maintenance-race-"));
  directories.push(bin);
  const actualGit = Bun.which("git");
  if (!actualGit) throw new Error("git is required");
  // Inject a concurrent writer at the git-process boundary, after final guards.
  writeFileSync(
    join(bin, "git"),
    `#!${process.execPath}
const args = process.argv.slice(2);
const git = ${JSON.stringify(actualGit)};
if (args[0] === "update-ref") {
  const writer = Bun.spawnSync([git, "commit", "--allow-empty", "-m", "feat(test): concurrent writer"]);
  if (writer.exitCode !== 0) process.exit(writer.exitCode ?? 1);
}
const result = Bun.spawnSync([git, ...args]);
process.stdout.write(result.stdout);
process.stderr.write(result.stderr);
process.exit(result.exitCode ?? 1);
`,
    { mode: 0o755 },
  );
  const result = f.run(old, "main", { PATH: `${bin}:${Bun.env.PATH}` });
  expect(result.code).toBe(128);
  expect(result.err).toContain("expected");
  expect(f.git("log", "-1", "--format=%s")).toBe(
    "feat(test): concurrent writer",
  );
  expect(f.git("rev-parse", "HEAD^")).toBe(old);
});

test("consolidation preserves co-author attribution from every folded commit", () => {
  const f = fixture();
  f.commit("first");
  f.git(
    "commit",
    "--amend",
    "-m",
    "feat(test): first\n\nCo-authored-by: First <first@example.com>",
  );
  f.commit("final");
  f.git(
    "commit",
    "--amend",
    "-m",
    "fix(test): final\n\nCo-authored-by: Second <second@example.com>",
  );
  expect(f.run().code).toBe(0);
  const message = f.git("log", "-1", "--format=%B");
  expect(message).toContain("Co-authored-by: First <first@example.com>");
  expect(message).toContain("Co-authored-by: Second <second@example.com>");
});
