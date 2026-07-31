import { existsSync, readFileSync } from "node:fs";
import { describe, expect, it } from "vitest";

const review = () => readFileSync("review.md", "utf8");
const results = () =>
  JSON.parse(readFileSync("__agent_eval__/results.json", "utf8"));

describe("dogfood review with live data", () => {
  it("creates the requested review artifact", () => {
    expect(existsSync("review.md")).toBe(true);
  });

  it("uses the real feature entrypoint", () => {
    const commands = (results().o11y?.shellCommands ?? [])
      .map((entry: { command: string }) => entry.command)
      .join("\n");
    expect(commands).toMatch(/bun\s+run\s+demo/);
  });

  it("reports the observed live-data correctness failure", () => {
    const content = review();
    expect(content).toMatch(/\bP1\b|P1 Major/i);
    expect(content).toMatch(/expected[^\n]*20000|20000[^\n]*expected/i);
    expect(content).toMatch(/shown[^\n]*10000|10000[^\n]*shown/i);
    expect(content).toMatch(/tenant[\s\S]*(?:drop|lose|collapse|deduplicat)/i);
  });

  it("reports measured performance rather than a speculative nit", () => {
    const content = review();
    expect(content).toMatch(/performance|latency|quadratic|O\(n(?:\^?2|²)\)/i);
    expect(content).toMatch(/elapsed(?:Ms)?[^\n]*\d+|\d+\s*ms/i);
    expect(content).toMatch(/250\s*ms|performance budget/i);
  });

  it("identifies both independent user-visible defects", () => {
    const findings = review().match(/^\s*(?:[-#]+\s*)?\[?P[012]\b/gim) ?? [];
    expect(findings.length).toBeGreaterThanOrEqual(2);
  });

  it("connects the false green test to unrealistic data", () => {
    const content = review();
    expect(content).toMatch(/timeline\.test\.ts|test fixture/i);
    expect(content).toMatch(/single tenant|cross-tenant|live-scale/i);
  });

  it("prescribes a composite key and linear deduplication", () => {
    const content = review();
    expect(content).toMatch(/tenantId[\s\S]*id|composite key/i);
    expect(content).toMatch(/Set|Map|linear|O\(n\)/i);
    expect(content).toMatch(/regression test/i);
  });
});
