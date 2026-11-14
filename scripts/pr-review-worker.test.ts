import { afterEach, expect, spyOn, test } from "bun:test";
import {
  mkdirSync,
  mkdtempSync,
  realpathSync,
  rmSync,
  writeFileSync,
} from "node:fs";
import { release, tmpdir } from "node:os";
import { join } from "node:path";
import { runIsolatedReview } from "./pr-review-worker";

const dirs: string[] = [];
afterEach(() => {
  for (const dir of dirs.splice(0))
    rmSync(dir, { recursive: true, force: true });
});

function fixture() {
  const root = realpathSync(
    mkdtempSync(join(tmpdir(), "isolated-review-test-")),
  );
  dirs.push(root);
  for (const name of ["checkout", "guidance", "auth", "launcher", "ledger"])
    mkdirSync(join(root, name));
  mkdirSync(join(root, "launcher/.git"));
  writeFileSync(
    join(root, "checkout/source.ts"),
    "export const answer = 42;\n",
  );
  writeFileSync(join(root, "guidance/SKILL.md"), "Review source only.\n");
  writeFileSync(join(root, "review.diff"), "diff fixture\n");
  return {
    model: "gpt-6.1-sol",
    effort: "xhigh",
    prompt: "Review the source.",
    checkout: join(root, "checkout"),
    diff: join(root, "review.diff"),
    guidanceRoots: [join(root, "guidance")],
    output: join(root, "launcher/result.json"),
    authHome: join(root, "auth"),
    publisherRoots: [join(root, "ledger")],
  };
}

test("rejects unsupported providers before launching any worker", () => {
  const spawn = spyOn(Bun, "spawnSync");
  try {
    expect(() =>
      runIsolatedReview({ ...fixture(), model: "claude-opus-4-6" }),
    ).toThrow("Unsupported isolated review provider");
    expect(spawn).not.toHaveBeenCalled();
  } finally {
    spawn.mockRestore();
  }
});

const nativeHost = process.platform === "darwin" && release().startsWith("27.");
function subprocess(stdout: string, exitCode = 0) {
  return {
    stdout: Buffer.from(stdout),
    stderr: Buffer.from(""),
    exitCode,
  } as ReturnType<typeof Bun.spawnSync>;
}

test("rejects unverified platforms before launching any worker", () => {
  const descriptor = Object.getOwnPropertyDescriptor(process, "platform");
  const spawn = spyOn(Bun, "spawnSync");
  try {
    Object.defineProperty(process, "platform", { value: "linux" });
    expect(() => runIsolatedReview(fixture())).toThrow(
      "verified Darwin 27 Seatbelt required",
    );
    expect(spawn).not.toHaveBeenCalled();
  } finally {
    if (descriptor) Object.defineProperty(process, "platform", descriptor);
    spawn.mockRestore();
  }
});

test.skipIf(!nativeHost)(
  "rejects ambient user config without invoking Codex",
  () => {
    const input = fixture();
    writeFileSync(
      join(input.authHome, "config.toml"),
      "sandbox_mode='danger-full-access'\n",
    );
    const spawn = spyOn(Bun, "spawnSync");
    try {
      expect(() => runIsolatedReview(input)).toThrow(
        "dedicated auth-only CODEX_HOME",
      );
      expect(spawn).not.toHaveBeenCalled();
    } finally {
      spawn.mockRestore();
    }
  },
);

test.skipIf(!nativeHost)(
  "rejects unsupported CLI and unknown or enabled MCP before model dispatch",
  () => {
    for (const [version, mcp, error] of [
      ["codex-cli 0.166.0", "[]", "Codex 0.167.0 or 0.167.1 required"],
      ["codex-cli 0.167.2", "[]", "Codex 0.167.0 or 0.167.1 required"],
      [
        "codex-cli 0.167.1",
        '[{"name":"github","enabled":true}]',
        "effective MCP servers",
      ],
      [
        "codex-cli 0.167.0",
        '[{"name":"github","enabled":true}]',
        "effective MCP servers",
      ],
      ["codex-cli 0.167.0", '[{"name":"unknown"}]', "effective MCP servers"],
      ["codex-cli 0.167.0", "not-json", "effective MCP servers"],
    ]) {
      let dispatched = false;
      const spawn = spyOn(Bun, "spawnSync").mockImplementation((cmd) => {
        if (!Array.isArray(cmd)) throw new Error("Unexpected subprocess shape");
        if (cmd.includes("exec")) dispatched = true;
        return subprocess(
          cmd.includes("--version") ? `${version}\n` : (mcp ?? ""),
        );
      });
      try {
        expect(() => runIsolatedReview(fixture())).toThrow(error);
        expect(dispatched).toBe(false);
      } finally {
        spawn.mockRestore();
      }
    }
  },
);

test.skipIf(!nativeHost)(
  "real no-model Seatbelt probes deny publisher, symlink, writes and loopback before sanitized dispatch",
  () => {
    const input = fixture();
    const realSpawn = Bun.spawnSync;
    const previous = {
      GH_TOKEN: process.env.GH_TOKEN,
      SSH_AUTH_SOCK: process.env.SSH_AUTH_SOCK,
      HTTP_PROXY: process.env.HTTP_PROXY,
    };
    Object.assign(process.env, {
      GH_TOKEN: "dummy-gh-secret",
      SSH_AUTH_SOCK: "/dummy/agent",
      HTTP_PROXY: "http://127.0.0.1:1",
    });
    let dispatched = false;
    const spawn = spyOn(Bun, "spawnSync").mockImplementation(((
      cmd: string[],
      options?: Parameters<typeof Bun.spawnSync>[1],
    ) => {
      if (!Array.isArray(cmd)) throw new Error("Unexpected subprocess shape");
      if (cmd[1] !== "exec") {
        if (
          cmd[0] === "/usr/bin/nc" ||
          cmd[1] === "--version" ||
          cmd[1] === "sandbox" ||
          (cmd[1] === "mcp" && cmd[2] === "list")
        ) {
          if (cmd[1] === "sandbox") {
            expect(cmd).not.toContain("-P");
            expect(cmd).not.toContain("-C");
            expect(cmd).not.toContain("--include-managed-config");
          }
          return realSpawn(cmd, options);
        }
        throw new Error(
          "Refusing unexpected native command during no-model test",
        );
      }
      dispatched = true;
      expect(options?.cwd).toBe(
        input.output.slice(0, input.output.lastIndexOf("/")),
      );
      expect(options?.env).not.toHaveProperty("GH_TOKEN");
      expect(options?.env).not.toHaveProperty("SSH_AUTH_SOCK");
      expect(options?.env).not.toHaveProperty("HTTP_PROXY");
      expect(options?.stdin?.toString()).toBe(input.prompt);
      expect(cmd).toContain("--ignore-user-config");
      expect(cmd).toContain("--strict-config");
      expect(cmd).not.toContain("--sandbox");
      expect(cmd).toContain('shell_environment_policy.inherit="none"');
      expect(cmd).toContain("features.multi_agent_v2=false");
      expect(cmd).toContain("features.plugins=false");
      return subprocess('{"type":"review-test-dispatch"}\n');
    }) as typeof Bun.spawnSync);
    try {
      const result = runIsolatedReview(input);
      expect(dispatched).toBe(true);
      expect(result.exitCode).toBe(0);
      expect(result.isolation.networkPolicy).toBe("disabled");
      expect(result.isolation.ambientMcpServers).toBe(0);
    } finally {
      spawn.mockRestore();
      for (const [key, value] of Object.entries(previous)) {
        if (value === undefined) delete process.env[key];
        else process.env[key] = value;
      }
    }
  },
);
