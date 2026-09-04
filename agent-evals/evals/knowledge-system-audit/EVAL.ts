import { existsSync, readFileSync } from "node:fs";
import { describe, expect, it } from "vitest";

const audit = () => readFileSync("knowledge-audit.md", "utf8");

describe("knowledge system audit", () => {
  it("creates the requested audit", () => {
    expect(existsSync("knowledge-audit.md")).toBe(true);
  });

  it("finds schema and ingestion defects", () => {
    const content = audit();
    expect(content).toMatch(/brain\/schema\.md/i);
    expect(content).toMatch(/brain\/inbox\/session-2026-08-30\.md/i);
    expect(content).toMatch(/frontmatter|metadata/i);
    expect(content).toMatch(/ingestion\/ingest\.sh/i);
    expect(content).toMatch(/validat/i);
  });

  it("finds the duplicate and retention conflict", () => {
    const content = audit();
    expect(content).toMatch(/duplicate/i);
    expect(content).toMatch(/model-routing(?:-copy)?\.md/i);
    expect(content).toMatch(/30\s+days/i);
    expect(content).toMatch(/90\s+days/i);
    expect(content).toMatch(/conflict|contradic/i);
  });

  it("identifies retrieval and scheduling gaps", () => {
    const content = audit();
    expect(content).toMatch(/search\/config\.json/i);
    expect(content).toMatch(/brain\/archive|archive/i);
    expect(content).toMatch(/ingestion\/cron\.txt/i);
    expect(content).toMatch(/cron|schedule|daily/i);
  });

  it("treats apparent non-use as a candidate, not deletion proof", () => {
    const content = audit();
    expect(content).toMatch(/usage\/access-log\.csv/i);
    expect(content).toMatch(
      /candidate|insufficient|limited|not proof|more evidence/i,
    );
    expect(content).toMatch(/verify|check|measure|observ/i);
  });
});
