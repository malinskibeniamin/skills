import { afterAll, describe, expect, test } from "bun:test";
import { chmodSync, mkdtempSync, rmSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";

const directory = mkdtempSync(join(tmpdir(), "postgresql-version-"));
const psql = join(directory, "psql");
const script = join(import.meta.dir, "detect-version.ts");
writeFileSync(
  psql,
  `#!${process.execPath}
const args = process.argv.slice(2);
await Bun.write(process.env.PROBE_LOG, JSON.stringify(args));
if (args[0] === "--version") {
  console.log(process.env.CLIENT_BANNER);
} else {
  if (process.env.SERVER_FAILURE) {
    console.error("password=do-not-leak host=private.invalid");
    process.exit(2);
  }
  console.log(process.env.SERVER_RESPONSE);
}
`,
);
chmodSync(psql, 0o755);
afterAll(() => rmSync(directory, { recursive: true, force: true }));

function probe(args: string[] = [], env: Record<string, string> = {}) {
  const result = Bun.spawnSync(
    [process.execPath, script, "--psql", psql, ...args],
    {
      env: {
        ...process.env,
        CLIENT_BANNER: "psql (PostgreSQL) 18.6 (Homebrew)",
        PROBE_LOG: join(directory, "args.json"),
        ...env,
      },
    },
  );
  return {
    code: result.exitCode,
    output: result.stdout.toString(),
    error: result.stderr.toString(),
  };
}

describe("version detection CLI", () => {
  test("detects the local client without connecting or inventing a server", async () => {
    const result = probe();
    expect(result.code).toBe(0);
    expect(JSON.parse(result.output)).toMatchObject({
      client: {
        version: "18.6",
        major: "18",
        version_num: 180006,
        channel: "stable",
      },
      server: null,
    });
    expect(await Bun.file(join(directory, "args.json")).json()).toEqual([
      "--version",
    ]);
  });

  test.each([
    ["19rc1", "19", 190000, "rc"],
    ["19beta4", "19", 190000, "beta"],
    ["20devel", "20", 200000, "devel"],
    ["19.0", "19", 190000, "stable"],
    ["9.6.24", "9.6", 90624, "stable"],
  ])(
    "preserves %s's channel independently of its numeric version",
    (version, major, number, channel) => {
      const result = probe([], {
        CLIENT_BANNER: `psql (PostgreSQL) ${version} (Debian build)`,
      });
      expect(result.code).toBe(0);
      expect(JSON.parse(result.output).client).toMatchObject({
        version,
        major,
        version_num: number,
        channel,
      });
    },
  );

  test("probes only the selected service and reports mismatched versions", async () => {
    const result = probe(["--service", "project-readonly"], {
      SERVER_RESPONSE: JSON.stringify({
        server_version: "19rc1 (Debian)",
        server_version_num: "190000",
        build: "PostgreSQL 19rc1 on aarch64",
      }),
    });
    expect(result.code).toBe(0);
    const report = JSON.parse(result.output);
    expect(report.client.major).toBe("18");
    expect(report.server).toMatchObject({
      version: "19rc1",
      major: "19",
      channel: "rc",
      version_num: 190000,
      build: "PostgreSQL 19rc1 on aarch64",
    });
    expect(report.warnings).toContain(
      "Client is older than server; psql backslash/catalog commands may fail.",
    );
    expect(report.warnings).toContain(
      "Server is prerelease; verify exact-build documentation and open items before advice.",
    );
    const args = await Bun.file(join(directory, "args.json")).json();
    expect(args).toContain("service=project-readonly");
    expect(args).toContain("-X");
    expect(args).toContain("-w");
    expect(args).toContain("ON_ERROR_STOP=1");
    expect(args.at(-1)).toContain("BEGIN READ ONLY");
    expect(args.at(-1)).toContain("statement_timeout = '3s'");
  });

  test.each([
    { SERVER_FAILURE: "1" },
    { SERVER_RESPONSE: "not JSON" },
    {
      SERVER_RESPONSE:
        '{"server_version":"19rc1","server_version_num":"180006","build":"PostgreSQL"}',
    },
  ])("fails closed on failed or inconsistent server evidence", (env) => {
    const result = probe(["--service", "project-readonly"], env);
    expect(result.code).not.toBe(0);
    expect(result.output).toBe("");
    expect(result.error).not.toContain("do-not-leak");
    expect(result.error).not.toContain("private.invalid");
  });

  test.each([
    "service=secret password=do-not-leak",
    "postgres://private.invalid/db",
    "--command",
  ])("rejects connection strings and arbitrary psql options: %s", (service) => {
    const result = probe(["--service", service]);
    expect(result.code).toBe(1);
    expect(result.error).not.toContain("do-not-leak");
  });

  test("fails explicitly when psql is missing", () => {
    const result = probe(["--psql", join(directory, "missing")]);
    expect(result.code).toBe(1);
    expect(result.error).toContain("Client probe failed");
  });

  test("uses the server's version for SQL even with a newer RC client", () => {
    const result = probe(["--service", "project-readonly"], {
      CLIENT_BANNER: "psql (PostgreSQL) 19rc1",
      SERVER_RESPONSE: JSON.stringify({
        server_version: "16.15",
        server_version_num: "160015",
        build: "PostgreSQL 16.15",
      }),
    });
    expect(result.code).toBe(0);
    const report = JSON.parse(result.output);
    expect(report.server).toMatchObject({ major: "16", channel: "stable" });
    expect(report.warnings).toEqual([
      "Client is prerelease; gate psql options on its exact build, not the server version.",
    ]);
  });

  test.each(["unrecognized fork 19", "19", "19.0.1", "19rc1garbage"])(
    "keeps unrecognized client evidence unknown: %s",
    (version) => {
      const result = probe([], {
        CLIENT_BANNER: `psql (PostgreSQL) ${version}`,
      });
      expect(result.code).toBe(1);
      expect(result.output).toBe("");
      expect(result.error).toContain("verify manually");
    },
  );
});
