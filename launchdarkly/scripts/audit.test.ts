import { afterEach, expect, test } from "bun:test";
import { chmodSync, mkdtempSync, rmSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { auditProject } from "./audit.ts";

const at = Date.parse("2026-10-15T00:00:00Z");
const day = 86_400_000;

function environment() {
  return {
    on: true,
    lastModified: at - 15 * day,
    prerequisites: [],
    targets: [],
    contextTargets: [],
    rules: [],
    fallthrough: { variation: 1 },
  };
}

function flag() {
  return {
    key: "old-release",
    name: "Old release",
    creationDate: at - 31 * day,
    kind: "boolean",
    archived: false,
    variations: [{ value: false }, { value: true }],
    environments: { integration: environment(), production: environment() },
  };
}

function fixture(flags: unknown[] = [flag()]) {
  const calls: string[][] = [];
  const cli = (args: string[]): unknown => {
    calls.push(args);
    if (args[0] === "environments" && args[1] === "list") {
      return {
        items: [{ key: "integration" }, { key: "production" }],
        _links: {},
      };
    }
    if (args[0] === "flags" && args[1] === "list") {
      return { items: flags, totalCount: flags.length, _links: {} };
    }
    if (args[0] === "audit-log" && args[1] === "list") {
      return { items: [], _links: {} };
    }
    throw new Error("Unexpected or mutating ldcli command");
  };
  return { cli, calls, flags };
}

test("counts an old, universally true flag after checking Integration and Production history", () => {
  const { cli, calls } = fixture();
  const result = auditProject("example", cli, at);
  expect(result.candidateCount).toBe(1);
  expect(result.exactCount).toBe(1);
  expect(result.flags).toEqual([
    expect.objectContaining({ key: "old-release", status: "candidate" }),
  ]);
  const history = calls.filter((args) => args[0] === "audit-log");
  expect(history).toHaveLength(2);
  expect(history[0]).toContain("proj/example:env/integration:flag/old-release");
  expect(history[1]).toContain("proj/example:env/production:flag/old-release");
  expect(history[0]).toContain(String(at - 14 * day - 1));
});

type AuditCase = [
  string,
  Record<string, unknown>,
  "candidate" | "excluded" | "unknown",
];

// Public report cases: independently specified thresholds and targeting outcomes.
test.each<AuditCase>([
  ["exactly 30 days old", { creationDate: at - 30 * day }, "excluded"],
  ["archived", { archived: true }, "excluded"],
  ["numeric string date", { creationDate: String(at - 31 * day) }, "candidate"],
  ["missing creation time", { creationDate: undefined }, "unknown"],
  ["invalid creation time", { creationDate: "yesterday" }, "unknown"],
  [
    "non-boolean flag",
    { kind: "multivariate", variations: [{ value: "off" }, { value: "on" }] },
    "unknown",
  ],
])("classifies %s without inventing evidence", (_name, patch, status) => {
  const { cli } = fixture([{ ...flag(), ...patch }]);
  const result = auditProject("example", cli, at);
  expect(result.flags[0]?.status).toBe(status);
  expect(result.exactCount).toBe(
    status === "unknown" ? null : status === "candidate" ? 1 : 0,
  );
});

test.each<AuditCase>([
  ["one environment off", { on: false }, "excluded"],
  ["on with false default", { fallthrough: { variation: 0 } }, "excluded"],
  [
    "false individual target",
    { targets: [{ values: ["context-key"], variation: 0 }] },
    "excluded",
  ],
  [
    "false context target",
    {
      contextTargets: [
        { contextKind: "org", values: ["org-key"], variation: 0 },
      ],
    },
    "excluded",
  ],
  ["false rule", { rules: [{ variation: 0, clauses: [] }] }, "excluded"],
  ["true rule", { rules: [{ variation: 1, clauses: [] }] }, "candidate"],
  [
    "100 percent true rollout",
    {
      fallthrough: {
        rollout: {
          variations: [
            { variation: 1, weight: 100_000 },
            { variation: 0, weight: 0 },
          ],
        },
      },
    },
    "candidate",
  ],
  [
    "partial rollout",
    {
      fallthrough: {
        rollout: {
          variations: [
            { variation: 1, weight: 99_000 },
            { variation: 0, weight: 1_000 },
          ],
        },
      },
    },
    "excluded",
  ],
  [
    "incomplete rollout",
    { fallthrough: { rollout: { variations: [{ variation: 1, weight: 1 }] } } },
    "unknown",
  ],
  ["invalid variation", { fallthrough: { variation: 9 } }, "unknown"],
  [
    "prerequisite",
    { prerequisites: [{ key: "other", variation: 1 }] },
    "unknown",
  ],
  [
    "change at inclusive 14-day cutoff",
    { lastModified: at - 14 * day },
    "excluded",
  ],
  ["recent change", { lastModified: at - day }, "excluded"],
  ["future timestamp", { lastModified: at + day }, "unknown"],
  ["summary response missing rules", { rules: undefined }, "unknown"],
])("handles %s across every environment", (_name, patch, status) => {
  const { cli } = fixture([
    {
      ...flag(),
      environments: {
        integration: environment(),
        production: { ...environment(), ...patch },
      },
    },
  ]);
  expect(auditProject("example", cli, at).flags[0]?.status).toBe(status);
});

test.each(["recent metadata change", "denied history", "incomplete history"])(
  "%s cannot produce a candidate or falsely exact count",
  (scenario) => {
    const base = fixture();
    const cli = (args: string[]) => {
      if (args[0] !== "audit-log") return base.cli(args);
      if (scenario === "denied history") throw new Error("History unavailable");
      if (scenario === "incomplete history")
        return { items: [], _links: { next: { href: "/next" } } };
      return { items: [{ date: at - day }], _links: {} };
    };
    const result = auditProject("example", cli, at);
    expect(result.candidateCount).toBe(0);
    expect(result.flags[0]?.status).toBe(
      scenario === "recent metadata change" ? "excluded" : "unknown",
    );
    expect(result.exactCount).toBe(
      scenario === "recent metadata change" ? 0 : null,
    );
  },
);

test("paginates environment and flag inventory and includes the final environment", () => {
  const base = fixture();
  const cli = (args: string[]) => {
    const offset = args[args.indexOf("--offset") + 1];
    if (args[0] === "environments") {
      return offset === "0"
        ? {
            items: [{ key: "integration" }],
            totalCount: 2,
            _links: { next: { href: "/environments?offset=1" } },
          }
        : { items: [{ key: "production" }], totalCount: 2, _links: {} };
    }
    if (args[0] === "flags") {
      const second = {
        ...flag(),
        key: "another",
        environments: {
          integration: environment(),
          production: { ...environment(), on: false },
        },
      };
      return offset === "0"
        ? {
            items: [flag()],
            totalCount: 2,
            _links: { next: { href: "/flags?offset=1" } },
          }
        : { items: [second], totalCount: 2, _links: {} };
    }
    return base.cli(args);
  };
  const result = auditProject("example", cli, at);
  expect(result.scannedCount).toBe(2);
  expect(result.environmentKeys).toEqual(["integration", "production"]);
  expect(result.exactCount).toBe(1);
});

test.each([
  "no environments",
  "missing flag",
  "denied environment",
  "bad pagination",
  "wrong total",
])("stops without a count for %s", (scenario) => {
  const base = fixture();
  const cli = (args: string[]) => {
    if (args[0] === "environments") {
      if (scenario === "no environments") return { items: [], _links: {} };
      if (scenario === "wrong total")
        return { items: [{ key: "integration" }], totalCount: 2, _links: {} };
      if (scenario === "bad pagination")
        return {
          items: [{ key: "integration" }],
          _links: { next: { href: "/?offset=0" } },
        };
    }
    if (args.includes("production")) {
      if (scenario === "missing flag") return { items: [], _links: {} };
      if (scenario === "denied environment") throw new Error("Access denied");
    }
    return base.cli(args);
  };
  expect(() => auditProject("example", cli, at)).toThrow();
});

test("missing environment configuration cannot count as universally enabled", () => {
  const { cli } = fixture([
    { ...flag(), environments: { integration: environment() } },
  ]);
  const result = auditProject("example", cli, at);
  expect(result.unknownCount).toBe(1);
  expect(result.exactCount).toBeNull();
});

test("ignores unused environments and their history but requires Integration and Production", () => {
  const base = fixture();
  const cli = (args: string[]) => {
    if (args[0] === "environments") {
      return {
        items: [{ key: "integration" }, { key: "production" }, { key: "test" }],
        _links: {},
      };
    }
    if (args[0] === "flags") {
      return {
        items: [
          {
            ...flag(),
            environments: {
              integration: environment(),
              production: environment(),
              test: { ...environment(), on: false, lastModified: at - day },
            },
          },
        ],
        _links: {},
      };
    }
    if (args[0] === "audit-log") {
      if (
        args.includes("proj/example:env/*:flag/old-release") ||
        args.includes("proj/example:env/test:flag/old-release")
      ) {
        return { items: [{ date: at - day }], _links: {} };
      }
    }
    return base.cli(args);
  };
  const result = auditProject("example", cli, at);
  expect(result.exactCount).toBe(1);
  expect(result.environmentKeys).toEqual(["integration", "production"]);
});

const tempDirectories: string[] = [];
afterEach(() => {
  for (const directory of tempDirectories.splice(0))
    rmSync(directory, { recursive: true, force: true });
});

test.each(["candidate", "unknown", "denied", "malformed"])(
  "CLI reports %s with an honest exit code and no leaked subprocess output",
  (scenario) => {
    const directory = mkdtempSync(join(tmpdir(), "launchdarkly-audit-"));
    tempDirectories.push(directory);
    const input = join(directory, "flags.json");
    const data =
      scenario === "unknown"
        ? { ...flag(), environments: { integration: environment() } }
        : flag();
    writeFileSync(input, JSON.stringify({ items: [data], _links: {} }));
    const executable = join(directory, "ldcli");
    writeFileSync(
      executable,
      scenario === "malformed"
        ? "#!/bin/sh\nprintf 'secret-from-cli'\n"
        : scenario === "denied"
          ? "#!/bin/sh\nprintf 'secret-from-cli' >&2\nexit 1\n"
          : `#!/bin/sh
case "$1 $2" in
  "environments list") printf '%s' '{"items":[{"key":"integration"},{"key":"production"}],"_links":{}}' ;;
  "flags list") cat "$LD_FIXTURE" ;;
  "audit-log list") printf '%s' '{"items":[],"_links":{}}' ;;
  *) exit 3 ;;
esac
`,
    );
    chmodSync(executable, 0o755);
    const result = Bun.spawnSync(
      [
        process.execPath,
        new URL("./audit.ts", import.meta.url).pathname,
        "--project",
        "example",
      ],
      {
        env: {
          ...process.env,
          PATH: `${directory}:${process.env.PATH}`,
          LD_FIXTURE: input,
        },
        timeout: 5_000,
      },
    );
    expect(result.exitCode).toBe(
      scenario === "candidate" ? 0 : scenario === "unknown" ? 2 : 1,
    );
    expect(result.stderr.toString()).not.toContain("secret-from-cli");
    if (scenario === "denied" || scenario === "malformed") {
      expect(result.stdout.toString()).toBe("");
      expect(result.stderr.toString()).toContain(
        scenario === "denied"
          ? "ldcli environments list failed"
          : "ldcli returned invalid JSON",
      );
    } else {
      const report = JSON.parse(result.stdout.toString());
      expect(report.candidateCount).toBe(scenario === "candidate" ? 1 : 0);
      expect(report.exactCount).toBe(scenario === "candidate" ? 1 : null);
    }
  },
);

test("an explicitly off environment excludes a non-boolean flag without guessing its enabled value", () => {
  const { cli } = fixture([
    {
      ...flag(),
      kind: "multivariate",
      variations: [{ value: "off" }, { value: "on" }],
      environments: {
        integration: environment(),
        production: { ...environment(), on: false },
      },
    },
  ]);
  const report = auditProject("example", cli, at);
  expect(report.exactCount).toBe(0);
  expect(report.unknownCount).toBe(0);
});
