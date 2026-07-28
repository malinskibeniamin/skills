import { describe, expect, test } from "bun:test";
import {
  diffRecords,
  extractArticleText,
  groupByDocument,
  isPostgresqlCandidate,
  normalizeUrl,
  parseFeed,
  parseGitHubTree,
  parseSitemap,
  requestHeaders,
  shouldFetchRecord,
  validateLedger,
  type DiscoveredRecord,
  type SourceRecord,
} from "./refresh-corpus";

describe("corpus discovery", () => {
  test("authenticates GitHub API discovery without leaking the token", () => {
    expect(
      requestHeaders(
        "https://api.github.com/repos/go-jet/jet/releases",
        "github-token",
      ),
    ).toMatchObject({ authorization: "Bearer github-token" });
    expect(
      requestHeaders(
        "https://planetscale.com/blog/sitemap.xml",
        "github-token",
      ),
    ).not.toHaveProperty("authorization");
  });

  test("parses and normalizes sitemap URLs", () => {
    const xml = `<?xml version="1.0"?>
      <urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
        <url><loc>https://example.com/blog/postgres-locks/</loc></url>
        <url><loc>https://example.com/blog/sql-plans#section</loc></url>
      </urlset>`;

    expect(parseSitemap(xml)).toEqual([
      "https://example.com/blog/postgres-locks",
      "https://example.com/blog/sql-plans",
    ]);
  });

  test("parses RSS and Atom entries", () => {
    const atom = `<?xml version="1.0"?>
      <feed xmlns="http://www.w3.org/2005/Atom">
        <entry>
          <title>Postgres plans</title>
          <link href="https://example.com/postgres-plans" />
          <published>2026-07-20T00:00:00Z</published>
        </entry>
      </feed>`;
    const rss = `<?xml version="1.0"?>
      <rss><channel><item>
        <title>SQL release</title>
        <link>https://example.com/sql-release#postgres</link>
        <pubDate>Tue, 21 Jul 2026 00:00:00 GMT</pubDate>
      </item></channel></rss>`;

    expect(parseFeed(atom)).toEqual([
      {
        title: "Postgres plans",
        url: "https://example.com/postgres-plans",
        published: "2026-07-20",
      },
    ]);
    expect(parseFeed(rss)).toEqual([
      {
        title: "SQL release",
        url: "https://example.com/sql-release#postgres",
        published: "2026-07-21",
      },
    ]);
  });

  test("parses complete GitHub trees into source-file URLs", () => {
    expect(
      parseGitHubTree(
        {
          truncated: false,
          tree: [
            { path: "changelogs/drizzle-orm/1.0.0.md", type: "blob" },
            { path: "changelogs/media/demo.gif", type: "blob" },
            { path: "docs/readme.md", type: "blob" },
          ],
        },
        "drizzle-team/drizzle-orm",
        "changelogs/",
      ),
    ).toEqual([
      {
        title: "changelogs/drizzle-orm/1.0.0.md",
        url: "https://github.com/drizzle-team/drizzle-orm/blob/main/changelogs/drizzle-orm/1.0.0.md",
      },
    ]);
    expect(() =>
      parseGitHubTree(
        { truncated: true, tree: [] },
        "drizzle-team/drizzle-orm",
        "changelogs/",
      ),
    ).toThrow("truncated");
  });
});

describe("candidate screening", () => {
  test("keeps PostgreSQL, portable SQL, and database-operation evidence", () => {
    expect(
      isPostgresqlCandidate({
        source: "databricks",
        kind: "blog",
        title: "Inside the Spark SQL optimizer",
        url: "https://example.com/catalyst",
      }),
    ).toBe(true);
    expect(
      isPostgresqlCandidate({
        source: "planetscale",
        kind: "blog",
        title: "Deadlocks and downtime",
        url: "https://example.com/deadlocks",
      }),
    ).toBe(true);
    expect(
      isPostgresqlCandidate({
        source: "drizzle",
        kind: "release",
        title: "PostgreSQL migration conflict detection",
        url: "https://example.com/release",
      }),
    ).toBe(true);
  });

  test("rejects company-only material", () => {
    const record = {
      source: "neon",
      kind: "blog",
      title: "Meet us at the summer developer conference",
      url: "https://example.com/conference",
    };
    expect(isPostgresqlCandidate(record)).toBe(false);
    expect(shouldFetchRecord(record, new Set())).toBe(false);
    expect(shouldFetchRecord(record, new Set([record.url]))).toBe(true);
  });
});

test("groups anchored release items into one fetched document", () => {
  const first: DiscoveredRecord = {
    source: "databricks",
    kind: "release_item",
    url: "https://example.com/releases/july#one",
  };
  const second: DiscoveredRecord = {
    source: "databricks",
    kind: "release_item",
    url: "https://example.com/releases/july#two",
  };
  const third: DiscoveredRecord = {
    source: "neon",
    kind: "blog",
    url: "https://example.com/postgres",
  };

  expect(groupByDocument([first, second, third])).toEqual([
    [first, second],
    [third],
  ]);
});

describe("ledger integrity", () => {
  const included: SourceRecord = {
    source: "postgresql",
    kind: "documentation",
    url: "https://www.postgresql.org/docs/18/using-explain.html",
    status: "included",
    reviewed_at: "2026-07-28",
    topics: ["performance"],
  };

  test("accepts classified unique records", () => {
    expect(() =>
      validateLedger([
        included,
        {
          source: "supabase",
          kind: "blog",
          url: "https://supabase.com/blog/company-update",
          status: "excluded",
          reviewed_at: "2026-07-28",
          reason: "Company material without SQL or PostgreSQL behavior.",
        },
      ]),
    ).not.toThrow();
  });

  test("rejects duplicates and incomplete decisions", () => {
    expect(() => validateLedger([included, included])).toThrow("duplicate URL");
    expect(() =>
      validateLedger([
        {
          ...included,
          topics: [],
        },
      ]),
    ).toThrow("included record needs topics");
    expect(() =>
      validateLedger([
        {
          source: "supabase",
          kind: "blog",
          url: "https://supabase.com/blog/company-update",
          status: "excluded",
          reviewed_at: "2026-07-28",
        },
      ]),
    ).toThrow("excluded record needs a reason");
    expect(() =>
      validateLedger([
        {
          ...included,
          status: "pending" as SourceRecord["status"],
        },
      ]),
    ).toThrow("invalid status");
    expect(() =>
      validateLedger([
        {
          ...included,
          url: "not a URL",
        },
      ]),
    ).toThrow("valid HTTP");
  });
});

describe("refresh diff", () => {
  test("reports added, changed, and removed sources", () => {
    const discovered: DiscoveredRecord[] = [
      {
        source: "postgresql",
        kind: "documentation",
        url: "https://example.com/kept",
        content_sha256: "new",
      },
      {
        source: "neon",
        kind: "blog",
        url: "https://example.com/added",
      },
    ];
    const ledger: SourceRecord[] = [
      {
        source: "postgresql",
        kind: "documentation",
        url: "https://example.com/kept",
        status: "included",
        reviewed_at: "2026-07-28",
        topics: ["performance"],
        content_sha256: "old",
      },
      {
        source: "planetscale",
        kind: "blog",
        url: "https://example.com/removed",
        status: "included",
        reviewed_at: "2026-07-28",
        topics: ["operations"],
      },
    ];

    expect(diffRecords(discovered, ledger)).toEqual({
      added: ["https://example.com/added"],
      changed: ["https://example.com/kept"],
      removed: ["https://example.com/removed"],
    });
  });
});

test("extracts article text without navigation or scripts", async () => {
  const html = `<html><body>
    <nav>Navigation</nav>
    <main><article><h1>Postgres locks</h1><p>Keep transactions short.</p></article></main>
    <script>ignore()</script>
  </body></html>`;

  expect(await extractArticleText(html)).toBe(
    "Postgres locks Keep transactions short.",
  );
  expect(normalizeUrl("https://example.com/path/#fragment")).toBe(
    "https://example.com/path",
  );
});
