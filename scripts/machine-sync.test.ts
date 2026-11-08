import { afterEach, expect, test } from "bun:test";
import {
  mkdtempSync,
  mkdirSync,
  readFileSync,
  rmSync,
  writeFileSync,
} from "node:fs";
import { tmpdir } from "node:os";
import { join, resolve } from "node:path";

const roots: string[] = [];
afterEach(() => {
  for (const root of roots.splice(0))
    rmSync(root, { recursive: true, force: true });
});

function fixture() {
  const root = mkdtempSync(join(tmpdir(), "machine-sync-test-"));
  roots.push(root);
  const repo = join(root, "source");
  const state = join(root, "state");
  mkdirSync(repo);
  const run = (args: string[]) => {
    const result = Bun.spawnSync(args, {
      cwd: repo,
      env: {
        ...process.env,
        GIT_CONFIG_GLOBAL: "/dev/null",
        GIT_CONFIG_NOSYSTEM: "1",
      },
    });
    expect(result.exitCode).toBe(0);
    return result.stdout.toString().trim();
  };
  const put = (path: string, data: unknown) => {
    mkdirSync(join(repo, path, ".."), { recursive: true });
    writeFileSync(
      join(repo, path),
      typeof data === "string" ? data : JSON.stringify(data),
    );
  };
  put(".claude-plugin/plugin.json", {
    name: "frontend-skills",
    version: "1.0.0",
    skills: ["./review/"],
    hooks: "./hooks/hooks.json",
  });
  put(".codex-plugin/plugin.json", {
    name: "frontend-skills",
    version: "1.0.0",
    skills: "./codex-skills/",
    hooks: "./hooks/codex-hooks.json",
  });
  for (const path of [
    ".claude-plugin/marketplace.json",
    ".agents/plugins/marketplace.json",
  ])
    put(path, {
      name: "skills",
      owner: { name: "test" },
      plugins: [{ name: "frontend-skills", source: "./", version: "1.0.0" }],
    });
  put("review/SKILL.md", "---\nname: review\n---\nReview things.\n");
  put(
    "codex-skills/review/SKILL.md",
    "---\nname: review\n---\nRead ../../review/SKILL.md\n",
  );
  put("hooks/hooks.json", { hooks: {} });
  put("hooks/codex-hooks.json", { hooks: {} });
  run(["git", "init", "-b", "main"]);
  const commit = () => {
    run(["git", "add", "."]);
    run([
      "git",
      "-c",
      "user.name=Test",
      "-c",
      "user.email=test@example.com",
      "commit",
      "-qm",
      "fixture",
    ]);
    return run(["git", "rev-parse", "HEAD"]);
  };
  const sha = commit();
  // Hosts are external process boundaries. Real host compatibility is also
  // exercised by the existing isolated native plugin installers.
  const host = join(root, "host.py");
  writeFileSync(
    host,
    `#!/usr/bin/env python3
import json, os, pathlib, shutil, sys
host = pathlib.Path(sys.argv[0]).name
args = sys.argv[1:]
r = pathlib.Path(os.environ['FAKE_HOME']) / 'hosts' / host
r.mkdir(parents=True, exist_ok=True)
if os.environ.get('FAIL_CODEX') and host == 'codex' and args[:2] == ['plugin','add']: sys.exit(9)
if args == ['--version']: print('test'); sys.exit()
if args[:3] == ['plugin', 'marketplace', 'list']:
 entries = [{'name':'skills','repo':'other/skills','root':'/unrelated','marketplaceSource':{'source':'https://github.com/other/skills.git'}}] if os.environ.get('FOREIGN_MARKETPLACE') else []
 print(json.dumps(entries if host == 'claude' else {'marketplaces':entries})); sys.exit()
if args[:3] == ['plugin', 'marketplace', 'add']:
 (r/'source').write_text(args[3]); print('{}'); sys.exit()
if host == 'claude' and args[:2] == ['plugin','install'] and (r/'installed').exists(): print('{}'); sys.exit()
if args[:2] in [['plugin','install'],['plugin','add'],['plugin','update']]:
 marketplace = pathlib.Path((r/'source').read_text())
 source = marketplace / json.loads((marketplace/'.claude-plugin/marketplace.json').read_text())['plugins'][0]['source']
 version = json.loads((source/'.codex-plugin/plugin.json').read_text())['version']
 cache = r/version
 if not cache.exists(): shutil.copytree(source, cache, symlinks=True)
 (r/'installed').write_text(json.dumps({'id':'frontend-skills@skills','pluginId':'frontend-skills@skills','version':version,'enabled':True,'scope':'user','installPath':str(cache),'source':{'path':str(cache)}}))
 print(json.dumps({'installedPath':str(cache)})); sys.exit()
if args[:2] == ['plugin','list']:
 items = [json.loads((r/'installed').read_text())] if (r/'installed').exists() else []
 print(json.dumps(items if host == 'claude' else {'installed':items})); sys.exit()
if args[:2] == ['features','list']: print('hooks stable ' + ('false' if os.environ.get('DISABLE_HOOKS') else 'true') + '\\nplugins stable true'); sys.exit()
print('{}')
`,
    { mode: 0o755 },
  );
  const env = {
    ...process.env,
    FAKE_HOME: root,
    CLAUDE_BIN: join(root, "claude"),
    CODEX_BIN: join(root, "codex"),
  };
  for (const name of ["claude", "codex"])
    Bun.spawnSync(["ln", "-s", host, join(root, name)]);
  const argv = (command: string) => [
    "python3",
    resolve("scripts/machine-sync.py"),
    "--state-dir",
    state,
    "--source",
    repo,
    command,
  ];
  const sync = (command: string, extraEnv = {}) =>
    Bun.spawnSync(argv(command), { env: { ...env, ...extraEnv } });
  return { root, state, put, commit, sha, sync, env, argv };
}

test("sync installs one revision for both hosts and detects installed file drift", () => {
  const f = fixture();
  const result = f.sync("sync");
  expect(result.stderr.toString()).toBe("");
  expect(result.exitCode).toBe(0);
  const receipt = JSON.parse(
    readFileSync(join(f.state, "current.json"), "utf8"),
  );
  expect(receipt.revision).toBe(f.sha);
  expect(f.sync("status").exitCode).toBe(0);
  const disabled = f.sync("status", { DISABLE_HOOKS: "1" });
  expect(disabled.exitCode).toBe(1);
  expect(disabled.stdout.toString()).toContain("hooks");
  writeFileSync(join(receipt.hosts.codex.path, "review/SKILL.md"), "broken");
  const status = f.sync("status");
  expect(status.exitCode).toBe(1);
  expect(status.stdout.toString()).toContain("review/SKILL.md");
});

test("same-version commits get distinct immutable bundles and rollback restores both hosts", () => {
  const f = fixture();
  expect(f.sync("sync").exitCode).toBe(0);
  f.put("review/SKILL.md", "Updated without a release bump");
  const second = f.commit();
  expect(f.sync("sync").exitCode).toBe(0);
  const receipt = JSON.parse(
    readFileSync(join(f.state, "current.json"), "utf8"),
  );
  expect(receipt.revision).toBe(second);
  expect(receipt.version).toBe(`1.0.0-sync.${second}`);
  expect(f.sync("rollback").exitCode).toBe(0);
  expect(
    JSON.parse(readFileSync(join(f.state, "current.json"), "utf8")).revision,
  ).toBe(f.sha);
  expect(f.sync("status").exitCode).toBe(0);
});

test("failed second host does not publish a successful receipt and remains visible", () => {
  const f = fixture();
  expect(f.sync("sync").exitCode).toBe(0);
  f.put("review/SKILL.md", "new revision");
  f.commit();
  expect(f.sync("sync", { FAIL_CODEX: "1" }).exitCode).toBe(1);
  expect(
    JSON.parse(readFileSync(join(f.state, "current.json"), "utf8")).revision,
  ).toBe(f.sha);
  expect(f.sync("status").exitCode).toBe(1);
});

test("refuses an unrelated marketplace before changing either host", () => {
  const f = fixture();
  expect(f.sync("sync").exitCode).toBe(0);
  const installation = join(f.root, "hosts/claude/installed");
  const before = readFileSync(installation, "utf8");
  f.put("review/SKILL.md", "new source, unrelated registry");
  f.commit();
  const denied = f.sync("sync", { FOREIGN_MARKETPLACE: "1" });
  expect(denied.exitCode).toBe(1);
  expect(denied.stderr.toString()).toContain("unrelated");
  expect(readFileSync(installation, "utf8")).toBe(before);
});

test("a scheduled mutation waits for a concurrent health check instead of losing its run", async () => {
  const f = fixture();
  expect(f.sync("sync").exitCode).toBe(0);
  const holder = Bun.spawn(
    [
      "python3",
      "-u",
      "-c",
      "import fcntl,sys; f=open(sys.argv[1],'w'); fcntl.flock(f,fcntl.LOCK_EX); print('locked'); input()",
      join(f.state, "lock"),
    ],
    { stdin: "pipe", stdout: "pipe" },
  );
  let queued: Bun.Subprocess<"ignore", "pipe", "pipe"> | undefined;
  try {
    const locked = await holder.stdout.getReader().read();
    expect(new TextDecoder().decode(locked.value)).toContain("locked");
    queued = Bun.spawn(f.argv("sync"), {
      env: f.env,
      stdin: "ignore",
      stdout: "pipe",
      stderr: "pipe",
    });
    const output = queued.stdout.getReader();
    const waiting = await output.read();
    expect(new TextDecoder().decode(waiting.value)).toContain("Waiting");
    holder.stdin.write("\n");
    holder.stdin.end();
    expect(await holder.exited).toBe(0);
    while (!(await output.read()).done) {
      /* drain the CLI receipt */
    }
    expect(await queued.exited).toBe(0);
    expect(f.sync("status").exitCode).toBe(0);
  } finally {
    holder.kill();
    queued?.kill();
    await holder.exited;
    if (queued) await queued.exited;
  }
});
