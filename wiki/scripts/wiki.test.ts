import { afterAll, expect, test } from "bun:test";
import {
  existsSync,
  mkdirSync,
  mkdtempSync,
  readFileSync,
  rmSync,
  symlinkSync,
  writeFileSync,
} from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";

const scratch = mkdtempSync(join(tmpdir(), "skills-wiki-test-"));
const cli = new URL("./wiki.ts", import.meta.url).pathname;
afterAll(() => rmSync(scratch, { recursive: true, force: true }));

function run(home: string, args: string[], stdin?: string) {
  return Bun.spawnSync(["bun", cli, "--home", home, ...args], {
    stdin: stdin === undefined ? "ignore" : Buffer.from(stdin),
    timeout: 10_000,
    cwd: scratch,
  });
}
function json(result: ReturnType<typeof run>) {
  expect(result.exitCode).toBe(0);
  expect(result.stderr.toString()).toBe("");
  return JSON.parse(result.stdout.toString());
}

// The real CLI is the public contract: no test-only exports or mock filesystem.
test("initializes a home, ingests cited knowledge, and finds it from another cwd", () => {
  const home = join(scratch, "journey");
  json(run(home, ["init"]));
  const agents = readFileSync(join(home, "AGENTS.md"), "utf8");
  expect(agents).toContain("wiki/index.md");
  const content =
    "On 2026-11-12, we chose a separate home.\nSee [search](search.md).\n";
  const args = [
    "ingest",
    "home-pattern",
    "--title",
    "Home pattern",
    "--source",
    "https://example.com/home",
    "--stdin",
  ];
  expect(json(run(home, args, content)).created).toBe(true);
  expect(json(run(home, args, content)).created).toBe(false);
  json(
    run(
      home,
      [
        "ingest",
        "search",
        "--title",
        "Search",
        "--source",
        "owner decision",
        "--stdin",
      ],
      "Use literal search.",
    ),
  );
  const page = json(run(home, ["read", "home-pattern"]));
  expect(page.content).toBe(content);
  expect(page.source).toBe("https://example.com/home");
  expect(page.date).toMatch(/^\d{4}-\d{2}-\d{2}$/);
  expect(
    json(run(home, ["list"])).map((p: { slug: string }) => p.slug),
  ).toEqual(["home-pattern", "search"]);
  expect(readFileSync(join(home, "wiki/index.md"), "utf8")).toContain(
    "[Home pattern](home-pattern.md)",
  );
  const matches = json(run(home, ["search", "SEPARATE HOME"]));
  expect(matches).toHaveLength(1);
  expect(matches[0]).toMatchObject({
    slug: "home-pattern",
    line: 1,
    text: "On 2026-11-12, we chose a separate home.",
  });
  expect(json(run(home, ["lint"])).issues).toEqual([]);
  json(
    run(home, [
      "repo",
      "add",
      "skills",
      "--path",
      "/not-cloned/skills",
      "--remote",
      "git@github.com:example/skills.git",
      "--summary",
      "Shared harness",
    ]),
  );
  expect(json(run(home, ["repo", "list"]))[0]).toMatchObject({
    name: "skills",
    path: "/not-cloned/skills",
    summary: "Shared harness",
  });
  json(run(home, ["init"]));
  expect(readFileSync(join(home, "AGENTS.md"), "utf8")).toBe(agents);
  expect(existsSync(join(home, ".git"))).toBe(false);
});

test("fails promptly without the required home, input, or known flags", () => {
  const missingHome = Bun.spawnSync(["bun", cli, "list"], { stdin: "ignore" });
  expect(missingHome.exitCode).not.toBe(0);
  expect(missingHome.stderr.toString()).toContain("--home");
  const home = join(scratch, "invalid");
  json(run(home, ["init"]));
  for (const args of [
    ["search"],
    ["list", "--typo"],
    ["ingest", "page", "--title", "Page", "--source", "ref"],
    ["ingest", "../escape", "--title", "Page", "--source", "ref", "--stdin"],
  ]) {
    expect(run(home, args, "text").exitCode).not.toBe(0);
  }
  expect(existsSync(join(scratch, "escape.md"))).toBe(false);
});

test("never adopts existing knowledge or overwrites a conflicting page", () => {
  const existing = join(scratch, "existing");
  mkdirSync(join(existing, "wiki"), { recursive: true });
  writeFileSync(join(existing, "wiki/notes.md"), "keep me");
  expect(run(existing, ["init"]).exitCode).not.toBe(0);
  expect(readFileSync(join(existing, "wiki/notes.md"), "utf8")).toBe("keep me");
  const home = join(scratch, "conflict");
  json(run(home, ["init"]));
  const args = [
    "ingest",
    "decision",
    "--title",
    "Decision",
    "--source",
    "owner",
    "--stdin",
  ];
  json(run(home, args, "Original."));
  expect(run(home, args, "Replacement.").exitCode).not.toBe(0);
  expect(json(run(home, ["read", "decision"])).content).toBe("Original.");
});

test("reports broken links and refuses knowledge symlinks without exposing targets", () => {
  const home = join(scratch, "links");
  json(run(home, ["init"]));
  json(
    run(
      home,
      ["ingest", "broken", "--title", "Broken", "--source", "test", "--stdin"],
      "[missing](absent.md) and [[other-page]]",
    ),
  );
  const lint = run(home, ["lint"]);
  expect(lint.exitCode).toBe(1);
  expect(JSON.parse(lint.stdout.toString()).issues).toEqual(
    expect.arrayContaining([
      expect.objectContaining({ page: "broken", target: "absent.md" }),
      expect.objectContaining({ page: "broken", target: "other-page" }),
    ]),
  );
  const secret = join(scratch, "outside.md");
  writeFileSync(
    secret,
    '---\ntitle: "Outside"\nsource: "private"\ndate: "2026-11-12"\n---\nDo not disclose this',
  );
  symlinkSync(secret, join(home, "wiki/secret.md"));
  const result = run(home, ["read", "secret"]);
  expect(result.exitCode).not.toBe(0);
  expect(result.stdout.toString()).not.toContain("Do not disclose this");
  expect(run(home, ["search", "disclose"]).exitCode).not.toBe(0);
  rmSync(join(home, "wiki/secret.md"));
  rmSync(join(home, "wiki"), { recursive: true });
  symlinkSync(scratch, join(home, "wiki"));
  expect(
    run(
      home,
      ["ingest", "escaped", "--title", "X", "--source", "test", "--stdin"],
      "No.",
    ).exitCode,
  ).not.toBe(0);
  expect(existsSync(join(scratch, "escaped.md"))).toBe(false);
});

test("repairs index drift on an identical file ingest, and honors another writer's lock", () => {
  const home = join(scratch, "recovery");
  json(run(home, ["init"]));
  const input = join(scratch, "notes.md");
  writeFileSync(input, "Dated decision with evidence.");
  const args = [
    "ingest",
    "decision",
    "--title",
    "Decision",
    "--source",
    "owner decision",
    "--file",
    input,
  ];
  json(run(home, args));
  rmSync(join(home, "wiki/index.md"));
  expect(run(home, ["lint"]).exitCode).toBe(1);
  expect(json(run(home, args)).created).toBe(false);
  expect(json(run(home, ["lint"])).issues).toEqual([]);
  mkdirSync(join(home, ".wiki-lock"));
  const locked = run(home, [
    "repo",
    "add",
    "other",
    "--path",
    "/missing",
    "--summary",
    "Another repo",
  ]);
  expect(locked.exitCode).not.toBe(0);
  expect(locked.stderr.toString()).toContain("Home is locked");
  expect(existsSync(join(home, ".wiki-lock"))).toBe(true);
  expect(json(run(home, ["repo", "list"]))).toEqual([]);
  rmSync(join(home, ".wiki-lock"), { recursive: true });
  json(
    run(home, [
      "repo",
      "add",
      "other",
      "--path",
      "/missing",
      "--summary",
      "Another repo",
    ]),
  );
});

test("ignores link examples in Markdown code while detecting real missing page links", () => {
  const home = join(scratch, "code-links");
  json(run(home, ["init"]));
  json(
    run(
      home,
      [
        "ingest",
        "examples",
        "--title",
        "Examples",
        "--source",
        "owner",
        "--stdin",
      ],
      "Inline `[[not-a-page]]`.\n\n```md\n[example](not-real.md)\n```\n\n[actual](missing.md)",
    ),
  );
  const result = run(home, ["lint"]);
  expect(result.exitCode).toBe(1);
  expect(JSON.parse(result.stdout.toString()).issues).toEqual([
    expect.objectContaining({ page: "examples", target: "missing.md" }),
  ]);
});
