import { afterEach, expect, test } from "bun:test";
import { mkdtempSync, rmSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";

const roots: string[] = [];
afterEach(() => {
  for (const root of roots.splice(0))
    rmSync(root, { recursive: true, force: true });
});

function run(nodes: unknown[]) {
  const root = mkdtempSync(join(tmpdir(), "review-metrics-"));
  roots.push(root);
  const response = join(root, "response.json");
  writeFileSync(
    response,
    JSON.stringify({ data: { repository: { pullRequests: { nodes } } } }),
  );
  writeFileSync(join(root, "gh"), `#!/bin/sh\ncat '${response}'\n`, {
    mode: 0o755,
  });
  const result = Bun.spawnSync(
    [
      process.execPath,
      new URL("./review-metrics.ts", import.meta.url).pathname,
      "example/project",
      "2",
    ],
    {
      env: { ...Bun.env, PATH: `${root}:${Bun.env.PATH}` },
    },
  );
  return {
    code: result.exitCode,
    out: result.stdout.toString(),
    err: result.stderr.toString(),
  };
}

const human = { __typename: "User", login: "reviewer" };
const bot = { __typename: "Bot", login: "reviewer-bot" };
const connection = (nodes: unknown[]) => ({
  nodes,
  pageInfo: { hasNextPage: false },
});
const pr = (number: number) => ({
  number,
  createdAt: "2026-10-01T00:00:00Z",
  mergedAt: "2026-10-01T02:00:00Z",
  comments: connection([]),
  reviews: connection([]),
});

test("reports observed human effort, excludes bots, and leaves safety unknown", () => {
  const first = {
    ...pr(1),
    comments: connection([{ author: human }, { author: bot }]),
    reviews: connection([
      {
        author: bot,
        state: "APPROVED",
        submittedAt: "2026-10-01T00:05:00Z",
        comments: { totalCount: 99 },
      },
      {
        author: human,
        state: "APPROVED",
        submittedAt: "2026-10-01T00:10:00Z",
        comments: { totalCount: 2 },
      },
      {
        author: human,
        state: "APPROVED",
        submittedAt: "2026-10-01T00:20:00Z",
        comments: { totalCount: 0 },
      },
    ]),
  };
  const result = run([first, pr(2)]);
  expect(result.code).toBe(0);
  const report = JSON.parse(result.out);
  expect(report.observedHumanApprovalsPerPr).toEqual({ median: 1, p95: 2 });
  expect(report.humanComments).toBe(3);
  expect(report.timeToFirstHumanReviewMinutes).toEqual({ median: 10, p95: 10 });
  expect(report.prsWithoutHumanReview).toBe(1);
  expect(report.guardrails).toEqual({
    incidentRate: null,
    revertRate: null,
    reviewerRecall: null,
    falsePositiveRate: null,
  });
});

test("an empty sample is unavailable evidence, not zero human effort", () => {
  const result = run([]);
  expect(result.code).toBe(0);
  expect(JSON.parse(result.out).observedHumanApprovalsPerPr).toBeNull();
});

test("incomplete review history cannot produce a complete metric", () => {
  const result = run([
    { ...pr(1), reviews: { nodes: [], pageInfo: { hasNextPage: true } } },
  ]);
  expect(result.code).toBe(1);
  expect(result.err).toContain("Incomplete review history");
  expect(result.out).toBe("");
});
