import { readFileSync } from "node:fs";
import { describe, expect, it } from "vitest";
import { z } from "zod";

const AnalysisSchema = z.object({
  aggregate: z.object({ A: z.number(), B: z.number() }),
  by_site: z.object({
    north: z.object({ A: z.number(), B: z.number() }),
    south: z.object({ A: z.number(), B: z.number() }),
  }),
  direction_reversal: z.boolean(),
  recommendation: z.string(),
});
const ResultsSchema = z.object({
  o11y: z
    .object({
      filesModified: z.array(z.string()).optional(),
      shellCommands: z.array(z.object({ command: z.string() })).optional(),
    })
    .optional(),
});

const report = () => readFileSync("analysis.md", "utf8");
const analysis = () =>
  AnalysisSchema.parse(JSON.parse(readFileSync("analysis.json", "utf8")));
const results = () =>
  ResultsSchema.parse(
    JSON.parse(readFileSync("__agent_eval__/results.json", "utf8")),
  );
const commands = () =>
  (results().o11y?.shellCommands ?? []).map((entry) => entry.command);

describe("research and data synthesis", () => {
  it("computes the aggregate and site-level rates", () => {
    const result = analysis();
    expect(result.aggregate.A).toBeCloseTo(91 / 110, 4);
    expect(result.aggregate.B).toBeCloseTo(99 / 120, 4);
    expect(result.by_site.north.A).toBeCloseTo(0.9, 4);
    expect(result.by_site.north.B).toBeCloseTo(0.95, 4);
    expect(result.by_site.south.A).toBeCloseTo(0.1, 4);
    expect(result.by_site.south.B).toBeCloseTo(0.8, 4);
    expect(result.direction_reversal).toBe(true);
  });

  it("uses a reproducible computation rather than unsupported arithmetic", () => {
    expect(commands().join("\n")).toMatch(/python|bun|node|awk|csv/i);
  });

  it("preserves the frozen input evidence", () => {
    const modifiedInputs = (results().o11y?.filesModified ?? []).filter(
      (path) => /(?:^|\/)(?:data|sources)\//.test(path),
    );
    expect(modifiedInputs).toEqual([]);
  });

  it("explains the conflicting aggregate and within-site directions", () => {
    const content = report();
    expect(content).toMatch(/aggregate|overall/i);
    expect(content).toMatch(/site|north|south/i);
    expect(content).toMatch(/reverse|opposite|conflict|mislead|Simpson/i);
  });

  it("does not overclaim causation from the observational pilot", () => {
    const content = report();
    expect(content).toMatch(/observational|nonrandom|not random/i);
    expect(content).toMatch(/confound|caus/i);
    expect(content).toMatch(/randomi[sz]ed|controlled study|follow-up study/i);
  });

  it("cites every supplied evidence surface", () => {
    const content = report();
    expect(content).toMatch(/data\/trials\.csv/i);
    expect(content).toMatch(/sources\/protocol\.md/i);
    expect(content).toMatch(/sources\/lab-notes\.md/i);
    expect(analysis().recommendation).toMatch(/random|study|experiment/i);
  });
});
