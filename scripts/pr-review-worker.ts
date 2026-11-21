import {
  existsSync,
  lstatSync,
  mkdirSync,
  mkdtempSync,
  readdirSync,
  realpathSync,
  rmSync,
  symlinkSync,
  writeFileSync,
} from "node:fs";
import { homedir, release, tmpdir } from "node:os";
import { basename, dirname, join, resolve, sep } from "node:path";

type ReviewInput = {
  model: string;
  effort: string;
  prompt: string;
  checkout: string;
  diff: string;
  guidanceRoots: readonly string[];
  output: string;
  authHome?: string | undefined;
  publisherRoots: readonly string[];
};

const disabledFeatures = [
  "apps",
  "plugins",
  "hooks",
  "codex_hooks",
  "plugin_hooks",
  "multi_agent",
  "multi_agent_v2",
  "in_app_browser",
  "browser_use",
  "computer_use",
  "shell_snapshot",
  "shell_snapshot_v2",
  "skill_mcp_dependency_install",
  "skill_env_var_dependency_prompt",
  "skill_search",
  "image_generation",
  "imagegenext",
  "js_repl",
  "memories",
  "memory_tool",
  "remote_control",
  "remote_plugin",
  "plugin_discovery_prefetch",
  "apps_early_resource_discovery",
  "connectors",
  "search_tool",
  "web_search",
  "standalone_web_search",
  "external_agent_memory_import",
  "daemon_auto_start",
  "request_permissions_tool",
];

function contains(parent: string, child: string) {
  return parent === child || child.startsWith(`${parent}${sep}`);
}
function canonical(path: string) {
  return realpathSync(resolve(path));
}
function quote(value: string) {
  return JSON.stringify(value);
}
function shellQuote(value: string) {
  return `'${value.replaceAll("'", "'\\''")}'`;
}
function table(values: Record<string, string>) {
  return `{${Object.entries(values)
    .map(([key, value]) => `${quote(key)}=${quote(value)}`)
    .join(",")}}`;
}
function sourceFile(root: string): string | undefined {
  const entries = readdirSync(root, { withFileTypes: true });
  const file = entries.find((entry) => entry.isFile());
  if (file) return join(root, file.name);
  for (const entry of entries) {
    if (entry.isDirectory() && ![".git", ".codex"].includes(entry.name)) {
      const found = sourceFile(join(root, entry.name));
      if (found) return found;
    }
  }
}

/** Trusted CLI keeps provider authentication; model tools receive no publisher env. */
export function runIsolatedReview(input: ReviewInput) {
  if (!/^gpt-[a-z0-9][a-z0-9.-]*$/.test(input.model))
    throw new Error(
      "Unsupported isolated review provider: only explicit GPT models are verified",
    );
  if (
    !["low", "medium", "high", "xhigh", "max", "ultra"].includes(input.effort)
  )
    throw new Error("Unsupported isolated review reasoning effort");
  if (process.platform !== "darwin" || release().split(".")[0] !== "27")
    throw new Error(
      "Unsupported review isolation capability: verified Darwin 27 Seatbelt required",
    );
  const executable = ["/opt/homebrew/bin/codex", "/usr/local/bin/codex"].find(
    (path) => existsSync(path),
  );
  if (!executable)
    throw new Error(
      "Unsupported review isolation capability: trusted Codex installation missing",
    );
  const codex = canonical(executable);
  const checkout = canonical(input.checkout);
  const diff = canonical(input.diff);
  const guidance = input.guidanceRoots.map(canonical);
  const cwd = canonical(dirname(input.output));
  const output = join(cwd, basename(input.output));
  const auth = canonical(
    input.authHome ?? process.env.CODEX_HOME ?? join(homedir(), ".codex"),
  );
  if (
    existsSync(join(auth, "config.toml")) ||
    existsSync(join(auth, "managed_config.toml"))
  )
    throw new Error(
      "Review isolation requires a dedicated auth-only CODEX_HOME without config.toml or managed_config.toml",
    );
  if (existsSync(join(cwd, ".codex")) || !existsSync(join(cwd, ".git")))
    throw new Error(
      "Review isolation requires a private config-free Git launcher directory",
    );
  if (
    [
      "/etc/codex/config.toml",
      "/etc/codex/managed_config.toml",
      join(cwd, "config.toml"),
    ].some((path) => existsSync(path))
  )
    throw new Error(
      "Review isolation bootstrap rejected: system, managed or launcher config may override permission profiles; use a config-free automation host",
    );
  if (
    !lstatSync(checkout).isDirectory() ||
    !lstatSync(diff).isFile() ||
    !guidance.length
  )
    throw new Error(
      "Review isolation requires a checkout, diff file and trusted guidance roots",
    );
  const protectedRoots = [...input.publisherRoots.map(canonical), auth, output];
  const allowed = [checkout, diff, ...guidance];
  if (
    allowed.some(
      (root) =>
        contains(root, auth) ||
        contains(auth, root) ||
        protectedRoots.some((protectedRoot) => contains(root, protectedRoot)) ||
        contains(root, cwd),
    )
  )
    throw new Error(
      "Review isolation readable roots overlap publisher authentication, ledger or launcher",
    );

  const scratch = canonical(mkdtempSync(join(tmpdir(), "pr-review-worker-")));
  let listener: { stop(closeActiveConnections?: boolean): void } | undefined;
  const writeCanary = join(
    checkout,
    `.review-isolation-${crypto.randomUUID()}`,
  );
  const symlinkCanary = join(checkout, `.review-escape-${crypto.randomUUID()}`);
  try {
    const home = join(scratch, "home");
    mkdirSync(home, { mode: 0o700 });
    const env = {
      PATH: "/usr/bin:/bin",
      HOME: home,
      TMPDIR: scratch,
      CODEX_HOME: auth,
      LANG: "en_US.UTF-8",
    };
    const run = (args: string[], timeout = 30_000, stdin?: string) => {
      const result = Bun.spawnSync([codex, ...args], {
        cwd,
        env,
        timeout,
        ...(stdin === undefined ? {} : { stdin: Buffer.from(stdin) }),
      });
      return {
        stdout: result.stdout.toString(),
        stderr: result.stderr.toString(),
        exitCode: result.exitCode,
      };
    };
    const version = run(["--version"]);
    if (
      version.exitCode !== 0 ||
      !["codex-cli 0.167.0", "codex-cli 0.167.1"].includes(
        version.stdout.trim(),
      )
    )
      throw new Error(
        "Unsupported review isolation capability: Codex 0.167.0 or 0.167.1 required",
      );
    const profile = `review_${crypto.randomUUID().replaceAll("-", "")}`;
    const filesystem: Record<string, string> = {
      ":root": "deny",
      ":minimal": "read",
      ":tmpdir": "deny",
      ":slash_tmp": "deny",
      [canonical("/private/tmp")]: "deny",
      [canonical(tmpdir())]: "deny",
      [canonical(homedir())]: "deny",
      [scratch]: "deny",
    };
    for (const root of protectedRoots) filesystem[root] = "deny";
    for (const root of allowed) filesystem[root] = "read";
    const configs = [
      `default_permissions=${quote(profile)}`,
      `permissions.${profile}={filesystem=${table(filesystem)},network={enabled=false}}`,
      'approval_policy="never"',
      'web_search="disabled"',
      'model_provider="openai"',
      "agents.enabled=false",
      "notify=[]",
      "project_doc_max_bytes=0",
      'shell_environment_policy.inherit="none"',
      "shell_environment_policy.experimental_use_profile=false",
      `shell_environment_policy.set=${table({ PATH: "/usr/bin:/bin", HOME: home, TMPDIR: scratch })}`,
      ...disabledFeatures.map((feature) => `features.${feature}=false`),
      "features.skip_host_skill_discovery=true",
    ].flatMap((setting) => ["-c", setting]);

    // This read-only command does not connect servers. Unknown/forced integrations fail closed.
    const mcp = run(["mcp", "list", "--json", ...configs]);
    let servers: unknown;
    try {
      servers = JSON.parse(mcp.stdout);
    } catch {
      /* fail closed below */
    }
    if (
      mcp.exitCode !== 0 ||
      !Array.isArray(servers) ||
      servers.some(
        (server: unknown) =>
          !server ||
          typeof server !== "object" ||
          !("name" in server) ||
          typeof server.name !== "string" ||
          !("enabled" in server) ||
          server.enabled !== false,
      )
    )
      throw new Error(
        "Review isolation bootstrap rejected: effective MCP servers must be known and disabled (use a dedicated auth-only CODEX_HOME)",
      );

    // No model: exercise this exact config, cwd and managed requirements before dispatch.
    const denied = join(scratch, "publisher-secret");
    writeFileSync(denied, "dummy publisher secret\n", { mode: 0o600 });
    symlinkSync(denied, symlinkCanary);
    const socket = Bun.listen({
      hostname: "127.0.0.1",
      port: 0,
      socket: { data() {} },
    });
    listener = socket;
    const port = socket.port;
    const connect = Bun.spawnSync(
      ["/usr/bin/nc", "-z", "-w", "1", "127.0.0.1", String(port)],
      { env, timeout: 3_000 },
    );
    if (connect.exitCode !== 0)
      throw new Error("Review isolation network positive control unavailable");
    const script = [
      "set -eu",
      "if /usr/bin/env | /usr/bin/sed 's/=.*//' | /usr/bin/grep -Ev '^(PATH|HOME|TMPDIR|PWD|SHLVL|_|LC_CTYPE|CODEX_SANDBOX|CODEX_SANDBOX_NETWORK_DISABLED)$' >/dev/null; then exit 74; fi",
      `/bin/ls ${shellQuote(checkout)} >/dev/null`,
      `/bin/cat ${shellQuote(sourceFile(checkout) ?? diff)} >/dev/null`,
      `/bin/cat ${shellQuote(diff)} >/dev/null`,
      ...guidance.map((root) => `/bin/ls ${shellQuote(root)} >/dev/null`),
      ...[denied, symlinkCanary].map(
        (path) =>
          `if /bin/cat ${shellQuote(path)} >/dev/null 2>&1; then exit 71; fi`,
      ),
      ...[auth, ...input.publisherRoots.map(canonical)].map(
        (path) =>
          `if /bin/ls ${shellQuote(path)} >/dev/null 2>&1; then exit 71; fi`,
      ),
      `if ( : > ${shellQuote(writeCanary)} ) 2>/dev/null; then exit 72; fi`,
      `if /usr/bin/nc -z -w 1 127.0.0.1 ${port} >/dev/null 2>&1; then exit 73; fi`,
      "printf review-isolation-ok",
    ].join("\n");
    const canary = run(["sandbox", ...configs, "/bin/sh", "-c", script]);
    if (canary.exitCode !== 0 || canary.stdout !== "review-isolation-ok")
      throw new Error(
        `Review isolation capability probe failed (exit ${canary.exitCode}): source access or publisher/filesystem/network denial not enforced`,
      );
    const result = run(
      [
        "exec",
        "--ignore-user-config",
        "--ignore-rules",
        "--ephemeral",
        "--strict-config",
        ...configs,
        "--model",
        input.model,
        "-c",
        `model_reasoning_effort=${quote(input.effort)}`,
        "-C",
        cwd,
        "--json",
        "-o",
        output,
        "-",
      ],
      900_000,
      input.prompt,
    );
    return {
      ...result,
      isolation: {
        version: "codex-seatbelt-review-v1" as const,
        codexVersion: version.stdout.trim(),
        permissionProfile: profile,
        networkPolicy: "disabled" as const,
        ambientMcpServers: 0 as const,
      },
    };
  } finally {
    listener?.stop(true);
    rmSync(writeCanary, { force: true });
    rmSync(symlinkCanary, { force: true });
    rmSync(scratch, { recursive: true, force: true });
  }
}
