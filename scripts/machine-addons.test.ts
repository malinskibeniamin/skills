import { afterEach, expect, test } from "bun:test";
import {
  existsSync,
  copyFileSync,
  mkdtempSync,
  mkdirSync,
  readFileSync,
  rmSync,
  symlinkSync,
  writeFileSync,
} from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";

const roots: string[] = [];
afterEach(() => {
  for (const root of roots.splice(0))
    rmSync(root, { recursive: true, force: true });
});
function fixture() {
  const root = mkdtempSync(join(tmpdir(), "machine-addons-"));
  roots.push(root);
  for (const name of ["claude-home", "codex-home", "bin"])
    mkdirSync(join(root, name));
  const cli = join(root, "cli.py");
  writeFileSync(
    cli,
    `#!/usr/bin/env python3
import json,os,pathlib,sys,tomllib
args=sys.argv[1:]; host=pathlib.Path(sys.argv[0]).name
if args==['--version']: print('test'); sys.exit()
with open(os.environ['CALLS'],'a') as f:f.write(json.dumps([host,*args])+'\\n')
if host=='claude':
 p=pathlib.Path(os.environ['CLAUDE_CONFIG_DIR'])/'.claude.json'
 d=json.loads(p.read_text()) if p.exists() else {}
 if args[:2]==['mcp','add-json']:
  d.setdefault('mcpServers',{})[args[-2]]=json.loads(args[-1]);p.write_text(json.dumps(d))
else:
 p=pathlib.Path(os.environ['CODEX_HOME'])/'config.toml'
 if args[:2]==['mcp','add']:
  name=args[2];url=args[4]
  with p.open('a') as f:f.write('[mcp_servers.'+name+']\\nurl = '+json.dumps(url)+'\\n')
print('{}')
`,
    { mode: 0o755 },
  );
  for (const name of ["claude", "codex"])
    symlinkSync(cli, join(root, "bin", name));
  const config = join(root, "codex-home/config.toml");
  writeFileSync(config, 'model = "keep-my-model"\n');
  const state = join(root, "state");
  const env = {
    ...process.env,
    HOME: root,
    CLAUDE_CONFIG_DIR: join(root, "claude-home"),
    CODEX_HOME: join(root, "codex-home"),
    CLAUDE_BIN: join(root, "bin/claude"),
    CODEX_BIN: join(root, "bin/codex"),
    CALLS: join(root, "calls"),
  };
  const run = (...args: string[]) =>
    Bun.spawnSync(
      [
        "python3",
        new URL("./machine-addons.py", import.meta.url).pathname,
        "--state-dir",
        state,
        ...args,
      ],
      { env },
    );
  return { root, state, config, run };
}

test("plan does not launch tools or save approval; apply needs explicit enrollment", () => {
  const f = fixture();
  expect(f.run("plan").exitCode).toBe(0);
  expect(existsSync(f.state)).toBe(false);
  expect(existsSync(join(f.root, "calls"))).toBe(false);
  const unapproved = f.run("--only", "openai-docs", "apply");
  expect(unapproved.exitCode).toBe(1);
  expect(unapproved.stderr.toString()).toContain("--yes");
  expect(existsSync(f.state)).toBe(false);
});

test("enrolls docs in both hosts, preserves the model, and never expands saved consent", () => {
  const f = fixture();
  const first = f.run("--only", "openai-docs", "--yes", "apply");
  expect(
    first.exitCode,
    first.stderr.toString() + first.stdout.toString(),
  ).toBe(0);
  expect(readFileSync(f.config, "utf8")).toContain('model = "keep-my-model"');
  expect(f.run("status").exitCode).toBe(0);
  const rerun = f.run("apply");
  expect(rerun.exitCode, rerun.stderr.toString()).toBe(0);
  expect(
    JSON.parse(readFileSync(join(f.state, "addons-consent.json"), "utf8"))
      .capabilities,
  ).toEqual(["openai-docs"]);
  expect(f.run("--only", "media", "apply").exitCode).toBe(1);
  expect(readFileSync(join(f.root, "calls"), "utf8")).not.toContain('"npm"');
  writeFileSync(f.config, `${readFileSync(f.config, "utf8")}enabled = false\n`);
  const disabled = readFileSync(f.config, "utf8");
  expect(f.run("status").exitCode).toBe(1);
  expect(f.run("apply").exitCode).toBe(1);
  expect(readFileSync(f.config, "utf8")).toBe(disabled);
});

test("does not replace an existing same-name connection or report it as ready", () => {
  const f = fixture();
  writeFileSync(
    f.config,
    'model = "keep-my-model"\n[mcp_servers.openaiDeveloperDocs]\nurl = "https://existing.example/mcp"\n',
  );
  const original = readFileSync(f.config, "utf8");
  const result = f.run("--only", "openai-docs", "--yes", "apply");
  expect(result.exitCode).toBe(1);
  expect(result.stdout.toString()).toContain("refusing to overwrite");
  expect(readFileSync(f.config, "utf8")).toBe(original);
  expect(f.run("status").exitCode).toBe(1);
});

test("installed runner finds its sibling profile without the bootstrap checkout", () => {
  const f = fixture();
  mkdirSync(f.state);
  for (const name of ["machine-addons.py", "machine-sync.py"])
    copyFileSync(new URL(`./${name}`, import.meta.url), join(f.state, name));
  copyFileSync(
    new URL("../config/machine-addons.json", import.meta.url),
    join(f.state, "machine-addons.json"),
  );
  const result = Bun.spawnSync(
    ["python3", join(f.state, "machine-addons.py"), "plan"],
    { cwd: f.root },
  );
  expect(result.exitCode, result.stderr.toString()).toBe(0);
  expect(JSON.parse(result.stdout.toString()).startIndexer).toBe(false);
});
