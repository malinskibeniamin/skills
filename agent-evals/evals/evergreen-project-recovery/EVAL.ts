import { execFileSync } from "node:child_process";
import { existsSync, readFileSync } from "node:fs";
import { describe, expect, it } from "vitest";
import { z } from "zod";

const AgentEvalResultsSchema = z.object({
  o11y: z
    .object({
      shellCommands: z.array(z.object({ command: z.string() })).optional(),
    })
    .optional(),
});

const plan = () => readFileSync("recovery-plan.md", "utf8");
const shellCommands = (): string[] => {
  const parsed = AgentEvalResultsSchema.parse(
    JSON.parse(readFileSync("__agent_eval__/results.json", "utf8")),
  );
  return (parsed.o11y?.shellCommands ?? []).map((entry) => entry.command);
};

describe("evergreen project recovery", () => {
  it("creates the requested recovery plan without editing source", () => {
    expect(existsSync("recovery-plan.md")).toBe(true);
    expect(readFileSync("src/health.ts", "utf8")).toMatch(
      /items\.some\(\(item\) => Date\.parse\(item\.updatedAt\) < cutoffTime\)/,
    );
  });

  it("runs tests, type checking, and the real demo", () => {
    const commands = shellCommands().join("\n");
    expect(commands).toMatch(/bun\s+(?:run\s+)?test/);
    expect(commands).toMatch(/bun\s+run\s+typecheck/);
    expect(commands).toMatch(/bun\s+run\s+demo/);
  });

  it("keeps the supplied checks green while reproducing the demo failure", () => {
    expect(() =>
      execFileSync("bun", ["run", "test"], { stdio: "pipe" }),
    ).not.toThrow();
    expect(() =>
      execFileSync("bun", ["run", "typecheck"], { stdio: "pipe" }),
    ).not.toThrow();
    expect(execFileSync("bun", ["run", "demo"], { encoding: "utf8" })).toMatch(
      /Atlas: stale/,
    );
  });

  it("traces the root cause and false-green coverage", () => {
    const content = plan();
    expect(content).toMatch(/src\/health\.ts/i);
    expect(content).toMatch(/completed|terminal/i);
    expect(content).toMatch(/src\/health\.test\.ts/i);
    expect(content).toMatch(/missing|omit|coverage|fixture/i);
  });

  it("gives file-scoped changes and exact verification", () => {
    const content = plan();
    expect(content).toMatch(/fixtures\/atlas\.json|README\.md/i);
    expect(content).toMatch(/healthy[\s\S]*stale|stale[\s\S]*healthy/i);
    expect(content).toMatch(/bun\s+(?:run\s+)?test/i);
    expect(content).toMatch(/bun\s+run\s+typecheck/i);
    expect(content).toMatch(/bun\s+run\s+demo/i);
  });
});
