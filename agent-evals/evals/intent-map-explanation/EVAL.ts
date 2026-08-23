import { existsSync, readdirSync, readFileSync } from "node:fs";
import { describe, expect, it } from "vitest";

const plan = () => readFileSync("plan.md", "utf8");

describe("intent-map explanation", () => {
  it("creates only the requested plan artifact", () => {
    expect(existsSync("plan.md")).toBe(true);
    const sideArtifacts = readdirSync(".").filter((file) =>
      /\.(?:html|png|svg|excalidraw)$/i.test(file),
    );
    expect(sideArtifacts).toHaveLength(0);
  });

  it("leads with the current decision and renders causality", () => {
    const content = plan();
    expect(content.slice(0, 300)).toMatch(/server|canonical/i);
    expect(content).toMatch(/```mermaid[\s\S]*flowchart[\s\S]*-->/i);
  });

  it("connects the objective, evidence, decision, implementation, and verification", () => {
    const content = plan();
    for (const concept of [
      "objective",
      "assumption",
      "decision",
      "reference",
      "implementation",
      "verification",
      "risk",
    ]) {
      expect(content).toMatch(new RegExp(concept, "i"));
    }
    expect(content).toMatch(/research\/interviews\.md/);
    expect(content).toMatch(/decision-record\.md/);
  });

  it("makes the superseded local-only direction inspectable", () => {
    const content = plan();
    expect(content).toMatch(/localStorage|local storage/i);
    expect(content).toMatch(/supersed|replac|changed|instead/i);
    expect(content).toMatch(/single browser|one browser/i);
  });

  it("preserves concrete implementation and verification receipts", () => {
    const content = plan();
    expect(content).toMatch(/proto\/preferences\/v1\/preferences\.proto/);
    expect(content).toMatch(/src\/api\/preferences\.ts/);
    expect(content).toMatch(/src\/routes\/settings\/notifications\.tsx/);
    expect(content).toMatch(/integration test/i);
    expect(content).toMatch(/cross-session/i);
    expect(content).toMatch(/mutation-error|mutation error|retry/i);
  });

  it("keeps the explanation bounded", () => {
    const words = plan().trim().split(/\s+/);
    expect(words.length).toBeLessThanOrEqual(550);
  });
});
