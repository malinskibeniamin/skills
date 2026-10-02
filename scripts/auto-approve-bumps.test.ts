// Pins which bot bump PRs the approver accepts. Fixtures mirror real diffs:
// cloudv2 #30145 (console), cloudv2 #25405 (AI gateway), serverless #3323.

import { describe, expect, test } from "bun:test";
import {
  type BumpPr,
  checkBump,
  checkPromotion,
  parseDiff,
  pendingPrs,
  reviewAction,
  searchQuery,
} from "./auto-approve-bumps.ts";

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
        deleted: false,
        removed: ["  console_image_tag: master-7c97ba0"],
        added: ["  console_image_tag: master-2cf6ee1"],
      },
      {
        path: "install-pack/26.2.yml",
        structural: false,
        deleted: false,
        removed: ["  console_image_tag: master-7c97ba0"],
        added: ["  console_image_tag: master-2cf6ee1"],
      },
    ]);
  });

  test("reads hunk lines that look like file headers as content", () => {
    const [file] = parseDiff(
      "diff --git a/x.yml b/x.yml\n--- a/x.yml\n+++ b/x.yml\n@@ -1 +1 @@\n--- hidden: true\n+++ shown: true\n",
    );
    expect(file?.removed).toEqual(["-- hidden: true"]);
    expect(file?.added).toEqual(["++ shown: true"]);
  });

  test("marks deleted files", () => {
    const [file] = parseDiff(
      "diff --git a/.changeset/x.md b/.changeset/x.md\ndeleted file mode 100644\n--- a/.changeset/x.md\n+++ /dev/null\n@@ -1 +0,0 @@\n-note\n",
    );
    expect(file).toEqual({
      path: ".changeset/x.md",
      structural: false,
      deleted: true,
      removed: ["note"],
      added: [],
    });
  });

  test("flags new, renamed, and binary files as structural", () => {
    for (const marker of [
      "new file mode 100644",
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
    ["an unknown branch", { headRefName: "auto/bump-operator" }, /branch/],
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
@@ -1,0 +1,1 @@
+  console_image_tag: master-2cf6ee1
`;
    expect(checkBump(pr(), diff)).toEqual({
      ok: false,
      reason: "unbalanced change in install-pack/26.1.yml",
    });
  });

  test("rejects a deleted install-pack file", () => {
    const deleted =
      "diff --git a/install-pack/26.1.yml b/install-pack/26.1.yml\ndeleted file mode 100644\n@@ -1 +0,0 @@\n-  console_image_tag: master-7c97ba0\n";
    expect(checkBump(pr(), deleted)).toEqual({
      ok: false,
      reason: "deleted install-pack/26.1.yml",
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

// Shape of cloudv2 #30318: version bump plus additive release notes.
const ADP_RELEASE_DIFF = `diff --git a/adp/RELEASE_NOTES.md b/adp/RELEASE_NOTES.md
--- a/adp/RELEASE_NOTES.md
+++ b/adp/RELEASE_NOTES.md
@@ -2,6 +2,12 @@
 User-facing changes to the Redpanda Agentic Data Plane, by release.
 
+## v0.2.67 (2026-09-25)
+
+### ✨ Improvements
+
+#### Interface \`[UI]\`
+Numeric input fields now use plus and minus steppers.
diff --git a/apps/adp-ui/package.json b/apps/adp-ui/package.json
--- a/apps/adp-ui/package.json
+++ b/apps/adp-ui/package.json
@@ -1,4 +1,4 @@
 {
-  "version": "0.2.66",
+  "version": "0.2.67",
diff --git a/apps/adp-ui/src/lib/release-notes.generated.ts b/apps/adp-ui/src/lib/release-notes.generated.ts
--- a/apps/adp-ui/src/lib/release-notes.generated.ts
+++ b/apps/adp-ui/src/lib/release-notes.generated.ts
@@ -22,6 +22,18 @@ export interface ReleaseNote {
 export const RELEASE_NOTES: ReleaseNote[] = [
+  {
+    version: '0.2.67',
+    date: '2026-09-25',
+    sections: [
+      {
+        kind: 'improvement',
+        items: [
+          { headline: 'Interface', tag: 'UI', body: 'The product\\'s inputs use steppers.' },
+          { headline: 'MCP Servers', body: 'Queries no longer truncate.' },
+        ],
+      },
+    ],
+  },
`;

const GENERATED = "apps/adp-ui/src/lib/release-notes.generated.ts";

describe("checkBump for ADP releases", () => {
  const release = pr({ number: 30318, headRefName: "adp-release/v0.2.67" });

  test("approves a version bump with additive release notes", () => {
    expect(checkBump(release, ADP_RELEASE_DIFF)).toEqual({ ok: true });
  });

  test("rejects a release whose files disagree with the branch version", () => {
    const other = pr({ headRefName: "adp-release/v0.2.68" });
    expect(checkBump(other, ADP_RELEASE_DIFF)).toEqual({
      ok: false,
      reason: "version 0.2.67 in adp/RELEASE_NOTES.md, expected 0.2.68",
    });
  });

  test("rejects generated notes for a different version", () => {
    const diff = ADP_RELEASE_DIFF.replace(
      "version: '0.2.67'",
      "version: '0.2.9'",
    );
    expect(checkBump(release, diff)).toEqual({
      ok: false,
      reason: `version 0.2.9 in ${GENERATED}, expected 0.2.67`,
    });
  });

  test("rejects markdown without the release heading", () => {
    const diff = ADP_RELEASE_DIFF.replace("## v0.2.67", "## v0.2.66");
    expect(checkBump(release, diff)).toEqual({
      ok: false,
      reason: "version 0.2.66 in adp/RELEASE_NOTES.md, expected 0.2.67",
    });
  });

  test.each([
    ["a code statement", "+  console.log(document.cookie),"],
    [
      "an escaped string concatenation",
      "+          { headline: 'a' + fetch('x') + '', body: 'b' },",
    ],
    ["an unknown kind", "+        kind: 'breaking',"],
    ["an unknown tag", "+          { headline: 'a', tag: 'API', body: 'b' },"],
  ])("rejects generated notes containing %s", (_label, line) => {
    const diff = `${ADP_RELEASE_DIFF}${line}\n`;
    const result = checkBump(release, diff);
    expect(result.ok ? "" : result.reason).toMatch(
      `unexpected change in ${GENERATED}`,
    );
  });

  test("rejects removed release-note lines", () => {
    const diff = ADP_RELEASE_DIFF.replace(
      " User-facing changes",
      "-User-facing changes",
    );
    expect(checkBump(release, diff)).toEqual({
      ok: false,
      reason: "removed lines in adp/RELEASE_NOTES.md",
    });
  });

  test("rejects a release that skips one of the three files", () => {
    const withoutMarkdown = ADP_RELEASE_DIFF.slice(
      ADP_RELEASE_DIFF.indexOf("diff --git a/apps/adp-ui/package.json"),
    );
    expect(checkBump(release, withoutMarkdown)).toEqual({
      ok: false,
      reason: "missing file adp/RELEASE_NOTES.md",
    });
  });

  test("rejects a release that also edits other files", () => {
    const diff = `${ADP_RELEASE_DIFF}diff --git a/.claude/skills/adp-release/SKILL.md b/.claude/skills/adp-release/SKILL.md
--- a/.claude/skills/adp-release/SKILL.md
+++ b/.claude/skills/adp-release/SKILL.md
@@ -1,0 +1,1 @@
+new step
`;
    expect(checkBump(release, diff)).toEqual({
      ok: false,
      reason: "unexpected file .claude/skills/adp-release/SKILL.md",
    });
  });
});

describe("checkPromotion", () => {
  // Shape of cloudv2 #30533, opened by release-promotion.yml.
  const promotion = pr({
    number: 30533,
    baseRefName: "preprod",
    headRefName: "ux/3885-main-to-preprod",
    commitAuthors: ["frenchfrywpepper"],
  });

  test.each(["behind", "identical"])(
    "approves a head that is %s main",
    (status) => {
      expect(checkPromotion(promotion, status)).toEqual({ ok: true });
    },
  );

  test.each(["ahead", "diverged"])("rejects a head %s of main", (status) => {
    expect(checkPromotion(promotion, status)).toEqual({
      ok: false,
      reason: `head is ${status} main, so it has commits not on main`,
    });
  });

  test.each([
    ["another author", { author: "someone" }, /author/],
    ["a draft", { isDraft: true }, /draft/],
    ["a production base", { baseRefName: "production" }, /base/],
    [
      "a production promotion",
      { headRefName: "ux/3885-preprod-to-production" },
      /branch/,
    ],
  ])("rejects %s", (_label, overrides, reason) => {
    const result = checkPromotion({ ...promotion, ...overrides }, "behind");
    expect(result.ok ? "" : result.reason).toMatch(reason);
  });

  test("does not treat a promotion as a diff-checked bump", () => {
    expect(checkBump(promotion, "")).toEqual({
      ok: false,
      reason: "unknown branch ux/3885-main-to-preprod",
    });
  });
});

describe("reviewAction", () => {
  const HEAD = "b".repeat(40);
  const OLD = "a".repeat(40);
  const approved = (commitId: string) => ({ state: "APPROVED", commitId });

  test.each([
    ["no review yet", [], "check"],
    ["an approval of this head", [approved(HEAD)], "skip"],
    ["an approval of an older head", [approved(OLD)], "recheck"],
    [
      "a comment after approving (cloudv2 #30515)",
      [approved(HEAD), { state: "COMMENTED", commitId: HEAD }],
      "skip",
    ],
    [
      "an approval of an older head, then a comment",
      [approved(OLD), { state: "COMMENTED", commitId: OLD }],
      "recheck",
    ],
    [
      "requested changes",
      [{ state: "CHANGES_REQUESTED", commitId: OLD }],
      "skip",
    ],
    [
      "requested changes after approving",
      [approved(OLD), { state: "CHANGES_REQUESTED", commitId: HEAD }],
      "skip",
    ],
    ["only a comment", [{ state: "COMMENTED", commitId: HEAD }], "skip"],
    ["a dismissed approval", [{ state: "DISMISSED", commitId: OLD }], "check"],
  ] as const)("returns %s → %s", (_label, reviews, action) => {
    expect(reviewAction(reviews, HEAD)).toBe(action);
  });
});

// Shape of ui-registry #316: a Changesets "version packages" PR.
const UI_REGISTRY_DIFF = `diff --git a/.changeset/fix-loading-animation-destroy-order.md b/.changeset/fix-loading-animation-destroy-order.md
deleted file mode 100644
index 1d2c3b4..0000000
--- a/.changeset/fix-loading-animation-destroy-order.md
+++ /dev/null
@@ -1,5 +0,0 @@
----
-"@redpanda-data/registry": patch
----
-
-Stop unmounting a Lottie animation from crashing the React tree.
diff --git a/CHANGELOG.md b/CHANGELOG.md
--- a/CHANGELOG.md
+++ b/CHANGELOG.md
@@ -1,3 +1,8 @@
 # Changelog
 
+## 3.6.0
+
+### Patch Changes
+
+- ef9acfd: Stop unmounting a Lottie animation from crashing the React tree.
diff --git a/bun.lock b/bun.lock
--- a/bun.lock
+++ b/bun.lock
@@ -10,7 +10,7 @@
     "packages/registry": {
       "name": "@redpanda-data/registry",
-      "version": "3.5.0",
+      "version": "3.6.0",
diff --git a/packages/docs/data/changelog.json b/packages/docs/data/changelog.json
--- a/packages/docs/data/changelog.json
+++ b/packages/docs/data/changelog.json
@@ -1,6 +1,20 @@
 [
+  {
+    "id": "3.5.0-ef9acfd",
+    "version": "3.5.0",
+    "pr": 315,
+    "components": [
+      "loading-animation"
+    ],
+    "summary": "Stop unmounting a Lottie animation from crashing the React tree."
+  },
   {
     "id": "3.4.0-a1b2c3d",
-      "components": ["tabs", "dialog"],
+      "components": [
+        "tabs",
+        "dialog"
+      ],
diff --git a/packages/registry/package.json b/packages/registry/package.json
--- a/packages/registry/package.json
+++ b/packages/registry/package.json
@@ -1,4 +1,4 @@
 {
   "name": "@redpanda-data/registry",
-  "version": "3.5.0",
+  "version": "3.6.0",
`;

describe("checkBump for ui-registry version packages", () => {
  const versionPackages = pr({
    repo: "redpanda-data/ui-registry",
    number: 316,
    author: "app/github-actions",
    headRefName: "changeset-release/main",
    commitAuthors: ["github-actions[bot]"],
  });

  test("approves a Changesets version PR", () => {
    expect(checkBump(versionPackages, UI_REGISTRY_DIFF)).toEqual({ ok: true });
  });

  test.each([
    ["another author", { author: "vbotbuildovich" }, /author/],
    [
      "a human commit",
      { commitAuthors: ["github-actions[bot]", "a"] },
      /commit/,
    ],
  ])("rejects %s", (_label, overrides, reason) => {
    const result = checkBump(
      { ...versionPackages, ...overrides },
      UI_REGISTRY_DIFF,
    );
    expect(result.ok ? "" : result.reason).toMatch(reason);
  });

  test.each([".changeset/config.json", ".changeset/README.md"])(
    "rejects deleting %s",
    (path) => {
      const diff = UI_REGISTRY_DIFF.replaceAll(
        ".changeset/fix-loading-animation-destroy-order.md",
        path,
      );
      expect(checkBump(versionPackages, diff)).toEqual({
        ok: false,
        reason: `unexpected file ${path}`,
      });
    },
  );

  test("rejects editing a changeset instead of consuming it", () => {
    const diff = UI_REGISTRY_DIFF.replace("deleted file mode 100644\n", "");
    expect(checkBump(versionPackages, diff)).toEqual({
      ok: false,
      reason:
        "expected .changeset/fix-loading-animation-destroy-order.md to be deleted",
    });
  });

  test("rejects a bun.lock change beyond a version line", () => {
    const diff = UI_REGISTRY_DIFF.replace(
      '+      "version": "3.6.0",',
      '+      "version": "3.6.0",\n-    "zod": "^4.5.0",\n+    "zod": "^4.6.0",',
    );
    expect(checkBump(versionPackages, diff)).toEqual({
      ok: false,
      reason: 'unexpected change in bun.lock: "zod": "^4.5.0",',
    });
  });

  test("rejects removing a changelog.json entry", () => {
    const diff = UI_REGISTRY_DIFF.replace(
      '     "id": "3.4.0-a1b2c3d",',
      '-    "id": "3.4.0-a1b2c3d",',
    );
    expect(checkBump(versionPackages, diff)).toEqual({
      ok: false,
      reason: "removed lines in packages/docs/data/changelog.json",
    });
  });
});

describe("searchQuery", () => {
  test("searches every rule's repos once per PR author", () => {
    const query = searchQuery();
    expect(query).toContain(
      'search(query: "is:pr is:open author:vbotbuildovich repo:redpanda-data/cloudv2 repo:redpanda-data/serverless"',
    );
    expect(query).toContain(
      'search(query: "is:pr is:open author:app/github-actions repo:redpanda-data/ui-registry"',
    );
    expect(query.match(/search\(/g)).toHaveLength(2);
  });
});

describe("pendingPrs", () => {
  const open = [
    { key: "redpanda-data/cloudv2#1", head: "a" },
    { key: "redpanda-data/cloudv2#2", head: "b" },
    { key: "redpanda-data/serverless#3", head: "c" },
  ];

  test("returns PRs whose head has no decision yet", () => {
    const decided = {
      "redpanda-data/cloudv2#1": "a",
      "redpanda-data/cloudv2#2": "old",
    };
    expect(pendingPrs(open, decided).pending.map((p) => p.key)).toEqual([
      "redpanda-data/cloudv2#2",
      "redpanda-data/serverless#3",
    ]);
  });

  test("forgets decisions for PRs that are no longer open", () => {
    const decided = {
      "redpanda-data/cloudv2#1": "a",
      "redpanda-data/x#9": "z",
    };
    expect(pendingPrs(open, decided).decided).toEqual({
      "redpanda-data/cloudv2#1": "a",
    });
  });
});
