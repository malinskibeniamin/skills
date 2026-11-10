#!/usr/bin/env bun

import { spawnSync } from "node:child_process";

type Version = {
  version: string;
  major: string;
  version_num: number;
  channel: "stable" | "beta" | "rc" | "devel";
};

function parseVersion(value: string): Version {
  const match =
    /^(\d+)(?:\.(\d+))?(?:\.(\d+))?(?:(beta|rc)(\d+)|(devel))?(?=$|\s)/.exec(
      value,
    );
  if (!match)
    throw new Error("Unrecognized PostgreSQL version; verify manually.");
  const major = Number(match[1]);
  const minor = Number(match[2] ?? 0);
  const patch = Number(match[3] ?? 0);
  if (
    (match[2] === undefined && !match[4] && !match[6]) ||
    (major >= 10 && match[3] !== undefined)
  ) {
    throw new Error("Incomplete PostgreSQL version; verify manually.");
  }
  return {
    version: match[0],
    major: major >= 10 ? String(major) : `${major}.${minor}`,
    version_num: major * 10000 + (major >= 10 ? minor : minor * 100 + patch),
    channel:
      match[4] === "beta"
        ? "beta"
        : match[4] === "rc"
          ? "rc"
          : match[6]
            ? "devel"
            : "stable",
  };
}

let psql = "psql";
let service: string | undefined;
const args = process.argv.slice(2);

try {
  for (let i = 0; i < args.length; i++) {
    const option = args[i];
    if (option === "--help") {
      console.log(
        "Usage: bun detect-version.ts [--psql PATH] [--service NAME]\nWithout --service, detects only the local client. NAME selects an authorized libpq service; no connection URLs or passwords are accepted.",
      );
      process.exit(0);
    }
    const value = args[++i];
    if (!value || value.startsWith("--"))
      throw new Error("Expected --psql PATH or --service NAME.");
    if (option === "--psql") psql = value;
    else if (option === "--service" && /^[\w.-]+$/.test(value)) service = value;
    else
      throw new Error(
        "Expected --psql PATH or --service NAME (letters, digits, _, ., -).",
      );
  }

  function run(command: string[], connect = false) {
    const result = spawnSync(psql, command, {
      encoding: "utf8",
      timeout: 10000,
      maxBuffer: 65536,
      stdio: ["ignore", "pipe", "pipe"],
      // A process deadline also bounds DNS, multi-host services, and auth helpers.
      env: { ...process.env, PGCONNECT_TIMEOUT: "5" },
    });
    if (result.error || result.status !== 0) {
      // libpq errors may contain private endpoints or credentials. Do not echo them.
      throw new Error(
        connect
          ? "Server probe failed; server version unknown. Check the selected service/authentication privately; no automatic retry."
          : "Client probe failed; check the psql executable (--psql PATH). No server connection attempted.",
      );
    }
    return result.stdout.trim();
  }

  const banner = run(["--version"]);
  const client = {
    ...parseVersion(banner.replace(/^psql \(PostgreSQL\)\s+/, "")),
    build: banner,
  };
  let server: (Version & { build: string }) | null = null;
  const warnings: string[] = [];
  if (service) {
    const sql = `BEGIN READ ONLY;
SET LOCAL statement_timeout = '3s';
SET LOCAL lock_timeout = '1s';
SELECT pg_catalog.json_build_object(
  'server_version', pg_catalog.current_setting('server_version'),
  'server_version_num', pg_catalog.current_setting('server_version_num'),
  'build', pg_catalog.version()
);
ROLLBACK;`;
    const output = run(
      [
        "-X",
        "-w",
        "-qAt",
        "-v",
        "ON_ERROR_STOP=1",
        "-d",
        `service=${service}`,
        "-c",
        sql,
      ],
      true,
    );
    try {
      const data: unknown = JSON.parse(output);
      if (
        typeof data !== "object" ||
        data === null ||
        !("server_version" in data) ||
        typeof data.server_version !== "string" ||
        !("server_version_num" in data) ||
        typeof data.server_version_num !== "string" ||
        !("build" in data) ||
        typeof data.build !== "string"
      ) {
        throw new Error();
      }
      const parsed = parseVersion(data.server_version);
      if (String(parsed.version_num) !== data.server_version_num)
        throw new Error();
      server = { ...parsed, build: data.build };
    } catch {
      throw new Error(
        "Unrecognized or inconsistent server version evidence; verify manually.",
      );
    }
    const majorDivisor = server.version_num >= 100000 ? 10000 : 100;
    if (
      client.version_num <
      Math.floor(server.version_num / majorDivisor) * majorDivisor
    ) {
      // Compare majors, including pre-10's two-component major numbering.
      warnings.push(
        "Client is older than server; psql backslash/catalog commands may fail.",
      );
    }
    if (server.channel !== "stable")
      warnings.push(
        "Server is prerelease; verify exact-build documentation and open items before advice.",
      );
  } else {
    warnings.push(
      "Server not probed; client version does not establish SQL compatibility.",
    );
  }
  if (client.channel !== "stable")
    warnings.push(
      "Client is prerelease; gate psql options on its exact build, not the server version.",
    );
  console.log(JSON.stringify({ client, server, warnings }, null, 2));
} catch (error) {
  console.error(
    error instanceof Error ? error.message : "Version detection failed.",
  );
  process.exitCode = 1;
}
