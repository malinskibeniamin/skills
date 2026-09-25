// Pins which bot bump PRs the approver accepts. Fixtures mirror real diffs:
// cloudv2 #30145 (console), cloudv2 #25405 (AI gateway), serverless #3323.

import { describe, expect, test } from "bun:test";
import { type BumpPr, checkBump, parseDiff } from "./auto-approve-bumps.ts";

const CLOUDV2_CONSOLE_DIFF = `diff --git a/install-pack/26.1.yml b/install-pack/26.1.yml
index 543a136a1443..0317c5ceea36 100644
--- a/install-pack/26.1.yml
+++ b/install-pack/26.1.yml
@@ -15,7 +15,7 @@ vars:
   operator_crds_git_ref: 6a30245c23d535936713692db03dfc3bc4e60912
-  console_image_tag: master-7c97ba0
+  console_image_tag: master-2cf6ee1
   redpanda_console_helm_chart_version: 3.1.0
diff --git a/install-pack/26.2.yml b/install-pack/26.2.yml
index 912c6fdbe649..e06051c26202 100644
--- a/install-pack/26.2.yml
+++ b/install-pack/26.2.yml
@@ -15,7 +15,7 @@ vars:
-  console_image_tag: master-7c97ba0
+  console_image_tag: master-2cf6ee1
`;

const CLOUDV2_AI_GATEWAY_DIFF = `diff --git a/install-pack/25.3.yml b/install-pack/25.3.yml
--- a/install-pack/25.3.yml
+++ b/install-pack/25.3.yml
@@ -1,1 +1,1 @@
-  ai_gateway_version: nightly-20260404-e14779d
+  ai_gateway_version: nightly-20260408-e14779d
`;

const SERVERLESS_CONSOLE_DIFF = `diff --git a/infra/terraform/config/dev/eu-west-1/tags.yaml b/infra/terraform/config/dev/eu-west-1/tags.yaml
--- a/infra/terraform/config/dev/eu-west-1/tags.yaml
+++ b/infra/terraform/config/dev/eu-west-1/tags.yaml
@@ -1,1 +1,1 @@
-console_image_tag: "master-761148d"
+console_image_tag: "master-2cf6ee1"
`;

function pr(overrides: Partial<BumpPr> = {}): BumpPr {
  return {
    repo: "redpanda-data/cloudv2",
    number: 30145,
    author: "vbotbuildovich",
    baseRefName: "main",
    headRefName: "auto/bump-console-image",
    isDraft: false,
    commitAuthors: ["vbotbuildovich"],
    ...overrides,
  };
}

describe("parseDiff", () => {
  test("collects changed lines per file and ignores context", () => {
    expect(parseDiff(CLOUDV2_CONSOLE_DIFF)).toEqual([
      {
        path: "install-pack/26.1.yml",
        structural: false,
        removed: ["  console_image_tag: master-7c97ba0"],
        added: ["  console_image_tag: master-2cf6ee1"],
      },
      {
        path: "install-pack/26.2.yml",
        structural: false,
        removed: ["  console_image_tag: master-7c97ba0"],
        added: ["  console_image_tag: master-2cf6ee1"],
      },
    ]);
  });

  test("flags new, deleted, renamed, and binary files as structural", () => {
    for (const marker of [
      "new file mode 100644",
      "deleted file mode 100644",
      "rename from x",
      "Binary files a/x and b/x differ",
    ]) {
      const [file] = parseDiff(
        `diff --git a/install-pack/x.yml b/install-pack/x.yml\n${marker}\n`,
      );
      expect(file?.structural).toBe(true);
    }
  });
});

describe("checkBump", () => {
  test("approves the cloudv2 console image bump", () => {
    expect(checkBump(pr(), CLOUDV2_CONSOLE_DIFF)).toEqual({ ok: true });
  });

  test("approves the cloudv2 AI gateway bump", () => {
    const aiGateway = pr({ headRefName: "auto/bump-ai-gateway-version" });
    expect(checkBump(aiGateway, CLOUDV2_AI_GATEWAY_DIFF)).toEqual({ ok: true });
  });

  test("approves the serverless console image bump", () => {
    const serverless = pr({ repo: "redpanda-data/serverless", number: 3323 });
    expect(checkBump(serverless, SERVERLESS_CONSOLE_DIFF)).toEqual({
      ok: true,
    });
  });

  test.each([
    ["another author", { author: "someone" }, /author/],
    ["a draft", { isDraft: true }, /draft/],
    ["a non-main base", { baseRefName: "preprod" }, /base/],
    ["an unknown branch", { headRefName: "adp-release/v0.2.66" }, /branch/],
    ["a human commit", { commitAuthors: ["vbotbuildovich", "a"] }, /commit/],
    ["no commit authors", { commitAuthors: [] }, /commit/],
    ["an unknown repo", { repo: "redpanda-data/console" }, /branch/],
  ])("rejects %s", (_label, overrides, reason) => {
    const result = checkBump(pr(overrides), CLOUDV2_CONSOLE_DIFF);
    expect(result.ok).toBe(false);
    expect(result.ok ? "" : result.reason).toMatch(reason);
  });

  test("rejects a file outside the allowed paths", () => {
    const diff = CLOUDV2_CONSOLE_DIFF.replaceAll(
      "install-pack/26.2.yml",
      ".github/workflows/deploy.yml",
    );
    expect(checkBump(pr(), diff)).toEqual({
      ok: false,
      reason: "unexpected file .github/workflows/deploy.yml",
    });
  });

  test("rejects any changed line that is not the tag", () => {
    const diff = `${CLOUDV2_CONSOLE_DIFF}-  connectors_version: v1\n+  connectors_version: v2\n`;
    expect(checkBump(pr(), diff)).toEqual({
      ok: false,
      reason:
        "unexpected change in install-pack/26.2.yml: connectors_version: v1",
    });
  });

  test("rejects the tag of a different bump family", () => {
    expect(checkBump(pr(), CLOUDV2_AI_GATEWAY_DIFF)).toMatchObject({
      ok: false,
    });
  });

  test("rejects an added tag line without a matching removal", () => {
    const diff = `diff --git a/install-pack/26.1.yml b/install-pack/26.1.yml
--- a/install-pack/26.1.yml
+++ b/install-pack/26.1.yml
+  console_image_tag: master-2cf6ee1
`;
    expect(checkBump(pr(), diff)).toEqual({
      ok: false,
      reason: "unbalanced change in install-pack/26.1.yml",
    });
  });

  test("rejects structural and empty diffs", () => {
    const newFile =
      "diff --git a/install-pack/27.1.yml b/install-pack/27.1.yml\nnew file mode 100644\n";
    expect(checkBump(pr(), newFile)).toEqual({
      ok: false,
      reason: "structural change in install-pack/27.1.yml",
    });
    expect(checkBump(pr(), "")).toEqual({ ok: false, reason: "empty diff" });
  });
});
