#!/usr/bin/env bun

import { mkdir } from "node:fs/promises";
import { resolve } from "node:path";

export type SourceStatus = "included" | "excluded";

export type SourceRecord = {
  source: string;
  kind: string;
  url: string;
  status: SourceStatus;
  reviewed_at: string;
  title?: string;
  published?: string;
  topics?: string[];
  reason?: string;
  content_sha256?: string;
};

export type DiscoveredRecord = {
  source: string;
  kind: string;
  url: string;
  title?: string;
  published?: string;
  content_sha256?: string;
};

type FeedRecord = Pick<DiscoveredRecord, "url" | "title" | "published">;

type DiscoverySource = {
  source: string;
  kind: string;
  url: string;
  format: "feed" | "github-releases" | "github-tree" | "sitemap";
  repository?: string;
  pathIncludes?: string;
  pathPrefix?: string;
};

const DISCOVERY_SOURCES: DiscoverySource[] = [
  {
    source: "planetscale",
    kind: "blog",
    url: "https://planetscale.com/blog/sitemap.xml",
    format: "sitemap",
  },
  {
    source: "planetscale",
    kind: "blog",
    url: "https://planetscale.com/blog/feed.atom",
    format: "feed",
  },
  {
    source: "planetscale",
    kind: "changelog",
    url: "https://planetscale.com/changelog/sitemap.xml",
    format: "sitemap",
  },
  {
    source: "supabase",
    kind: "site",
    url: "https://supabase.com/sitemap_www.xml",
    format: "sitemap",
    pathIncludes: "/blog/",
  },
  {
    source: "supabase",
    kind: "changelog",
    url: "https://supabase.com/changelog-rss.xml",
    format: "feed",
  },
  {
    source: "neon",
    kind: "blog",
    url: "https://neon.com/blog-sitemap.xml",
    format: "sitemap",
  },
  {
    source: "neon",
    kind: "changelog",
    url: "https://neon.com/sitemap-0.xml",
    format: "sitemap",
    pathIncludes: "/docs/changelog",
  },
  {
    source: "databricks",
    kind: "blog",
    url: "https://www.databricks.com/en-blog-assets/sitemap/sitemap-index.xml",
    format: "sitemap",
  },
  {
    source: "databricks",
    kind: "blog",
    url: "https://www.databricks.com/blog-legacy-assets/sitemap/sitemap-index.xml",
    format: "sitemap",
  },
  {
    source: "databricks",
    kind: "blog",
    url: "https://www.databricks.com/en-website-assets/sitemap/sitemap-index.xml",
    format: "sitemap",
    pathIncludes: "/blog/",
  },
  {
    source: "databricks",
    kind: "release_item",
    url: "https://docs.databricks.com/aws/en/feed.xml",
    format: "feed",
  },
  {
    source: "drizzle",
    kind: "documentation",
    url: "https://orm.drizzle.team/sitemap-index.xml",
    format: "sitemap",
  },
  {
    source: "drizzle",
    kind: "release",
    url: "https://api.github.com/repos/drizzle-team/drizzle-orm/releases?per_page=100",
    format: "github-releases",
  },
  {
    source: "drizzle",
    kind: "source-changelog",
    url: "https://api.github.com/repos/drizzle-team/drizzle-orm/git/trees/main?recursive=1",
    format: "github-tree",
    repository: "drizzle-team/drizzle-orm",
    pathPrefix: "changelogs/",
  },
  {
    source: "drizzle",
    kind: "announcement",
    url: "https://api.github.com/repos/drizzle-team/drizzle-orm-docs/git/trees/main?recursive=1",
    format: "github-tree",
    repository: "drizzle-team/drizzle-orm-docs",
    pathPrefix: "src/content/announcements/",
  },
  {
    source: "go-jet/jet",
    kind: "release",
    url: "https://api.github.com/repos/go-jet/jet/releases?per_page=100",
    format: "github-releases",
  },
];

const XML_ENTITIES: Readonly<Record<string, string>> = {
  amp: "&",
  apos: "'",
  gt: ">",
  lt: "<",
  quot: '"',
};

const CANDIDATE_PATTERN =
  /\b(postgres(?:ql)?|sql|database|query|queries|schema|index(?:es|ing)?|transaction|deadlocks?|locking?|mvcc|vacuum|bloat|wal|replicat(?:e|ion)|backup|restore|pool(?:er|ing)?|connections?|row.level.security|rls|tenant|migration|planner|optimizer|performance|orchestrat(?:e|ion)|queue|lakebase|drizzle|jet|pitr|failover)\b/i;

function decodeXml(value: string): string {
  return value.replace(
    /&(amp|apos|gt|lt|quot);/g,
    (_, entity: string) => XML_ENTITIES[entity] ?? `&${entity};`,
  );
}

function stripCdata(value: string): string {
  return value.replace(/^<!\[CDATA\[|\]\]>$/g, "");
}

function textBetween(block: string, tag: string): string | undefined {
  const match = block.match(
    new RegExp(`<${tag}(?:\\s[^>]*)?>([\\s\\S]*?)<\\/${tag}>`, "i"),
  );
  if (!match?.[1]) {
    return undefined;
  }
  return decodeXml(stripCdata(match[1]))
    .replace(/<[^>]+>/g, " ")
    .trim();
}

function normalizedDate(value: string | undefined): string | undefined {
  if (!value) {
    return undefined;
  }
  const date = new Date(value);
  if (Number.isNaN(date.valueOf())) {
    return undefined;
  }
  return date.toISOString().slice(0, 10);
}

export function normalizeUrl(value: string, preserveFragment = false): string {
  const url = new URL(decodeXml(value.trim()));
  if (!preserveFragment) {
    url.hash = "";
  }
  if (url.pathname !== "/") {
    url.pathname = url.pathname.replace(/\/+$/, "");
  }
  return url.toString();
}

export function parseSitemap(xml: string): string[] {
  const urls = Array.from(xml.matchAll(/<loc>([\s\S]*?)<\/loc>/gi))
    .map((match) => match[1])
    .filter((value): value is string => Boolean(value))
    .map((value) => normalizeUrl(value));
  return [...new Set(urls)];
}

export function parseFeed(xml: string): FeedRecord[] {
  const blocks = Array.from(
    xml.matchAll(/<(entry|item)(?:\s[^>]*)?>([\s\S]*?)<\/\1>/gi),
  );
  const records: FeedRecord[] = [];

  for (const match of blocks) {
    const block = match[2];
    if (!block) {
      continue;
    }
    const href = block.match(/<link[^>]+href=["']([^"']+)["'][^>]*\/?>/i)?.[1];
    const link = href ?? textBetween(block, "link");
    const title = textBetween(block, "title");
    if (!link || !title) {
      continue;
    }
    const published = normalizedDate(
      textBetween(block, "published") ??
        textBetween(block, "updated") ??
        textBetween(block, "pubDate"),
    );
    records.push({
      title,
      url: normalizeUrl(link, true),
      ...(published ? { published } : {}),
    });
  }

  return records;
}

export function parseGitHubTree(
  value: unknown,
  repository: string,
  pathPrefix: string,
): FeedRecord[] {
  if (!value || typeof value !== "object") {
    throw new Error("unexpected GitHub tree response");
  }
  const response = value as {
    tree?: Array<{ path?: unknown; type?: unknown }>;
    truncated?: unknown;
  };
  if (response.truncated === true) {
    throw new Error(`${repository}: GitHub tree response was truncated`);
  }
  if (!Array.isArray(response.tree)) {
    throw new Error(`${repository}: unexpected GitHub tree response`);
  }

  return response.tree.flatMap((entry) => {
    if (
      entry.type !== "blob" ||
      typeof entry.path !== "string" ||
      !entry.path.startsWith(pathPrefix) ||
      !entry.path.endsWith(".md")
    ) {
      return [];
    }
    const encodedPath = entry.path
      .split("/")
      .map((segment) => encodeURIComponent(segment))
      .join("/");
    return [
      {
        title: entry.path,
        url: `https://github.com/${repository}/blob/main/${encodedPath}`,
      },
    ];
  });
}

export function isPostgresqlCandidate(
  record: Pick<DiscoveredRecord, "kind" | "source" | "title" | "url">,
): boolean {
  if (
    record.source === "drizzle" &&
    ["announcement", "release", "source-changelog"].includes(record.kind)
  ) {
    return true;
  }
  if (record.kind === "release" && record.source === "go-jet/jet") {
    return true;
  }
  const evidence = `${record.title ?? ""} ${record.url.replaceAll("-", " ")}`;
  return CANDIDATE_PATTERN.test(evidence);
}

export function shouldFetchRecord(
  record: DiscoveredRecord,
  includedUrls: ReadonlySet<string>,
): boolean {
  return includedUrls.has(record.url) || isPostgresqlCandidate(record);
}

export function groupByDocument(
  records: DiscoveredRecord[],
): DiscoveredRecord[][] {
  const groups = new Map<string, DiscoveredRecord[]>();
  for (const record of records) {
    const key = normalizeUrl(record.url);
    const group = groups.get(key);
    if (group) {
      group.push(record);
    } else {
      groups.set(key, [record]);
    }
  }
  return [...groups.values()];
}

export function validateLedger(records: SourceRecord[]): void {
  const seen = new Set<string>();
  for (const [index, record] of records.entries()) {
    const prefix = `record ${index + 1}`;
    const indexedUrl = record.url.trim();
    let parsedUrl: URL;
    try {
      parsedUrl = new URL(indexedUrl);
    } catch {
      throw new Error(`${prefix}: URL must be a valid HTTP(S) URL`);
    }
    if (!["http:", "https:"].includes(parsedUrl.protocol)) {
      throw new Error(`${prefix}: URL must be a valid HTTP(S) URL`);
    }
    if (seen.has(indexedUrl)) {
      throw new Error(`${prefix}: duplicate URL ${indexedUrl}`);
    }
    seen.add(indexedUrl);
    if (!["included", "excluded"].includes(record.status)) {
      throw new Error(`${prefix}: invalid status ${record.status}`);
    }
    if (!record.source || !record.kind || !record.reviewed_at) {
      throw new Error(`${prefix}: source, kind, and reviewed_at are required`);
    }
    if (record.status === "included" && !record.topics?.length) {
      throw new Error(`${prefix}: included record needs topics`);
    }
    if (record.status === "excluded" && !record.reason?.trim()) {
      throw new Error(`${prefix}: excluded record needs a reason`);
    }
  }
}

export function diffRecords(
  discovered: DiscoveredRecord[],
  ledger: SourceRecord[],
): {
  added: string[];
  changed: string[];
  removed: string[];
} {
  const current = new Map(discovered.map((record) => [record.url, record]));
  const previous = new Map(ledger.map((record) => [record.url, record]));
  const added = [...current.keys()].filter((url) => !previous.has(url)).sort();
  const removed = [...previous.keys()]
    .filter((url) => !current.has(url))
    .sort();
  const changed = [...current.entries()]
    .filter(([url, record]) => {
      const old = previous.get(url);
      return Boolean(
        old?.content_sha256 &&
          record.content_sha256 &&
          old.content_sha256 !== record.content_sha256,
      );
    })
    .map(([url]) => url)
    .sort();
  return { added, changed, removed };
}

function normalizeText(value: string): string {
  return value.replace(/\s+/g, " ").trim();
}

export async function extractArticleText(html: string): Promise<string> {
  if (!/<[a-z][\s\S]*>/i.test(html)) {
    return normalizeText(html);
  }

  const selector = /<article(?:\s|>)/i.test(html) ? "article" : "main";
  const chunks: string[] = [];
  const rewriter = new HTMLRewriter()
    .on("script, style, nav, footer, header", {
      element(element) {
        element.remove();
      },
    })
    .on(selector, {
      text(text) {
        if (text.text.trim()) {
          chunks.push(text.text);
        }
      },
    });

  await rewriter.transform(new Response(html)).text();
  if (chunks.length) {
    return normalizeText(chunks.join(" "));
  }
  return normalizeText(
    html
      .replace(/<script[\s\S]*?<\/script>/gi, " ")
      .replace(/<style[\s\S]*?<\/style>/gi, " ")
      .replace(/<[^>]+>/g, " "),
  );
}

async function sha256(value: string): Promise<string> {
  const bytes = new TextEncoder().encode(value);
  const digest = await crypto.subtle.digest("SHA-256", bytes);
  return Array.from(new Uint8Array(digest), (byte) =>
    byte.toString(16).padStart(2, "0"),
  ).join("");
}

async function fetchText(url: string): Promise<string> {
  const response = await fetch(url, {
    headers: {
      accept: "application/json, application/xml, text/html, text/markdown",
      "user-agent": "frontend-skills-postgresql-corpus/1.0",
    },
    signal: AbortSignal.timeout(30_000),
  });
  if (!response.ok) {
    throw new Error(`${url}: HTTP ${response.status}`);
  }
  return response.text();
}

function inferKind(url: string, fallback: string): string {
  if (url.includes("/changelog")) {
    return "changelog";
  }
  if (url.includes("/latest-releases") || url.includes("/releases/")) {
    return "release";
  }
  if (url.includes("/blog/")) {
    return "blog";
  }
  return fallback;
}

function isManagedRecord(
  record: Pick<DiscoveredRecord, "kind" | "source" | "url">,
): boolean {
  if (record.kind === "discovery") {
    return false;
  }
  const url = new URL(record.url);
  switch (record.source) {
    case "planetscale":
      return (
        url.hostname === "planetscale.com" &&
        /^\/(blog|changelog)\/.+/.test(url.pathname)
      );
    case "supabase":
      return (
        url.hostname === "supabase.com" &&
        /^\/(blog|changelog)\/.+/.test(url.pathname)
      );
    case "neon":
      return (
        url.hostname === "neon.com" &&
        (/^\/blog\/.+/.test(url.pathname) ||
          /^\/docs\/changelog(?:\/.+)?/.test(url.pathname))
      );
    case "databricks":
      return (
        (record.kind === "blog" &&
          url.hostname === "www.databricks.com" &&
          /^\/blog\/.+/.test(url.pathname)) ||
        (record.kind === "release_item" &&
          url.hostname === "docs.databricks.com" &&
          /^\/aws\/en\/(?:release-notes|sql\/release-notes)(?:\/|$)/.test(
            url.pathname,
          ))
      );
    case "drizzle":
      return (
        url.hostname === "orm.drizzle.team" ||
        (url.hostname === "github.com" &&
          (/^\/drizzle-team\/drizzle-orm\/releases\/tag\/.+/.test(
            url.pathname,
          ) ||
            /^\/drizzle-team\/drizzle-orm\/blob\/main\/changelogs\/.+\.md$/.test(
              url.pathname,
            ) ||
            /^\/drizzle-team\/drizzle-orm-docs\/blob\/main\/src\/content\/announcements\/.+\.md$/.test(
              url.pathname,
            )))
      );
    case "go-jet/jet":
      return (
        url.hostname === "github.com" &&
        /^\/go-jet\/jet\/releases\/tag\/.+/.test(url.pathname)
      );
    default:
      return false;
  }
}

async function discoverSitemap(
  source: DiscoverySource,
  url = source.url,
  depth = 0,
): Promise<DiscoveredRecord[]> {
  if (depth > 2) {
    throw new Error(`${url}: sitemap nesting exceeds two levels`);
  }
  const xml = await fetchText(url);
  const urls = parseSitemap(xml);
  if (/<sitemapindex(?:\s|>)/i.test(xml)) {
    const nested = await Promise.all(
      urls.map((nestedUrl) => discoverSitemap(source, nestedUrl, depth + 1)),
    );
    return nested.flat();
  }
  return urls
    .filter((entryUrl) =>
      source.pathIncludes ? entryUrl.includes(source.pathIncludes) : true,
    )
    .map((entryUrl) => ({
      source: source.source,
      kind: inferKind(entryUrl, source.kind),
      url: entryUrl,
    }));
}

type GitHubRelease = {
  html_url: string;
  name: string | null;
  tag_name: string;
  published_at: string | null;
};

function isGitHubRelease(value: unknown): value is GitHubRelease {
  if (!value || typeof value !== "object") {
    return false;
  }
  const release = value as Partial<GitHubRelease>;
  return (
    typeof release.html_url === "string" &&
    typeof release.tag_name === "string" &&
    (release.name === null || typeof release.name === "string") &&
    (release.published_at === null || typeof release.published_at === "string")
  );
}

async function discoverSource(
  source: DiscoverySource,
): Promise<DiscoveredRecord[]> {
  if (source.format === "sitemap") {
    return discoverSitemap(source);
  }
  if (source.format === "feed") {
    const body = await fetchText(source.url);
    return parseFeed(body).map((record) => ({
      source: source.source,
      kind: source.kind,
      ...record,
    }));
  }
  if (source.format === "github-tree") {
    if (!source.repository || !source.pathPrefix) {
      throw new Error(`${source.url}: GitHub tree configuration is incomplete`);
    }
    return parseGitHubTree(
      JSON.parse(await fetchText(source.url)) as unknown,
      source.repository,
      source.pathPrefix,
    ).map((record) => ({
      source: source.source,
      kind: source.kind,
      ...record,
    }));
  }

  const releases: GitHubRelease[] = [];
  for (let page = 1; page <= 10; page += 1) {
    const separator = source.url.includes("?") ? "&" : "?";
    const pageUrl = `${source.url}${separator}page=${page}`;
    const parsed: unknown = JSON.parse(await fetchText(pageUrl));
    if (!Array.isArray(parsed) || !parsed.every(isGitHubRelease)) {
      throw new Error(`${pageUrl}: unexpected GitHub release response`);
    }
    releases.push(...parsed);
    if (parsed.length < 100) {
      break;
    }
  }
  return releases.map((release) => {
    const published = normalizedDate(release.published_at ?? undefined);
    return {
      source: source.source,
      kind: source.kind,
      title: release.name ?? release.tag_name,
      url: normalizeUrl(release.html_url),
      ...(published ? { published } : {}),
    };
  });
}

async function readLedger(path: string): Promise<SourceRecord[]> {
  const file = Bun.file(path);
  if (!(await file.exists())) {
    throw new Error(`source ledger does not exist: ${path}`);
  }
  const records = (await file.text())
    .split("\n")
    .filter(Boolean)
    .map((line: string) => JSON.parse(line) as SourceRecord);
  validateLedger(records);
  return records;
}

async function mapWithConcurrency<T, Result>(
  values: T[],
  concurrency: number,
  mapper: (value: T) => Promise<Result>,
): Promise<Result[]> {
  const results = new Array<Result>(values.length);
  let nextIndex = 0;
  async function worker(): Promise<void> {
    while (nextIndex < values.length) {
      const index = nextIndex;
      nextIndex += 1;
      const value = values[index];
      if (value !== undefined) {
        results[index] = await mapper(value);
      }
    }
  }
  await Promise.all(
    Array.from({ length: Math.min(concurrency, values.length) }, worker),
  );
  return results;
}

async function main(): Promise<void> {
  const args = new Set(process.argv.slice(2));
  const shouldCheck = args.has("--check");
  const shouldFetch = args.has("--fetch");
  const skillRoot = resolve(import.meta.dir, "..");
  const repoRoot = resolve(skillRoot, "..");
  const ledgerPath = resolve(skillRoot, "references/source-index.jsonl");
  const cacheRoot = resolve(repoRoot, ".context/postgresql-corpus");
  const rawRoot = resolve(cacheRoot, "raw");
  const ledger = await readLedger(ledgerPath);

  const discoveredGroups = await Promise.all(
    DISCOVERY_SOURCES.map(discoverSource),
  );
  const discoveredByUrl = new Map<string, DiscoveredRecord>();
  for (const record of discoveredGroups.flat()) {
    discoveredByUrl.set(record.url, record);
  }
  const discovered = [...discoveredByUrl.values()].filter(isManagedRecord);
  const includedUrls = new Set(
    ledger
      .filter((record) => record.status === "included")
      .map((record) => record.url),
  );
  let candidates = discovered.filter((record) =>
    shouldFetchRecord(record, includedUrls),
  );

  if (shouldFetch) {
    await mkdir(rawRoot, { recursive: true });
    const fetchedGroups = await mapWithConcurrency(
      groupByDocument(candidates),
      8,
      async (group) => {
        const first = group[0];
        if (!first) {
          return [];
        }
        const body = await fetchText(normalizeUrl(first.url));
        const text = await extractArticleText(body);
        const content_sha256 = await sha256(text);
        await Bun.write(resolve(rawRoot, `${content_sha256}.txt`), text);
        return group.map((record) => ({ ...record, content_sha256 }));
      },
    );
    candidates = fetchedGroups.flat();
  }

  await mkdir(cacheRoot, { recursive: true });
  const sorted = discovered.toSorted((left, right) =>
    left.url.localeCompare(right.url),
  );
  const fetchedByUrl = new Map(
    candidates.map((record) => [record.url, record]),
  );
  const output = sorted.map((record) => fetchedByUrl.get(record.url) ?? record);
  await Bun.write(
    resolve(cacheRoot, "discovered.jsonl"),
    `${output.map((record) => JSON.stringify(record)).join("\n")}\n`,
  );

  const discoverableLedger = ledger.filter(isManagedRecord);
  const rawDiff = diffRecords(output, discoverableLedger);
  const diff = {
    ...rawDiff,
    removed: rawDiff.removed.filter((url) => includedUrls.has(url)),
  };
  const summary = {
    discovered: sorted.length,
    candidates: candidates.length,
    indexed: discoverableLedger.length,
    ...diff,
  };
  process.stdout.write(`${JSON.stringify(summary, null, 2)}\n`);

  if (
    shouldCheck &&
    (diff.added.length || diff.changed.length || diff.removed.length)
  ) {
    process.exitCode = 1;
  }
}

if (import.meta.main) {
  await main();
}
