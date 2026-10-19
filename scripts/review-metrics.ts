#!/usr/bin/env bun
// Read-only GitHub observations. Missing quality outcomes never imply safety.
import { z } from "zod";

const actor = z
  .object({ __typename: z.string(), login: z.string() })
  .nullable();
const review = z.object({
  author: actor,
  state: z.enum([
    "PENDING",
    "COMMENTED",
    "APPROVED",
    "CHANGES_REQUESTED",
    "DISMISSED",
  ]),
  submittedAt: z.string().datetime().nullable(),
  comments: z.object({ totalCount: z.number().int().nonnegative() }),
});
const pageInfo = z.object({ hasNextPage: z.boolean() });
const pullRequest = z.object({
  number: z.number().int().positive(),
  createdAt: z.string().datetime(),
  mergedAt: z.string().datetime(),
  reviews: z.object({ nodes: z.array(review), pageInfo }),
  comments: z.object({ nodes: z.array(z.object({ author: actor })), pageInfo }),
});
const response = z.object({
  data: z.object({
    repository: z.object({
      pullRequests: z.object({ nodes: z.array(pullRequest) }),
    }),
  }),
});

function distribution(values: number[]) {
  if (!values.length) return null;
  const sorted = [...values].sort((a, b) => a - b);
  const middle = Math.floor(sorted.length / 2);
  const lower = sorted[Math.floor((sorted.length - 1) / 2)];
  const upper = sorted[middle];
  const p95 = sorted[Math.ceil(sorted.length * 0.95) - 1];
  if (lower === undefined || upper === undefined || p95 === undefined)
    throw new Error("Missing metric sample");
  return { median: (lower + upper) / 2, p95 };
}

try {
  const [repo, rawLimit = "30", ...extra] = process.argv.slice(2);
  const limit = Number(rawLimit);
  if (
    !repo ||
    !/^[\w.-]+\/[\w.-]+$/.test(repo) ||
    !/^\d+$/.test(rawLimit) ||
    !Number.isInteger(limit) ||
    limit < 1 ||
    limit > 100 ||
    extra.length
  )
    throw new Error("Usage: review-metrics.ts owner/repo [sample-size:1-100]");
  const [owner, name] = repo.split("/");
  const query = `query($owner:String!,$name:String!,$limit:Int!) {
    repository(owner:$owner,name:$name) {
      pullRequests(first:$limit,states:MERGED,orderBy:{field:UPDATED_AT,direction:DESC}) {
        nodes { number createdAt mergedAt
          reviews(first:100) { pageInfo { hasNextPage }
            nodes { author { __typename login } state submittedAt comments { totalCount } } }
          comments(first:100) { pageInfo { hasNextPage } nodes { author { __typename login } } }
        }
      }
    }
  }`;
  const result = Bun.spawnSync(
    [
      "gh",
      "api",
      "graphql",
      "--hostname",
      "github.com",
      "-f",
      `query=${query}`,
      "-f",
      `owner=${owner}`,
      "-f",
      `name=${name}`,
      "-F",
      `limit=${limit}`,
    ],
    { timeout: 30_000 },
  );
  if (result.exitCode !== 0)
    throw new Error(
      `GitHub metrics unavailable: ${result.stderr.toString().trim()}`,
    );
  const raw: unknown = JSON.parse(result.stdout.toString());
  if (typeof raw === "object" && raw !== null && "errors" in raw)
    throw new Error("Incomplete GitHub metrics response");
  const prs = response.parse(raw).data.repository.pullRequests.nodes;
  const approvals: number[] = [];
  const firstReviews: number[] = [];
  let humanComments = 0;
  let unknownReviewAuthors = 0;
  for (const pr of prs) {
    if (pr.reviews.pageInfo.hasNextPage || pr.comments.pageInfo.hasNextPage)
      throw new Error(
        `Incomplete review history for PR #${pr.number}; reduce the sample or retrieve its remaining pages`,
      );
    const humans = pr.reviews.nodes.filter(
      (item) => item.author?.__typename === "User" && item.state !== "PENDING",
    );
    approvals.push(humans.filter((item) => item.state === "APPROVED").length);
    humanComments +=
      humans.reduce((sum, item) => sum + item.comments.totalCount, 0) +
      pr.comments.nodes.filter((item) => item.author?.__typename === "User")
        .length;
    unknownReviewAuthors += pr.reviews.nodes.filter(
      (item) =>
        !item.author || !["User", "Bot"].includes(item.author.__typename),
    ).length;
    const times = humans.flatMap((item) =>
      item.submittedAt ? [Date.parse(item.submittedAt)] : [],
    );
    if (times.length) {
      const elapsed = Math.min(...times) - Date.parse(pr.createdAt);
      if (elapsed < 0)
        throw new Error(`Invalid review chronology for PR #${pr.number}`);
      firstReviews.push(elapsed / 60_000);
    }
  }
  console.log(
    JSON.stringify(
      {
        repo,
        collectedAt: new Date().toISOString(),
        sample: "latest-updated merged PRs",
        sampleSize: prs.length,
        observedHumanApprovalsPerPr: distribution(approvals),
        humanComments,
        timeToFirstHumanReviewMinutes: distribution(firstReviews),
        prsWithoutHumanReview: prs.length - firstReviews.length,
        unknownReviewAuthors,
        guardrails: {
          incidentRate: null,
          revertRate: null,
          reviewerRecall: null,
          falsePositiveRate: null,
        },
      },
      null,
      2,
    ),
  );
} catch (error) {
  console.error(error instanceof Error ? error.message : String(error));
  process.exitCode = 1;
}
