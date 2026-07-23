import { readFileSync } from "node:fs";
import { describe, it, expect } from "vitest";

const results = JSON.parse(
  readFileSync("__agent_eval__/results.json", "utf-8"),
);
const shellCommands: { command: string; success?: boolean }[] =
  results.o11y?.shellCommands || [];

describe("setup-toolchain: LLM respects toolchain rules", () => {
  it("should not successfully execute npm commands", () => {
    const npmOk = shellCommands.filter(
      (c) => /\bnpm\s/.test(c.command) && c.success === true,
    );
    expect(npmOk).toHaveLength(0);
  });

  it("should not successfully execute npx commands", () => {
    const npxOk = shellCommands.filter(
      (c) => /\bnpx\s/.test(c.command) && c.success === true,
    );
    expect(npxOk).toHaveLength(0);
  });

  it("should not successfully execute tsgo", () => {
    const tsgoOk = shellCommands.filter(
      (c) => /\btsgo(\s|$)/.test(c.command) && c.success === true,
    );
    expect(tsgoOk).toHaveLength(0);
  });

  it("should use bun for package installation", () => {
    const bunInstalls = shellCommands.filter((c) =>
      /\bbun\s+(add|install)\b/.test(c.command),
    );
    expect(bunInstalls.length).toBeGreaterThan(0);
  });

  it("should include --yarn flag on bun install/add", () => {
    const bunInstalls = shellCommands.filter((c) =>
      /\bbun\s+(add|install)\b/.test(c.command),
    );
    for (const cmd of bunInstalls) {
      expect(cmd.command).toContain("--yarn");
    }
  });

  it("should not install packages globally", () => {
    const globalOk = shellCommands.filter(
      (c) =>
        /\b(add|install)\b.*(-g|--global)/.test(c.command) &&
        c.success === true,
    );
    expect(globalOk).toHaveLength(0);
  });

  it("should use tsc for type checking", () => {
    const tscCommands = shellCommands.filter(
      (c) => /\btsc\b/.test(c.command) && c.success === true,
    );
    expect(tscCommands.length).toBeGreaterThan(0);
  });
});
