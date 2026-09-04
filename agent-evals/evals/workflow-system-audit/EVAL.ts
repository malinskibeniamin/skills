import { existsSync, readFileSync } from "node:fs";
import { describe, expect, it } from "vitest";

const audit = () => readFileSync("workflow-audit.md", "utf8");

describe("workflow system audit", () => {
  it("creates the requested audit", () => {
    expect(existsSync("workflow-audit.md")).toBe(true);
  });

  it("finds the repeated ship-tail prompt and stop point", () => {
    const content = audit();
    expect(content).toMatch(/sessions\/claude-release\.md/i);
    expect(content).toMatch(/sessions\/codex-release\.md/i);
    expect(content).toMatch(
      /(?:lint|type)[\s\S]*(?:commit|push)[\s\S]*(?:PR|CI)/i,
    );
    expect(content).toMatch(/stop|ended|handoff/i);
  });

  it("turns manual release work into a verifiable script or integration", () => {
    const content = audit();
    expect(content).toMatch(/operations\/release-checklist\.md/i);
    expect(content).toMatch(/script|integration|automat/i);
    expect(content).toMatch(/verify|check|test/i);
  });

  it("covers skill, instruction, and schedule opportunities", () => {
    const content = audit();
    expect(content).toMatch(/skill/i);
    expect(content).toMatch(/project\/AGENTS\.md/i);
    expect(content).toMatch(/@\/env|environment variable/i);
    expect(content).toMatch(/schedule|cron|weekday/i);
  });

  it("keeps cross-model execution owner-controlled", () => {
    const content = audit();
    expect(content).toMatch(/explicit|human|owner/i);
    expect(content).toMatch(/delegat|handoff/i);
  });
});
